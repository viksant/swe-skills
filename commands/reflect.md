---
allowed-tools: Read, Edit, Write
description: 🪞 Analyze session errors and save generalizable reflections
model: opus
---

## Context

- Existing reflections: !`cat .claude/reflections.md 2>/dev/null || echo "Empty"`

## Your Mission

You are your own critic. Analyze THIS conversation with brutal honesty to identify errors you made and extract lessons that will make you better in FUTURE sessions.

## Step 1: Identify Errors (actively look for these patterns)

Review the conversation specifically looking for:

**Execution Errors:**
- Commands that failed and you had to retry
- Code that didn't compile/work on first attempt
- Incorrect paths you assumed
- Tools you used incorrectly or in wrong order

**Assumption Errors:**
- Things you assumed without verifying (that turned out incorrect)
- Data structures/schemas you imagined differently
- API/library behaviors you misinterpreted

**Process Errors:**
- Steps you skipped and then had to go back
- Times the user had to correct you
- Solutions you proposed that the user rejected
- Moments where you were too verbose or unclear

**Tooling Errors:**
- Wrong tool for the task (e.g., grep when you should have used cclsp)
- Inefficient searches that took multiple attempts
- Lack of use of available tools that would have been more efficient

## Step 2: Extract the Universal Lesson

For EACH error identified, ask yourself:

1. **What was the ROOT CAUSE?** (not the symptom)
2. **What PRINCIPLE did I violate?** (not what command failed)
3. **How does this apply to ANY project?** (not just this one)
4. **What will I do DIFFERENTLY next time?** (concrete action)

**Transforming error to lesson:**
```
ERROR: "I assumed the table had column X and the query failed"
   ↓
ROOT CAUSE: Didn't verify schema before writing code
   ↓
PRINCIPLE: Verify before assuming
   ↓
LESSON: "Always query real schema/structure before writing queries or code that depends on it"
   ↓
CATEGORY: Database
```

## Step 3: Categorize the Reflection

**CRITICAL**: Each reflection MUST go under the appropriate section in the file.

**Available sections** (you can create new ones if none apply):

| Section | Content |
|---------|---------|
| **Database** | Schema, queries, migrations, connections, transactions |
| **API** | Endpoints, validation, responses, authentication, HTTP |
| **Frontend** | React, stores, components, TypeScript types, UI/UX |
| **Tooling** | Tool usage (cclsp, grep, git), commands, IDEs |
| **Cleanup** | Code deletion, refactoring, dead code, deprecations |
| **Architecture** | Patterns, structure, dependencies, system design |
| **Communication** | Clarification with user, assumptions, requirement interpretation |

**If a reflection applies to multiple categories**, choose the MOST SPECIFIC one to the error made.

## Step 4: Reflection Format

One line per reflection. It must be:
- **Actionable**: Indicates WHAT TO DO, not just what to avoid
- **Universal**: Applies to any project/language/context
- **Specific in action**: No vagueness like "be more careful"

**GOOD examples:**
```
- Use LSP tools (cclsp) to find definitions before assuming code locations
- Verify database schema before writing queries that assume structure
- Read existing files before proposing modifications to understand context
```

**BAD examples (DO NOT write like this):**
```
- Be more careful (vague)
- The users table didn't have email (specific)
- Review code better (doesn't say how)
```

## Step 5: Smart Deduplication

BEFORE writing, read existing reflections in ALL sections:

1. **If identical reflection exists** → DO NOT add
2. **If similar reflection exists** (same idea, different wording) → IMPROVE the existing one
3. **If truly new** → Add under the correct section

To improve an existing one, use Edit tool to replace the line with improved version.

## Step 6: Write to File

Use Edit tool to add reflections **UNDER THE CORRECT SECTION**.

**Process:**
1. Identify the section where the reflection goes
2. Find that section in the file (## Database, ## API, etc.)
3. Add the reflection as a new bullet under that section
4. If the section doesn't exist, CREATE it in alphabetical order

**Edit example:**
```
# If the reflection is about Database, find:
## Database
- [existing reflections]

# And add the new one:
## Database
- [existing reflections]
- [new reflection here]
```

## Final Validation

Before saving each reflection, verify:
- [ ] Is it actionable? (says what TO DO)
- [ ] Is it universal? (applies to any project)
- [ ] Does it avoid specific names? (doesn't mention specific tables, functions, files)
- [ ] Is it in the correct section?
- [ ] Does it not duplicate an existing reflection?

If any answer is NO → rewrite, recategorize, or discard it.

## Expected Output

When finished, briefly list:
1. Errors identified in the session
2. Reflections added/improved (indicating section)
3. If there were no significant errors, state it honestly
