---
name: ts-review
description: Run a full TypeScript code review against project conventions
argument-hint: File or directory to review (defaults to changed files)
allowed-tools:
  - Agent
---

Dispatch the `ts-reviewer` agent to perform a full TypeScript code review.

Target: $ARGUMENTS

If no target was provided, the agent should review all uncommitted `.ts`/`.tsx` changes. If a file or directory path was provided, the agent should review that path.
