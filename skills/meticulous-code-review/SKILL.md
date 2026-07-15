---
name: meticulous-code-review
description: >
  Detailed code inspection before declaring work complete. Use when: about to say
  "done"/"ready"/"finished", after writing >10 lines of code, user says "check my code",
  "review before done", "any bugs?", "is this safe?", modifying business logic,
  touching critical paths.
  NOT for: pure documentation, config-only changes, or trivial typo fixes (1-2 chars).
version: 1.0.0
---

# Meticulous Code Review

> **Core Philosophy**: "Working code is not the same as quality code. Every line deserves scrutiny before declaring completion."

## No-Sycophancy Clause (NON-NEGOTIABLE)

Treat code as **guilty until proven innocent**. Forbidden phrases: "looks good",
"great work", "nice", "clean", "well done", "solid implementation". If something
is wrong, say it directly with `file:line` evidence. If something is right,
prove it with a concrete reason (test passes, invariant preserved, edge case
covered) — not with vague praise.

Reviewer's job is to find what is wrong, not to validate effort.

## Production Stakes

Remember: This code review is for PRODUCTION code.
- Real users will experience any bugs you miss
- Security vulnerabilities will be exploited
- Performance issues will cause real frustration
- Unclear code will confuse future maintainers at 3AM

Review as if your professional reputation depends on it - because it does.

---

## Why This Skill Exists

Claude tends to rush to completion, declaring work "done" after code compiles or tests pass, missing:
- Subtle bugs and edge cases
- Security vulnerabilities
- Code that works but is fragile
- Violations of project patterns
- Technical debt accumulation
- Missing error handling

This skill FORCES thorough self-review of ALL code written before any completion claims.

---

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT THOROUGH CODE REVIEW
```

If you haven't reviewed every line you wrote, you cannot say "done", "ready", "finished", or "complete".

---

## When to Use (Mandatory)

### Explicit Triggers
- About to say: "done", "ready", "finished", "complete", "implemented"
- User asks: "is it ready?", "can I test it?", "are we done?"
- After implementing any feature or fix

### Implicit Triggers (Auto-detect)
| Condition | Reason |
|-----------|--------|
| Wrote >10 lines of code | Enough complexity to hide bugs |
| Modified business logic | High impact area |
| Touched authentication/authorization | Security critical |
| Changed database queries | Data integrity at risk |
| Modified API contracts | Breaking changes possible |
| Added error handling | Easy to miss cases |
| Used external inputs | Injection risks |

### When NOT to Use
- Pure documentation changes
- Config file edits with no logic
- Trivial typo fixes (1-2 characters)

---

## The Review Checklist (MANDATORY)

Before declaring ANY work complete, verify EVERY item:

### 1. Correctness Check
```
[ ] Does the code do what was requested?
[ ] Are all requirements addressed?
[ ] Does it handle the happy path correctly?
[ ] Have I tested mentally with sample inputs?
```

### 2. Edge Cases Check
```
[ ] What happens with empty input?
[ ] What happens with null/undefined?
[ ] What happens with very large inputs?
[ ] What happens with negative numbers (if applicable)?
[ ] What happens with special characters?
[ ] What happens at boundary conditions?
[ ] What happens with concurrent access (if applicable)?
```

### 3. Error Handling Check
```
[ ] Are all error conditions caught?
[ ] Are errors logged appropriately?
[ ] Are errors propagated correctly?
[ ] Are user-facing errors meaningful?
[ ] Is there proper cleanup on failure?
```

### 4. Security Check
```
[ ] Is user input validated/sanitized?
[ ] Are SQL queries parameterized?
[ ] Is sensitive data protected?
[ ] Are permissions checked?
[ ] Is the principle of least privilege followed?
[ ] No hardcoded secrets or credentials?
```

### 5. Quality Check
```
[ ] Does it follow project patterns?
[ ] Is the code readable?
[ ] Are variable names descriptive?
[ ] Is there unnecessary complexity?
[ ] Could this be simpler?
[ ] Are there magic numbers that should be constants?
```

### 6. Completeness Check
```
[ ] No TODO comments left behind?
[ ] No commented-out code?
[ ] No debug/console.log statements?
[ ] Are all imports used?
[ ] Are all variables used?
[ ] Is documentation updated if needed?
```

### 7. Integration Check
```
[ ] Does it break existing functionality?
[ ] Are there unintended side effects?
[ ] Does it work with the rest of the system?
[ ] Are dependencies properly handled?
```

---

## The Review Process

### Step 1: Re-read Every Line
```
DO NOT skim. Read each line as if you're reviewing someone else's code.
Look for:
- Typos in variable names
- Off-by-one errors
- Missing null checks
- Incorrect operators (== vs ===, = vs ==)
- Logic inversions
```

### Step 2: Trace Data Flow
```
Follow data from input to output:
- Where does data enter?
- How is it transformed?
- Where does it go?
- What could go wrong at each step?
```

### Step 3: Consider Failure Modes
```
Ask yourself:
- "What if this fails?"
- "What if this is called twice?"
- "What if the network is slow?"
- "What if the database is down?"
- "What if the user is malicious?"
```

### Step 4: Verify Against Requirements
```
Go back to the original request:
- Did I actually solve the problem?
- Did I solve it completely?
- Did I add unnecessary complexity?
```

---

## Red Flags - STOP and Review More

If you notice ANY of these, you haven't reviewed enough:
- "I think it works" (uncertainty = insufficient review)
- "It should handle that" (speculation = insufficient review)
- "That edge case probably won't happen" (dismissal = insufficient review)
- "I'll fix that later" (deferral = incomplete work)
- "The tests will catch it" (abdication = insufficient review)

---

## Common Bugs This Skill Prevents

For detailed examples of off-by-one errors, null references, race conditions, and injection vulnerabilities, see `references/common-bugs.md`.

---

## Anti-Patterns to Avoid

### "It compiles, it's done"
**Problem**: Compilation doesn't prove correctness.
**Fix**: Review logic, not just syntax.

### "Tests pass, ship it"
**Problem**: Tests might not cover all cases.
**Fix**: Review tests too - are they comprehensive?

### "It's a small change, no need to review"
**Problem**: Small changes cause big bugs.
**Fix**: Review everything, regardless of size.

### "I'll review it later"
**Problem**: Later never comes.
**Fix**: Review NOW, before claiming completion.

### "The code is self-explanatory"
**Problem**: Your fresh perspective might miss issues.
**Fix**: Review as if you've never seen the code.

---

## Output Format

When completing code review, report:

```markdown
## Code Review Completed

### Changes Reviewed
- [file1.py]: [brief description]
- [file2.ts]: [brief description]

### Checklist Status
- [x] Correctness verified
- [x] Edge cases handled
- [x] Error handling complete
- [x] Security reviewed
- [x] Quality acceptable
- [x] No leftover TODOs
- [x] Integration verified

### Potential Concerns (if any)
- [Any edge cases that might need attention]
- [Any assumptions made]

### Ready for: [testing/deployment/user review]
```

---

## Integration with Other Skills

This skill works in sequence with others:
1. **deliberate-thinking**: Plan the approach
2. **scope-creep-prevention**: Stay focused during implementation
3. **meticulous-code-review**: Review code quality (THIS SKILL)
4. **verification-before-completion**: Verify it works (tests, builds)

**Order matters**: Review code BEFORE running verification tests.

---

## Example Flow

```
User: "Add tenant validation to the API endpoint"
→ Claude implements 25 lines of validation logic
→ meticulous-code-review activates before declaring done
→ Checklist reveals: missing null check on tenant_id parameter
→ Claude adds guard clause: `if not tenant_id: return error("missing tenant_id")`
→ Re-runs checklist — all items pass
→ NOW declares completion with checklist evidence
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Declared "done" but user found bug | Skipped review or rushed checklist | Go through EVERY checklist item; don't check boxes without verifying |
| Review missed a security issue | Security check was superficial | For each input: ask "what if this is malicious?" explicitly |
| Review takes too long | Reviewing unchanged code too | Focus on code YOU wrote/modified, not the entire file |
| Found issues but didn't fix them | Noted as "minor" and moved on | CRITICAL/IMPORTANT issues MUST be fixed before completion |

## The Bottom Line

**Read every line. Check every case. Question every assumption.**

A bug found during self-review costs 1 minute.
A bug found by the user costs hours of debugging and trust.

Do the review. Every time. No exceptions.
