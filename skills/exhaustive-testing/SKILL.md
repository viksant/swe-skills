---
name: exhaustive-testing
description: >
  Generates and executes production-grade exhaustive tests for a feature under
  development, driven by the current conversation context. Simulates real production
  conditions: concurrency, malformed input, network failures, edge cases, race
  conditions, and adversarial scenarios.
  Use when: user says "test this", "create tests", "write tests", "cover the edge
  cases", after implementing a feature, or before declaring a feature complete.
  NOT for: pure test-strategy planning with no execution, characterization tests
  written only to freeze existing behavior before a refactor, or throwaway prototypes.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
model: opus
---

# Exhaustive Testing

> **Core philosophy:** "If it can happen in production, it MUST be tested. If you think it can't happen, test it anyway."

## Why This Skill Exists

Production bugs come from scenarios nobody tested. This skill ensures:
- Every code path is exercised, including error paths.
- Edge cases are enumerated systematically, not guessed.
- Mocks simulate REAL behavior, not idealized behavior.
- Tests catch bugs BEFORE production does.

## The Iron Law

```
EVERY test must answer: "What production scenario does this prevent?"
If you can't answer that, DELETE THE TEST. It is noise.
```

## Mock vs Real Data

Two testing modes. Decide per dependency, not per file.

| Mode | When | Data source |
|------|------|-------------|
| **Mock** (default) | Pure logic, transformations, unit tests | Mocks, factories, fixtures |
| **Real data** | Authenticated endpoints, DB/adapter operations, end-to-end flows | The project's DB/cache/queue tooling; real secrets from the project's env |

Decision tree:

```
Is the test about...
- An endpoint behind auth?          -> REAL DATA (mint a real token, make a real request)
- A DB query or a data adapter?     -> REAL DATA (query the real store via the project's tooling)
- An end-to-end flow?               -> REAL DATA
- A pure function / transform?      -> MOCK
- A third-party API (payments,      -> MOCK (unless the user provides credentials)
  LLM, messaging, email)?
- Explicitly requested as real?     -> REAL DATA
- Unknown data source?              -> STOP and ask the user
```

Obtaining real data (adapt to the host project):
- **Primary store / cache / queue:** query it through the project's DB client, CLI, or an MCP server the repo exposes. Discover connection details from the project's config; never hardcode them.
- **Secrets** (signing keys, service tokens): read from the project's env/secrets file. Never inline a secret into a test.
- **Auth tokens:** mint a real token with the project's signing secret and realistic claims (subject, tenant id, role, expiry). Templates in `references/test-patterns.md`.

### When to Stop and Ask the User

Pause and ask when you:
- Cannot find a needed value in the project's tooling or env.
- Need a specific tenant/account/entity to test against.
- Don't know which endpoint or path to prioritize.
- Are missing credentials for a service.
- Are unsure whether a dependency should be exercised with real data.

---

## Phase 1: Feature Analysis (from conversation context)

Before writing any test, understand what you are testing:

```
1. READ the implementation (files created/modified in this conversation).
2. MAP the data flow: input -> processing -> output -> side effects.
3. IDENTIFY dependencies: DB, cache, queue, external APIs, other modules.
4. LIST every public function/method/endpoint that needs testing.
5. DETERMINE test type: unit, integration, or both.
6. DETERMINE data strategy: for EACH dependency, mock or real data (tree above).
7. If real data is needed, obtain it (project tooling) or stop and ask.
```

Feature decomposition template:

```markdown
## Feature Under Test: [name]

### Entry points
- [function/endpoint]: [what it does]

### Data flow
Input -> [step 1] -> [step 2] -> ... -> Output
              |            |
        [side effect] [side effect]

### Dependencies
- Datastore: [tables/collections/queries]
- Cache:     [keys, if any]
- Queue:     [topics/queues, if any]
- External:  [APIs, services]
- Internal:  [other modules called]

### State changes
- [what state is modified, and where]
```

---

## Phase 2: Edge-Case Enumeration (systematic, NOT random)

Use the BICEP framework to find edge cases by category:

| Category | What to test | Examples |
|----------|--------------|----------|
| **B**oundary | Limits, thresholds, transitions | 0, 1, max-1, max, max+1, empty, null |
| **I**nverse | Opposite of the happy path | Delete nonexistent, update deleted, query empty |
| **C**ross-check | Verify via an alternate path | Write then read; count matches length |
| **E**rror | Every failure mode | Network timeout, store down, invalid input, expired auth |
| **P**erformance | Under load/stress | Large payloads, many concurrent calls, slow responses |

The full mandatory checklist (input, state, async/concurrency, and multi-tenant
isolation) lives in `references/edge-cases.md`. Walk every item that applies; do
not cherry-pick. That exhaustiveness is what "exhaustive testing" means.

---

## Phase 3: Test-Writing Standards

Write behavior-focused tests. Code templates (file skeleton, factories, real-data
fixtures, and stack-agnostic mock patterns for DB / cache / queue / external service)
are in `references/test-patterns.md`.

Mock quality is what makes a suite catch real bugs:

**GOOD mocks (simulate reality):**
- Return realistic data structures, not just `true`/`false`.
- Simulate latency where it matters.
- Raise realistic exceptions (connection error, timeout), not a generic Exception.
- Track call counts and arguments.
- Respect state changes (a store mock remembers what was written).

**BAD mocks (misleading):**
- Return `true` for everything.
- Never raise.
- Return an empty object when the real response has ten fields.
- Mock the very thing under test (too high), or reimplement the real code (too low).

Assertion quality:

```
# WEAK (tells you almost nothing)
assert result is not None
assert len(result) > 0
assert "error" not in str(result)

# STRONG (specific)
assert result.status == "completed"
assert result.items == expected_items
assert store.insert.call_count == 1
assert store.insert.call_args[0][0] == expected_record
```

---

## Phase 4: Execute -> Analyze -> Fix -> Repeat (iterative loop)

This is NOT single-pass. Iterate until ALL tests pass AND the feature is correct.

```
RUN -> ANALYZE output -> TEST bug or CODE bug? -> FIX -> RE-RUN the whole suite
   (loop until all green)
```

Execute with the project's own test runner — detect it from the repo (the manifest,
lockfile, CI config, or existing test scripts). Capture the FULL output and read
every line. Do not skim.

Classify each failure:

| Failure | Meaning | Action |
|---------|---------|--------|
| Import / module-not-found | Wrong path or missing dep | Fix the import or install the dep |
| Attribute / type error | Mock doesn't match the real interface | Update the mock to the real signature |
| Assertion (expected != actual) | Either the expectation is wrong OR the code has a bug | **Investigate which** |
| Timeout / async error | Async setup issue or a real timeout bug | Fix fixtures or the real code |
| Connection / store error | Missing mock; the test hit a real dependency | Add the mock |
| Test passes but shouldn't | Test isn't exercising the feature | Rewrite with stronger assertions |

**Test bug vs code bug** — decide for EACH failure:
- **TEST is wrong:** mock out of date, assertion expects the wrong value, incomplete setup, wrong import -> fix the test.
- **CODE is wrong:** wrong output for valid input, missing/incorrect error handling, unhandled edge case, race condition -> fix the code (this is the real payoff of testing).

Make the MINIMAL fix, then re-run the WHOLE suite (fixing one thing can break another).

Iteration limits:

| Iteration | Status | Action |
|-----------|--------|--------|
| 1-3 | Normal | Fix and re-run |
| 4-5 | Concerning | Stop. Are the tests testing the right thing? Is the approach wrong? |
| 6+ | Problem | **STOP. Ask the user.** Something is fundamentally wrong |

After iteration 5 without all-green, stop and report: tests passing/failing, the
persistent failures and why, whether it is a test-design or an architecture problem,
and 2-3 options for the user to choose.

### Phase 4b: Red-Green Verification (after all tests pass)

```
For each critical test:
1. Run it -> GREEN.
2. Break the key logic in the implementation -> it MUST go RED.
   If it stays GREEN, the test is useless -> rewrite with stronger assertions.
3. Restore the implementation -> GREEN again.
```

This proves the test actually catches the bug it claims to prevent.

### Phase 4c: Regression Check

Run the FULL suite, not just the new tests. If any pre-existing test broke, fix it
before proceeding. New tests must never break existing behavior.

---

## Phase 5: Code Fixes Found During Testing

Tests revealing real bugs is EXPECTED and VALUABLE. When a failure is a code bug:
fix the code, re-run all tests, and record it:

```
BUG FOUND BY test_[name]
Location: [file:line]
Issue:    [what was wrong]
Fix:      [what changed]
Impact:   [what would have happened in production]
```

Fix priority: **Critical** (data loss / security / crash) -> fix immediately;
**High** (wrong behavior, missing validation) -> this iteration; **Medium**
(unhandled edge case) -> this iteration; **Low** (cosmetic / logging) -> note it,
don't block completion.

---

## Phase 6: Final Review

Before declaring the tests complete, walk the full checklist (iteration results,
coverage, quality, production realism, red-green, regression, maintainability) and
produce the summary. Both the checklist and the output template are in
`references/final-review.md`.

---

## Integration with Workflow

```
Feature implementation
  -> Phase 1: analyze the feature from context
  -> Phase 2: enumerate edge cases (BICEP + full checklist)
  -> Phase 3: write production-grade tests
  -> Phase 4: iterative loop (run/analyze/classify/fix/re-run) until all green
  -> Phase 4b: red-green verify critical tests
  -> Phase 4c: regression check (full suite)
  -> Phase 5: document bugs found + fixes applied
  -> Phase 6: final checklist + report
```

The loop continues until ALL tests pass. If 6+ iterations, STOP and ask the user.

For the common failure modes and their fixes, see the troubleshooting table in
`references/final-review.md`.
