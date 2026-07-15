---
name: write-prompt
description: >
  Generates a self-sufficient XML prompt to hand a task to a fresh Claude Code
  session/subagent that shares no context. Use when: the user says "write/give me a
  prompt for…", building a meta-prompt, handing a task to a new session with no shared
  context, or packaging a task spec for another agent to execute. NOT for: executing the
  task yourself, or a trivial instruction that needs no context transfer.
---

# Write Prompt

## Overview

Distill THIS conversation + code-anchored research into a self-sufficient, delimited **XML
prompt** you can paste into ANOTHER Claude Code session (or hand to a subagent) that shares
none of the current context.

- **Produces:** a copy-paste artifact — an optional startup slash-command line + one (or a
  numbered sequence of) ```xml block(s). That's it.
- **Does NOT:** implement the task, touch task code, or commit. The output is the prompt only.

**Core principle:** maximum signal per token — every word must affect the destination's
execution; anything that doesn't, cut it.

**Final test (the only one that matters):** "Would a fresh Claude Code session with NONE of
this context execute the task correctly, without asking again, using only this prompt?" If
no → the prompt isn't ready.

## Mental model

The destination session has no memory of this conversation. Its behavior emerges SOLELY from
the text it receives — it never saw your discussion, can't infer what went unsaid, recovers
nothing from earlier prompts. **Everything the task needs must be EXPLICIT in the prompt.**
Rich anchored context = precise execution; missing context = hallucination.

## Sufficiency gate (always FIRST)

Before generating anything, judge qualitatively (no numbers) whether you can produce a prompt
another session runs without guessing. **Two doubt types — handled DIFFERENTLY, never mix them:**

- **Doubt about the REQUIREMENT** (the final goal, scope, what "success" means, priorities,
  what must NOT happen): at the SLIGHTEST doubt → **`AskUserQuestion`, ALWAYS, before
  generating.** The user is the only source of truth for intent and is here right now. Never
  pick a "reasonable" default for them. `<abstention>` does NOT solve this — deferring it
  leaves the destination just as blind (it can't read the user's mind either).
- **Doubt about a CODE FACT** (where X lives, a signature, a pattern to mirror): resolve it by
  READING/exploring; if you can't verify it, mark it in `<abstention>` for the destination to
  confirm against the code. Never use `<abstention>` to paper over a requirement doubt.

| Level | Means | Action |
|-------|-------|--------|
| **Sufficient** | Requirement unambiguous + goal/scope/success clear | Generate |
| **Marginal** | Requirement clear; only a non-critical code fact missing | Generate, mark that fact in `<abstention>` |
| **Insufficient** | ANY doubt — however small — about the desired end result | STOP → `AskUserQuestion` before generating anything |

## Workflow (condensed)

1. **Frame.** Classify `problem_type` (bug / feature / optimization / refactor / test /
   architecture) + `complexity` (simple / moderate / complex / architectural). complex or
   architectural → a **SEQUENCE** of prompts (each declares in `<context>` the state it
   assumes already done).
2. **Gather anchors (zero fabrication).** Pull decisions/constraints/discarded approaches
   LITERALLY from this conversation. Anchor to real `path:line` / symbols / existing patterns.
   If anchoring is missing and the target is a real codebase → delegate recon to a subagent
   with `model: "opus"` (broad read-only sweep → native `Explore`). Don't spawn one if the
   anchor is already in context. Verify everything; never invent a path/symbol/flag.
3. **Decompose (only if complex/architectural).** Subtasks each with a binary success
   criterion, a dependency only on prior subtasks, and verification before the next. One
   prompt per coherent unit.
4. **Generate.** Fill the XML template (`references/template.md`) with REAL content — no
   unresolved `[...]`. Prose is English; XML tags stay in English.
5. **Deliver** (see Delivery format).

## Startup-point selection

The generated prompt should START by invoking the most relevant AVAILABLE element — chosen
from what ACTUALLY exists, never a hardcoded list.

- **Discover the real catalog at runtime.** Glob this pack's own `skills/`, `commands/`,
  `agents/` (and consult the session's available `/swe-skills:*` commands + skills), PLUS the
  host project's own `.claude/{skills,commands,agents}` if present.
- **Always-available native fallback.** `Explore` (broad read-only search), `general-purpose`
  (implementer), `Plan` (planning), and the `Task` tool are ALWAYS present. When nothing in
  the pack/project fits, start generic with these — never name a command or agent you haven't
  confirmed exists.
- **Guidance (verify against the real catalog before emitting)** — mapping task types to the
  real `swe-skills` catalog. Commands are the slash first-line (`/swe-skills:<name>`); skills
  and agents load DURING execution (skills by relevance, agents via `Task`):

  | Task type | Start with (confirm each exists first) |
  |-----------|----------------------------------------|
  | refactor | `/swe-skills:refactor` + skills `code-simplifier`, `scope-creep-prevention` |
  | optimization / perf | `/swe-skills:optimize` |
  | code removal (feature or dead) | `/swe-skills:code-deletion` |
  | analytics/tracking removal | `/swe-skills:analytics-cleaner` |
  | architecture / design decision | skill `battle-tested-patterns` + agent `battle-tested-architect` |
  | context-driven / multi-file build | `/swe-skills:context-implement` + native `Plan` |
  | documentation | `/swe-skills:generate-docs` |
  | session handoff (save / resume) | `/swe-skills:handoff` / `/swe-skills:load-handoff` |
  | deep reasoning / plan a complex change | skill `deliberate-thinking` (+ native `Plan`) |
  | pre-close review / "is it done?" | skills `meticulous-code-review` + `verification-before-completion` |
  | claim / citation checking | skill `verify-claims` |
  | retrospective / lessons learned | `/swe-skills:reflect` |
  | broad exploration / unknown terrain | native `Explore` |
  | bug fix / debugging (no matching command) | native `Explore` to locate → `general-purpose` to fix; `deliberate-thinking` if non-obvious |
  | any build with no fitting command | native `general-purpose` + `Plan` |

- The choice materializes in the `<entry_point>` tag (see `references/template.md`) and shapes
  `<subagent_delegation>`.

## Delivery format

**Output = (optional) startup slash-command on the FIRST LITERAL LINE + the ```xml block(s).
Nothing else** — no preamble, no annotations, no post-summary. The user copies it verbatim.

- Claude Code only interprets a slash command when it OPENS the pasted message; buried inside
  the XML it is dead text. So the command goes on line 1, alone; then a blank line; then the
  ```xml block, which serves as its context/arguments.
- **One command at a time.** Domain agents (`Task`) and protocol skills are invoked DURING
  execution and documented inside `<entry_point>` / `<subagent_delegation>`, not on line 1.
- **Omit the first line** when the best start is a native agent, or a skill with no slash
  command, or the target project has no fitting installed element → deliver only the XML.
- **Multi-prompt sequence:** each prompt = its (optional) command line + its ```xml block
  (numbered inside with `<!-- PROMPT 1/N -->`), consecutive, no text between them.
- The only other exception is `AskUserQuestion` when the sufficiency gate is Insufficient
  (you ask and stop; you generate no prompt).

---

**Full XML template, quality-rules table, anti-patterns table, and the pre-delivery checklist:**
see `references/template.md`. **Underlying prompting protocol** (sufficiency gate, framing,
decomposition, success criteria): see `../../prompting.md`.
