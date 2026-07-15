---
name: load-handoff
description: 📥 Reconstruct the full context of a previous session from HANDOFF.md (fresh session, no context)
color: cyan
tools: Read, Bash, Grep, Glob
model: opus
---

> **Prerequisite:** Read `CLAUDE.md` first. Confirm with "📋 CLAUDE.md read ✓"
> **File to load:** `docs/ai-context/HANDOFF.md`
> **Language of the summary to the user:** your project's working language.

# 📥 LOADING CONTEXT FROM A PREVIOUS SESSION

## 🎯 PURPOSE

This session starts WITH NO context. Your job is to reconstruct the mental state of the previous session by reading `HANDOFF.md` and leave the user ready to continue the task **without having to re-explain anything to you**.

**Expected result:** after running this command, you (Claude) must know:
1. What was being done and why
2. What technical decisions were made and their rationale
3. What approaches failed (so you do NOT repeat them)
4. What the concrete next step is
5. What project warnings/gotchas you must respect

---

## ⛔ ANTI-PATTERNS (DO NOT DO THIS)

| Anti-pattern | Why it's forbidden |
|-------------|------------------------|
| Starting to execute the "next step" without the user confirming | The handoff may be outdated or the user may have changed priorities |
| Summarizing the handoff while omitting technical decisions or warnings | The user needs to see that you UNDERSTAND, not just that you READ |
| Assuming the repo state is identical to the handoff's | The user may have committed/moved files between sessions |
| Inventing context that is NOT in the handoff | If something is missing, ASK the user, don't fill in gaps |
| Skipping verification of the key files mentioned | Paths may have changed or files may have been moved |

---

## 📋 LOADING PROTOCOL

### Step 1: VERIFY THE HANDOFF EXISTS

```bash
# Pre-check
ls docs/ai-context/HANDOFF.md
```

If it does NOT exist, stop and answer the user:

```
❌ I can't find docs/ai-context/HANDOFF.md

Options:
1. Tell me the path where the handoff is
2. If there's no previous handoff, tell me what you want to work on this session
```

### Step 2: READ THE FULL HANDOFF

Use the `Read` tool on `docs/ai-context/HANDOFF.md`. Read it WHOLE, not in parts. It is the single source of truth for this session.

### Step 3: VERIFY THE KEY FILES MENTIONED

For each file listed in the handoff's "Files modified" section:

1. Verify it exists (`Glob` or `Read`).
2. If the handoff claims it has certain content relevant to the next step, read it and confirm it matches.
3. If there are discrepancies (file deleted, moved, different content), DOCUMENT them before continuing.

### Step 4: VERIFY GIT STATE (if the handoff mentions it)

If the handoff included a "Git Context" section, check for drift:

```bash
git branch --show-current
git status --short
git log --oneline -3
```

Compare with what the handoff said. If the user has committed or switched branches since then, REPORT the change.

### Step 5: SUMMARIZE TO THE USER WHAT YOU UNDERSTOOD

Return a structured summary (format below) that demonstrates you:
- Know what was being done
- Understand the technical decisions and the failed approaches
- Have detected any drift between the handoff and the current state
- Are clear on the next step

### Step 6: WAIT FOR CONFIRMATION BEFORE ACTING

**NEVER execute the "next step" automatically.** Ask the user:

> Should I continue with the next step described in the handoff, or has something changed since then?

---

## 📊 FORMAT OF THE SUMMARY TO THE USER

```markdown
## 📥 Context Restored from HANDOFF.md

**Generated:** <handoff date>
**Previous session lasted:** <if inferable from the handoff>
**Declared status:** <COMPLETED / IN PROGRESS / BLOCKED>

---

### 🎯 What was being done
<1-2 sentences — goal of the previous session>

### 🧠 Why it was being done
<motivation / the user's original request>

### ✅ What was completed
- <point 1>
- <point 2>

### 🚧 What was left half-done
- **Task:** <description>
- **How far it got:** <exact point: file + function>
- **What's concretely missing:** <remaining steps>

### 🛑 Approaches that FAILED (I won't repeat)
- <failed attempt 1>: <root cause>
- <failed attempt 2>: <root cause>

### 🔑 Key technical decisions I'll respect
- <decision 1>: <summarized rationale>
- <decision 2>: <summarized rationale>

### ⚠️ Project warnings I'll keep in mind
- <warning 1>
- <warning 2>

### 📂 Key files (verified)
- `<path>` — <what it's for> — <status: exists / moved / discrepancy>

### 🔍 Drift detected vs handoff (if applicable)
<only if you found differences between the handoff and the current repo state>
- <file X was MODIFIED in the handoff but now appears committed>
- <branch changed from Y to Z>
- ...

### ❓ Open questions the previous session left
- <question 1>
- <question 2>

---

### 🚀 Proposed next step

According to the handoff, the concrete next step is:

> <verbatim copy of the handoff's next step>

**Should I continue with that step, or has the context changed since the previous session?**
```

---

## ✅ CHECKLIST BEFORE RESPONDING

- [ ] I've read the WHOLE HANDOFF.md (not fragments)
- [ ] I've verified the key files mentioned exist
- [ ] I've reported any git/file drift detected
- [ ] I've summarized technical decisions AND failed approaches (not just "what was done")
- [ ] I've listed the project warnings I'm going to respect
- [ ] I have NOT executed the next step — I've waited for confirmation
- [ ] The summary is in the project's working language
- [ ] If critical info was missing, I said so and asked the user for clarification

---

## 🚧 EDGE CASES

### The handoff exists but is incomplete
Tell the user which sections are missing or empty. Ask for the minimum information needed to continue.

### The handoff is stale (>7 days or a large number of commits since then)
Warn the user with `git log --since="<handoff date>" --oneline` and ask whether they want to continue with the original plan or redefine it.

### Conflict between the handoff and the current state
Report the conflict EXPLICITLY. Don't assume which prevails — let the user decide.

### The user says "continue" with nothing else
Proceed with the handoff's next step, but confirm the concrete action in the first tool call before modifying anything.

---

Proceeding to load `docs/ai-context/HANDOFF.md`...
