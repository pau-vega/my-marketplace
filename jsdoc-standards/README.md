# jsdoc-standards

A Claude Code plugin that enforces consistent JSDoc documentation across TypeScript projects with three configurable enforcement levels.

## Enforcement Levels

| Level | What's documented |
|-------|-------------------|
| **Minimal** | Exported functions, classes, interfaces, type aliases (summary only) |
| **Standard** | Minimal + `@param`, `@returns` tags, public class methods |
| **Strict** | Standard + constants, private helpers, `@example`, `@throws`, `@see`, `{@link}` |

## Components

### Skill: `jsdoc-conventions`

Reference guide with the full JSDoc style rules. Claude consults this automatically when writing or documenting TypeScript code.

### Command: `jsdoc-review`

User-invoked review command:

```
/jsdoc-review                    # Standard level, changed files
/jsdoc-review strict             # Strict level, changed files
/jsdoc-review minimal src/utils  # Minimal level, specific path
```

### Agent: `jsdoc-reviewer`

Autonomous reviewer that triggers when you ask about JSDoc quality (e.g., "review my JSDocs", "check documentation coverage"). Reports findings by file with Error/Warning/Suggestion severity.

### Hooks

PreToolUse hook on Write/Edit that **warns** (never blocks) when exported TypeScript constructs are missing JSDoc comments.

## Installation

```bash
claude --plugin-dir /path/to/jsdoc-standards
```

## License

MIT
