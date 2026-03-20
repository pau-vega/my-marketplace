---
name: prd-to-issues
description: This skill should be used when the user asks to "break down a PRD", "convert PRD to issues", "create issues from a PRD", "split a PRD into tickets", "create implementation tickets", or wants to turn a product requirements document into independently-grabbable GitHub issues.
---

# PRD to Issues

Break a PRD into independently-grabbable GitHub issues using vertical slices (tracer bullets). Each issue cuts through all integration layers end-to-end — not horizontal slices of a single layer.

## Process

### 1. Locate the PRD

Ask the user for the PRD GitHub issue number or URL. If the PRD is not already in the conversation context, fetch it with `gh issue view <number>`.

### 2. Explore the Codebase

If the codebase has not already been explored, read relevant files to understand the current architecture. This grounds the slice boundaries in reality.

### 3. Draft Vertical Slices

Break the PRD into tracer bullet issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end.

Slices are either:

- **AFK** — Can be implemented and merged without human interaction. Prefer these.
- **HITL** — Require a human decision (architectural choice, design review, etc.).

Rules for slicing:

- Each slice delivers a narrow but complete path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- Identify dependencies between slices explicitly

### 4. Quiz the User

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title** — Short descriptive name
- **Type** — AFK or HITL
- **Blocked by** — Which other slices must complete first (if any)
- **User stories covered** — Which user stories from the PRD this addresses

Then ask:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as AFK and HITL?

Iterate until the user approves the breakdown.

### 5. Create GitHub Issues

For each approved slice, create a GitHub issue using `gh issue create` with the template in `references/issue-template.md`.

Create issues in dependency order (blockers first) so real issue numbers can be referenced in the "Blocked by" field.

Do NOT close or modify the parent PRD issue.

## Guidelines

- **Vertical over horizontal.** Never create issues like "build the database layer" or "add the UI." Each issue delivers a thin but complete feature path.
- **AFK by default.** Mark slices as HITL only when a genuine human decision is required. The goal is maximum parallelism.
- **Dependency order matters.** Create blocker issues first so downstream issues can reference real numbers.
- **Reference, don't duplicate.** Issue bodies should point back to the parent PRD, not copy its content.
- **Iterate the breakdown.** The first draft is rarely right. Expect 1-2 rounds of adjustment with the user.

## Next Step

Once the issues are created, suggest: "Pick an issue to start on, and ask me to **use TDD** to implement it."

## Additional Resources

- **`references/issue-template.md`** — GitHub issue body template for each vertical slice
