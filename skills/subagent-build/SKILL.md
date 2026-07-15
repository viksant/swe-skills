---
name: subagent-build
description: >
  Use when executing an already-written implementation plan task-by-task with maximum rigor:
  one fresh-context subagent per task, then an exhaustive multi-reviewer gate (spec, quality,
  adversarial, domain/security) with real per-task verification and a final
  /swe-skills:senior-review over the whole diff. Pairs with /swe-skills:write-plans (which
  authors the plan). Triggers: "build this plan", "execute the plan", "implement the plan file".
  NOT for: authoring the plan (that is /swe-skills:write-plans), or a trivial one-file change
  that needs no plan. Heavy and user-invoked — do not auto-invoke.
allowed-tools: Read, Grep, Glob, Bash, Task, TodoWrite, AskUserQuestion
model: opus
disable-model-invocation: true
---

> **Core:** A plan is only as good as its execution. Implement task-by-task with a FRESH
> subagent per task (no context pollution), and let NO task advance until every reviewer AND
> real verification pass. The plan comes from `/swe-skills:write-plans` — this skill executes it.
> **Final test:** "Could a hostile senior reviewer find a single real defect in this diff?"
> If yes, you are not done.

# Subagent-Driven Build

**Request / plan reference:** "$ARGUMENTS"

---

## PHASE 0 — PRECONDITIONS (always first)

```yaml
GATES (all must pass before any code):
  1. PLAN EXISTS:
     - Look for the plan (the file produced by /swe-skills:write-plans, or a path in $ARGUMENTS).
     - If none -> STOP. Tell the user: "No plan found. Run /swe-skills:write-plans first,
       then /swe-skills:subagent-build." Do NOT improvise a plan here — planning is
       /swe-skills:write-plans' job.
  2. CRITICAL GATE:
     - Classify every file the plan touches by risk. If the host project defines
       <project>/.claude/REVIEW_TIERS.md, use its assignments; else the neutral heuristic:
       CRITICAL = security/auth, data-loss/destructive, money/billing, boot/config, or a
       public API/contract; NORMAL = standard logic; LOW = docs/tests/cosmetic.
     - If any file is CRITICAL -> show the [CRITICAL CONFIRM] block (same as
       /swe-skills:write-plans) and WAIT for the literal "[CRITICAL CONFIRM]" from the user.
  3. BRANCH SAFETY:
     - Never start implementation on main/master without explicit user consent.
     - Offer an isolated worktree (optional, if your host supports one) for large/risky plans.
  4. CONVENTIONS / PLAYBOOKS:
     - Pre-load any subsystem conventions or playbooks the host documents (e.g. its docs/,
       CLAUDE.md, AGENTS.md) for the subsystems in scope, so subagents inherit the invariants.
```

---

## PHASE 1 — LOAD PLAN & DECOMPOSE

1. Read the plan ONCE. Extract EVERY task with its **full text + context** (don't make
   subagents re-read the plan — you curate exactly what each needs).
2. `TodoWrite`: one item per task, in dependency order.
3. For each task note: files, contract, `verification` command, pattern reference, invariants
   it must not break (from the plan's untouchable-invariants section + the playbooks).

---

## PHASE 2 — PER-TASK LOOP (the heart)

For EACH task, in order. **A task is DONE only when every gate below is green.**

### 2a. Dispatch the implementer (fresh context)

```yaml
Task:
  agentType: the implementer MUST be able to Edit/Write — native general-purpose (default) is
             the safe choice. A host-defined domain specialist may be used ONLY if it has
             Edit/Write tools (e.g. a security-guardian used as an implementer). Many
             domain <domain>-specialist agents are READ-ONLY (investigation/design only) —
             check their tools: use them to DESIGN the fix, then hand the distilled fix
             (file:line + exact change) to a general-purpose implementer. A read-only agent
             forced to edit via Bash is fragile — don't.
  model: cheap/fast for mechanical 1-2 file tasks · opus for integration / judgment / CRITICAL
  prompt MUST include:
    - The full task text + curated context (NOT "go read the plan")
    - Constraints: follow existing patterns (reuse > new); follow the project's config-access
      conventions (don't bypass its config layer); follow its comment/docstring conventions;
      NO git add/commit/push (that is the user's call)
    - Testing: use regression-safety-net to characterize existing behavior BEFORE touching it;
      use superpowers-test-driven-development (test-first) for new logic. Tests may be
      local/ephemeral per the project's conventions; run them with the project's test runner.
    - Money code (billing / quotas / payments): idempotency + atomicity, no "fix later"
    - Return a STATUS: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED + a summary
```

### 2b. Handle implementer status

| Status | Action |
|--------|--------|
| DONE | proceed to review |
| DONE_WITH_CONCERNS | read concerns; if correctness/scope -> resolve before review |
| NEEDS_CONTEXT | provide the missing context, re-dispatch (same model) |
| BLOCKED | context problem -> re-dispatch with more context; needs reasoning -> stronger model; too large -> split; plan is wrong -> escalate to user. NEVER retry the same model unchanged |

### 2c. EXHAUSTIVE REVIEW GATE (this is the "zero margin" part)

Capture the task's commit/diff range. Dispatch reviewers as **fresh subagents** (never your
own context). All run against the task diff; ALL must pass:

| # | Reviewer | Lens | Pass criteria |
|---|----------|------|---------------|
| 1 | **Spec compliance** (fresh general-purpose) | does it implement the task EXACTLY — nothing missing, nothing extra (YAGNI)? | every plan requirement met, zero scope creep |
| 2 | **Code quality** (fresh, `meticulous-code-review` lens) | bugs, edge cases, error handling, naming, dead code, maintainability | no Critical/Important open |
| 3 | **Adversarial** (`red-team-auditor`) | actively REFUTE that it's correct — silent failures, race conditions, boundary values, IDOR, regressions. Default to "guilty until proven innocent" | no real defect survives; disputes resolved with evidence |
| 4 | **Domain/Security** (conditional) | if the task touches auth/IDOR/billing/tenant isolation -> `security-guardian` + a matching `<domain>-specialist` if the host defines one; if async/concurrency -> `async-performance-guardian`; other domains -> the host's matching specialist, else native `general-purpose` | domain invariants intact |

Each finding is a hypothesis: reproduce it at file:line before accepting; evaluate red-team
disputes on evidence (it can false-positive). Apply `superpowers-receiving-code-review`.

### 2d. REAL per-task verification (not just at the end)

Run the task's own verification command from the plan, with the project's real toolchain
(its test runner, its typecheck, etc.), and show the **actual output** — per
`verification-before-completion`, never "should pass". Then `regression-safety-net`: confirm
previously-passing behavior still passes (no regression).

### 2e. CONVERGENCE GATE — no advance with open issues

```
WHILE any reviewer has an open Critical/Important finding OR verification is not green:
    the SAME implementer subagent fixes ONLY those findings
    re-run the failed reviewer(s) + re-run verification
NEVER:
    - advance to the next task with an open issue
    - "accept close enough" on spec compliance
    - mark done on the implementer's word alone (diff + verification are the evidence)
```

### 2f. Mark the task complete in TodoWrite. Next task.

---

## PHASE 3 — FINAL WHOLE-DIFF REVIEW

After ALL tasks: run the senior pipeline over the full session diff — do NOT trust the
per-task greens to compose cleanly:

- Invoke **`/swe-skills:senior-review`** (mechanical: lint/typecheck/tests/grep + blue
  `senior-code-auditor` + adversarial `red-team-auditor` + blue-vs-red synthesis).
- Any Critical/Important from the synthesis -> back to PHASE 2 for the offending task.

---

## PHASE 4 — E2E VERIFICATION (evidence, not claims)

Run the FULL suite + the FULL typecheck with the project's toolchain and show the REAL output.
If anything fails -> fix (PHASE 2 loop), don't proceed. (Note: if you run integration tests
against a live dev server, it may serve stale code until restarted — prefer in-process tests.)

---

## PHASE 5 — FINISH (no auto-commit)

- **Do NOT `git commit`/`push`** — that is the user's call (the no-auto-commit rule).
- Present: tasks completed, the final-review verdict, the verification output, and the diff
  summary. Then offer (the user chooses; you execute only what they pick):
  1. Review the diff together
  2. Commit (the user confirms the message) / open a PR
  3. Keep as-is
  4. Discard / revert
- If you used a worktree, only clean it up on explicit choice (merge or discard).

---

## RED FLAGS — STOP

- Improvising a plan instead of consuming /swe-skills:write-plans' plan
- Advancing a task with ANY open Critical/Important finding or red verification
- Trusting an implementer's "done" without the diff + verification as evidence
- Reusing your own (polluted) context as a reviewer instead of a fresh subagent
- Skipping the adversarial (red-team) pass because "it looks fine"
- Dispatching multiple implementers in parallel on overlapping files (conflicts) — and WATCH
  cross-cutting tasks (metrics/telemetry, logging, shared types, generated code): such a task is
  often DEFINED in one place but EMITTED/used from many, so it EDITS files other tasks own even
  when its stated locations list only the definition site. NEVER dispatch it in the same parallel
  wave as the task that owns the file where it emits: sequence it AFTER (declare an explicit
  `depends_on` toward that task) or partition the exact lines up front. (A metrics task run in
  parallel with the worker task it instruments is the classic collision -> a false "Critical"
  double-count.)
- Auto-committing/pushing (the no-auto-commit rule)
- Editing the host's config / rules / hooks as part of "the build" (out of scope unless the task
  is explicitly about them)

---

## SUCCESS CRITERIA

1. Every plan task implemented by a fresh subagent and individually verified.
2. Every task passed spec + quality + adversarial (+ domain/security where relevant).
3. Real per-task AND E2E verification output shown — zero failures.
4. Final /swe-skills:senior-review synthesis clean (no open Critical/Important).
5. Nothing committed without the user's explicit go.

**Quality metric:** "A hostile senior reviewer finds zero real defects in this diff."

---

Starting PHASE 0 (preconditions) for: **$ARGUMENTS**
