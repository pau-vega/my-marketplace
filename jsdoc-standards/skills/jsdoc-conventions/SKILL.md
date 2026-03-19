---
name: jsdoc-conventions
description: >
  TypeScript JSDoc documentation conventions with three enforcement levels
  (Minimal, Standard, Strict). This skill should be used when the user asks to
  "add JSDoc", "document this code", "add documentation", "write JSDocs",
  "improve documentation", "set JSDoc level", "which JSDoc level", or when
  applying JSDoc conventions to TypeScript code. Provides rules for tag usage,
  format, and level selection across any TypeScript project.
---

# JSDoc Conventions for TypeScript

## Enforcement Levels

Three levels control documentation scope. Each level includes all requirements from the previous one.

### Minimal

Document **exported** functions, classes, interfaces, and type aliases with a brief summary line.

```ts
/** Parses a raw CSV string into structured row objects. */
export const parseCsv = (raw: string): CsvRow[] => { ... };

/** Represents a single row of parsed CSV data. */
export interface CsvRow { ... }
```

### Standard

Everything in Minimal, plus:

- `@param` and `@returns` tags on exported functions
- Public class methods documented
- Complex type parameters described

```ts
/**
 * Fetches a user by ID from the database.
 *
 * @param userId - The unique identifier of the user
 * @returns The user object, or undefined if not found
 */
export const getUser = async (userId: string): Promise<User | undefined> => { ... };
```

### Strict

Everything in Standard, plus:

- Module-level constants documented
- Private and internal helper functions documented
- `@example` blocks on non-trivial functions
- `@throws`, `@see`, and `{@link}` where applicable

```ts
/** Maximum number of retry attempts for failed API calls. */
const MAX_RETRIES = 3;

/**
 * Retries an async operation with exponential backoff.
 *
 * @param fn - The async function to retry
 * @param maxAttempts - Maximum retry attempts (defaults to {@link MAX_RETRIES})
 * @returns The result of the first successful invocation
 * @throws {RetryExhaustedError} When all attempts fail
 *
 * @example
 * ```ts
 * const data = await retry(() => fetchApi("/users"), 5);
 * ```
 *
 * @see {@link MAX_RETRIES} for the default retry limit
 */
const retry = async <TResult>(
  fn: () => Promise<TResult>,
  maxAttempts: number = MAX_RETRIES,
): Promise<TResult> => { ... };
```

## Core Rules (All Levels)

### Format

- Always use `/** */` block comments, never `//` for documentation
- First line is a concise summary ending with a period
- Separate summary from tags with a blank line

### Do Not Duplicate TypeScript Types

TypeScript already provides type information. Never repeat it in JSDoc tags.

```ts
// Avoid — redundant type annotation
/** @param {string} name - The user name */

// Prefer — description only
/** @param name - The user name */
```

Do not use `@type` tags — the TypeScript compiler is the source of truth.

### Tag Conventions

| Tag | When to use | Format |
|-----|------------|--------|
| `@param` | Standard+ level, every parameter | `@param name - Description` |
| `@returns` | Standard+ level, non-void functions | `@returns Description` |
| `@throws` | Strict level, functions that throw | `@throws {ErrorType} When...` |
| `@example` | Strict level, non-trivial functions | Fenced code block |
| `@see` | Strict level, related functions/docs | `@see {@link OtherThing}` |
| `@deprecated` | Any level, deprecated APIs | `@deprecated Use {@link replacement} instead` |
| `{@link}` | Any level, cross-references | `{@link FunctionOrType}` |

### Use `@returns`, Not `@return`

The canonical tag is `@returns` (with an "s"). Both work, but consistency matters.

### Exempt Constructs

These never require JSDoc at any level:

- Trivial type aliases that are self-descriptive (`type UserId = string`)
- Single-field interfaces with obvious meaning
- Re-exports (`export { Thing } from "./thing"`)
- Index signature types
- JSX component return types and custom hook return types (already clear from usage)

### What Not to Document

Avoid stating the obvious. Ensure every JSDoc comment adds information beyond what the code already says.

```ts
// Avoid — adds nothing
/** Gets the user ID. */
const getUserId = (user: User): string => user.id;

// Prefer — explains why or how
/** Extracts the user ID, falling back to the session ID if unauthenticated. */
const getUserId = (user: User | null, sessionId: string): string =>
  user?.id ?? sessionId;
```

### Multi-Line Descriptions

For complex functions, use a summary line followed by a detailed paragraph.

```ts
/**
 * Validates and normalizes an email address.
 *
 * Strips leading/trailing whitespace, lowercases the domain part, and checks
 * against RFC 5322. Returns a Result with the normalized email on success
 * or a validation error on failure.
 *
 * @param raw - The unprocessed email string from user input
 * @returns A Result containing the normalized email or a validation error
 */
```

### Classes and Interfaces

Document the construct itself, not just its members.

```ts
/**
 * Manages WebSocket connections with automatic reconnection.
 *
 * Handles connection lifecycle, message queuing during disconnects,
 * and exponential backoff for reconnection attempts.
 */
export class ConnectionManager { ... }
```

## Level Selection Guidelines

| Scenario | Recommended level |
|----------|------------------|
| Internal tooling, scripts, prototypes | Minimal |
| Libraries consumed by other teams, production apps | Standard |
| Public APIs, SDKs, open-source libraries | Strict |

## Additional Resources

### Reference Files

For detailed patterns and edge cases:
- **`references/patterns.md`** — Extended JSDoc patterns for each level with more examples and edge cases
