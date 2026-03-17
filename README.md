# typescript-rules

A Claude Code plugin that enforces TypeScript coding conventions with automatic validation, code review, and a dedicated reviewer agent.

## Overview

This plugin provides opinionated TypeScript conventions and enforces them automatically as you code. It includes a comprehensive conventions guide, shell hooks that block non-compliant patterns, prompt-based validation on file writes, and an agent-powered code reviewer.

## Features

- **Conventions skill** — full TypeScript style guide covering types, error handling, imports, naming, and dependencies
- **Code review agent** — AI-powered reviewer that checks files against the conventions and reports issues with severity levels
- **`/ts-review` command** — run a code review on specific files, directories, or your uncommitted changes
- **Enforcement hooks** — automatically blocks `any`, `enum`, `export default`, manual `package.json` edits, and non-pnpm package managers

## Installation

Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code) v1.0.33 or later.

### 1. Add the marketplace

From within Claude Code, run:

```
/plugin marketplace add pau-vega/my-marketplace
```

### 2. Install the plugin

```
/plugin install typescript-rules@pau-vega-my-marketplace
```

### 3. Activate

Run `/reload-plugins` to load the plugin without restarting.

### Alternative: test locally

Clone the repo and load it directly:

```bash
git clone https://github.com/pau-vega/my-marketplace.git
claude --plugin-dir ./my-marketplace
```

## Usage

### Review your code

```
/typescript-rules:ts-review              # reviews uncommitted changes or last commit
/typescript-rules:ts-review src/utils    # reviews a specific directory
/typescript-rules:ts-review src/app.ts   # reviews a specific file
```

### Reference conventions

Ask Claude to use the `typescript-conventions` skill when writing or reviewing TypeScript code. The conventions are applied automatically on every file write and edit via prompt hooks.

### Hooks

No setup needed — hooks activate automatically once the plugin is installed. They block non-compliant patterns in real time and suggest the correct alternative.
