---
name: jsdoc-review
description: >
  Review TypeScript files for JSDoc compliance at a specified enforcement level.
  This skill should be used when the user runs "/jsdoc-review", "/jsdoc-review minimal",
  "/jsdoc-review standard", or "/jsdoc-review strict".
argument-hint: "[minimal|standard|strict] [path]"
allowed-tools:
  - Agent
---

# JSDoc Review

Dispatch the `jsdoc-reviewer` agent to audit TypeScript files for JSDoc compliance.

Arguments: $ARGUMENTS

## Argument Parsing

Parse the arguments to extract the enforcement level and optional path:

- **No arguments** — use `standard` level, review changed files
- **Level only** (e.g., `strict`) — use that level, review changed files
- **Level and path** (e.g., `standard src/utils`) — use that level, review files at path
- **Path only** (e.g., `src/utils`) — use `standard` level, review files at path

Valid levels: `minimal`, `standard`, `strict`.

## Execution

1. Load the jsdoc-conventions skill from `${CLAUDE_PLUGIN_ROOT}/skills/jsdoc-conventions/SKILL.md` to get the full rule set
2. Determine the enforcement level from arguments (default: `standard`)
3. Discover target `.ts` and `.tsx` files:
   - If a path was provided, glob for files at that path
   - If no path, run `git diff --name-only HEAD` to find changed files
   - If no uncommitted changes, run `git diff --name-only HEAD~1` for the last commit
   - Filter for `.ts` and `.tsx` files only
4. Read each file and check against the rules for the selected level
5. Report findings grouped by file, using severity levels:
   - **Error** — Required JSDoc is completely missing
   - **Warning** — JSDoc is present but incomplete or malformed for the level
   - **Suggestion** — Opportunity to improve documentation quality
6. End with a summary: total files reviewed, errors, warnings, suggestions, and the level used
