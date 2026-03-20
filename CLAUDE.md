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

## Design Context

### Users
Developers curious about or adopting Claude Code who stumble on this marketplace via GitHub, a blog post, or a referral. They arrive already technical — they understand what agents, hooks, and skills are. The job to be done is quick evaluation: "Is this plugin worth installing?" The interface should answer that question with minimal friction, then get out of the way.

### Brand Personality
Calm and trustworthy. This is a personal portfolio that signals craft and reliability — not a flashy product page. Voice is direct and precise. The work earns trust through consistency, not persuasion.

Three words: **reliable, precise, unassuming**

### Aesthetic Direction
- **Warm dark neutrals as the foundation** — `#0f0e0c` background, not cool steel gray. The warmth signals care, not just efficiency.
- **Violet accent (`#7c6aef`)** for interactive elements — distinct without being aggressive.
- **Space Grotesk** for headings (technical yet slightly geometric), system UI for body, monospace for code.
- **Minimal cards** — no border at rest, border reveals on hover/focus. Visual noise only earns its place on interaction.
- Light mode is a first-class alternative (not an afterthought), using `[data-theme="light"]` CSS variables.
- Anti-references: no heavy glows, no gradients on cards, no external decorative imagery, no overstyled hero sections.

### Design Principles
1. **Let the content lead.** The plugins are the point. The UI frames and clarifies — it never competes.
2. **Earn every pixel.** If an element doesn't carry information or guide interaction, remove it. Restraint is a feature.
3. **Consistent over clever.** Predictable spacing, transition timing, and color usage build the sense of a well-maintained tool.
4. **Accessible by default.** Target WCAG 2.1 AA. Focus rings, ARIA roles, reduced motion, and sufficient contrast are not optional.
5. **Warm, not sterile.** Prefer warm neutrals over cool grays. The palette should feel hand-picked, not auto-generated.
