---
name: design-brainstorm
description: >
  Use BEFORE any creative/implementation work — new feature, component, behavior change,
  non-trivial design — to turn an idea into an approved design through one-question-at-a-time
  dialogue. Use when: "let's build", "I want to add", "how should we design", "new feature",
  vague/ambiguous scope. NOT for: trivial one-line changes, pure bug investigation (use a
  debugging protocol), or writing the step-by-step plan (that's /swe-skills:write-plans, the
  terminal state of this skill).
allowed-tools: Read, Grep, Glob, Write, Task, AskUserQuestion, TodoWrite
model: opus
---

> **Core:** An idea is not a design. Convert it into an *approved* design through
> one-question-at-a-time dialogue grounded in the real repo — never guess a requirement, never
> touch code before the user signs off. The cheapest place to kill a wrong assumption is one
> sentence in a conversation, not one diff in review.

# Design Brainstorm — Idea → Approved Design

Take a raw idea, ground it in the project's actual architecture and available agents, refine it
into a design the user has explicitly approved, then hand that design to `/swe-skills:write-plans`.

---

## The Iron Law

```
NO IMPLEMENTATION BEFORE AN APPROVED DESIGN
```

Holds for EVERY task, no matter how trivial it looks — no code, no scaffold, no file created
until you have presented a design and the user has approved it. (Same discipline as the toolkit's
epistemic rule: close a gap by reading or asking, never by assuming.)

---

## What makes this DISTINCT (never confuse it with its siblings)

| Skill | Its job | Interaction | Terminal output |
|-------|---------|-------------|-----------------|
| **`design-brainstorm`** (this) | idea → an APPROVED design | interactive, one question at a time, gated on approval | a design spec at `.claude/write-plans/…-design.md`, handed to `write-plans` |
| `architect-design` | enterprise-grade architecture over an ALREADY-framed problem | heavy solo orchestration — battle-tested patterns + Clean Architecture, no dialogue gate | an evidence-backed architecture proposal |
| `write-plans` | an approved design → bite-sized executable tasks | classify → risk-tier → structured plan on disk | `docs/PLAN.json` — the hand-off INTO implementation |
| `consensus-board` | ONE high-stakes decision → a convergence verdict | N independent agents on the SAME problem, different lenses | a confidence-weighted verdict |

This skill is the FRONT of the chain: it decides *what* to build and gets it approved.
`architect-design` and `consensus-board` are what you escalate TO mid-dialogue (see Escalation);
`write-plans` is where you hand OFF at the end.

---

## The protocol (run in order)

Create a `TodoWrite` item per phase. Each phase has a gate you may not skip.

| Phase | What | Output | Gate |
|-------|------|--------|------|
| 1 · Explore context | Read the project's docs index → area summaries → recent commits → the files in scope, in that order. Undocumented subsystem? Say so and read the code before designing. | A grounded read of the current state | — |
| 2 · Resolve unknowns | Hand each domain unknown to a specialist agent with clean context (see the delegation table) instead of guessing. | Answers backed by evidence | No guessing to fill a gap |
| 3 · Clarify | `AskUserQuestion`, ONE question per message, multiple-choice when you can. Target purpose, constraints, success criteria. | Confirmed intent | One question at a time |
| 4 · Propose approaches | 2-3 options grounded in existing repo patterns (reuse > reinvent) + their blast radius; lead with your recommendation and why. | Ranked options with trade-offs | Never fewer than 2 |
| 5 · Escalate (conditional) | High-stakes or enterprise-scale design decision? Escalate it BEFORE the spec — see Escalation. | An evidence-weighted decision | Escalate before writing the spec |
| 6 · Present & approve | Present the design in sections scaled to complexity (a few sentences up to ~250 words each): architecture, components, data flow, error handling, how it's verified. | An approved design | **Approval AFTER EACH section — the Iron Law** |
| 7 · Write & self-review the spec | Save to `.claude/write-plans/YYYY-MM-DD-<topic>-design.md` (NEVER commit — the user commits). Self-review: strip placeholders (TBD/TODO), contradictions, ambiguity; confirm one cohesive scope. Then the user reviews the written file. | A reviewed spec on disk | No commit; user approves the file |
| 8 · Hand off | Invoke `/swe-skills:write-plans` — the ONLY next step. It turns the approved design into bite-sized, executable tasks. | Terminal state | Nothing else runs after this |

---

## Escalation — when the decision outgrows a one-on-one dialogue

Some design calls are too consequential to settle in a two-person conversation. Escalate the
DESIGN decision BEFORE writing the spec, then fold the result back into Phase 6:

| Trigger | Escalate to | What it buys you |
|---------|-------------|------------------|
| High-stakes / irreversible — **auth · data · money · config** — or the design spans **3+ subsystems** | `Skill(skill="consensus-board")` | N independent lenses must CONVERGE on the design before you commit; divergence is the signal it's fragile or mis-framed |
| Needs **enterprise-grade architecture** (10× load, production-proven patterns, Clean Architecture) | `Skill(skill="architect-design")` | An evidence-backed architecture over the frame approved here |

Neither replaces the user's approval — they produce the evidence you bring to it.

---

## Resolve domain unknowns with a specialist

A design question that lives in a subsystem you don't fully hold in context goes to an agent that
does — a fresh, domain-scoped context beats a primed guess:

| If a design unknown lives in… | Delegate it to |
|-------------------------------|----------------|
| Async performance, connection pools, concurrency ceilings | `Task(subagent_type="async-performance-guardian")` |
| Blast radius / who-consumes-this across 3+ subsystems | `Task(subagent_type="impact-analyzer")` |
| Auth, authorization, tenant / data isolation | `Task(subagent_type="security-guardian")` |
| "Is there a production-proven pattern for this?" | `Task(subagent_type="battle-tested-architect")` |
| Any other subsystem with a dedicated expert (data layer, queue, frontend, LLM, payments, external API, …) | a matching `<domain>-specialist` agent **if the host project defines one**; otherwise native `general-purpose` / `Explore` |

---

## Example

```
User: "let's add per-key rate limiting to the public API"
Skill: [1 · reads the API + config docs and recent commits]
       [2 · delegates the concurrency ceiling to async-performance-guardian]
       [3 · asks ONE question: reject or queue requests over the limit?]
       [4 · proposes 2 approaches built on the existing middleware, recommends one]
       [6 · presents architecture → data flow → errors, approved per section]
       [7 · writes .claude/write-plans/2026-07-16-rate-limiting-design.md, no commit]
       [8 · → /swe-skills:write-plans]
```

---

## Red Flags — STOP

If you catch yourself thinking any of these, you are about to skip the gate — STOP and return to
the protocol:

- "This is too simple to need a design."
- "I'll scaffold it now and we'll adjust the design later."
- "I basically know what they want." (You know what you read or were told — the rest is a guess.)
- "I'll batch all my questions into one message to save time."
- "The requirement is probably X." (Read it or ask it.)
- Proposing a single approach with no alternatives.
- Writing code or creating a file before any approval.

---

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "It's a one-liner, skip the design." | "Simple" tasks hide the costliest assumptions — a wrong one can hit auth, data, a money path, or ordering. The design may be three sentences, but you MUST present it and get approval. |
| "I'll scaffold now and design as I go." | Code written before approval anchors the design to whatever you typed first. Design → approve → build. |
| "Faster to ask everything at once." | A wall of questions gets skimmed and half-answered. One at a time gets real answers. |
| "I already know the requirement." | You know what's in your context. The rest is invention — read it or ask it. |
| "One approach is enough." | Without 2-3 options there is no decision, only the first thing you thought of. |

---

## Key principles

- **One question at a time** — `AskUserQuestion`, multiple-choice when you can; a wall of questions gets skimmed.
- **Reuse > reinvent** — mimic neighboring files; no new abstraction without ≥2 real consumers today (YAGNI). Fix only what's in scope; flag unrelated debt, don't refactor it.
- **Always 2-3 approaches** — lead with a recommendation; check the blast radius (who consumes this) and respect tenant / data isolation; treat any money or critical path with extra rigor (idempotency, atomicity).
- **Small units, clear seams** — decompose into pieces with one purpose and a defined interface (what it does · how it's used · what it depends on). Smaller, focused files reason better.
- **Decompose independent subsystems** — if the "one idea" is really several, split it; each gets its own design → `/swe-skills:write-plans` cycle.
- **Incremental validation** — approval after each section, not one big reveal at the end.

---

## Visual companion (optional)

If a browser-automation or diagramming tool is available, offer a visual ONLY for a genuinely
visual question (a layout comparison, an architecture flow) — never for conceptual or trade-off
questions, which stay in text. The test: would the user grasp this faster by seeing it than by
reading it?

---

## Related skills / hand-off

The flow, front to back:

`design-brainstorm` (here) → `/swe-skills:write-plans` → an implementation flow (e.g. `/swe-skills:subagent-build`).

- Escalate a design DECISION mid-dialogue: `Skill(skill="consensus-board")` (high-stakes convergence) or `Skill(skill="architect-design")` (enterprise architecture) — both before Phase 7.
- Terminal state is invoking `/swe-skills:write-plans`. Do not jump to implementation and do not invoke anything else.
