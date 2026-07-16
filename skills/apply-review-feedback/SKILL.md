---
name: apply-review-feedback
description: >
  Use when receiving code-review feedback — from the user, from an automated review
  agent/skill (a senior/blue-team auditor, an adversarial red-team auditor,
  meticulous-code-review, verify-claims), or from an external reviewer (GitHub PR) — before
  implementing any of it. Triggers: review findings to act on, "address this review", a
  disputed finding, feedback that seems wrong. NOT for: requesting or running a review, or
  general bug fixing (use systematic-debugging).
allowed-tools: Read, Grep, Glob, Bash
model: opus
---

> **Core:** A review finding is a HYPOTHESIS that carries a `file:line` — not a verdict you
> owe obedience to. You reproduce it against the code before touching anything, then answer
> with a technical acknowledgment or reasoned pushback. Never performative agreement.

# Applying Review Feedback

Receiving a review is a technical evaluation, not a social ritual. Every item — however
authoritative its source — is a claim you route through one loop before it earns a place in
the diff.

## The Iron Law

```
NO FINDING IS IMPLEMENTED BEFORE IT REPRODUCES AT file:line
```

If you cannot open the cited location and watch the problem exist, you hold a claim, not a
bug. A claim you cannot reproduce goes to dispute resolution (below) — it does NOT go into
the code.

## The loop — run every item through it, in order

| # | Step | Do | Done when |
|---|------|-----|-----------|
| 1 | **READ** | Read the WHOLE feedback first. React to nothing yet. | The full set of items is in view. |
| 2 | **UNDERSTAND** | Restate each item as a concrete requirement in your own words; if you can't, ask. | Another engineer could build the same thing from your restatement. |
| 3 | **VERIFY** | Open the cited `file:line`; confirm the problem reproduces against the code AS IT IS NOW. | You've seen it with your own read/grep, or proven it absent. |
| 4 | **EVALUATE** | Ask: correct FOR THIS codebase/stack? Does it earn its keep (YAGNI)? | You can state why it's sound, or why it isn't. |
| 5 | **RESPOND** | Technical acknowledgment OR reasoned pushback with `file:line`. No gratitude, no theater. | Your answer is a fact or an argument, not a feeling. |
| 6 | **IMPLEMENT** | Fix ONE item, verify it, take the next — in severity order (below). | Each change is verified before the next begins. |

## Gate — one unclear item stops the whole batch

Feedback items are usually coupled: a partial understanding yields a wrong implementation
that then has to be redone. So:

- If ANY item is ambiguous, STOP. Implement NOTHING.
- Collect EVERY unclear item and clarify them together, in one pass.
- Resume the loop only once the whole set is unambiguous.

Guessing at scope to look responsive is the same failure as guessing at code.

## Source-specific handling

Where a finding came from changes how much you trust it — but NO source exempts it from the
Iron Law.

### 1. The user (trusted, still bounded)
The user's intent is authoritative; you don't verify their *right* to ask. You DO clarify
unclear scope before acting, and you still skip performative agreement. Understand, then act
or acknowledge technically.

### 2. Automated review agents / skills (the default case)
A review may come from a blue-team auditor (`Task(subagent_type="senior-code-auditor")`), an
adversarial red-team auditor (`Task(subagent_type="red-team-auditor")`), or a self-review
skill (`Skill(skill="meticulous-code-review")`, `Skill(skill="verify-claims")`). Their output
is a set of HYPOTHESES with `file:line`, not a work order:

- **Every finding is a claim.** Open the `file:line` and reproduce it before changing
  anything. The report can be stale (the code moved since it ran) — your grep is the
  evidence, the report is only the hypothesis.
- **A red-team pass is adversarial BY DESIGN.** It exists to attack findings, so it
  manufactures disputes and will itself produce false positives. Judge each dispute on its
  `file:line`, not on the fact that it pushed back — and don't dismiss it just because "it's
  only the red team." Reproduction plus severity decides, nothing else.
- **These agents report to the user exactly as you do.** A finding that demands an unused
  "proper" implementation gets the YAGNI check (below), not automatic compliance.

### 3. External reviewers (GitHub PR)
An outside reviewer rarely holds your full context. Before implementing, check:

| Check | If the answer is bad |
|-------|----------------------|
| Correct for THIS stack/codebase? | Push back with the stack-specific reason. |
| Does it break existing behavior? (grep the consumers — blast radius) | Push back; cite the consumers. |
| Is there a reason the current code is the way it is? | Explain the reason; don't silently revert it. |
| Does the reviewer have the context this assumes? | Supply the missing context in the thread. |

If you can't verify a PR finding, say so in the thread: *"Can't confirm this without X —
investigate, or is this intended?"* If it conflicts with a decision the user already made,
STOP and raise it before changing code.

## Anti-sycophancy — acknowledge with actions, not applause

This skill holds the toolkit's NO-SYCOPHANCY posture: correctness over comfort. Validation
theater burns tokens and hides whether you actually verified anything.

| Don't say | Say instead |
|-----------|-------------|
| "You're absolutely right!" | "Confirmed at `file:line` — <what's wrong>. Fixing." |
| "Great point!" / "Excellent catch!" | State the specific issue, then the fix. |
| "Thanks for catching that!" | [just show the diff] |
| "Let me implement that right away!" | Verify first; implement in severity order. |
| ANY gratitude / apology / hedge | A fact, a `file:line`, or a reasoned objection. |

If you catch yourself typing "Thanks" or "You're right", delete it and state the change. A
correct fix shown at `file:line` IS the acknowledgment.

## Fix order — drain the queue by severity

Once items are verified, implement them as a queue, highest-impact first. This bounds the
blast radius of each change and keeps the diff reviewable:

1. **Blocking** — correctness bugs, security holes, data-loss / data-corruption paths.
2. **Behavioral** — wrong-but-not-catastrophic logic, missing edge-case handling.
3. **Cheap wins** — small, isolated, low-risk fixes.
4. **Refactors / style** — structural changes with no behavior delta. Last, and only if in scope.

One item at a time. Verify each — `Skill(skill="verification-before-completion")` before any
"done" claim — before pulling the next off the queue. Never fold a refactor into the same
change as a correctness fix: you lose the ability to say which one worked.

## Disputed or non-reproducing findings → self-verify before you rule

Two situations must never be settled by gut feel:
- You cannot reproduce a finding at its cited `file:line`.
- Two sources conflict (a red-team dispute contradicts a blue-team finding), or you are about
  to REJECT a finding.

In both, YOUR reasoning is now the thing on trial — so verify it before accepting or
rejecting anything. Run `Skill(skill="verify-claims")` on your accept/reject argument: it
forces each step to earn its `file:line` and flags any conclusion you'd have reached WITHOUT
the evidence (a decorative citation means you're pattern-matching, not verifying).

```
Finding won't reproduce, or you're about to overrule it
        │
        ▼
Skill(skill="verify-claims")   ← put YOUR reasoning under the check, not the finding's
        │
        ├─ rejection is grounded   → reject it; record the file:line that disproves it
        ├─ rejection is FLAGGED    → you can't justify overruling it; keep it OPEN, ask
        └─ genuinely can't tell    → escalate to the user with both sides + evidence
```

(`verify-claims` is also listed as a feedback SOURCE; here you use it as a RESOLUTION tool,
turned on your OWN reasoning.) Never silently drop a finding you merely *feel* is wrong.
Either disprove it at `file:line`, or carry it as OPEN and surface it — an unreproduced
finding is unresolved, not closed.

## When to push back (and how)

Push back — with technical reasoning, never defensiveness — when the suggestion:
- breaks existing behavior (you grepped the consumers and it does),
- violates YAGNI (adds an abstraction nothing calls today),
- is wrong for this stack / language / framework,
- fights a legacy or compatibility constraint that still holds, or
- contradicts an architectural decision the user already made.

**How:** cite the working code or test at `file:line`, state the consequence, propose the
alternative. If it's an architectural call, escalate to the user rather than deciding
unilaterally. Pushback is an argument with evidence, not a refusal.

## The YAGNI check on "do it properly"

"Implement this properly / handle the general case" is a common finding. Before you build the
general case, prove it's needed:

```
grep the codebase for real callers of the thing.
  0 callers    → "Nothing uses this. Propose removal (YAGNI) instead of building it out?"
  1-2 callers  → keep it inline / minimal; a general abstraction isn't earned yet.
  3+ callers   → the generalization is justified — implement it properly.
```

No abstraction without real consumers today. Reach for `Skill(skill="scope-creep-prevention")`
if a finding keeps growing the task beyond what was asked.

## Correcting your own pushback

If you pushed back and the finding was right, correct it as a fact and move on — no ritual
apology, no defense of why you resisted:

| Do | Don't |
|----|-------|
| "Re-checked `file:line` — it does <X>. The finding is correct; fixing." | "I'm so sorry, you were right all along, I should have…" |
| State what you verified, then the fix. | Re-litigate why your original pushback seemed reasonable. |

Being wrong and saying so plainly is cheaper than defending a wrong position.

## GitHub PR replies

Answer a PR finding INSIDE its comment thread, never as a new top-level PR comment — the
thread is where the reviewer's context lives:

```
gh api repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies -f body='<reply>'
```

## Red flags — STOP

If you catch yourself thinking any of these, stop and return to the loop:
- "You're absolutely right, let me fix that." (agreeing before reproducing)
- "The report says line 45, so I'll just change line 45." (trusting, not verifying)
- "The red team disputed it, so the finding must be wrong." (a dispute is a hypothesis too)
- "I'll knock out all the findings in one commit." (no per-item verification)
- "This is clearly wrong, I'll skip it." (dropping a finding without disproving it)
- "I'll implement most of it and ask about the rest later." (partial understanding)
- "While I'm in here, I'll also add…" (scope creep the finding never asked for)

## Common mistakes

| Mistake | Correction |
|---------|-----------|
| Performative agreement ("You're right!") | State the requirement, or just show the fix. |
| Implementing before reproducing | Open the `file:line` first — Iron Law. |
| Treating an audit finding as fact | It's a hypothesis; reproduce or disprove it. |
| Silently dropping a finding you "feel" is wrong | Disprove it at `file:line`, or keep it OPEN → `verify-claims`. |
| Batching all fixes at once | One at a time, in severity order, verify each. |
| Building the "proper" general case unprompted | YAGNI grep first; propose removal if unused. |
| Acting on a half-understood item | Clarify ALL unclear items before any change. |
| Long apology after wrong pushback | State the correction as a fact; move on. |
| Top-level PR comment instead of thread reply | Reply in the finding's own thread. |

## Composition — where this sits

This skill CONSUMES findings; other skills PRODUCE them. Keep the roles straight:

| Skill / agent | Its role | Your job here |
|---------------|----------|---------------|
| `/swe-skills:senior-review` · `Skill(skill="meticulous-code-review")` | GENERATE findings on a diff | Run each finding through the loop before acting. |
| `Task(subagent_type="senior-code-auditor")` (blue) | Defends findings with `file:line` | Reproduce before implementing. |
| `Task(subagent_type="red-team-auditor")` (red) | DISPUTES findings adversarially | Its disputes are ALSO hypotheses — reproduce them, don't obey them. |
| `Skill(skill="verify-claims")` | Adjudicates reasoning | Self-verify before you accept OR reject a disputed / non-reproducing finding. |
| `Skill(skill="verification-before-completion")` | Proves a fix works | Run it before any "done" claim on an implemented item. |
| `Skill(skill="scope-creep-prevention")` | Keeps the task bounded | Invoke when a finding tries to grow the scope. |
| `Skill(skill="systematic-debugging")` | Roots out a bug from scratch | Use it INSTEAD when there's no review — a failure you found yourself. |

**Boundary:** this skill begins once findings EXIST. Requesting or running a review is
`/swe-skills:senior-review` / `Skill(skill="meticulous-code-review")`; diagnosing an
undiagnosed failure is `Skill(skill="systematic-debugging")`. This skill is only the
disciplined RESPONSE to feedback — nothing more.
