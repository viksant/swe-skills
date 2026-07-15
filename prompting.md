# Prompting protocol — self-application

> Triggered by the `inject-prompt-forge` hook (UserPromptSubmit) with a short reminder
> each turn; **this file is the detail you read ON DEMAND** when the request is
> substantive. If the request is trivial, ignore all of this and proceed.

## 1. Sufficiency gate (always first)

Before touching anything, classify your confidence to solve with what you have:

| Level | What it means | Action |
|-------|---------------|--------|
| **Sufficient** | You have the info to decide well | Proceed |
| **Marginal** | You're missing something non-critical | Proceed, but state your assumptions and verify early |
| **Insufficient** | You're missing info for a key decision | STOP and ask — don't guess |

It's a **qualitative** judgment, not a calculation (no numbers). Abstaining when info is
insufficient is already enforced by the `epistemic-honesty` hook; this gate just makes it
explicit BEFORE you start.

## 2. Framing

- **problem_type**: bug | feature | optimization | refactor | test | architecture
- **complexity**: simple | moderate | complex | architectural

The framing decides how much rigor to apply: a typo fix needs no decomposition; a
cross-cutting change does.

## 3. Context: read only what's relevant

Open ONLY the files directly involved (ideally ≤5). Expand to direct dependencies only if
needed. Exclude the noise: unrelated tests, global config, modules with no interaction,
generic docs. More irrelevant context = worse signal/noise ratio = higher risk of error.

## 4. Decomposition (only if complex/architectural)

Split the task into subtasks with:
- a **binary** success criterion (pass/fail) per subtask,
- dependency only on prior subtasks,
- verification before moving to the next.

Don't accumulate unverified changes. Reuse a planning workflow and `/context-implement` if the
size justifies it.

## 5. Success criteria

Binary and verifiable with a concrete command/test. No "make it work well" or "make it
fast" — that's not verifiable.

## 6. Final verification

Already wired: `completion-gate` requires verifying the touched code before closing.
Don't duplicate it here; just satisfy it.

---

> **Origin:** distilled from a meta-prompting framework (EDFL/ISR, information-theoretic),
> adapted from "generate a prompt" to "how to approach the task" (1 model, not 2). The ISR
> is used as a qualitative checklist (the sufficiency gate), never as a number.

## Accumulated prompting lessons
<!-- Add verified prompting lessons here over time. -->
