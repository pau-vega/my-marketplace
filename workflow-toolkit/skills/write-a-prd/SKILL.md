---
name: write-a-prd
description: This skill should be used when the user asks to "write a PRD", "create a product requirements document", "plan a new feature", "write requirements", "draft a spec", "spec out a feature", "define requirements", or wants to plan and define what to build before building it.
---

# Write a PRD

Create a Product Requirements Document through structured user interview, codebase exploration, and module design. Submit the final PRD as a GitHub issue, or write it as a markdown file if no repository is available or the user prefers.

Steps may be skipped if clearly unnecessary for the scope of the work.

## Process

### 1. Gather the Problem

Ask the user for a thorough description of:

- The problem they want to solve
- Who experiences the problem
- Any potential ideas for solutions they already have

Let the user talk. Do not interrupt with questions yet — the goal is to get the full picture before digging in.

### 2. Explore the Codebase

Verify the user's assertions and understand the current state:

- Read relevant files to understand existing architecture
- Identify what exists that can be reused or extended
- Note any constraints the codebase imposes on the solution
- Flag any discrepancies between what the user described and what the code shows

Report findings to the user before proceeding.

### 3. Interview

Interview the user relentlessly about every aspect of the plan until reaching shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one by one.

For each question, provide a recommended answer. If a question can be answered by exploring the codebase, explore the codebase instead of asking.

Cover at minimum:

- Exact scope — what is in, what is out
- User stories and workflows
- Error states and edge cases
- Data model implications
- API contracts if applicable
- Migration path from current state

### 4. Design Modules

Sketch out the major modules to build or modify. Actively look for opportunities to extract **deep modules** — modules that encapsulate significant functionality behind a simple, testable interface that rarely changes.

A deep module (as opposed to a shallow module) provides:
- A simple interface
- Complex internal implementation
- Strong encapsulation
- Independent testability

Present the module sketch to the user. Confirm:

- The modules match their expectations
- Which modules they want tests written for
- Any modules they want to approach differently

### 5. Write the PRD

Once there is complete understanding of the problem and solution, write the PRD using the template in `references/prd-template.md`.

### 6. Submit

- **If in a git repository**: Submit the PRD as a GitHub issue using `gh issue create`
- **If no repo or user prefers**: Write the PRD as a markdown file
- Ask the user which approach they prefer if unclear

## Guidelines

- **The interview is the core of the process.** Do not rush to writing. A thorough interview produces a better PRD with less revision.
- **One question at a time.** Each answer may change the next question.
- **Recommend answers.** For every question, provide a recommended answer to accelerate the process.
- **Use the codebase.** Explore the repo to ground decisions in reality, not assumptions.
- **Write exhaustive user stories.** 10-30 stories is normal for a meaningful feature. If there are only 3, dig deeper.
- **Deep modules over shallow modules.** Prefer fewer modules with rich internals and simple interfaces over many thin wrappers.
- **Keep implementation decisions abstract.** No file paths or code in the PRD — it ages well.

## Next Step

Once the PRD is submitted, suggest: "When ready to break this into implementation tickets, ask me to **convert the PRD to issues**."

## Additional Resources

- **`references/prd-template.md`** — PRD template with all required sections
