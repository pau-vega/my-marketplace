#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
MARKETPLACE_HTML="$REPO_ROOT/marketplace.html"

# Check dependencies
command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required but not installed" >&2; exit 1; }

# ── Helpers ──────────────────────────────────────────────────────────

# Parse YAML frontmatter from a markdown file.
# Outputs JSON: {"name": "...", "description": "...", "version": "..."}
# version defaults to null if not present.
parse_frontmatter() {
  local file="$1"
  local in_frontmatter=false
  local found_frontmatter=false
  local current_key=""
  local name="" description="" version=""

  while IFS= read -r line; do
    # Detect frontmatter boundaries
    if [[ "$line" == "---" ]]; then
      if $in_frontmatter; then
        break  # closing ---
      else
        in_frontmatter=true
        found_frontmatter=true
        continue
      fi
    fi

    $in_frontmatter || continue

    # Key: value line (not indented)
    if [[ "$line" =~ ^[a-zA-Z_-]+: ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
      current_key="${line%%:*}"
      local value="${line#*:}"
      # Strip leading space and trailing whitespace
      value="${value#"${value%%[![:space:]]*}"}"
      value="${value%"${value##*[![:space:]]}"}"

      case "$current_key" in
        name) name="$value" ;;
        version) version="$value" ;;
        description)
          if [[ "$value" == ">" || "$value" == "|" ]]; then
            description=""  # multi-line follows
          else
            description="$value"
            current_key=""  # single-line, done
          fi
          ;;
        *) current_key="" ;;  # skip unknown keys
      esac
      continue
    fi

    # Continuation line for multi-line description
    if [[ "$current_key" == "description" ]]; then
      # Stop at blank line or <example> tag
      if [[ -z "${line// /}" ]] || [[ "$line" == *"<example>"* ]]; then
        current_key=""
        continue
      fi
      # Strip leading whitespace (YAML indentation)
      local trimmed="${line#"${line%%[![:space:]]*}"}"
      if [[ -n "$description" ]]; then
        description="$description $trimmed"
      else
        description="$trimmed"
      fi
    fi
  done < "$file"

  if ! $found_frontmatter || [[ -z "$name" ]]; then
    echo "WARN: no valid frontmatter or missing name in $file" >&2
    return 1
  fi

  jq -n \
    --arg name "$name" \
    --arg desc "$description" \
    --arg ver "${version:-null}" \
    '{name: $name, description: $desc, version: (if $ver == "null" then null else $ver end)}'
}

# ── Component discovery ──────────────────────────────────────────────

# Discover skills in {plugin_root}/skills/*/SKILL.md
# Outputs a JSON array of skill objects.
discover_skills() {
  local plugin_root="$1"
  local plugin_name="$2"
  local skills="[]"

  if [[ ! -d "$plugin_root/skills" ]]; then
    echo "[]"
    return
  fi

  for skill_file in "$plugin_root"/skills/*/SKILL.md; do
    [[ -f "$skill_file" ]] || continue
    local fm
    if ! fm=$(parse_frontmatter "$skill_file"); then
      continue
    fi
    local s_name s_desc s_ver s_cmd
    s_name=$(echo "$fm" | jq -r '.name')
    s_desc=$(echo "$fm" | jq -r '.description')
    s_ver=$(echo "$fm" | jq -r 'if .version then .version else "0.0.0" end')
    s_cmd="/${plugin_name}:${s_name}"

    skills=$(echo "$skills" | jq \
      --arg n "$s_name" --arg d "$s_desc" --arg v "$s_ver" --arg c "$s_cmd" \
      '. + [{name: $n, version: $v, description: $d, command: $c}]')
  done

  echo "$skills"
}

# Discover agents in {plugin_root}/agents/*.md
# Outputs a JSON array of agent objects.
discover_agents() {
  local plugin_root="$1"
  local agents="[]"

  if [[ ! -d "$plugin_root/agents" ]]; then
    echo "[]"
    return
  fi

  for agent_file in "$plugin_root"/agents/*.md; do
    [[ -f "$agent_file" ]] || continue
    local fm
    if ! fm=$(parse_frontmatter "$agent_file"); then
      continue
    fi
    local a_name a_desc
    a_name=$(echo "$fm" | jq -r '.name')
    a_desc=$(echo "$fm" | jq -r '.description')

    agents=$(echo "$agents" | jq \
      --arg n "$a_name" --arg d "$a_desc" \
      '. + [{name: $n, description: $d}]')
  done

  echo "$agents"
}

# Discover commands in {plugin_root}/commands/*.md
# Outputs a JSON array of command objects.
discover_commands() {
  local plugin_root="$1"
  local plugin_name="$2"
  local commands="[]"

  if [[ ! -d "$plugin_root/commands" ]]; then
    echo "[]"
    return
  fi

  for cmd_file in "$plugin_root"/commands/*.md; do
    [[ -f "$cmd_file" ]] || continue
    local fm
    if ! fm=$(parse_frontmatter "$cmd_file"); then
      continue
    fi
    local c_name c_desc c_cmd
    c_name=$(echo "$fm" | jq -r '.name')
    c_desc=$(echo "$fm" | jq -r '.description')
    c_cmd="/${plugin_name}:${c_name}"

    commands=$(echo "$commands" | jq \
      --arg n "$c_cmd" --arg d "$c_desc" \
      '. + [{name: $n, description: $d}]')
  done

  echo "$commands"
}

# Discover hooks from {plugin_root}/hooks/hooks.json
# Outputs a JSON array of {event, rules} objects.
discover_hooks() {
  local plugin_root="$1"
  local hooks_file="$plugin_root/hooks/hooks.json"
  local result="[]"

  if [[ ! -f "$hooks_file" ]]; then
    echo "[]"
    return
  fi

  # Iterate over each event type (e.g., PreToolUse)
  local event_types
  event_types=$(jq -r '.hooks | keys[]' "$hooks_file" 2>/dev/null) || { echo "[]"; return; }

  for event_type in $event_types; do
    # Iterate over matcher groups within this event type
    local matcher_count
    matcher_count=$(jq -r ".hooks.\"$event_type\" | length" "$hooks_file")

    for (( i=0; i<matcher_count; i++ )); do
      local matcher
      matcher=$(jq -r ".hooks.\"$event_type\"[$i].matcher" "$hooks_file")
      local event_label="${event_type} (${matcher})"

      local command_rules="[]"
      local has_prompt=false

      # Process each hook in this matcher group
      local hook_count
      hook_count=$(jq -r ".hooks.\"$event_type\"[$i].hooks | length" "$hooks_file")

      for (( j=0; j<hook_count; j++ )); do
        local hook_type
        hook_type=$(jq -r ".hooks.\"$event_type\"[$i].hooks[$j].type" "$hooks_file")

        if [[ "$hook_type" == "command" ]]; then
          # Derive rule name from script filename
          local cmd_str
          cmd_str=$(jq -r ".hooks.\"$event_type\"[$i].hooks[$j].command" "$hooks_file")
          # Extract filename: last path component, remove .sh extension
          local filename="${cmd_str##*/}"
          filename="${filename%.sh}"
          # Replace hyphens with spaces, title-case each word (portable awk)
          local rule_name
          rule_name=$(echo "$filename" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
          command_rules=$(echo "$command_rules" | jq --arg r "$rule_name" '. + [$r]')

        elif [[ "$hook_type" == "prompt" ]]; then
          has_prompt=true
        fi
      done

      # Add command hooks as one entry (if any)
      local cmd_rule_count
      cmd_rule_count=$(echo "$command_rules" | jq 'length')
      if (( cmd_rule_count > 0 )); then
        result=$(echo "$result" | jq \
          --arg ev "$event_label" \
          --argjson rules "$command_rules" \
          '. + [{event: $ev, rules: $rules}]')
      fi

      # Add prompt hook as a separate entry
      if $has_prompt; then
        local prompt_text
        prompt_text=$(jq -r ".hooks.\"$event_type\"[$i].hooks[] | select(.type==\"prompt\") | .prompt" "$hooks_file" | cut -c1-80)
        # Truncate at last complete word
        if (( ${#prompt_text} >= 80 )); then
          prompt_text="${prompt_text% *}..."
        fi
        local prompt_label="${event_label} — Prompt"
        result=$(echo "$result" | jq \
          --arg ev "$prompt_label" \
          --arg rule "$prompt_text" \
          '. + [{event: $ev, rules: [$rule]}]')
      fi
    done
  done

  echo "$result"
}
