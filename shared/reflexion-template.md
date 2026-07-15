# Reflexion Phase Template

## MANDATORY EXECUTION

**YOU MUST complete this self-critique AFTER every piece of work. NO EXCEPTIONS.**

---

## 1. Completeness Check

**YOU MUST answer:**
- Did I address ALL aspects of the request?
- What is missing?
- What is extra (scope creep)?

| Requirement | Status |
|-------------|--------|
| Address 100% of request | **MANDATORY** |
| Identify ALL gaps | **MANDATORY** |
| Remove ALL scope creep | **MANDATORY** |

```
 CORRECT:
"Completeness: Request had 3 parts. I addressed parts 1 and 2.
MISSING: Part 3 (error handling). Adding now."

 INCORRECT:
"I think I covered everything."
(No explicit verification = violation)
```

---

## 2. Evidence Quality

**EVERY finding MUST have `file:line` reference.**

| Requirement | Status |
|-------------|--------|
| All claims have file:line citations | **MANDATORY** |
| All assertions backed by code inspection | **MANDATORY** |
| NEVER make unsupported claims | **PROHIBITED** |

```
 CORRECT:
"Bug found in auth_service.py:145 - missing null check"

 INCORRECT:
"There's a bug in the auth service somewhere."
(No file:line = violation)
```

---

## 3. Assumption Validation

**YOU MUST:**
1. List ALL assumptions made
2. Verify EACH against actual code
3. Correct ANY wrong assumptions

```
 CORRECT:
"ASSUMPTIONS:
1. Cache TTL is 300s - VERIFIED in config.py:23
2. User model has email field - VERIFIED in models/user.py:15
3. API returns JSON - WRONG, returns XML. Correcting..."

 INCORRECT:
"I assumed the standard configuration."
(No explicit verification = violation)
```

---

## 4. Pattern Adherence

**YOU MUST verify:**

| Check | Action |
|-------|--------|
| Follows project conventions? | Verify against existing code |
| Matches existing patterns? | Find similar implementations |
| Uses project libraries? | Check package.json/requirements.txt |

```
 CORRECT:
"Pattern check: Project uses factory pattern for services (see user_factory.py:10).
My implementation follows same pattern."

 INCORRECT:
"I used best practices."
(No project-specific verification = violation)
```

---

## 5. Risk Assessment

**YOU MUST evaluate:**

| Question | MUST Answer |
|----------|-------------|
| Could this break functionality? | YES/NO with specifics |
| What is the rollback plan? | Explicit steps |
| What edge cases exist? | List ALL |

```
 CORRECT:
"RISKS:
- Could break: YES - changes shared utility used by 3 services
- Rollback: Revert commit abc123
- Edge cases: Empty input, Unicode characters, >1MB payloads"

 INCORRECT:
"Should be safe."
(No explicit risk analysis = violation)
```

---

## Corrections Format

**WHEN corrections are needed, YOU MUST use this format:**

```markdown
**What I Got Wrong:**
1. [Issue]: [Correction]

**What I Need to Add:**
1. [Missing item]: [How to add]

**What I Need to Remove:**
1. [Extra item]: [Why removing]
```

---

## Final Validation Gate

**YOU MUST ask yourself:**

> "Would I bet my reputation this is correct?"

| Answer | Action |
|--------|--------|
| YES with evidence | Proceed to deliver |
| NO or uncertain | FIX before completing |

**NEVER declare "done" while uncertain. ALWAYS fix first.**
