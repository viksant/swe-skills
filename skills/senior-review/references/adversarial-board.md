# Senior Review — Adversarial board (Layer 3 semantic + Layer 3b counter-weight)

Operational detail for Phases 5, 5.5, 5.6 — the blue -> red -> synthesis methodology that is the
core value of this review. Every `Task` prompt below is a template; fill the `<...>` slots from the
real session.

---

## Phase 5 — Layer 3 (semantic review) via `senior-code-auditor` — BLUE TEAM

Delegate to the specialized agent. This is the **blue team**: it defends a verdict by reading the
diff. Phase 5.5 will counter-weight it, so also hand it the Phase 4.5 output so its read is not
purely static.

```
Task:
  subagent_type: senior-code-auditor
  description: "Audit the session diff"
  prompt: |
    Audit this session.

    Branch: <current branch>
    Base: $BASE

    Diff:
    <full output of `git diff $BASE...HEAD`>

    Files changed:
    <output of `git diff --name-only $BASE...HEAD`>

    Stated objective of the session: <summarize what the user asked for>

    Dynamic analysis already done (Phase 4.5): <flows + edge cases + executions>

    Apply your audit protocol (classification -> numeric suspicion -> risk-category grep ->
    the mandatory questions -> tests first -> topological diff -> bug categories). Report in
    the format defined in your own prompt.
```

---

## Phase 5.5 — Adversarial counter-board (Layer 3b) — RED TEAM

The blue team (Phase 5) can have false positives (over-flags) and false negatives (comfort zone:
nobody looked at the code with hostility). This phase counter-weights it with **structured dissent**.
Risk-gated:

| Risk touched | Red-team composition |
|--------------|----------------------|
| **CRITICAL** | `red-team-auditor` (lead) + 1-2 counter-board specialists by hotspot, IN PARALLEL |
| **NORMAL** | `red-team-auditor` alone |
| **LOW** | Nothing |

### 5.5.1 Invoke the red-team-auditor (dissent lead)

```
Task:
  subagent_type: red-team-auditor
  description: "Counter-weight the session"
  prompt: |
    Counter-weight this session. Branch: <branch>. Base: $BASE.

    Report from the senior-code-auditor (blue team):
    <full output of Phase 5>

    Mechanical results (Phase 3): <compile/lint/typecheck/tests PASS/FAIL>
    Risk classification (Phase 2): <which file at which risk level>
    Dynamic analysis (Phase 4.5): <flows + edge cases + executions>

    Diff: <git diff $BASE...HEAD>
    Stated objective: <summary of what the user asked for>

    Apply your attacks. Dissent WITH evidence, confirm what survives, do NOT decide the verdict.
```

### 5.5.2 Invoke domain specialists as counter-weight (CRITICAL only)

IN PARALLEL with the red-team-auditor (one message, several `Task` calls), invoke the specialists that
match the touched hotspot. The prompt is **adversarial**, not a neutral review: their job is to attack
what the auditor took for granted IN THEIR DOMAIN.

| Hotspot touched | Counter-board agent | Attack angle |
|-----------------|---------------------|--------------|
| auth / JWT / identity / tenant isolation | `security-guardian` | The auditor assumed authorization is correct. Prove it false. |
| async / pools / latency / workers | `async-performance-guardian` | The auditor did not measure. Where does it degrade under load? |
| any other domain hotspot (queues, DB/migrations, billing/quotas, external connectors, cross-layer error contracts, ...) | a matching `<domain>-specialist` agent if the host project defines one, else native `general-purpose` | Attack the domain assumption the auditor took for granted: race, non-atomicity, broken idempotency, boundary value, contract that breaks a consumer, internals leaked in an error. |

Prompt for each specialist:
```
Task:
  subagent_type: <specialist, or general-purpose if the host has none for this domain>
  description: "Counter-weight <domain>"
  prompt: |
    Do NOT do a neutral review. You are an adversarial counter-weight. The senior-code-auditor
    declared this diff acceptable in what concerns <domain>. Your job is to DEMONSTRATE it was
    wrong: find the edge case / race / assumption it did NOT consider.

    Auditor report: <output of Phase 5>
    Diff (filtered to your domain): <relevant subset>

    Report ONLY with evidence (file:line + repro or trace). If after attacking honestly you find
    nothing, say so: "domain <X> holds."
```

**At most 2 specialists** (beyond that, cost with no return). Pick the ones most relevant to the diff's
dominant hotspot.

---

## Phase 5.6 — Synthesis & reconciliation (blue vs red)

You (the main thread) reconcile. Do NOT delegate this — you are the arbiter.

1. **Cross-check** each blue-team finding against the red-team refutations:
   - Refuted with valid counter-evidence -> **retract or downgrade** to an observation.
   - Confirmed after attack -> **keep**, raise confidence.
2. **Integrate** the red team's new blind spots (the ones the auditor missed):
   - With an executed reproduction -> enter the report at their severity.
   - Reasoned only (no repro) -> enter as NEEDS_FIX **at most**, never BLOCK (user decision:
     "propose, synthesis decides" — without a repro it does not block).
3. **Resolve risk disputes:** if the red team proved a LOW file was actually CRITICAL, re-run the
   adversarial grep (Phase 4) for that hotspot before closing.
4. **Decide the final verdict** with the consolidated evidence. Document EACH reconciliation (what blue
   said, what red said, who won and why).

Golden rule: a finding is BLOCK only if it has `file:line` + a concrete reproduction or trace that
survived the cross-check. Neither blue nor red blocks alone.
