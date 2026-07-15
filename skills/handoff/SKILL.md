---
name: handoff
description: >
  Produces an EXHAUSTIVE session handoff written to docs/ai-context/HANDOFF.md so a
  future person or a fresh Claude session with ZERO context can resume the work without
  asking anything (timeline, files changed, decisions + rationale, failed approaches,
  glossary, exact current state, next steps). Use when the user explicitly asks to
  "hand off", "dump the context", "write a handoff", "save the session for later", or
  "create HANDOFF.md". NOT for: loading/resuming a prior handoff (use the load-handoff
  skill), generating general documentation (use the generate-docs skill), or a quick
  status summary — and do NOT auto-invoke to write HANDOFF.md unless the user explicitly
  asks for a handoff.
allowed-tools: Read, Write, Bash, Grep, Glob, TodoRead
model: opus
---

# Exhaustive Session Handoff

> **Prerequisite:** Read the project's `CLAUDE.md` first (if present). Confirm with "CLAUDE.md read".
> **Language of the generated HANDOFF.md:** your project's working language — be consistent, never mix languages.
> **Destination:** `docs/ai-context/HANDOFF.md` (always overwrite — the git log preserves history).
> **Load-bearing:** BEFORE updating an existing HANDOFF.md you MUST read it first.

## Purpose

Generate a document that lets **another person or another Claude session WITH NO prior
context** understand **EVERYTHING** that happened in this session and **continue from
exactly where it was left off**, without having to ask the user anything.

**Target audience:** someone who knows NOTHING about the project, does NOT know the
jargon, does NOT know what was discussed or decided. Reading ONLY the HANDOFF.md, they
must be able to resume the task in under 5 minutes.

---

## Anti-patterns (DO NOT do this)

| Anti-pattern | Why it's forbidden |
|--------------|--------------------|
| "Files Modified: `auth.py`" without explaining what changed or why | The reader doesn't know what changed or the motivation |
| "Approach failed" without saying what was tried, the error, and why it was discarded | Risk of repeating the same failed attempt |
| Empty bullet lists like "- [Task 1]" with no real content | The template is not the output: fill it with real content |
| Assuming the reader knows internal jargon (tenant IDs, message queue, graph DB, LLM provider) | Define each technical term the first time it appears |
| Summarizing conversations like "the user asked for X" while omitting refinements | Every change of direction from the user must be recorded |
| Skipping the "why" of a technical decision | Without the why, the next session will undo the decision |
| Generating HANDOFF.md without having actually read the modified files | Verify before asserting — use Read on the key files |

---

## Generation protocol

### Step 1: RECONSTRUCT THE TIMELINE
Review the full conversation from the user's first message to the last. Identify: the
user's initial request (verbatim, not paraphrased), each refinement/change of course,
each question Claude asked and its answer, and each technical decision Claude made
autonomously (what it was, what alternatives were discarded, why).

### Step 2: REAL INVENTORY OF CHANGES
For each file touched: (1) Read the current file to confirm its final state; (2) if in
doubt versus disk, run `git diff <file>` or `git log -p -1 <file>`; (3) document absolute
path, lines touched, what changed, **why**, and which project pattern/convention was followed.

### Step 3: GIT CONTEXT (ONLY IF RELEVANT)
**Do NOT capture git context automatically.** Include it only if the conversation
discussed commits/branches/merges/conflicts/PRs, or the user is mid-way through an
uncommitted multi-file change that affects the continuation. If it applies, run the
minimum: `git status --short`, `git branch --show-current`, `git log --oneline -5`.

### Step 4: EXTRACT DECISIONS AND FAILED APPROACHES
For each decision: what was chosen, alternatives considered, rationale (cite evidence).
For each failed approach: what was tried, the real error message (not paraphrased), the
root cause, and the lesson (what NOT to try again).

### Step 5: DOMAIN GLOSSARY
List every technical term, acronym, service name, ID, or project concept in the handoff.
Define each in 1 line so the novice reader doesn't get lost.

---

## HANDOFF.md template

The full 14-section template (executive summary, original request, project context,
glossary, timeline, files, commands, decisions, failed approaches, current state, git
context, next steps, warnings, quick references) lives in `references/handoff.md`. Read
it, fill every section with REAL content, and write the result to `docs/ai-context/HANDOFF.md`.

---

## Checklist before saving

- [ ] Every template section has real content (no `<...>` placeholders left)
- [ ] Each modified file has WHAT + WHY + verification
- [ ] Each technical decision has alternatives + rationale
- [ ] Each failed approach has root cause + lesson
- [ ] The glossary defines every technical term mentioned
- [ ] The next step is actionable without ambiguity
- [ ] A reader with no context can understand it in under 5 minutes
- [ ] The whole document is in one consistent language
- [ ] No phrases like "the user probably wanted" — everything is verified

---

## Execution

1. Review the full conversation of this session.
2. If you need to confirm the current state of any file, read it with `Read`.
3. If git was discussed, run the minimum commands with `Bash`.
4. Read `references/handoff.md` and fill the template with REAL content (no placeholders).
5. Write `docs/ai-context/HANDOFF.md` with `Write` (overwrite if it exists).
6. Confirm to the user: file path + line count + how to load it.

**To load this handoff in a new session:** run `/swe-skills:load-handoff`.
