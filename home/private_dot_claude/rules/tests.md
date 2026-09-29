---
description: Testing rules that apply to every project regardless of language.
paths: 
- ./**/tests
- ./tests
- ./src/tests
- ./**/src/tests
- ./**/*.test.js
- ./**/*.test.php
- ./**/*.test.ts
---

# Testing Rules

All tests belong in `./tests` in the project directory OR package directory (if its a monorepo). If there's no tests written yet, create the directory.

If there's a test file (e.g. `*.test`) outside of the folder, move it. 

---

## 1. When to Write Tests [MUST]

**MUST write tests for:**
- Every public API or function with business logic
- Every bug fix — the test reproduces the bug before the fix, passes after
- Every edge case explicitly mentioned in requirements
- Any code that has caused a bug before

**SHOULD write tests for:**
- A new feature BEFORE writing the actual feature code (Test-Driven Development)
- Non-trivial private functions with complex logic
- Integration points between components or services

**Do NOT test:**

- Framework boilerplate (getters/setters, auto-generated code)
- Third-party library behavior
- Implementation details that change without behavior changes

---

## 2. Test Names [SHOULD]

Test names describe behavior, not implementation.

Format: `should [expected behavior] when [condition]`

```
// Correct
should return null when user does not exist
should throw unauthorized when token is expired
should retry three times before failing

// Forbidden
testGetUser
test1
getUserTest
```

---

## 3. Test Structure [SHOULD]

Every test follows Arrange-Act-Assert:

```
// Arrange — set up state and inputs
// Act — call the thing being tested
// Assert — verify the outcome
```

One assertion per test when possible. Multiple assertions are acceptable when they verify the same behavior from different angles — not when they test different behaviors.

---

## 4. Mocks vs Integration [SHOULD]

**Use mocks when:**

- Testing a unit in isolation from its dependencies
- The dependency is slow (network, DB, filesystem)
- You need to simulate error conditions that are hard to reproduce

**Use integration tests when:**

- Verifying that two or more components work together correctly
- Testing database queries (use a real test DB, not mocks)
- Testing API contracts end-to-end

Do not mock what you own. If you control the code, test the real thing.

---

## 5. Test Coverage [SHOULD]

Coverage is a signal, not a goal. 100% coverage with meaningless tests is worse than 60% coverage with meaningful ones.

**SHOULD:**

- All critical paths have tests before a feature is marked complete
- Unhappy paths (errors, edge cases) have at least as much coverage as happy paths
- New code does not reduce overall test coverage

**Do NOT:**

- Skip tests to ship faster and "add them later" — they do not get added later
- Write tests that only verify the happy path
- Comment out or skip failing tests to make the build pass

---

## 6. Never Commit a Red Suite [MUST]

A commit is a claim that the work is sound. Committing with failing tests breaks that claim and hides the failure in history.

**MUST:**

- Before every commit, run the tests. If any test fails, do NOT commit.
- If the failure cannot be fixed, STOP and report it (BLOCKED) — leave the work staged, do not commit around it.
- This applies to delegated work too: a subagent that cannot get the suite green reports BLOCKED. It does NOT commit a red suite and hand it back.

**MUST NOT:**

- Commit with `--no-verify` or by disabling a pre-commit test hook to get past a failure.
- Skip, comment out, or `.only`/`.skip` a failing test to make the commit go through. (See §5.)

The commit gate is: **full suite green AND typecheck clean.** Nothing less passes.

---

## 7. The Whole Suite Is the Gate [MUST]

"The tests pass" means the ENTIRE suite passes in one run — never a single file checked in isolation.

**Why:** test files share global state — a module mock, a registered stub, an env var, a singleton. A file that is green alone can turn another file red when they run together (mock leakage across files is the classic case). Running one file hides exactly this class of bug.

**MUST:**

- Run the complete suite (e.g. `bun test`, not `bun test path/to/one.test.ts`) before claiming pass or committing.
- Reproduce any failure with the full suite before believing it fixed — "passes on its own" is not fixed.
- When a shared dependency is mocked in more than one file, register the mock ONCE in a global setup/preload, not per-file, so file order cannot change the result.

---

## 8. Test as Documentation [RECOMMENDED]

Tests describe how the system behaves. A new developer reading the test suite should understand what the system does without reading the implementation.

If a test is hard to understand, the test (or the code it tests) is probably too complex.

## 9. Tests as reusable test functions [RECOMMEND]
- Extract the test as a reusable module/package when:
  - The test can be reused in another package. E.g. Within the same monorepo.
  - The test can be modularized and apply to any coding project to reinforce architecture patterns (e.g. no circular dependencies, builds).
