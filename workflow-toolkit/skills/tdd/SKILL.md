---
name: tdd
description: This skill should be used when the user asks to "use TDD", "write tests first", "red-green-refactor", "test-driven development", "build this with tests", "fix this bug with TDD", or wants to implement features or fix bugs using a test-first approach.
---

# Test-Driven Development

Implement features and fix bugs using the red-green-refactor loop. Write one test, make it pass, repeat. Never write all tests first — work in vertical slices.

## Philosophy

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests should not break unless behavior changes. A good test reads like a specification — "user can checkout with valid cart" tells you exactly what capability exists.

See `references/tests.md` for good vs bad test examples and `references/mocking.md` for mocking guidelines.

## Anti-Pattern: Horizontal Slices

Never write all tests first, then all implementation. This produces tests that verify imagined behavior instead of actual behavior.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
```

Each test responds to what was learned from the previous cycle.

## Workflow

### 1. Planning

Before writing any code:

- Confirm with the user what interface changes are needed
- Confirm which behaviors to test and prioritize them
- Identify opportunities for deep modules (see `references/deep-modules.md`)
- Design interfaces for testability (see `references/interface-design.md`)
- List behaviors to test — not implementation steps
- Get user approval on the plan

Ask: "What should the public interface look like? Which behaviors are most important to test?"

Not everything can be tested. Focus testing effort on critical paths and complex logic, not every possible edge case.

### 2. Tracer Bullet

Write ONE test that confirms ONE thing about the system:

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This proves the path works end-to-end.

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:
- One test at a time
- Only enough code to pass the current test
- Do not anticipate future tests
- Keep tests focused on observable behavior

### 4. Refactor

After all tests pass, look for refactor candidates (see `references/refactoring.md`):

- Extract duplication
- Deepen modules — move complexity behind simple interfaces
- Apply SOLID principles where natural
- Consider what new code reveals about existing code
- Run tests after each refactor step

Never refactor while RED. Get to GREEN first.

## Checklist Per Cycle

- [ ] Test describes behavior, not implementation
- [ ] Test uses public interface only
- [ ] Test would survive an internal refactor
- [ ] Code is minimal for this test
- [ ] No speculative features added

## Next Step

Once the feature is implemented and tests pass, suggest: "When the codebase has grown enough to warrant it, ask me to **improve the architecture** to find deepening opportunities."

## Additional Resources

### Reference Files

- **`references/tests.md`** — Good vs bad test examples with code
- **`references/mocking.md`** — When to mock and designing for mockability
- **`references/deep-modules.md`** — Deep vs shallow module design
- **`references/interface-design.md`** — Interface design for testability
- **`references/refactoring.md`** — Refactor candidates after the TDD cycle
