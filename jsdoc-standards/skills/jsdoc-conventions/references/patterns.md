# JSDoc Patterns Reference

## Level-Specific Patterns

### Minimal Level Patterns

#### Exported Functions

```ts
/** Converts a timestamp to a human-readable relative string. */
export const timeAgo = (timestamp: number): string => { ... };
```

#### Exported Classes

```ts
/** HTTP client with built-in retry and timeout support. */
export class ApiClient { ... }
```

#### Exported Interfaces

```ts
/** Configuration options for the database connection pool. */
export interface PoolConfig {
  maxConnections: number;
  idleTimeout: number;
  host: string;
}
```

#### Exported Type Aliases

```ts
/** Maps event names to their corresponding handler signatures. */
export type EventMap = Record<string, (...args: unknown[]) => void>;
```

Only self-descriptive aliases are exempt:

```ts
// Exempt — name says it all
type UserId = string;

// Needs JSDoc — purpose not obvious from name
/** Unix timestamp in milliseconds since epoch. */
type Timestamp = number;
```

### Standard Level Patterns

#### Functions with Parameters

```ts
/**
 * Calculates the distance between two geographic coordinates.
 *
 * @param from - The origin coordinate
 * @param to - The destination coordinate
 * @returns Distance in kilometers
 */
export const distance = (from: Coordinate, to: Coordinate): number => { ... };
```

#### Optional and Default Parameters

```ts
/**
 * Paginates an array of items.
 *
 * @param items - The full list to paginate
 * @param page - The page number, starting at 1
 * @param pageSize - Items per page (defaults to 20)
 * @returns The slice of items for the requested page
 */
export const paginate = <TItem>(
  items: TItem[],
  page: number,
  pageSize: number = 20,
): TItem[] => { ... };
```

#### Public Class Methods

```ts
export class Cache<TValue> {
  /**
   * Retrieves a value from the cache.
   *
   * @param key - The cache key to look up
   * @returns The cached value, or undefined if expired or missing
   */
  get(key: string): TValue | undefined { ... }

  /**
   * Stores a value in the cache with an optional TTL.
   *
   * @param key - The cache key
   * @param value - The value to store
   * @param ttl - Time-to-live in milliseconds (no expiry if omitted)
   */
  set(key: string, value: TValue, ttl?: number): void { ... }
}
```

#### Complex Generics

Document generic type parameters using `@typeParam` (not `@param`). Some tools also accept `@template`, but `@typeParam` is preferred for consistency:

```ts
/**
 * Merges two objects, preferring values from the override.
 *
 * @typeParam TBase - The base object type
 * @typeParam TOverride - The override object type, whose keys take precedence
 * @param base - The base object
 * @param override - The object whose values take priority
 * @returns A merged object combining both inputs
 */
export const merge = <TBase extends object, TOverride extends object>(
  base: TBase,
  override: TOverride,
): TBase & TOverride => { ... };
```

### Strict Level Patterns

#### Module-Level Constants

```ts
/** Base URL for all API requests in production. */
const API_BASE = "https://api.example.com/v2";

/** Default timeout for HTTP requests in milliseconds. */
const DEFAULT_TIMEOUT = 30_000;

/** Supported image MIME types for upload validation. */
const ALLOWED_MIME_TYPES = ["image/png", "image/jpeg", "image/webp"] as const;
```

#### Private Helpers

```ts
/**
 * Normalizes a header name to lowercase with hyphens.
 *
 * @param raw - The raw header name (e.g., "Content_Type", "ACCEPT")
 * @returns The normalized header (e.g., "content-type", "accept")
 */
const normalizeHeader = (raw: string): string =>
  raw.toLowerCase().replace(/_/g, "-");
```

#### @example Blocks

Always use fenced TypeScript code blocks inside `@example`:

```ts
/**
 * Deeply freezes an object and all nested objects.
 *
 * @param obj - The object to freeze
 * @returns The same object, deeply frozen
 *
 * @example
 * ```ts
 * const config = deepFreeze({ db: { host: "localhost", port: 5432 } });
 * config.db.port = 3000; // TypeError at runtime
 * ```
 */
export const deepFreeze = <TObj extends object>(obj: TObj): Readonly<TObj> => { ... };
```

#### @throws Tag

```ts
/**
 * Parses a JSON string into a typed object.
 *
 * @param raw - The JSON string to parse
 * @returns The parsed object
 * @throws {SyntaxError} When the string is not valid JSON
 * @throws {ValidationError} When the parsed object does not match the schema
 */
export const parseJson = <TResult>(raw: string): TResult => { ... };
```

#### @see and {@link}

```ts
/**
 * Serializes a user object for API transmission.
 *
 * @param user - The user to serialize
 * @returns A JSON-safe representation of the user
 *
 * @see {@link deserializeUser} for the inverse operation
 * @see {@link UserSchema} for the validation schema
 */
export const serializeUser = (user: User): SerializedUser => { ... };
```

#### @deprecated

```ts
/**
 * Formats a date as "YYYY-MM-DD".
 *
 * @deprecated Use {@link formatIsoDate} instead, which handles timezones correctly.
 */
export const formatDate = (date: Date): string => { ... };
```

## Edge Cases

### Overloaded Functions

Document each overload signature separately:

```ts
/** Parses a string into a number. */
export function parse(input: string): number;
/** Parses a string into a boolean. */
export function parse(input: string, asBoolean: true): boolean;
/**
 * Parses a string into the requested type.
 *
 * @param input - The string to parse
 * @param asBoolean - When true, parse as boolean instead of number
 * @returns The parsed value
 */
export function parse(input: string, asBoolean?: boolean): number | boolean {
  ...
}
```

### Destructured Parameters

Name the parameter object, then describe each property:

```ts
/**
 * Creates a database connection.
 *
 * @param options - Connection configuration
 * @param options.host - Database hostname
 * @param options.port - Database port
 * @param options.ssl - Whether to use SSL (defaults to true)
 * @returns An active database connection
 */
export const connect = (options: ConnectionOptions): Connection => { ... };
```

### Callback Parameters

```ts
/**
 * Registers a listener for the specified event.
 *
 * @param event - The event name to listen for
 * @param handler - Called when the event fires, receives the event payload
 * @returns A cleanup function that removes the listener
 */
export const on = <TPayload>(
  event: string,
  handler: (payload: TPayload) => void,
): (() => void) => { ... };
```

### Re-exported Types

Re-exports do not need JSDoc — the original source should be documented:

```ts
// No JSDoc needed
export type { User, Role } from "./user";
```

### Enum-Like Constants (as const)

```ts
/**
 * Available log severity levels.
 *
 * @see {@link Logger.log} for usage
 */
export const LOG_LEVEL = {
  debug: "DEBUG",
  info: "INFO",
  warn: "WARN",
  error: "ERROR",
} as const;
```
