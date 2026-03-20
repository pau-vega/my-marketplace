---
name: improve-codebase-architecture
description: This skill should be used when the user asks to "improve the architecture", "find refactoring opportunities", "deepen modules", "make the codebase more testable", "consolidate tightly-coupled modules", "review codebase architecture", or wants to surface architectural friction and propose module-deepening refactors.
---

# Improve Codebase Architecture

Explore a codebase organically, surface architectural friction, discover opportunities for improving testability, and propose module-deepening refactors as GitHub issue RFCs.

A **deep module** (John Ousterhout, "A Philosophy of Software Design") has a small interface hiding a large implementation. Deep modules are more testable, more navigable, and enable testing at the boundary instead of inside.

## Process

### 1. Explore the Codebase

Use the Agent tool with `subagent_type=Explore` to navigate the codebase naturally. Do not follow rigid heuristics — explore organically and note where friction occurs:

- Where does understanding one concept require bouncing between many small files?
- Where are modules so shallow that the interface is nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they are called?
- Where do tightly-coupled modules create integration risk in the seams between them?
- Which parts of the codebase are untested or hard to test?

The friction encountered IS the signal.

### 2. Present Candidates

Present a numbered list of deepening opportunities. For each candidate, show:

- **Cluster** — Which modules/concepts are involved
- **Why they're coupled** — Shared types, call patterns, co-ownership of a concept
- **Dependency category** — See `references/dependency-categories.md` for the four categories
- **Test impact** — What existing tests would be replaced by boundary tests

Do not propose interfaces yet. Ask: "Which of these would you like to explore?"

### 3. User Picks a Candidate

Wait for the user to select one.

### 4. Frame the Problem Space

Before spawning sub-agents, write a user-facing explanation of the problem space:

- The constraints any new interface would need to satisfy
- The dependencies it would need to rely on
- A rough illustrative code sketch to make the constraints concrete — this is not a proposal, just a way to ground the discussion

Present this to the user, then immediately proceed to Step 5. The user reads while the sub-agents work in parallel.

### 5. Design Multiple Interfaces

Spawn 3+ sub-agents in parallel using the Agent tool. Each must produce a radically different interface for the deepened module.

Prompt each sub-agent with a separate technical brief (file paths, coupling details, dependency category, what is being hidden). Give each agent a different design constraint:

- Agent 1: "Minimize the interface — aim for 1-3 entry points max"
- Agent 2: "Maximize flexibility — support many use cases and extension"
- Agent 3: "Optimize for the most common caller — make the default case trivial"
- Agent 4 (if applicable): "Design around the ports & adapters pattern for cross-boundary dependencies"

Each sub-agent outputs:

1. Interface signature (types, methods, params)
2. Usage example showing how callers use it
3. What complexity it hides internally
4. Dependency strategy (see `references/dependency-categories.md`)
5. Trade-offs

Present designs sequentially, then compare them in prose. Give a clear recommendation: which design is strongest and why. If elements from different designs combine well, propose a hybrid. Be opinionated — the user wants a strong read, not just a menu.

### 6. User Picks an Interface

Wait for selection or accept the recommendation.

### 7. Create GitHub Issue

Create a refactor RFC as a GitHub issue using `gh issue create` with the template in `references/issue-template.md`. Do not ask the user to review before creating — create it and share the URL.

## Guidelines

- **Explore organically.** The friction experienced while navigating is the primary signal. Do not run static analysis or follow checklists.
- **Deep over shallow.** Every proposal should make modules deeper — small interface, large implementation, testable at the boundary.
- **Replace, don't layer.** Old unit tests on shallow modules are waste once boundary tests exist. Delete them.
- **Be opinionated.** Recommend a design. The user is looking for a strong architectural perspective, not a list of options.

## Additional Resources

- **`references/dependency-categories.md`** — Four dependency categories (in-process, local-substitutable, ports & adapters, mock) and testing strategies
- **`references/issue-template.md`** — GitHub issue template for refactor RFCs
