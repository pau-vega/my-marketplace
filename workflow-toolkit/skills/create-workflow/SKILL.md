---
name: create-workflow
description: This skill should be used when the user asks to "show my workflow", "what skills are available", "start a workflow", "create-workflow", "show the development process", or wants an overview of the available development workflow skills and when to use each one.
---

# Development Workflow

A guided development process from idea to implementation. Each skill handles one phase and suggests the next step when complete. Use them in order for a full workflow, or jump to any skill individually.

## The Workflow

```
1. grill-me          Stress-test an idea or design
       ↓
2. write-a-prd       Formalize into a requirements document
       ↓
3. prd-to-issues     Break the PRD into GitHub issues
       ↓
4. tdd               Implement issues using test-driven development
       ↓
5. improve-codebase-architecture    Refactor and deepen modules
```

## Skills

### 1. Grill Me

**When to use:** An idea or design needs to be challenged before committing to it.

**What it does:** Interrogates every aspect of the plan, one question at a time, with recommended answers. Produces a structured decision log.

**Trigger:** "Grill me on my plan to..."

---

### 2. Write a PRD

**When to use:** The plan is solid and needs to be documented as formal requirements.

**What it does:** Interviews about the problem and solution, explores the codebase, designs modules, and produces a PRD. Submits as a GitHub issue or markdown file.

**Trigger:** "Write a PRD for..."

---

### 3. PRD to Issues

**When to use:** A PRD exists and needs to be broken into implementable work items.

**What it does:** Breaks the PRD into vertical slice GitHub issues (tracer bullets), each cutting through all layers end-to-end.

**Trigger:** "Break down the PRD into issues"

---

### 4. TDD

**When to use:** Ready to implement a feature or fix a bug, test-first.

**What it does:** Guides the red-green-refactor loop — one test at a time, minimal code to pass, refactor when green.

**Trigger:** "Use TDD to build..."

---

### 5. Improve Codebase Architecture

**When to use:** The codebase has grown and needs architectural review.

**What it does:** Explores the codebase organically, surfaces friction, proposes module-deepening refactors, and creates RFC issues with multiple interface design options.

**Trigger:** "Improve the architecture"

## Usage

Start at any point. Not every project needs all five steps — a quick bug fix might only need TDD, while a new feature benefits from the full pipeline. Each skill works independently.
