---
name: test-first-development
description: >
  Use when implementing a feature or bugfix and you want the test to drive the design —
  write the failing test FIRST, watch it fail for the right reason, then write the minimal
  code that passes. Triggers: "TDD", "test first", "write the test before", adding a new
  function/endpoint/component, reproducing a bug before fixing. NOT for: characterizing
  EXISTING code before a refactor (use regression-safety-net), generating a broad
  production-grade suite for a finished feature (use exhaustive-testing), or throwaway
  prototypes.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
model: opus
---

# Test-First Development (TDD)

> **Core:** a test you never watched fail proves nothing. Writing the test first is not a
> style preference — it is the only way to know the test *can* fail, and therefore the only
> way for a later green to mean anything. Keep the letter but drop the "watch it fail" gate
> and you have dropped the entire point.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote the code before the test? Delete it — all of it. Don't keep it "for reference", don't
peek at it while writing the test, don't paste it back. Re-derive it from the test. A test
written to fit code you already have is a *description* of that code, not a *check* on it.

## Which testing skill is this? (decide before you type a test)

Three skills write tests for three different reasons. Reach for the wrong one and the work
is wasted.

| You are… | The test… | Use |
|----------|-----------|-----|
| Building NEW code / fixing a NEW bug — you want the test to shape the design | **precedes** the code and drives its design | **this skill (TDD)** |
| About to refactor / debug / change code that ALREADY works | **freezes** current behavior, then is deleted afterward | `Skill(skill="regression-safety-net")` |
| Hardening a FINISHED feature against production reality (concurrency, malformed input, races, adversarial input) | **stresses** existing behavior to breaking | `Skill(skill="exhaustive-testing")` |

TDD tests one wished-for behavior at a time and lets that shape the interface. It is *not*
where you enumerate every edge case (that is `exhaustive-testing`), and *not* where you pin
down code you didn't write (that is `regression-safety-net`).

## The cycle: Red → Green → Refactor

| Step | Do | Gate |
|------|-----|------|
| **RED** | Write ONE minimal failing test for the next behavior. Name it after the behavior. | — |
| **Watch it FAIL** | Run it. It must FAIL on the assertion — the behavior is missing. | **MANDATORY** |
| **GREEN** | Write the least code that makes it pass. Nothing speculative. | — |
| **Watch it PASS** | Run it again. New test green, every old test still green, output clean. | **MANDATORY** |
| **REFACTOR** | Improve names / kill duplication with the suite green. Add NO behavior. | stay green |

Then loop back to RED for the next behavior. One behavior per lap.

### The two gates ARE the skill

**Watch it FAIL — for the RIGHT reason.** A failure only counts if it is an *assertion*
failure caused by the missing behavior. A `NameError` / `ImportError` / compile error is
indistinguishable from a typo in the test — so make the symbol resolve first (a stub that
returns a wrong-but-valid value or raises `NotImplementedError`), then watch the assertion
fail. If the test PASSES on its first run, you are describing behavior that already exists:
the test is wrong, or this isn't new code (see the contrast table above).

**Watch it PASS — on real code, in-process.** Import the module under test and call it
directly. Do NOT prove GREEN by hitting a running dev server: without a guaranteed rebuild
it can serve a STALE build and hand you a green that describes yesterday's code. In-process
tests see exactly the code you just wrote.

**Typed languages:** the typecheck is part of the loop. Run typecheck + tests on every lap.
A red typecheck is a valid RED — but still land on a failing *assertion* before you write
the real body.

## Worked example (pure function, zero mocks)

Behavior wanted: `clamp` caps a value to a `[low, high]` range.

**RED** — one behavior, the name is the spec:

```python
from rangeutil import clamp

def test_clamp_caps_a_value_above_the_maximum():
    assert clamp(12, low=0, high=10) == 10
```

**Watch it FAIL (right reason).** First run: `ImportError` — ambiguous, could be a typo. So
add the smallest stub that makes the symbol resolve:

```python
def clamp(value, low, high):
    raise NotImplementedError
```

Run again → the test now fails on the *assertion* (the capping behavior is missing). *That*
is a real RED.

**GREEN** — least code that passes, nothing more:

```python
def clamp(value, low, high):
    return min(max(value, low), high)
```

**Watch it PASS.** New test green, suite green, output clean.

**REFACTOR.** Nothing to clean here. The next lap adds the *next* behavior as its OWN test
(`test_clamp_raises_a_value_below_the_minimum`,
`test_clamp_returns_a_value_already_in_range`) — never three assertions crammed into one.

## Good tests

| Quality | Looks like | Smells like |
|---------|-----------|-------------|
| **Minimal** — one behavior | `test_clamp_caps_above_the_maximum` | `test_clamp_above_and_below_and_in_range` ("and" → split it) |
| **Clear** — the name IS the spec | reads as a sentence about behavior | `test_1`, `test_clamp_works` |
| **Real** — exercises real code | real inputs → real return value | asserts on a mock's call count |

> Mocks that end up testing the mock, test-only methods bleeding into production code,
> partial mocks that fail silently → read `testing-anti-patterns.md` (in this directory)
> BEFORE you reach for a mock.

## Fixing a bug = TDD in reverse gear

A bug fix is still test-first: the reproduction is your RED. But do NOT guess the fix from
the symptom. For anything non-trivial, run `Skill(skill="systematic-debugging")` first — its
Phase 4 produces "a failing test case (simplest reproduction) BEFORE fixing", and that
artifact IS this skill's RED gate:

1. Root-cause the bug with `Skill(skill="systematic-debugging")` (Phases 1–3).
2. Write the failing test that reproduces it → **watch it fail** for the real reason.
3. Apply the minimal fix → **watch it pass**.
4. The test now guards that bug forever and documents what broke.

Jump straight to step 2 only when the root cause is already proven.

## Common rationalizations

| Excuse | Reality |
|--------|---------|
| "Too trivial to test" | Trivial code still breaks, and the test costs 30 seconds. |
| "I'll add the tests after" | Tests written after code pass on the first run — which proves nothing about whether they *can* fail. |
| "The tests are throwaway here anyway" | Shipped or not, the test still drives YOUR red→green lap. The value is watching it fail, not committing it. |
| "I already tested it by hand" | Manual ≠ repeatable. No record, can't re-run, gone tomorrow. |
| "Deleting hours of code is wasteful" | Sunk cost. Unverified code is the actual waste. |
| "TDD is dogma; I'm being pragmatic" | Test-first is faster than debugging the same code in production. |

## Red flags — STOP and restart the lap

- Production code exists and no test failed for it first
- Test written after the implementation · test passed on its very first run
- You can't say WHY the test failed · "I'll add tests later" · "just this once"
- Celebrating a green from a dev server you never rebuilt
- "It's the spirit that matters, not the ritual" · "this case is different because…"

Any of these → delete back to the last real RED and run the lap again.

## When stuck

| Symptom | Move |
|---------|------|
| Don't know how to test it | Write the API you WISH existed in the test first, then build to it. Still stuck → ask the user. |
| The test is getting complicated | The *design* is complicated. Simplify the interface, not the test. |
| Have to mock everything to test it | The code is too coupled. Inject dependencies; see `testing-anti-patterns.md`. |
| It touches money / auth / destructive operations | High-stakes. Never ship a green you can't explain; get a second pair of eyes via `Skill(skill="senior-review")`. |

## Related skills

- `Skill(skill="systematic-debugging")` — root-cause a bug; its Phase-4 reproduction test is this skill's RED.
- `Skill(skill="regression-safety-net")` — freeze EXISTING behavior before a refactor (the mirror image of TDD).
- `Skill(skill="exhaustive-testing")` — broad adversarial suite once the feature is built.
- `Skill(skill="verification-before-completion")` — before claiming "done", prove the suite is actually green.
- `testing-anti-patterns.md` (this directory) — the mocking traps TDD is meant to keep you out of.

## Bottom line

```
Production code shipped  →  a test existed and FAILED first
No failing test first    →  not TDD, whatever else you call it
```

Where the test is local scaffolding rather than a committed artifact, the rule is unchanged:
no production code without a failing test first. End the lap on green — and let `git commit`
be a separate, deliberate step you take when asked, never a reflex to "save" a green.
