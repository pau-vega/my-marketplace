# TypeScript Rules Marketplace — Design Spec

## Overview

A Git-based marketplace repository for Claude Code plugins, starting with a `typescript-rules` plugin that enforces TypeScript coding conventions through a skill, automatic hooks, a review command, and a reviewer agent.

## Project Structure

```
my-marketplace/
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
└── plugins/
    └── typescript-rules/
        ├── .claude-plugin/
        │   └── plugin.json
        ├── skills/
        │   └── typescript-conventions/
        │       └── SKILL.md
        ├── agents/
        │   └── ts-reviewer.md
        ├── commands/
        │   └── ts-review.md
        └── hooks/
            ├── hooks.json
            └── scripts/
                └── validate-ts.sh
```

## Components

### 1. Marketplace Root

**`marketplace.json`** — Registers all plugins available in this marketplace.

```json
{
  "name": "my-marketplace",
  "metadata": {
    "description": "Curated collection of Claude Code plugins for TypeScript development"
  },
  "version": "1.0.0",
  "pluginRoot": "./plugins",
  "plugins": [
    {
      "name": "typescript-rules",
      "source": "./plugins/typescript-rules",
      "description": "TypeScript coding conventions with automatic validation, review command, and reviewer agent",
      "version": "1.0.0",
      "category": "development",
      "keywords": ["typescript", "conventions", "code-review", "linting"]
    }
  ]
}
```

**`plugin.json`** (root) — Identifies the marketplace itself as a Claude Code plugin.

```json
{
  "name": "my-marketplace",
  "version": "1.0.0",
  "description": "Marketplace for Claude Code plugins"
}
```

### 2. Skill — `typescript-conventions`

**File:** `plugins/typescript-rules/skills/typescript-conventions/SKILL.md`

**Frontmatter:**

```yaml
---
name: typescript-conventions
description: >
  TypeScript coding conventions for any TS project. Covers types & interfaces
  (interface extends over &, discriminated unions, no enums), functions & error
  handling (Result types, no any, explicit return types), imports (import type,
  no default exports), and naming conventions. Use when writing or reviewing
  TypeScript code.
---
```

**Body:** The user's complete TypeScript rules, organized in these sections:

1. **Types & Interfaces** — `interface extends` over `&`, discriminated unions, no `readonly` by default, optional properties with `?`, `noUncheckedIndexedAccess` awareness, no enums (use `as const`), T-prefixed type parameters
2. **Functions & Error Handling** — Explicit return types on top-level functions (except JSX/hooks), Result types over throwing, never use `any`
3. **Imports & Exports** — Top-level `import type`, no default exports (except framework requirements)
4. **Naming & Style** — kebab-case files, camelCase variables/functions, PascalCase types/classes, ALL_CAPS constants, concise JSDoc
5. **Dependencies** — Always use package manager CLI, never manual `package.json` edits

### 3. Hooks — Automatic Validation

**File:** `plugins/typescript-rules/hooks/hooks.json`

**Type:** `prompt` hook on `PreToolUse` for `Write|Edit` tools.

**Behavior:**
- Intercepts all `Write` and `Edit` tool calls
- If the target file is `.ts` or `.tsx`, checks the proposed code against core rules:
  - No `any`
  - No `type A = X & Y` for inheritance (use `interface extends`)
  - No enums (use `as const`)
  - No default exports (except framework requirements)
  - No inline `import { type X }` (use `import type { X }`)
  - No `T | undefined` for optional props (use `prop?: T`)
- If the file is not `.ts`/`.tsx`, allows immediately
- If all rules pass, allows the change
- If rules are violated, blocks with explanation

**Design rationale:** A `prompt` hook lets Claude analyze code semantically without external dependencies. A bash script would require a TypeScript parser or AST tooling, adding fragility and setup complexity. The trade-off is token consumption per Write/Edit on TS files.

### 4. Agent — `ts-reviewer`

**File:** `plugins/typescript-rules/agents/ts-reviewer.md`

**Frontmatter:**

```yaml
---
name: ts-reviewer
description: >
  Reviews TypeScript code for rule compliance, suggests refactorings aligned
  with conventions (e.g. & to interface extends), and detects bugs, logic
  issues, and opportunities for stricter typing. Use when reviewing TypeScript
  code quality.
model: sonnet
tools: Read, Glob, Grep
---
```

**Behavior:**
1. Discovers target `.ts`/`.tsx` files (from git diff or specified path)
2. Verifies compliance with all conventions from the skill
3. Suggests refactorings aligned with the rules (e.g., convert `&` to `interface extends`)
4. Detects bugs, incorrect logic, and opportunities for stricter typing
5. Reports findings by severity: error, warning, suggestion

**Constraint:** Read-only — the agent reports findings but does not modify code. The user decides what to apply.

### 5. Command — `/ts-review`

**File:** `plugins/typescript-rules/commands/ts-review.md`

**Frontmatter:**

```yaml
---
name: ts-review
description: Run a full TypeScript code review against project conventions
arguments:
  - name: path
    description: File or directory to review (defaults to changed files)
    required: false
---
```

**Behavior:**
- Without arguments: reviews `.ts`/`.tsx` files with uncommitted changes (`git diff`)
- With path argument: reviews the specified file or directory
- Dispatches the `ts-reviewer` agent to perform the review

**Usage examples:**
```
/ts-review                    — review pending changes
/ts-review src/utils          — review entire directory
/ts-review src/auth/login.ts  — review specific file
```

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Hook type | `prompt` over bash script | Semantic code analysis without external dependencies |
| Agent tools | Read, Glob, Grep only | Agent is read-only; it reports, doesn't modify |
| Agent model | sonnet | Good balance of quality and speed for code review |
| Plugin scope | Generic TypeScript | Not tied to any specific framework or stack |
| Marketplace type | Git repository | Simple distribution via `claude plugins add <repo>` |

## Success Criteria

1. Users can install the marketplace via `claude plugins add <repo-url>`
2. The skill activates automatically when Claude writes TypeScript code
3. Hooks block Write/Edit calls that violate core rules in `.ts`/`.tsx` files
4. `/ts-review` produces a clear, actionable review report
5. The `ts-reviewer` agent catches rule violations, suggests improvements, and detects bugs
