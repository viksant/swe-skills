# Exhaustive Testing — Final Review, Output Template, Troubleshooting

## Final review checklist

Walk this before declaring the tests complete.

**Iteration results**
- [ ] ALL tests pass (show the real runner output)
- [ ] Zero failures, zero errors, zero warnings
- [ ] Iterations to all-green recorded
- [ ] Code bugs found and fixed during testing listed

**Coverage**
- [ ] Every public function/method/endpoint has at least one test
- [ ] Every error path has a test
- [ ] Every branch in conditional logic is covered
- [ ] Every edge case from Phase 2 is tested

**Quality**
- [ ] Every test has a one-line docstring naming the production scenario it prevents
- [ ] Assertions are specific (not just "not null")
- [ ] Mocks simulate real behavior (real structures, real exception types)
- [ ] No test depends on another test's state
- [ ] No test uses `sleep()` for timing (use proper async/await or polling primitives)
- [ ] No hardcoded paths, ports, or environment-specific values
- [ ] Test names describe WHAT is tested, not HOW

**Production realism**
- [ ] Input data resembles real production data
- [ ] Error scenarios use the real exception types
- [ ] Timeouts match real production timeouts
- [ ] Concurrency levels are realistic

**Red-green**
- [ ] Critical tests verified: break code -> test fails -> restore -> test passes

**Regression**
- [ ] Full suite passes (no pre-existing test broken)

**Maintainability**
- [ ] DRY: shared setup in fixtures/factories
- [ ] Each test tests ONE thing
- [ ] Tests are independent (run in any order)
- [ ] No commented-out tests
- [ ] Test code is plain ASCII (no emoji in assertions)

**Real-data testing (if used)**
- [ ] Data strategy documented (mock vs real, per dependency)
- [ ] Real data obtained and verified against the live store via the project's tooling
- [ ] Auth token minted correctly (right algorithm, right claims, valid secret)
- [ ] Endpoints respond under real auth
- [ ] No secret or production id hardcoded in a test

---

## Output template

Deliver the results in this shape once the loop is all-green:

```markdown
## Exhaustive Test Summary: [Feature]

### Iteration summary
| Iter  | Run | Pass | Fail | Fixes applied         |
|-------|-----|------|------|-----------------------|
| 1     | X   | Y    | Z    | [test fix / code fix] |
| Final | X   | X    | 0    | All passing           |

### Bugs found in the implementation (fixed during testing)
| Bug | Location  | What was wrong | Impact if shipped |
|-----|-----------|----------------|-------------------|
| ... | file:line | ...            | ...               |

### Final results
| Category    | Count | Status   |
|-------------|-------|----------|
| Happy path  | X     | ALL PASS |
| Edge cases  | X     | ALL PASS |
| Error paths | X     | ALL PASS |
| Concurrency | X     | ALL PASS |
| Total       | X     | ALL PASS |

### Red-green verification
| Test | Green | Red (broken) | Green (restored) |
|------|-------|--------------|------------------|
| ...  | PASS  | FAIL         | PASS             |

### Regression
Full suite: X/X passing, 0 failures.
```

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Tests pass but the feature is broken | Tests don't exercise the real feature | Red-green verify: break the code, tests MUST fail |
| The same test fails across 3+ iterations | Wrong fix approach | Step back: is the test correct? Is the design sound? |
| Too many tests, hard to maintain | Testing implementation details | Test behavior via the public API, not internals |
| Tests are slow | Hitting a real store/network | Mock external deps; keep unit tests fast |
| Tests are flaky | Timing deps or shared state | No `sleep()`; isolate state; proper fixtures |
| Mocks don't catch real bugs | Mocks too permissive | Make them raise real exceptions, return real structures |
| High coverage but bugs still escape | Only happy paths tested | Apply BICEP + the full Phase-2 checklist |
| Iteration count keeps growing | Fundamental design issue | STOP at 6, report to the user; likely an architecture change |
| Fixing one test breaks another | Shared state or conflicting assumptions | Isolate state; each test must be independent |
