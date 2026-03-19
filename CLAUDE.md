# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code plugin marketplace** containing the `typescript-rules` plugin. It is not a traditional app or library — there is no build step, no package.json, and no npm dependencies. The entire project consists of markdown files, JSON configs, and shell scripts that integrate with the Claude Code plugin system.

## Repository Structure

- `.claude-plugin/` — Plugin and marketplace manifests (`plugin.json`, `marketplace.json`)
- `agents/ts-reviewer.md` — Sonnet-powered TypeScript code review agent
- `commands/ts-review.md` — `/ts-review` slash command that dispatches the reviewer agent
- `skills/typescript-conventions/SKILL.md` — Comprehensive TypeScript style guide (the source of truth for all enforced rules)
- `hooks/hooks.json` — Hook configuration (PreToolUse hooks on Bash, Write, Edit)
- `hooks/scripts/` — Shell scripts for convention enforcement (enforce-pnpm, no-any, no-enum, no-export-default, no-package-json-edit)

## How to Test Locally

```bash
claude --plugin-dir ./my-marketplace
```

There are no build, lint, or test commands — validation is done by loading the plugin in Claude Code and exercising the hooks, command, and agent.

## Architecture

The plugin enforces TypeScript conventions through three layers:

1. **Hooks (real-time)** — `hooks/hooks.json` registers PreToolUse hooks that fire on every Bash, Write, and Edit tool call. Shell script hooks do pattern matching (e.g., grep for `any`, `enum`). A prompt-based hook on Write/Edit validates proposed code against all six core rules.
2. **Command + Agent (on-demand)** — `/ts-review` dispatches the `ts-reviewer` agent, which loads the conventions skill, discovers target files, and produces a structured report with Error/Warning/Suggestion severity levels.
3. **Skill (reference)** — `typescript-conventions` is a passive skill that Claude can consult when writing or reviewing TypeScript in any project that has this plugin installed.

## Key Conventions When Editing This Plugin

- Hook scripts must read tool input from `$TOOL_INPUT` (JSON) and use `jq` to extract fields
- Hook scripts output JSON: `{"decision": "block", "reason": "..."}` to block, or exit 0 silently to allow
- The prompt-based hook in `hooks.json` is inline — it checks `.ts`/`.tsx` files against the six core rules and responds with "approve" or "deny"
- `${CLAUDE_PLUGIN_ROOT}` is the variable used in hooks.json and agent files to reference the plugin's root directory
- The agent uses `model: sonnet` and has access to `Read`, `Glob`, `Grep`, and `Bash` tools only
