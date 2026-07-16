# Testing Anti-Patterns

> **Core:** a test exists to check the CODE. The moment it starts checking your mocks
> instead, it inverts into theatre — green forever, protecting nothing. Every trap below is
> a variation on that one inversion: the test drifts away from real behavior and toward the
> scaffolding built around it.

**Read this when:** writing or changing tests, reaching for a mock, or tempted to add a
method to production code "just for the test". Companion to `SKILL.md` (in this directory):
TDD is what keeps you out of these traps; this catalog is what falling in anyway looks like.

## The Iron Law

```
TEST THE CODE, NOT THE SCAFFOLDING AROUND IT
```

Three corollaries, ordered by how often they bite:

1. Never assert on a mock — assert on what the real code *does*.
2. Never grow production code to serve a test — that belongs in test utilities.
3. Never mock a dependency you don't understand — learn what it does, then mock the least.

---

## 1 — Asserting on the mock instead of the behavior

**The trap:**
```tsx
// BAD — this only proves the mock rendered
test('renders the toolbar', () => {
  render(<Panel />);
  expect(screen.getByTestId('toolbar-mock')).toBeInTheDocument();
});
```

**Why it lies:** the assertion is true exactly when the mock is present and false when it is
absent — it tracks the mock's existence, never the component's behavior. Swap the real
`Toolbar` for a broken one and this test stays green.

**The fix:**
```tsx
// GOOD — render the real component and assert on real, observable behavior
test('renders the toolbar', () => {
  render(<Panel />);                       // don't mock the thing under test
  expect(screen.getByRole('toolbar')).toBeInTheDocument();
});
// If Toolbar MUST be stubbed for isolation, assert on Panel's OWN behavior
// with the toolbar present — never on the stub itself.
```

**Gate — before asserting on anything that came from a mock:**
> Ask: *am I checking real behavior, or just that my mock exists?*
> Mock existence → delete the assertion, or unmock and assert on a real role / output.

---

## 2 — Test-only methods smuggled into production code

**The trap:**
```ts
// BAD — teardown() exists only so tests can clean up
class ResourceManager {
  async teardown() {                       // reads as production API, isn't
    await this.client?.release(this.handle);
    // ...more cleanup that only tests ever call
  }
}

afterEach(() => manager.teardown());
```

**Why it lies:** production now carries a method no production path calls — dead weight that
*looks* live, is dangerous if ever invoked for real, and blurs who owns the resource's
lifecycle. The test's convenience became the code's liability.

**The fix:**
```ts
// GOOD — cleanup lives with the tests that need it
// ResourceManager has no teardown(); nothing in production needs one.

// test-support/cleanup.ts
export async function releaseResource(manager: ResourceManager) {
  const handle = manager.currentHandle();
  if (handle) await client.release(handle);
}

afterEach(() => releaseResource(manager));
```

**Gate — before adding any method to a production class:**
> Ask: *is this called only from tests?* → yes: it goes in test utilities, not the class.
> Ask: *does this class actually own this resource's lifecycle?* → no: wrong class, stop.

---

## 3 — Mocking a dependency you haven't understood

**The trap:**
```ts
// BAD — the mock removes the side effect the test relies on
test('rejects a duplicate registration', async () => {
  vi.mock('./registry', () => ({
    register: vi.fn().mockResolvedValue(undefined),  // no longer records anything
  }));

  await addEntry(entry);
  await addEntry(entry);   // should reject the duplicate — but nothing was recorded, so it won't
});
```

**Why it lies:** the real `register` had a side effect (it records the entry) that the whole
test depends on. Mocking it "to be safe" deletes that behavior, so the test passes for a fake
reason or fails somewhere baffling.

**The fix:**
```ts
// GOOD — mock the slow / external part, keep the behavior the test needs
test('rejects a duplicate registration', async () => {
  vi.mock('./remote-client');   // stub ONLY the slow network client

  await addEntry(entry);        // still recorded in the real registry
  await addEntry(entry);        // duplicate detected — real behavior exercised
});
```

**Gate — before mocking any method, STOP and answer three questions:**
> 1. What side effects does the REAL method have?
> 2. Does this test depend on any of them?
> 3. Do I actually know what this test needs to happen?
>
> Depends on a side effect → mock LOWER (the slow / external call), not the method the test needs.
> Not sure what the test needs → run it against the REAL implementation once, watch what has to
> happen, THEN add the least mocking at the right level.
> "I'll mock it to be safe" / "it might be slow" are not reasons — they *are* the anti-pattern.

---

## 4 — Partial mocks that fail silently

**The trap:**
```ts
// BAD — only the fields you happened to think of
const response = {
  status: 'ok',
  data: { id: '42', label: 'example' },
  // missing: the envelope real callers read (meta.requestId, meta.page, ...)
};
// blows up later — or worse, misbehaves quietly — when code reads response.meta.requestId
```

**Why it lies:** you mocked the shape you *imagined*, not the shape that *exists*. Downstream
code reading a field you left out breaks in integration while every unit test stays green —
the most expensive kind of false confidence.

**The rule:** mock the COMPLETE structure as reality returns it, not just the fields this one
test reads today.

**The fix:**
```ts
// GOOD — mirror the real payload in full
const response = {
  status: 'ok',
  data: { id: '42', label: 'example' },
  meta: { requestId: 'r-789', page: 1, total: 1 },  // every field the real source returns
};
```

**Gate — before hand-writing a mock payload:**
> Pull the REAL shape from a schema / type / recorded example first, then include EVERY field
> the system might read downstream — not just the ones this test touches. Uncertain? Include all
> documented fields. A partial mock fails silently; a complete one can't.

---

## 5 — Tests treated as an afterthought

**The trap:**
```
implementation: done
tests:          "later"
status:         "ready to test"
```

**Why it lies:** "ready to test" means untested. Tests are part of the implementation, not a
follow-up phase — and a feature with no failing-first test was never driven by one, so there
is no evidence it does what you think. TDD would have produced the test before the code existed.

**The fix:** run the loop from `SKILL.md` — failing test → minimal code → refactor → *then*
"done". "Done" without a test that once failed is a claim, not a result
(`Skill(skill="verification-before-completion")`).

---

## When the mock outgrows the test

If the mock setup is bigger than the logic it supports, that is the code telling you something:

- mock setup longer than the test body
- mocking more and more just to reach green
- the mock is missing methods the real object has
- the test breaks whenever the mock changes, not when behavior changes

**Ask:** *do we need a mock here at all?* A test against the REAL collaborators is often shorter
and truer than an elaborate mock. When a whole subsystem must be stood up realistically, that is
an integration test — hand it to `Skill(skill="exhaustive-testing")` rather than simulating the
world by hand.

---

## Why TDD keeps you out of all five

| TDD step | Trap it defuses |
|----------|-----------------|
| Write the test FIRST | forces you to name the real behavior under test → kills #5 |
| Watch it FAIL on real code | a mock-only assertion can't fail for the right reason → kills #1 |
| Write MINIMAL code | nothing speculative, so no test-only methods creep in → kills #2 |
| Use REAL dependencies until one hurts | you see what the test truly needs before mocking → kills #3, #4 |

If a test is checking a mock, TDD was skipped somewhere: a mock was added before the test was
ever watched failing against real code.

---

## Quick reference

| Anti-pattern | Tell | Fix |
|--------------|------|-----|
| Assert on the mock | assertion names a `*-mock` id | assert on a real role / output, or don't mock it |
| Test-only method in prod | method called only from test files | move it to test utilities |
| Mock without understanding | mocked away a side effect the test needs | understand deps, mock the lowest / slowest layer |
| Partial mock | payload has only the fields this test reads | mirror the complete real structure |
| Tests as afterthought | "implementation done, tests later" | test-first, then claim done |
| Mock outgrows test | setup longer than the logic | use real collaborators / integration |

## Red flags

- An assertion that names a `*-mock` test id
- A method that only ever appears in test files
- Mock setup that is more than half the test
- A test that goes red when you REMOVE a mock (it was testing the mock)
- Mocking "to be safe" / "it might be slow" with no measured reason
- You can't state, in one sentence, why this mock has to exist

## Bottom line

**A mock is there to isolate, never to be the thing you check.** If watching a test fail
reveals it can only ever fail *because of a mock*, you didn't test the code — you tested the
scaffolding. Assert on real behavior, or delete the mock and ask why it was ever there.
