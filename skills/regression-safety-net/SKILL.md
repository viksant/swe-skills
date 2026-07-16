---
name: regression-safety-net
description: >
  Ephemeral test safety net that shields any real source-code change (refactor, debug,
  fix, implement) against regressions. Captures observable behavior BEFORE touching code,
  verifies it continuously DURING, CONFIRMS it end-to-end at the end, then deletes the
  scaffolding. Use when: refactoring, debugging, fixing a bug, changing an implementation,
  or simplifying code — any task that will leave a non-empty diff on source code. NOT for:
  reading code, documentation, research, or read-only review.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
model: opus
---

# Regression Safety Net

Shield a real source-code change against breaking what already worked, writing tests the
way a 50-year veteran does: against contracts, not implementation.

---

## Activation gate (read this FIRST)

This skill applies **only when you are about to MUTATE source code**. The trigger is the
*mutation*, not any particular command.

| Situation | Applies? |
|-----------|----------|
| Refactor of a module | **YES** |
| Debug / fix of a bug | **YES** |
| Implementing a feature that touches existing code | **YES** |
| A review that **escalates** into applying fixes | **YES** (once it starts touching code) |
| Reading code to explain / document | **NO** |
| Investigating / answering a question | **NO** |
| A purely read-only review (reports findings only) | **NO** |
| Generating docs, diagrams, a handoff | **NO** |

**Rule:** if `git diff` on source code is empty when the task ends, this skill should not
have activated. If you are going to leave a diff with real changes, it is MANDATORY.

---

## Escape hatch: intentional behavior change

If the user EXPLICITLY asks to change the observable behavior (not preserve it),
characterization tests **do not apply** — they would pin down the old behavior you are
about to throw away. In that case:

1. Declare it in one sentence: "This changes behavior by design; I'm writing tests for the
   NEW contract, not characterization."
2. Write tests for the NEW contract (these may GRADUATE to permanent).
3. The rest of the protocol (determinism, fakes, naming) stays the same.

This is rare. When unsure whether it's a refactor or a paradigm change → **ask the user**.

---

## The mental shift: test contracts, not code

The junior tests **what the code does**. The senior tests **what the system promises**.

> **Core rule:** if you can refactor the implementation without changing the observable
> behavior and your test breaks, your test is WRONG — it was coupled to internals.

```
BAD  -> test verifies _backoff_delay() was called with arg 4
GOOD -> test verifies that after a 429 the retry waits >= Retry-After and <= 30s
```

Refactor `_backoff_delay` and the BAD test explodes for no reason. The GOOD test survives.

---

## The two natures (decide which one you delete)

| Nature | When | Initial state | Destiny |
|--------|------|---------------|---------|
| **Characterization** (golden master) | Refactor: behavior is PRESERVED | **GREEN** on current code | **DELETED** at the end (it is scaffolding) |
| **Bug regression** | Debug/fix: behavior changes at the bug | **RED** (reproduces the bug) | **PERMANENT — never deleted** |

This reconciles "tests get deleted" with "a regression test per bug, forever":
- Characterization scaffolding for a refactor is ephemeral.
- A test that reproduces a real bug is that bug's tombstone and stays in the suite.

If, during a refactor, a characterization test uncovers a PRE-EXISTING bug, that specific
test GRADUATES to permanent (don't delete it) and you tell the user.

---

## Lifecycle (before / during / after / cleanup)

### Phase A — BEFORE (green before you touch anything)

1. **Map the observable contract** of the target code: inputs, outputs, side-effects,
   errors it promises to raise, invariants. Read the code COMPLETELY plus its callers
   (blast radius).
2. **Write the ephemeral suite** in a clearly-named throwaway dir (see conventions below),
   attacking from several angles (see the coverage checklist).
3. **Run it and demand GREEN** on the CURRENT code (without touching anything yet).
   - Refactor: if you can't get green, you don't understand the behavior yet → stop and study.
   - Debug/fix: the bug test must be RED here (it reproduces the failure); confirm it.
4. Mental snapshot: "this is what the system promises TODAY".

### Phase B — DURING (continuous and progressive)

- **One atomic change at a time.** After each change, run the relevant subset of the suite.
- At every phase boundary (finishing a method, a file), run the FULL ephemeral suite.
- Green → keep going. Red → either your change broke a contract (revert/adjust) or the test
  was coupled to internals (rewrite the test to the contract). **Never** proceed on red.

### Phase C — AFTER (end-to-end guarantee)

1. Full ephemeral suite **100% green**.
2. Also run the project's real suite for the affected area (not just the ephemeral one).
3. Closing fail-first discipline: for the key tests, **mentally/actually revert the change
   and confirm the test WOULD still be green** — if it stays green with and without the
   change, it proves nothing. A good characterization test passes with both equivalent
   implementations; a good regression test FAILS if you revert the fix.

### Phase D — CLEANUP (surgical deletion)

1. Delete the ephemeral dir (the characterization tests). Use `git rm` if they got tracked
   by mistake; normally they were never staged.
2. **GRADUATE to permanent** and MOVE into the project's real test tree any test that
   reproduces a real bug found. These are NOT deleted.
3. Verify: `git status` must be clean of the ephemeral dir. If anything remains, you're not done.
4. Report to the user: how many ephemeral tests you ran, how many graduated and why.

---

## Coverage checklist (risk-selective, not coverage-driven)

Attack the code from several angles, including cases the user didn't think of:

| TEST (high risk — invest here) | DON'T TEST (coverage theater) |
|---|---|
| Complex decision logic (if/else trees, paths A/B/C) | Trivial getters/setters |
| Failure paths (retry, circuit breaker, fail-open, timeout) | Framework code (routing, request wiring) |
| Edges (empty input, None, 0, -1, list of 1, TTL=0, rotated key) | Static config |
| Parameter invariants (timeout >= p99*2, pool size, batch size) | Data models with no custom validators |
| Contracts across boundaries (UseCase <-> Adapter) | One-line wrappers over an SDK |
| Concurrency / atomicity (locks, atomic scripts, skip-locked) | The obvious happy path that prod exercises anyway |

> **The happy path tests itself in production.** Bugs live at the edges. Invest there.

**Outside-the-box** (cases the user didn't ask for but the system will suffer): concurrent
input, reverse order, re-entry, idempotency, unicode/emoji in strings, type-boundary
values, a dependency dying mid-operation, the same input twice.

---

## The hard rules

1. **The test must be able to fail.** For a regression test: revert the fix and confirm RED
   before restoring. A test that passes against any code proves nothing.
2. **One conceptual assert per test.** Several `assert`s verifying ONE property: fine. Four
   distinct behaviors in one test: forbidden (when it fails you don't know which).
3. **The test name IS the spec.** Read it without the body and you know what it guarantees.
   `test_jwt_with_rotated_key_blocks_expired_not_anonymous`, not `test_auth_1` / `test_2`.
4. **Absolute determinism.** Zero `sleep()`, zero unfrozen clock reads, zero real network,
   zero dependence on execution order. A flaky test is worse than no test.
5. **Don't mock what you don't own.** Never mock a third-party SDK directly. Build a **fake
   at YOUR boundary** (the interface you own) that returns your domain type. That way the
   test doesn't lie about the real shape of a third-party API.
6. **Given-When-Then visible.** Setup on top, ONE action in the middle, verification at the
   bottom. Verbose and obvious > DRY and clever: the test is documentation.

---

## Contextual pyramid (many systems want a "trophy", not a "pyramid")

Many real systems are mostly coordinated I/O (databases, caches, queues, external APIs,
streaming). A unit test with everything mocked proves your mocks match your mocks. Correct
split:

- **Unit** where there is PURE logic with no I/O (decision trees, converters, parameter
  computation). Here be exhaustive and parametrized.
- **Integration (the bulk)** with real ephemeral dependencies (a containerized real database
  for queue/DB code — a mock lies to you about real concurrency semantics or the native
  types the real dependency enforces).
- **E2E** very few (one full flow).

**Property-based** testing for invariants IF a property-testing library is available in the
project (verify first). If it isn't: do NOT install one for an ephemeral suite; use a
table-driven parametrized test covering the edges by hand.

---

## Conventions (adapt to your project)

| Aspect | Guidance |
|--------|----------|
| Ephemeral dir | A clearly-named throwaway dir (e.g. `tests/_regression_guard/`); delete at the end; never commit |
| Test runner | Your project's test command, scoped to the ephemeral dir (detect it from the repo) |
| Fast subset during Phase B | Your runner's fast/unit subset |
| Encoding | Keep test files plain ASCII if your project requires it (no emojis/accents inside test files) |
| Multi-tenant | If the system is multi-tenant, use the correct tenant/isolation identifier consistently |

If you want to guard against an accidental commit, add the ephemeral dir to `.gitignore`
once. Prefixing the dir with `_` keeps it sorted apart and easy to delete unambiguously.

---

## What to reject (coverage theater)

A test that passes a happy path with the third-party SDK mocked and a generic name RAISES
the number, it doesn't LOWER the risk. Reject it. Filter before you call the suite good:

- Could this test fail WITHOUT the change? (if not, it proves nothing)
- Does it test the contract or the implementation? (does an innocent refactor break it?)
- Does it cover the failure path or only the happy one? (branch coverage, not line)
- Am I mocking a third-party SDK? (red flag — it should be a fake at your boundary)
- Is the name the spec, or is it `test_executor_2`?

---

## Related skills

- New code (not existing) → **test-first-development** (test first, watch it fail).
- Root cause of a bug before touching code → **systematic-debugging**.
- Reviewing the finished diff → **meticulous-code-review** / **verification-before-completion**.
