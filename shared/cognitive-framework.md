# Cognitive Framework: CoT + Reflexion + ReAct

## MANDATORY APPLICATION

**YOU MUST apply these three methodologies to EVERY cognitive command. NO EXCEPTIONS.**

---

## 1. Chain-of-Thought (CoT)

**YOU MUST break reasoning into explicit steps BEFORE producing solutions.**

```
Observed Issue -> Analysis Step 1 -> Step 2 -> Step 3 -> Validated Solution
```

| Requirement | Status |
|-------------|--------|
| Document reasoning chain for EVERY decision | **MANDATORY** |
| Show explicit step-by-step progression | **MANDATORY** |
| NEVER jump directly to conclusions | **PROHIBITED** |

```
 CORRECT:
"Step 1: Identify the error location in auth.py:45
Step 2: Trace the call stack to find origin
Step 3: Verify the assumption against actual data
Step 4: Propose fix with evidence"

 INCORRECT:
"The fix is to change line 45."
(Missing reasoning chain = violation)
```

---

## 2. Reflexion

**YOU MUST self-critique your plan BEFORE implementing.**

### Mandatory Self-Questions:
- "Could this change behavior unexpectedly?"
- "Am I optimizing based on assumptions or measurements?"
- "Is there a simpler approach?"
- "What could go wrong?"

| Requirement | Status |
|-------------|--------|
| Include self-critique phase showing corrections | **MANDATORY** |
| Challenge your own assumptions | **MANDATORY** |
| NEVER skip critique for "simple" tasks | **PROHIBITED** |

```
 CORRECT:
"Self-critique: My initial approach assumes the cache is always valid.
Correction: I MUST add cache invalidation check first."

 INCORRECT:
"This should work."
(No self-critique = violation)
```

---

## 3. ReAct (Reasoning -> Actions -> Results)

**YOU MUST follow this exact flow:**

```yaml
REASONING: Plan what to do and why (with evidence)
ACTIONS:   Execute with validation at each step
RESULTS:   Deliver with measurements and proof
```

| Phase | Requirement |
|-------|-------------|
| Reasoning | MUST include "why" with code references |
| Actions | MUST validate each step before proceeding |
| Results | MUST include measurable evidence |

```
 CORRECT:
"REASONING: Query is slow because of N+1 in user_service.py:120
ACTIONS: Replace loop query with batch fetch, test with timing
RESULTS: Query time reduced from 2.3s to 0.15s (measured)"

 INCORRECT:
"I optimized the query. It should be faster now."
(No measurements = violation)
```

---

## Integration Flow

**YOU MUST execute phases in this EXACT order:**

```
Phase 1 (CoT):       Plan using explicit reasoning chain
Phase 2 (Actions):   Execute with validation at each step
Phase 3 (Reflexion): Self-critique and correct errors
Phase 4 (Results):   Deliver with measured outcomes
```

---

## Verification Checklist

**EVERY report MUST show evidence of ALL three methodologies:**

- [ ] CoT: Explicit reasoning steps documented
- [ ] Reflexion: Self-critique with corrections shown
- [ ] ReAct: Reasoning/Actions/Results all present with evidence

**IF ANY CHECKBOX IS UNCHECKED, THE REPORT IS INCOMPLETE.**
