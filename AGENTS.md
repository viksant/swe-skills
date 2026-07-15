# AGENTS.md — Code Conventions & Task Discipline

How to work inside a codebase: convention discipline before editing, task tracking, and
verification before declaring anything done. These are **reference content, not
auto-installed** — fold them into your own project's `AGENTS.md` (or `CLAUDE.md`).
Companion file: [`CLAUDE.md`](CLAUDE.md) (always-active behavioral rules). Repo orientation:
see [`CONTEXT.md`](CONTEXT.md).

---

## BEFORE Modifying Files

**YOU MUST:**
1. **UNDERSTAND existing conventions** - Mimic style, use existing libraries
2. **VERIFY libraries** - Check package.json, cargo.toml, etc.
3. **FOLLOW existing patterns** - Look at neighboring files as examples
4. **APPLY security** - NEVER expose or log secrets
5. **ADD useful comments** - Explain technical decisions

```
✅ CORRECT:
[Reads existing files first]
[Mimics naming convention: camelCase for variables]
[Uses existing utility function found in utils.ts]

❌ INCORRECT:
[Creates new utility function without checking if one exists]
[Uses snake_case when project uses camelCase]
[Adds new dependency when existing library can do it]
```

## Code Reuse

**ALWAYS prioritize reuse over new creation:**
- ❌ **NEVER** create files/functions/classes if reusable code exists
- ❌ **NEVER** duplicate existing logic
- ✅ **ALWAYS** search for existing code first
- ✅ **ONLY** create new when strictly necessary

**MANDATORY Process before creating new code:**
1. Search for similar functionality (grep / your editor's LSP symbol search first)
2. Evaluate if it can be reused
3. If similar exists, adapt/extend
4. ONLY if no alternative, create modularly

```
✅ CORRECT:
"Found existing formatDate() in utils/date.ts - reusing it"

❌ INCORRECT:
"Creating new formatDate() function"
[Without checking if one already exists]
```

## Size Limit

- ❌ **NEVER** create files >500-600 lines
- ✅ If exceeds limit, **MUST** divide into modules
- ✅ **ALWAYS** maintain single responsibility (SRP)

```
✅ CORRECT:
user-service/
├── user.types.ts (50 lines)
├── user.repository.ts (200 lines)
├── user.service.ts (150 lines)
└── index.ts (10 lines)

❌ INCORRECT:
user-service.ts (800 lines with everything mixed)
```

## Code References

**ALWAYS include `file_path:line_number` when referencing code:**

```
✅ CORRECT:
"Clients are marked as failed in `connectToServer` at src/services/process.ts:712"

❌ INCORRECT:
"The function is somewhere in the services folder"
```

## Code Reviewability

> The detailed rules for code comments, block-by-block narrative, complexity prohibitions
> and diff-friendly formatting are injected by the `code-quality-standards.sh` hook on
> every SessionStart. This rule is just the anchor — the live content lives in the hook.

---

## Task Management

### TodoWrite Usage

- **USE VERY FREQUENTLY** to track tasks
- **PLAN** complex tasks by dividing them into steps
- **MARK COMPLETED** immediately upon finishing
- **NEVER ACCUMULATE** multiple tasks before marking

```
✅ CORRECT:
[Creates task] → [Completes work] → [Marks complete immediately]

❌ INCORRECT:
[Creates 5 tasks] → [Completes all 5] → [Marks all complete at once]
```

### Visual Verification

**RULE:** If the user can't see it working, it's NOT done.

**MANDATORY Process:**
1. Implement code
2. Provide instructions to verify visually
3. Wait for user confirmation
4. ONLY THEN consider complete

**Completeness criteria:**

| Type | User MUST be able to see... |
|------|------------------------------|
| Frontend/UI | Interface working in browser |
| Backend/API | Visible responses (logs, HTTP, DB) |
| Integrations | Visual evidence working |
| Tests | Execution results |

```
✅ CORRECT:
"Done. To verify: run `npm test` and check line 45 output"
[Waits for user confirmation]

❌ INCORRECT:
"Done. The feature should work now."
[Declares complete without verification evidence]
```

### Final Principle

**Prioritize CORRECTNESS over speed, SECURITY over convenience.**

**For EACH request, YOU MUST:**
1. **Think critically** - Question the request
2. **Evaluate risks** - Identify problems
3. **Propose alternatives** - Suggest improvements
4. **Dialogue** - Explain if necessary
5. **Execute safely** - Implement only verified solutions

**REMEMBER:** You are a senior engineer with responsibility. Act like one.

```
✅ CORRECT:
"Before implementing: I noticed this approach has a race condition risk.
Alternative: use mutex. Proceed with original or alternative?"

❌ INCORRECT:
[Implements code with obvious race condition without mentioning it]
```
