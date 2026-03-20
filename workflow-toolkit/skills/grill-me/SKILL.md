---
name: grill-me
description: This skill should be used when the user asks to "grill me", "stress-test my plan", "challenge my design", "poke holes in this", "review my architecture", "play devil's advocate", "find the flaws", "what am I missing", or wants critical feedback on a plan, design, or idea before implementation.
---

# Grill Me — Design Interrogator

Interview the user relentlessly about every aspect of their plan until reaching shared understanding. Break the plan into categories and resolve dependencies between decisions one by one.

## Process

### 1. Identify the Plan

Ask the user to describe their plan, design, or idea in detail. If the plan is already in the conversation context, summarize the understanding and confirm before proceeding.

### 2. Categorize Decision Branches

Break the plan into categories. Common categories include:

- **Problem definition** — Is the problem clearly scoped? Who is affected? What happens if it's not solved?
- **Architecture** — What are the major components? How do they communicate? What are the boundaries?
- **Data model** — What data exists? How does it flow? What are the invariants?
- **User experience** — Who uses this? What are the key interactions? What happens on failure?
- **Edge cases** — What breaks? What happens at scale? What about empty states, concurrent access, partial failures?
- **Dependencies** — What does this depend on? What depends on this? What's the migration path?
- **Trade-offs** — What alternatives were considered? What was traded away and why?

Adapt categories to the plan. Not every plan is technical — the same rigor applies to product plans, process changes, or organizational decisions.

### 3. Interrogate Each Branch

For each category:

1. Ask one focused question at a time
2. Provide a recommended answer based on the codebase, context, or best practices
3. If the answer can be found by exploring the codebase (using Glob, Grep, Read), explore first and report findings instead of asking
4. Resolve dependencies between decisions before moving forward — do not ask about implementation details before the approach is settled
5. Push back on vague answers. "It depends" is not an answer — ask what it depends on

Keep the tone constructive but relentless. The goal is to surface blind spots, not to criticize. Challenge assumptions directly. If something sounds hand-wavy, say so.

### 4. Produce a Decision Log

After all branches are resolved, produce a structured decision log:

```markdown
## Decision Log

### Category: [Category Name]

| # | Question | Decision | Rationale |
|---|----------|----------|-----------|
| 1 | [Question asked] | [Answer agreed upon] | [Why this was chosen] |
| 2 | ... | ... | ... |

### Category: [Next Category]

| # | Question | Decision | Rationale |
|---|----------|----------|-----------|
| 1 | ... | ... | ... |

### Open Questions

- [Any unresolved items that need further investigation]

### Key Risks

- [Risks identified during the interrogation that the user should monitor]
```

### 5. Confirm and Close

Present the decision log to the user. Ask if anything was missed or if any decisions need revisiting. The interrogation is complete only when the user confirms the log is accurate.

## Guidelines

- **One question at a time.** Do not dump a list of questions. Each answer may change the next question.
- **Recommend answers.** For every question, provide a recommended answer. This accelerates the process and surfaces disagreements faster.
- **Use the codebase.** If exploring the repo would answer a question, do that instead of asking the user. Report findings, then ask the follow-up.
- **Resolve dependencies first.** If decision B depends on decision A, resolve A before asking about B.
- **Adapt to scope.** A quick feature gets 5-10 questions. A system redesign gets 30+. Match the depth to the stakes.
- **No softballs.** The value of this process is in the hard questions. If everything sounds fine, dig deeper — something is being overlooked.

## Next Step

Once the decision log is confirmed, suggest: "When ready to formalize this into a requirements document, ask me to **write a PRD**."
