# TypeScript Rules Marketplace — Design Spec

## Overview

A Git-based marketplace repository for Claude Code plugins, starting with a `typescript-rules` plugin that enforces TypeScript coding conventions through a skill, automatic hooks, a review command, and a reviewer agent.

## Project Structure

```
my-marketplace/
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── skills/
│   └── typescript-conventions/
│       └── SKILL.md
├── agents/
│   └── ts-reviewer.md
├── commands/
│   └── ts-review.md
└── hooks/
    └── hooks.json
```

Single-plugin marketplace with all components at the root level, following the standard marketplace convention (e.g., impeccable, superpowers). If more plugins are added later, the structure can be refactored to use explicit path arrays in `marketplace.json`.

## Components

### 1. Marketplace Root

**`marketplace.json`** — Registers all plugins available in this marketplace.

```json
{
  "name": "my-marketplace",
  "description": "Curated collection of Claude Code plugins for TypeScript development",
  "owner": {
    "name": "Pau Velasco Garrofe",
    "email": "pau@example.com"
  },
  "version": "1.0.0",
  "plugins": [
    {
      "name": "typescript-rules",
      "source": "./",
      "description": "TypeScript coding conventions with automatic validation, review command, and reviewer agent",
      "version": "1.0.0",
      "category": "development",
      "author": {
        "name": "Pau Velasco Garrofe"
      },
      "tags": ["typescript", "conventions", "code-review", "linting"]
    }
  ]
}
```

**`plugin.json`** — Identifies the marketplace as a Claude Code plugin.

```json
{
  "name": "typescript-rules",
  "version": "1.0.0",
  "description": "TypeScript coding conventions with automatic validation, review command, and reviewer agent"
}
```

### 2. Skill — `typescript-conventions`

**File:** `skills/typescript-conventions/SKILL.md`

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

**File:** `hooks/hooks.json`

**Type:** `prompt` hook on `PreToolUse` for `Write|Edit` tools.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if the target file is .ts or .tsx. If not, respond with 'approve'. If it is a TypeScript file, validate the proposed code against these rules: (1) No use of 'any' type — use generics, unknown, or overloads, (2) No 'type A = X & Y' for inheritance — use 'interface extends' instead, (3) No enums — use 'as const' objects, (4) No default exports unless required by framework, (5) No inline 'import { type X }' — use top-level 'import type { X }', (6) No 'T | undefined' for optional props — use 'prop?: T'. If all rules pass, respond 'approve'. If any rule is violated, respond 'deny' with an explanation of which rules were broken and how to fix them."
          }
        ]
      }
    ]
  }
}
```

**Design rationale:** A `prompt` hook lets Claude analyze code semantically without external dependencies. A bash script would require a TypeScript parser or AST tooling, adding fragility and setup complexity. The trade-off is token consumption per Write/Edit on TS files.

### 4. Agent — `ts-reviewer`

**File:** `agents/ts-reviewer.md`

**Frontmatter:**

```yaml
---
name: ts-reviewer
description: >
  Reviews TypeScript code for rule compliance, suggests refactorings aligned
  with conventions (e.g. & to interface extends), and detects bugs, logic
  issues, and opportunities for stricter typing. Use when reviewing TypeScript
  code quality.

  <example>
  Context: User wants to check their TypeScript code against conventions
  user: "Review my TypeScript code for quality"
  assistant: "I'll use the ts-reviewer agent to analyze the code."
  <commentary>User requesting TS code review triggers this agent.</commentary>
  </example>

  <example>
  Context: User completed a feature and wants validation
  user: "Check if my changes follow our TypeScript rules"
  assistant: "I'll dispatch the ts-reviewer agent to verify convention compliance."
  <commentary>Convention compliance check triggers this agent.</commentary>
  </example>
model: sonnet
color: cyan
tools: ["Read", "Glob", "Grep", "Bash"]
---
```

**Behavior:**
1. Discovers target `.ts`/`.tsx` files — uses `git diff --name-only` (via Bash) when no path is specified, or Glob when a path is provided
2. Reads and verifies compliance with all conventions from the skill
3. Suggests refactorings aligned with the rules (e.g., convert `&` to `interface extends`)
4. Detects bugs, incorrect logic, and opportunities for stricter typing
5. Reports findings by severity: error, warning, suggestion

**Constraint:** The agent reports findings but does not modify code. The user decides what to apply. `Bash` access is limited to `git diff` for file discovery.

### 5. Command — `/ts-review`

**File:** `commands/ts-review.md`

**Frontmatter:**

```yaml
---
name: ts-review
description: Run a full TypeScript code review against project conventions
argument-hint: File or directory to review (defaults to changed files)
allowed-tools: Agent
---
```

**Body:** The command receives the user's input via `$ARGUMENTS`. If `$ARGUMENTS` is empty, it instructs the `ts-reviewer` agent to review uncommitted changes. If a path is provided, it passes that path to the agent.

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
| Agent tools | Read, Glob, Grep, Bash | Bash needed for `git diff` file discovery; agent remains non-destructive |
| Agent model | `sonnet` (fixed) | Consistent review quality regardless of parent session model. `inherit` would give user control but inconsistent results |
| Plugin structure | Flat (root-level) | Single-plugin marketplace follows standard conventions (impeccable, superpowers) |
| Marketplace type | Git repository | Simple distribution via `claude plugins add <repo>` |

## Success Criteria

1. Users can install the marketplace via `claude plugins add <repo-url>`
2. The skill activates automatically when Claude writes TypeScript code
3. Hooks block Write/Edit calls that violate core rules in `.ts`/`.tsx` files
4. `/ts-review` produces a clear, actionable review report
5. The `ts-reviewer` agent catches rule violations, suggests improvements, and detects bugs
