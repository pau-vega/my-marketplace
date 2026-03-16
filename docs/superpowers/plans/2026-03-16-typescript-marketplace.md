# TypeScript Rules Marketplace — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Git-based Claude Code marketplace with a `typescript-rules` plugin containing a skill, prompt hooks, reviewer agent, and review command.

**Architecture:** Single-plugin flat marketplace. All plugin components (skills, agents, commands, hooks) live at the repo root alongside `.claude-plugin/`. No external dependencies — everything is markdown and JSON.

**Tech Stack:** Claude Code plugin system (markdown, YAML frontmatter, JSON)

---

## File Structure

| File | Responsibility |
|------|---------------|
| `.claude-plugin/marketplace.json` | Marketplace registry — lists available plugins |
| `.claude-plugin/plugin.json` | Plugin identity — name, version, description |
| `skills/typescript-conventions/SKILL.md` | TypeScript rules as a skill — Claude reads this when writing/reviewing TS |
| `hooks/hooks.json` | Hook config — prompt hook on PreToolUse for Write/Edit on .ts/.tsx files |
| `agents/ts-reviewer.md` | Reviewer agent — full code review with findings by severity |
| `commands/ts-review.md` | Review command — `/ts-review` dispatches the agent |

---

## Chunk 1: Marketplace scaffold and skill

### Task 1: Create marketplace manifest files

**Files:**
- Create: `.claude-plugin/marketplace.json`
- Create: `.claude-plugin/plugin.json`

- [ ] **Step 1: Create `.claude-plugin/marketplace.json`**

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

- [ ] **Step 2: Create `.claude-plugin/plugin.json`**

```json
{
  "name": "typescript-rules",
  "version": "1.0.0",
  "description": "TypeScript coding conventions with automatic validation, review command, and reviewer agent"
}
```

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/marketplace.json .claude-plugin/plugin.json
git commit -m "feat: add marketplace and plugin manifests"
```

---

### Task 2: Create TypeScript conventions skill

**Files:**
- Create: `skills/typescript-conventions/SKILL.md`

- [ ] **Step 1: Create `skills/typescript-conventions/SKILL.md`**

The file has YAML frontmatter followed by the complete TypeScript rules. The full content:

````markdown
---
name: typescript-conventions
description: >
  TypeScript coding conventions for any TS project. Covers types & interfaces
  (interface extends over &, discriminated unions, no enums), functions & error
  handling (Result types, no any, explicit return types), imports (import type,
  no default exports), and naming conventions. Use when writing or reviewing
  TypeScript code.
---

# TypeScript Conventions

## Types & Interfaces

### Prefer `interface extends` over `&`

The `&` (intersection) operator has poor performance in the TypeScript compiler. Use `interface extends` for inheritance — it's faster and produces clearer error messages.

```ts
// Avoid
type C = A & B;

// Prefer
interface C extends A, B {}
```

Only use `&` where `interface extends` is not possible (e.g., combining mapped types).

### Use discriminated unions for variant data

Model data that can be in different shapes with a shared discriminant field. This prevents the "bag of optionals" problem where impossible states are representable.

```ts
// Avoid — allows { status: "idle", data: someValue }
type FetchingState<TData> = {
  status: "idle" | "loading" | "success" | "error";
  data?: TData;
  error?: Error;
};

// Prefer — each status carries exactly the right fields
type FetchingState<TData> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: TData }
  | { status: "error"; error: Error };
```

Handle discriminated unions with `switch` statements:

```ts
const handleEvent = (event: Event) => {
  switch (event.type) {
    case "user.created":
      console.log(event.data.email);
      break;
    case "user.deleted":
      console.log(event.data.id);
      break;
  }
};
```

### Avoid `readonly` unless strictly needed

Do not add `readonly` to properties by default. Only use it when immutability is a critical invariant that must be enforced at compile time (e.g., a shared config object that must never be mutated).

```ts
// Default — no readonly
type User = {
  id: string;
  name: string;
};
```

### Prefer optional properties over `T | undefined`

Use `prop?: T` for optional properties — it's more concise and idiomatic.

```ts
// Avoid
type AuthOptions = {
  userId: string | undefined;
};

// Prefer
type AuthOptions = {
  userId?: string;
};
```

### `noUncheckedIndexedAccess` awareness

When this tsconfig option is enabled, indexing into arrays and records returns `T | undefined` instead of `T`. Handle the `undefined` case — don't assume the value exists.

```ts
const arr: string[] = [];
const value = arr[0]; // string | undefined — check before using
```

### No enums — use `as const` objects

Enums have surprising behavior (numeric reverse mappings, `Object.keys` doubling). Use `as const` objects instead:

```ts
const SIZE = {
  xs: "EXTRA_SMALL",
  sm: "SMALL",
  md: "MEDIUM",
} as const;

type SizeKey = keyof typeof SIZE; // "xs" | "sm" | "md"
type SizeValue = (typeof SIZE)[SizeKey]; // "EXTRA_SMALL" | "SMALL" | "MEDIUM"
```

Retain existing enums in the codebase — don't convert them unless asked.

### Prefix type parameters with `T`

```ts
type RecordOfArrays<TItem> = Record<string, TItem[]>;
```

## Functions & Error Handling

### Declare return types on top-level functions

Explicit return types on module-level functions help both humans and AI assistants understand intent. Exceptions: JSX components and custom hooks don't need a return type annotation.

```ts
const parseInput = (raw: string): ParsedInput => { ... };

// Components — no return type needed
const MyComponent = () => {
  return <div>Hello</div>;
};

// Custom hooks — no return type needed
const useMyHook = () => {
  const [value, setValue] = useState(0);
  return { value, setValue };
};
```

### Use Result types instead of throwing

Thrown errors require manual try-catch and lose type information. Use a Result type for operations that can fail predictably:

```ts
type Result<T, E extends Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

Throwing is fine when the framework handles it (e.g., inside a request handler that catches errors automatically). Use Result when the caller would need a manual try-catch.

### Never use `any` — prefer generics or `unknown`

`any` disables type checking entirely and defeats the purpose of TypeScript. Always use a more precise alternative:

- **Generic types** when the type varies but has structure:

```ts
// Avoid
const first = (arr: any[]): any => arr[0];

// Prefer
const first = <TItem>(arr: TItem[]): TItem | undefined => arr[0];
```

- **`unknown`** when the type is truly unknown — forces the caller to narrow before using:

```ts
// Avoid
const parse = (raw: string): any => JSON.parse(raw);

// Prefer
const parse = (raw: string): unknown => JSON.parse(raw);
```

- **Function overloads** when a generic function has conditional return types that TypeScript can't infer:

```ts
// Avoid — `as any` inside generic body
const toggle = <T extends "on" | "off">(
  input: T,
): T extends "on" ? "off" : "on" => {
  return (input === "on" ? "off" : "on") as any;
};

// Prefer — overloads with a generic implementation signature
function toggle(input: "on"): "off";
function toggle(input: "off"): "on";
function toggle(input: "on" | "off"): "on" | "off" {
  return input === "on" ? "off" : "on";
}
```

If none of the above work, use `as unknown as T` instead of `as any` — it preserves type safety at the boundary.

## Imports & Exports

### Use `import type` for type-only imports

Always use top-level `import type` — not inline `import { type ... }`. Without this, some bundlers leave behind an empty import side-effect.

```ts
// Avoid — may leave behind `import "./user"` after transpilation
import { type User } from "./user";

// Prefer
import type { User } from "./user";
```

### No default exports

Default exports create ambiguity at the import site — the name is arbitrary and disconnected from the source. Use named exports.

```ts
// Avoid
export default function myFunction() { ... }

// Prefer
export function myFunction() { ... }
```

Exception: frameworks that require default exports (e.g., Next.js pages).

## Naming & Style

| Element | Convention | Example |
|---------|-----------|---------|
| Files | kebab-case | `my-component.ts` |
| Variables & functions | camelCase | `myVariable`, `myFunction()` |
| Classes, types, interfaces | PascalCase | `MyClass`, `MyInterface` |
| Constants & enum values | ALL_CAPS | `MAX_COUNT`, `Color.RED` |
| Type parameters | T-prefixed | `TKey`, `TValue` |

### JSDoc comments

Add JSDoc only when the function's behavior isn't self-evident. Be concise. Use `{@link}` to reference related functions.

```ts
/** Subtracts two numbers */
const subtract = (a: number, b: number) => a - b;

/** Does the opposite of {@link subtract} */
const add = (a: number, b: number) => a + b;
```

## Dependencies

When installing libraries, always use the package manager CLI (e.g., `pnpm add`, `yarn add`, `npm install`) rather than manually editing `package.json`. This ensures you get the latest version, since training data has a cutoff date.

```bash
pnpm add -D @typescript-eslint/eslint-plugin
```
````

- [ ] **Step 2: Commit**

```bash
git add skills/typescript-conventions/SKILL.md
git commit -m "feat: add typescript-conventions skill with full rules"
```

---

## Chunk 2: Hooks, agent, and command

### Task 3: Create prompt hook for Write/Edit validation

**Files:**
- Create: `hooks/hooks.json`

- [ ] **Step 1: Create `hooks/hooks.json`**

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

- [ ] **Step 2: Commit**

```bash
git add hooks/hooks.json
git commit -m "feat: add prompt hook for TypeScript validation on Write/Edit"
```

---

### Task 4: Create ts-reviewer agent

**Files:**
- Create: `agents/ts-reviewer.md`

- [ ] **Step 1: Create `agents/ts-reviewer.md`**

````markdown
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

You are a TypeScript code reviewer. Your job is to review TypeScript code for compliance with the project's conventions, suggest improvements, and detect bugs.

## Review Process

1. **Discover files to review:**
   - If a specific path was provided, use Glob to find all `.ts` and `.tsx` files in that path
   - If no path was provided, run `git diff --name-only HEAD` to find changed files, then filter for `.ts`/`.tsx`
   - If there are no uncommitted changes, run `git diff --name-only HEAD~1` to review the last commit

2. **Read each file** using the Read tool

3. **Check against conventions** — for each file, verify:
   - No `any` type usage (use generics, `unknown`, or overloads)
   - No `type A = X & Y` for inheritance (use `interface extends`)
   - No enums (use `as const` objects)
   - No default exports (unless framework-required)
   - No inline `import { type X }` (use `import type { X }`)
   - No `T | undefined` for optional props (use `prop?: T`)
   - Return types declared on top-level functions (except JSX components and hooks)
   - Discriminated unions used instead of bags of optionals
   - Result types used instead of throwing (where caller would need try-catch)
   - Type parameters prefixed with `T`
   - Naming conventions followed (kebab-case files, camelCase vars, PascalCase types, ALL_CAPS constants)

4. **Detect bugs and logic issues** — look for:
   - Incorrect type narrowing
   - Missing null/undefined checks
   - Incorrect generic constraints
   - Unreachable code
   - Potential runtime errors

5. **Report findings** organized by file, with severity levels:
   - **Error**: Rule violations that must be fixed
   - **Warning**: Patterns that should be improved
   - **Suggestion**: Opportunities for stricter typing or cleaner code

## Output Format

For each file with findings:

```
### path/to/file.ts

- **Error**: Line 15 — Uses `any` as return type. Use `unknown` or a generic.
- **Warning**: Line 42 — `type Props = Base & Extra` should use `interface Props extends Base, Extra {}`
- **Suggestion**: Line 78 — Function `processData` has no explicit return type. Add `: ProcessedData`.
```

End with a summary: total files reviewed, errors, warnings, suggestions.

If no issues are found, report: "All files pass convention checks."
````

- [ ] **Step 2: Commit**

```bash
git add agents/ts-reviewer.md
git commit -m "feat: add ts-reviewer agent for TypeScript code review"
```

---

### Task 5: Create /ts-review command

**Files:**
- Create: `commands/ts-review.md`

- [ ] **Step 1: Create `commands/ts-review.md`**

```markdown
---
name: ts-review
description: Run a full TypeScript code review against project conventions
argument-hint: File or directory to review (defaults to changed files)
allowed-tools: Agent
---

Dispatch the `ts-reviewer` agent to perform a full TypeScript code review.

Target: $ARGUMENTS

If no target was provided, the agent should review all uncommitted `.ts`/`.tsx` changes. If a file or directory path was provided, the agent should review that path.
```

- [ ] **Step 2: Commit**

```bash
git add commands/ts-review.md
git commit -m "feat: add /ts-review command"
```

---

### Task 6: Final verification

- [ ] **Step 1: Verify all files exist**

Run: `find .claude-plugin skills agents commands hooks -type f | sort`

Expected output:
```
.claude-plugin/marketplace.json
.claude-plugin/plugin.json
agents/ts-reviewer.md
commands/ts-review.md
hooks/hooks.json
skills/typescript-conventions/SKILL.md
```

- [ ] **Step 2: Verify JSON files are valid**

Run: `python3 -c "import json; json.load(open('.claude-plugin/marketplace.json')); json.load(open('.claude-plugin/plugin.json')); json.load(open('hooks/hooks.json')); print('All JSON valid')"`

Expected: `All JSON valid`

- [ ] **Step 3: Verify YAML frontmatter is present in markdown files**

Run: `head -3 skills/typescript-conventions/SKILL.md agents/ts-reviewer.md commands/ts-review.md`

Expected: Each file starts with `---` (YAML frontmatter delimiter)

- [ ] **Step 4: Final commit if any changes needed**

Only if verification steps revealed issues that were fixed.
