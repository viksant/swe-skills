# HANDOFF.md Template (14 sections)

Fill this template with REAL content (no `<...>` placeholders left) and write it to
`docs/ai-context/HANDOFF.md` (overwrite if it exists — git history preserves the old one).
The template below is the exact target structure.

---

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
|------|---------------------|
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
|---------|----------------|-----------------|
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

### Completed
- <Completed task with verification evidence>

### In progress (half-done)
- **Task:** <description>
- **How far it got:** <exact point: file + function + line if applicable>
- **What's concretely missing:** <what's left to do, step by step>

### Blocked
- **Blocker:** <what prevents progress>
- **Waiting on:** <user decision / access / external dependency>
- **Workaround available:** <if any>

### Open questions for the user
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

- <Project-specific trap discovered in this session>
- <Non-obvious convention that must be respected>
- <Command that must NOT be run and why>

---

## 14. QUICK REFERENCES

- **Key files the reader should know:**
  - `<path>` — <what it's for>
- **Internal documentation consulted:**
  - `<path or URL>` — <what information it provides>
- **Project reflections / lessons that apply:**
  - <reference to a project reflections/lessons file if any lesson guided decisions>

---

> **Generated by `/swe-skills:handoff` on <YYYY-MM-DD HH:MM>**
> **Model:** <model-id>
> **To load in a new session:** run `/swe-skills:load-handoff`
