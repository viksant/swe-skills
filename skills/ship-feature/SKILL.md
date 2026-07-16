---
name: ship-feature
description: >
  Use when shipping a LARGE, multi-file feature that needs the full
  frame -> architect -> plan -> build discipline with an ADVERSARIAL REVIEW
  BOARD at EVERY step: every artifact (frame, architecture, plan, code) goes
  through a blue team (audits/defends it) -> a red team (refutes the blue =
  the reviewer of the reviewer) -> a synthesis (you arbitrate), writing a
  resumable dossier as it goes. It ORCHESTRATES the existing flow skills
  (design-brainstorm, architect-design, write-plans, subagent-build,
  deep-review, senior-review) — it does NOT reimplement them. Triggers:
  "ship this feature", "big feature end-to-end", "frame it, design it, plan
  it, build it with review at each step". NOT for: a small/localized change
  (< ~5 files — run /swe-skills:write-plans directly), pure bug investigation
  (use systematic-debugging), or when you only need one phase (invoke that
  skill directly). Heavy, user-invoked, with human gates and side effects —
  do NOT auto-invoke.
allowed-tools: Read, Grep, Glob, Bash, Task, Write, AskUserQuestion, TodoWrite
model: opus
disable-model-invocation: true
---

> **Core:** A big feature is not "implemented" — it is investigated, designed with
> evidence, planned, and built with a safety net, and EACH of those artifacts is put
> before a blue team (that defends it) and a red team (that refutes it), with an arbiter
> who reconciles. Multi-level adversarial review is not just for the code: it is for every step.
> **The reviewer of the reviewer:** the red team does not review the artifact head-on — it
> reviews the blue's AUDIT (hunts its false positives and its blind spots). The arbiter (you)
> reviews both. They are teams working together, not a linear checklist.
> **Reuse > reinvent:** each phase DELEGATES to an existing artifact
> (`/swe-skills:architect-design`, `/swe-skills:write-plans`, `/swe-skills:subagent-build`,
> `/swe-skills:deep-review`, the `design-brainstorm` skill) and the board reuses the
> host's review agents. This skill is the GLUE (sequence + board + dossier + gates), not a copy.
> **Final test:** *"If a hostile red team attacks EVERY artifact of this feature — the frame,
> the architecture, the plan, the code — does any real defect survive the blue-vs-red cross?"*
> If yes, you are not done.

# Ship Feature — Adversarial Review Board at Every Step

**Request:** "$ARGUMENTS"

---

## 0. CROSS-CUTTING POSTURE — NO SYCOPHANCY (applies to the WHOLE pipeline)

In EVERY phase and EVERY board synthesis:
- **Do NOT** open with "Great / Perfect / You're right". Open with the verdict.
- **CONTRADICT** the user and any agent when the evidence supports it — cite `file:line`, a
  benchmark, or an AOSA chapter.
- **NEVER fabricate** behavior, paths, lines, or numbers. Unverified: *"I don't know / I can't
  confirm without reading X"*.
- **QUESTION** every "I assume that…" from the user BEFORE building on it (user claims are
  hypotheses until verified against the code).
- **DEMAND SYSTEMIC FIT and SURFACE existing-system defects:** each design artifact must mimic
  the repo's patterns/vocabulary (not an island), and every defect of the current system found
  during discovery is stated CLEARLY and separately — the human can be wrong; do not fix it
  silently or bury it.

---

## 1. THE PIPELINE + THE DOSSIER

```
F0 TRIAGE -> F1 FRAME -> F2 ARCHITECT -> F3 PLAN -> F4 BUILD -> [F5 DEEP-REVIEW] -> [F6 CLOSE]
             brainstorm  architect-design write-plans subagent-build deep-review      verify + refuter
             '-- each phase ends in an ADVERSARIAL REVIEW BOARD (section 2) + a human gate --'
```

| Phase | Delegates to | Writes to dossier | Mandatory |
|-------|--------------|-------------------|-----------|
| F0 Triage | (this skill) | `00-index.md` | yes |
| F1 Frame | `design-brainstorm` skill (+ research fan-out) | `01-frame.md` | yes |
| F2 Architect | `/swe-skills:architect-design` | `02-architecture.md` | yes |
| F3 Plan | `/swe-skills:write-plans` | the plan file (referenced) | yes |
| F4 Build | `/swe-skills:subagent-build` | `04-build-log.md` | yes |
| F5 Deep-review | `/swe-skills:deep-review` | `05-deep-review.md` | opt-in / auto |
| F6 Close | `verification-before-completion` + a fresh refuter | `06-closeout.md` | opt-in / auto |

### The DOSSIER — the workflow's memory (lives in the host project)

```
.claude/features/<YYYY-MM-DD>-<slug>/
  00-index.md          # state: current phase, decisions, board verdicts, pointers, surfaced EXISTING-SYSTEM FINDINGS (not orphaned)
  01-frame.md          # problem, scope IN/OUT, VERIFIABLE success criteria + Board section
  02-architecture.md   # architect-design deliverable (incl. SYSTEMIC FIT + EXISTING-SYSTEM FINDINGS) + Board section
  04-build-log.md      # tasks, verdicts, real verification
  05-deep-review.md    # (if active) multi-agent report + Board section
  06-closeout.md       # (if active) close-out vs F1 success criteria
```

> Each `0X-<phase>.md` ends with an **`## Adversarial Review Board`** section holding that
> phase's blue-vs-red reconciliation. `/swe-skills:write-plans` writes the plan file in its own
> place; the index references its path. The dossier is process-state (NOT a code abstraction ->
> it does not violate YAGNI): it survives context compaction and lets a fresh Claude resume at
> the exact phase.

---

## 2. THE ADVERSARIAL REVIEW BOARD (the core of the framework)

**Runs at the end of EVERY phase, over the artifact that phase produced. FULL board always**
(maximum scrutiny — not proportional to risk). It inherits the canonical pattern of
`/swe-skills:senior-review` (blue `senior-code-auditor` -> red `red-team-auditor` -> synthesis),
generalized from "code" to "any phase artifact".

### The pattern (4 roles + convergence)

```
1 PRODUCER (blue)  -> the phase artifact (frame / architecture / plan / code).
2 AUDITOR (blue)   -> a FRESH agent that defends a verdict on the artifact, with evidence
                     (file:line / AOSA citation / a number with pedigree). A well-founded
                     PASS ("it is correct BECAUSE X") is a valid verdict.
3 RED TEAM (reviewer of the reviewer) -> fresh agent(s) that attack the artifact AND the blue's
                     audit: they refute its false positives and hunt its blind spots (the PASSes).
                     Dissent WITH evidence. They do NOT decide the verdict.
4 SYNTHESIS (arbiter = YOU, main thread) -> reconcile blue vs red. Neither blue nor red blocks
                     alone. Document each reconciliation (what blue said, what red said, who won
                     and why). Verdict: PASS / NEEDS_FIX / BLOCK.
5 CONVERGENCE -> WHILE verdict != PASS: the PRODUCER fixes ONLY what was flagged -> re-run the
                     board on the fix -> re-synthesize. Max 3 rounds; if it does not converge ->
                     ESCALATE to the user (do not force a PASS).
6 HUMAN GATE -> present the artifact + the reconciled verdict. The user approves.
```

### Hard rules of the board (inherited from red-team-auditor + /swe-skills:senior-review)

- **Agents ALWAYS fresh** (`Task`), never your contaminated context as a reviewer.
- Sequence blue -> red (red needs the blue's report to counter-weight it); the red specialists
  run IN PARALLEL with each other (one message, several `Task` calls).
- **Every dispute/finding demands evidence:** `file:line` + reproduction/trace, or a citation
  (AOSA/doc/benchmark), or a number with pedigree. No evidence -> discarded before it enters the synthesis.
- **The red team is NOT contrarian by reflex.** Whatever survives its attack it CONFIRMS
  explicitly (raises confidence). Inventing disputes = forbidden noise.
- **BLOCK requires reproducible evidence that survived the cross.** Neither blue nor red blocks alone.
- The orchestrator (you) does NOT delegate the synthesis — you are the arbiter. After synthesizing,
  WRITE the reconciliation to the dossier and drop that context.

### Board composition by phase (agent reuse)

| Phase | AUDITOR (blue) | RED TEAM (reviewer of the reviewer) | Synthesis |
|-------|----------------|-------------------------------------|-----------|
| **F1 Frame** | `Task(subagent_type="general-purpose")`: *"audit 01-frame.md — real problem or symptom? are the success criteria verifiable and complete? is scope well bounded, no creep? does the frame account for how it FITS the existing system (not an island)?"* | `Task(subagent_type="red-team-auditor")` (attacks assumptions/criteria) ∥ `Task(subagent_type="risk-assessor")` (which risk/edge did the frame miss?) | orchestrator |
| **F2 Architect** | `Task(subagent_type="battle-tested-architect")`: *"is each proposed pattern battle-tested REAL (company + scale + AOSA), or a blog post? is the Clean-Arch dependency direction respected? does the piece MIMIC the repo's patterns/vocabulary or is it an island? is the EXISTING-SYSTEM FINDINGS report present?"* | `Task(subagent_type="security-guardian")` ∥ `Task(subagent_type="async-performance-guardian")` ∥ `Task(subagent_type="risk-assessor")` ∥ `Task(subagent_type="impact-analyzer")` — each attacks the design from its angle (scales 10x? race? blast radius? attack surface?) | orchestrator |
| **F3 Plan** | `Task(subagent_type="general-purpose")`: *"audit the plan file — executable without asking? complete steps with verification + rollback? numbers with pedigree? untouchable invariants present?"* | `Task(subagent_type="red-team-auditor")` (gaps, missing invariants, magic numbers) ∥ `Task(subagent_type="impact-analyzer")` (blast radius the plan does not cover) | orchestrator |
| **F4 Build** | `senior-code-auditor` (run by `/swe-skills:senior-review` inside subagent-build) | `red-team-auditor` + specialists (run by subagent-build) | `/swe-skills:senior-review` (do NOT duplicate: subagent-build ALREADY has the per-task board + the final one) |
| **F5 Deep-review** | `/swe-skills:deep-review` (already multi-agent = blue panel) | `Task(subagent_type="red-team-auditor")`: *"attack deep-review's findings — false positives? which blind spot did the panel miss?"* | orchestrator |

> For DESIGN phases (frame / arch / plan) code-specific agents cannot operate on a doc -> the blue
> is `general-purpose` / `battle-tested-architect` with an audit prompt, and the red reuses
> `red-team-auditor` (its adversarial philosophy is generic) + the risk specialists with an
> **adversarial** prompt ("PROVE it got it wrong", not a neutral review). F4 stands up NO board of
> its own: subagent-build already brings it.

---

## 3. MODE OF OPERATION

- **Scope (configurable):** by default the core F0 -> F4; **`--deep`** or auto-escalation enables
  F5 + F6. Auto-escalate if it touches the CRITICAL heuristic (security/auth, data-loss/destructive
  ops, money/billing, boot/config, or a public API/contract) or 3+ subsystems (announce it in F0).
- **Board:** FULL at every gate of the phases that run (regardless of risk).
- **STRICT gates:** at the end of EACH phase, after the board synthesis, STOP and wait for the
  user's OK (`AskUserQuestion`: Continue / Revise / Adjust / Abort). **Non-negotiable:**
  `[CRITICAL CONFIRM]` (F3) and the final commit (F6).

---

## 4. PHASE 0 — TRIAGE & DOSSIER INIT

1. **Large feature?** If < ~5 files / a localized change -> STOP and redirect to
   `/swe-skills:write-plans` directly. Do not stand up this pipeline (with a full board x5) over
   something trivial (YAGNI).
2. Load the project's CLAUDE.md / conventions into context.
3. Create the dossier: `D=$(date +%Y-%m-%d); mkdir -p ".claude/features/${D}-<slug>"`.
4. Critical-path triage (auto-escalation F5/F6): grep for security/auth/money/billing/data-loss/
   boot-config surfaces; if the host defines `<project>/.claude/REVIEW_TIERS.md` use its tier
   assignments, else the CRITICAL/NORMAL/LOW heuristic; count the subsystems touched.
5. Write `00-index.md`: feature, scope, critical paths, current phase.

**GATE:** present the triage. Wait for OK. (F0 has no board — it produces no design artifact to refute.)

### RESUME mode (continuing a feature in progress)

If the request is a CONTINUATION ("continue", "pick up where it was left") AND
`.claude/features/<dir>/` exists with the feature's dossier:

1. Read `00-index.md` + the most advanced `0X-<phase>.md` (for F4: `04-build-log.md`) and
   determine the exact phase and the next task.
2. **SKIP the phases already closed with a board PASS** — do not re-run F0-F3 or re-stand-up their
   boards: their artifacts and reconciliations are already in the dossier.
3. **Do NOT repeat verification already done in the same session** (e.g. via a handoff load:
   files, git, migrations). Re-verify ONLY the state the next task touches.
4. A `[CRITICAL CONFIRM]` previously recorded in the dossier/handoff still stands for the scope it
   covered; do not re-block within that scope. Outside it, ask for a new one.
5. Resume the loop of the current phase (for F4: the next subagent-build task with its normal
   per-task board). The per-phase human gates still apply.

---

## 5. PHASE 1 — FRAME -> board -> gate

1. **Produce:** invoke the `design-brainstorm` skill (one-question dialogue, HARD-GATE,
   delegates open questions to specialists). + a research fan-out `Task(subagent_type="Explore")`
   in parallel if it touches 3+ subsystems. Close with **VERIFIABLE success criteria** (not "make
   it work"). Write `01-frame.md`.
2. **BOARD (section 2)** with the F1 composition: blue audits the framing; red
   (`red-team-auditor` ∥ `risk-assessor`) attacks it; you synthesize. Converge until PASS.
3. Write the reconciliation into the `## Adversarial Review Board` of `01-frame.md`.

**GATE:** frame + board verdict. Wait for OK.

---

## 6. PHASE 2 — ARCHITECT -> board -> gate

1. **Produce:** invoke `/swe-skills:architect-design` with `<feature> — design over the approved
   frame at .claude/features/<dir>/01-frame.md`. It reads the frame (does NOT repeat discovery).
   Inherits AOSA + Clean Arch + 10x concurrency + structured reasoning (e.g. the
   `deliberate-thinking` skill) + brutal self-critique. Write `02-architecture.md`.
2. **BOARD (section 2)** with the F2 composition: blue `battle-tested-architect` ∥ red panel
   (`security-guardian` ∥ `async-performance-guardian` ∥ `risk-assessor` ∥ `impact-analyzer`).
   architect-design's self-critique is only the starting point — the red ATTACKS it externally.
   You synthesize. Converge.
3. Write the reconciliation into `02-architecture.md`.

**GATE:** architecture (section by section) + board verdict. Wait for OK. Disagreement -> iterate in
architect-design. **If architect-design surfaced EXISTING-SYSTEM FINDINGS, present them SEPARATE
from the design at this gate — the user decides what to do with them; they are not fixed inside
this feature unless the user asks.**

---

## 7. PHASE 3 — PLAN -> board -> gate

1. **Produce:** invoke `/swe-skills:write-plans` with `implement the approved architecture at
   .claude/features/<dir>/02-architecture.md`. Inherits its problem-to-execution pattern + its
   tier & invariants pass (numbers with pedigree). Leaves the plan file.
2. **BOARD (section 2)** with the F3 composition: blue audits executability/completeness; red
   (`red-team-auditor` ∥ `impact-analyzer`) hunts gaps, missing invariants, magic numbers, blast
   radius the plan does not cover. You synthesize. Converge.
3. **`[CRITICAL CONFIRM]` gate** if the plan touches a CRITICAL surface (write-plans fires it).
   Not skippable.

**GATE:** plan summary + board verdict (+ `[CRITICAL CONFIRM]` if applicable). Wait for OK.

---

## 8. PHASE 4 — BUILD (`/swe-skills:subagent-build`)

**Invoke `/swe-skills:subagent-build` with the plan file.** subagent-build ALREADY brings the full
board: per task -> 1 fresh subagent + a gate **spec -> quality -> red-team adversarial ->
domain/security** + real verification, and at the end **`/swe-skills:senior-review`** (blue
`senior-code-auditor` + red `red-team-auditor` + synthesis) over the whole diff. **Do NOT stand up
an extra board here** (it would duplicate subagent-build's). Summarize in `04-build-log.md`.

**GATE:** build-log + the `/swe-skills:senior-review` verdict. Wait for OK. If the scope is
core-only -> skip to a light F6 (close-out) and finish.

---

## 9. PHASE 5 — DEEP REVIEW -> board -> gate (opt-in / auto)

1. **Produce (blue panel):** invoke `/swe-skills:deep-review` with `<implemented feature> —
   files: <from the build-log>`. Multi-agent, feature-focused. A DIFFERENT lens from F4's
   senior-review (that asks "is the diff well written?"; this asks "is the feature well
   designed/integrated, does it scale, is it secure?"). Write `05-deep-review.md`.
2. **RED over the audit:** `Task(subagent_type="red-team-auditor")` attacks deep-review's findings
   (false positives + the panel's blind spots). You synthesize.
3. If a CRITICAL/HIGH survives -> back to F4 (subagent-build on the offending task). Do not close
   with open criticals.

**GATE:** report + reconciliation. Wait for OK.

---

## 10. PHASE 6 — CLOSE (opt-in / auto; core does a light version)

1. **Close the loop vs the F1 success criteria** (`01-frame.md`): for each criterion, evidence
   that it is met. No evidence = NOT closed.
2. **Real E2E** (the `verification-before-completion` skill): run the project's full test suite +
   typecheck/linter (detect the toolchain from the repo) and show the REAL output. (If you run
   integration tests against a live dev server, it may serve stale code until restarted — prefer
   in-process tests.)
3. **Final adversarial refuter** (if --deep/auto): `Task(subagent_type="red-team-auditor")`:
   *"Try to REFUTE that this feature is complete and correct vs the success criteria of
   01-frame.md. Guilty until proven innocent."* Disputes with evidence.
4. Write `06-closeout.md`: a criterion -> evidence table + the verification output + the refuter's
   verdict.

**FINAL GATE (non-negotiable):** do NOT `git commit`/`push` (the no-auto-commit rule — never commit
without explicit user approval). Present the close-out and offer: (1) review the diff · (2) commit
(the user confirms the message) · (3) leave as-is · (4) discard. The user chooses; you execute only
what they pick.

---

## 11. HARD RULES — STOP

- ❌ Reimplementing the content of architect-design / write-plans / subagent-build / deep-review /
  senior-review. They are **invoked**, not copied.
- ❌ Standing up an extra board in F4 (subagent-build already brings it) — it would be a redundant
  triple-review of the same diff.
- ❌ Being you (contaminated context) the blue or the red of a board. Reviewers are ALWAYS fresh
  agents (`Task`).
- ❌ Letting the blue or the red decide the verdict alone. The synthesis (you) reconciles with evidence.
- ❌ Accepting a red dispute without `file:line`/repro/citation, or a blue PASS without evidence.
  Empty judgment (in either direction) is discarded.
- ❌ Forcing a PASS after 3 rounds without convergence -> ESCALATE to the user.
- ❌ Advancing a phase without the human gate's OK, or with an open CRITICAL/HIGH.
- ❌ Skipping `[CRITICAL CONFIRM]` (F3) or auto-committing (F6).
- ❌ Opening a phase or a synthesis with praise (section 0). Verdict first.
- ❌ Designing a feature that ignores the repo's patterns (an island), or STAYING SILENT about a
  defect of the existing system found during discovery because "it is not what you asked for" —
  systemic fit and surfacing are mandatory.
- ❌ Editing the host's config / rules / hooks / CLAUDE.md "while you're at it" — out of scope
  unless the task is explicitly about them.

---

## 12. SUCCESS CRITERIA

1. Every artifact (frame, architecture, plan, code, feature) went through its board
   blue -> red -> synthesis with the reconciliation documented in the dossier.
2. No red finding survived without being resolved or downgraded with evidence; no blue PASS was
   left unattacked.
3. Every phase delegated to its real artifact (zero duplication of protocols).
4. The dossier lets a fresh Claude resume at the exact phase without asking.
5. `/swe-skills:senior-review` (F4) and — if active — deep-review (F5) clean; every F1 success
   criterion with evidence in `06-closeout.md`.
6. Nothing committed without the user's explicit go.
7. The feature FITS the repo's patterns (not an island) and every defect of the existing system
   found was surfaced for the user's decision — neither orphaned nor silently fixed.

**Quality metric:** *"A hostile red team attacked EVERY artifact of this feature and not a single
real defect survived; the feature does exactly what F1 promised — no more (scope creep) and no less."*

---

## 13. PROCEED

1. F0 — Triage: large feature? dossier + critical paths (auto-escalation F5/F6). **Gate.**
2. F1 — Frame: brainstorming + research -> `01-frame.md` -> **board** -> **Gate.**
3. F2 — Architect: `/swe-skills:architect-design` -> `02-architecture.md` -> **board** -> **Gate.**
4. F3 — Plan: `/swe-skills:write-plans` -> the plan file -> **board** (+ `[CRITICAL CONFIRM]`) -> **Gate.**
5. F4 — Build: `/swe-skills:subagent-build` (internal board + `/swe-skills:senior-review`) -> **Gate.**
6. F5 — Deep-review (if --deep/auto): `/swe-skills:deep-review` -> **red** -> **Gate.**
7. F6 — Close: verification + refuter vs the success criteria -> **Final gate (human commit).**

Starting PHASE 0 (Triage) for: **$ARGUMENTS**
