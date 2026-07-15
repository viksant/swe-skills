---
name: handoff
description: 🤝 EXHAUSTIVE dump of the session context to HANDOFF.md (resume with zero gaps)
color: magenta
tools: Read, Write, Bash, Grep, Glob, TodoRead
model: opus
---

> **Prerequisite:** Read `CLAUDE.md` first. Confirm with "📋 CLAUDE.md read ✓"
> **Language of the generated HANDOFF.md:** your project's working language (be consistent — never mix languages).
> **Destination:** `docs/ai-context/HANDOFF.md` (always overwrite — the git log preserves history).

# 🤝 EXHAUSTIVE SESSION HANDOFF

## 🎯 PURPOSE

Load Bearing: BEFORE UPDATING THE HANDOFF.MD, you MUST read it first.

Generate a document that lets **another person or another Claude session WITH NO prior context** understand **EVERYTHING** that happened in this session and **continue from exactly where it was left off**, without having to ask the user anything.

**Target audience of the HANDOFF.md:** someone who knows NOTHING about the project, does NOT know the jargon, does NOT know what was discussed, does NOT know what decisions were made. Your job is to make that person, reading ONLY the HANDOFF.md, able to resume the task in under 5 minutes.

---

## ⛔ ANTI-PATTERNS (DO NOT DO THIS)

| Anti-pattern | Why it's forbidden |
|-------------|------------------------|
| "Files Modified: `auth.py`" without explaining what changed or why | The reader doesn't know what changed or the motivation |
| "Approach failed" without saying what was tried, what error it gave, and why it was discarded | Risk of repeating the same failed attempt |
| Empty bullet lists like "- [Task 1]" with no real content | The template is not the output: fill it with real content |
| Assuming the reader knows internal jargon (tenant IDs, your message queue, graph database, LLM provider, etc.) | Define each technical term the first time it appears |
| Summarizing conversations like "the user asked for X" while omitting refinements | Every change of direction from the user must be recorded |
| Skipping the "why" of a technical decision | Without the why, the next session will undo the decision |
| Generating HANDOFF.md without having actually read the modified files | Verify before asserting — use Read on the key files |

---

## 📋 GENERATION PROTOCOL

### Step 1: RECONSTRUCT THE TIMELINE

Review the full conversation of this session from the user's first message to the last. Identify:

- **The user's initial request** (verbatim, not paraphrased)
- **Each refinement or change of course** the user introduced afterwards
- **Each question Claude asked the user** and its answer (via AskUserQuestion or text)
- **Each technical decision** Claude made autonomously (what it was, what alternatives were discarded, why)

### Step 2: REAL INVENTORY OF CHANGES

For each file touched in the session:

1. Read the current file with the `Read` tool to confirm the final state.
2. If there's any doubt about what changed versus disk, run `git diff <file>` or `git log -p -1 <file>` with `Bash`.
3. Document: absolute path, lines touched, what changed, **why it changed**, what project pattern/convention was followed.

### Step 3: GIT CONTEXT (ONLY IF RELEVANT)

**Do NOT capture git context automatically.** Only include it if the conversation discussed commits, branches, merges, conflicts, PRs, or if the user is clearly mid-way through an uncommitted multi-file change and that affects the continuation.

If it applies, run the minimum necessary:
- `git status --short` (what's uncommitted)
- `git branch --show-current` (current branch)
- `git log --oneline -5` (last commits, if relevant)

### Step 4: EXTRACT DECISIONS AND FAILED APPROACHES

For each important technical decision:
- **Decision:** what was chosen
- **Alternatives considered:** what other options existed
- **Rationale:** why this one was chosen (cite evidence: docs, metrics, project constraints)

For each approach that failed:
- **What was tried:** concrete description
- **What error/problem it gave:** the real message, not paraphrased
- **Why it failed:** root cause if identified
- **Lesson:** what NOT to try again

### Step 5: DOMAIN GLOSSARY

List every technical term, acronym, service name, ID, or project concept that appears in the handoff. Define each in 1 line so the novice reader doesn't get lost.

---

## 📄 HANDOFF.md TEMPLATE

> Save to `docs/ai-context/HANDOFF.md`. Overwrite if it exists.

```markdown
# Session Handoff — <YYYY-MM-DD HH:MM>

> **Who this document is for:** a person or Claude session that knows NOTHING
> about the prior context. After reading this, they must be able to continue the
> task without asking the user anything.

---

## 1. EXECUTIVE SUMMARY (30-second read)

- **Session goal:** <one sentence: what we were trying to achieve>
- **Current status:** <COMPLETED / IN PROGRESS / BLOCKED>
- **Immediate next step:** <concrete, executable action>
- **Critical risk / warning:** <if any, in one line>

---

## 2. THE USER'S ORIGINAL REQUEST

> Verbatim quote of the user's first relevant message (do not paraphrase).

```
<verbatim message here>
```

**Later refinements from the user (in chronological order):**

1. <moment>: the user clarified that <...>. This changed the approach because <...>
2. <moment>: the user rejected option <X> and preferred <Y> because <...>
3. ...

---

## 3. PROJECT CONTEXT (the minimum needed to understand)

> MANDATORY section if the novice reader couldn't understand the rest without it.
> Explain the domain, the relevant architecture, the components involved.

- **What this project is:** <1-2 sentences>
- **Components involved in this session:** <short list with each one's role>
- **Critical conventions to respect:** <e.g. a required identifier convention, a code-style rule, etc.>

---

## 4. GLOSSARY

> Define EVERY non-obvious technical term that appears in this handoff.
> The novice reader doesn't know what your message queue, tenant IDs, graph database, LLM provider, etc. are.

| Term | Definition (1 line) |
|---------|----------------------|
| <e.g. message queue> | A message-queue system used for async processing |
| <e.g. tenant_id> | A UUID identifying the tenant; each tenant maps to its own database schema |
| ... | ... |

---

## 5. TIMELINE OF WHAT WAS DONE

> Step by step, in order. This is NOT a summary — it's the real narrative.
> Each step answers: WHAT was done + WHY it was done + WHAT resulted.

### Step 1: <descriptive title>
- **What:** <concrete action>
- **Why:** <motivation: what problem it solved or what the user asked for>
- **Result:** <what happened: success, error, unexpected discovery>
- **Files touched:** <paths>

### Step 2: <descriptive title>
- ...

### Step N: <descriptive title>
- ...

---

## 6. FILES MODIFIED / CREATED / DELETED

> For each file, explain WHAT changed and WHY. Include snippets if they're critical.

### `<absolute/path/to/file>`
- **Type of change:** CREATED / MODIFIED / DELETED
- **What changed:** <concrete description: functions added, lines rewritten, new exports>
- **Why:** <business or technical motivation>
- **Pattern followed:** <the project convention that was respected>
- **Verification:** <if tested, how: command + result>

### `<other/file>`
- ...

---

## 7. COMMANDS / TOOLS EXECUTED (relevant ones)

> Only those that changed system state or produced key evidence.
> Do NOT list every Read/Grep invocation — only what matters.

| Command | Why it was run | Relevant result |
|---------|--------------------|---------------------|
| `<command>` | <motivation> | <summarized output + interpretation> |

---

## 8. TECHNICAL DECISIONS MADE

> Each important decision with its rationale. Without the "why", the
> next session will undo the decision unknowingly.

### Decision 1: <title>
- **Context:** <what problem or trade-off motivated the decision>
- **Options considered:**
  - Option A: <description> — discarded because <...>
  - Option B: <description> — discarded because <...>
  - Option C (chosen): <description>
- **Rationale:** <evidence: docs, metrics, project constraint, explicit user preference>
- **Future implications:** <what consequences this decision has for the next work>

### Decision 2: <title>
- ...

---

## 9. APPROACHES THAT FAILED (DO NOT REPEAT)

> If this isn't documented, the next session will retry them.

### Failed attempt 1: <short description>
- **What was tried:** <concrete approach>
- **Error obtained:** <the real message, not paraphrased>
- **Root cause identified:** <why it really failed>
- **Lesson:** <what not to do next time>

### Failed attempt 2: <short description>
- ...

---

## 10. EXACT CURRENT STATE

### ✅ Completed
- <Completed task with verification evidence>

### 🚧 In progress (half-done)
- **Task:** <description>
- **How far it got:** <exact point: file + function + line if applicable>
- **What's concretely missing:** <what's left to do, step by step>

### ⏸️ Blocked
- **Blocker:** <what prevents progress>
- **Waiting on:** <user decision / access / external dependency>
- **Workaround available:** <if any>

### ❓ Open questions for the user
- <Concrete question left unanswered that blocks the next step>

---

## 11. GIT CONTEXT (only if relevant)

> Omit this entire section if the session didn't discuss git and there are no
> uncommitted changes critical to the continuation.

- **Current branch:** `<branch>`
- **Uncommitted changes:** <list of files>
- **Last relevant commit:** `<hash> <message>`
- **Notes:** <e.g. "merge to main pending", "PR #123 in review">

---

## 12. RECOMMENDED NEXT STEPS

> Concrete, executable actions, in priority order.
> Each step must be so specific the next session can run it without thinking.

1. **<Concrete action 1>** — <exact command or file+function to touch>
   - **Why this step:** <motivation>
   - **Expected result:** <success criterion>

2. **<Concrete action 2>** — <...>
   - ...

---

## 13. WARNINGS AND TRAPS TO AVOID

> Things that look obvious but ARE NOT. Gotchas discovered in the session.

- ⚠️ <Project-specific trap discovered in this session>
- ⚠️ <Non-obvious convention that must be respected>
- ⚠️ <Command that must NOT be run and why>

---

## 14. QUICK REFERENCES

- **Key files the reader should know:**
  - `<path>` — <what it's for>
- **Internal documentation consulted:**
  - `<path or URL>` — <what information it provides>
- **Project reflections / lessons that apply:**
  - <reference to a project reflections/lessons file if any lesson guided decisions>

---

> **Generated by `/handoff` on <YYYY-MM-DD HH:MM>**
> **Model:** <model-id>
> **To load in a new session:** run `/load-handoff`
```

---

## ✅ CHECKLIST BEFORE SAVING

Before writing `docs/ai-context/HANDOFF.md`, verify your output meets:

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

## 🚀 EXECUTION

1. Review the full conversation of this session.
2. If you need to confirm the current state of any file, read it with `Read`.
3. If git was discussed in the conversation, run the minimum commands with `Bash`.
4. Fill the template with REAL CONTENT (don't leave placeholders).
5. Write `docs/ai-context/HANDOFF.md` with `Write` (overwrite if it exists).
6. Confirm to the user: file path + line count + how to load it.

Proceeding to generate the handoff for this session...
