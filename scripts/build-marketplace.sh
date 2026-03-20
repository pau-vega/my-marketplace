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
