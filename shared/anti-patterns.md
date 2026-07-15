# Anti-Patterns: PROHIBITED Behaviors

## NEVER DO THESE

| Anti-Pattern | Status | Consequence |
|--------------|--------|-------------|
| Skip Reasoning/Reflexion phases | **PROHIBITED** | Invalid output |
| Make claims without `file:line` evidence | **PROHIBITED** | Rejected findings |
| Optimize based on assumptions (without measuring) | **PROHIBITED** | Wrong fixes |
| Add features user did NOT request (scope creep) | **PROHIBITED** | Wasted effort |
| Use patterns not validated in official docs | **PROHIBITED** | Broken code |
| Declare "done" without verification evidence | **PROHIBITED** | Incomplete work |
| Rush to deliver fast at expense of quality | **PROHIBITED** | Technical debt |
| Guess instead of verifying | **PROHIBITED** | Wrong conclusions |

### Overengineering Anti-Patterns (CRITICAL)

| Anti-Pattern | Status | What To Do Instead |
|--------------|--------|-------------------|
| Create base class for 1 subclass | **PROHIBITED** | Write the concrete class directly |
| Factory pattern for 1 product type | **PROHIBITED** | Direct instantiation |
| Registry/Plugin for < 5 items | **PROHIBITED** | Simple dict or if/else |
| Strategy pattern for 2 options | **PROHIBITED** | if/else or function parameter |
| Abstract interface with 1 implementation | **PROHIBITED** | Use the concrete type |
| Service layer that only proxies another layer | **PROHIBITED** | Remove the proxy layer |
| Create 3+ files for a single-file feature | **PROHIBITED** | Keep it in 1 file until it needs splitting |
| Add "extensibility" for imagined futures | **PROHIBITED** | YAGNI - build when needed |
| Config system for < 5 hardcoded values | **PROHIBITED** | Module-level constants |
| Class with only 1 method | **PROHIBITED** | Convert to a function |
| Generic types used with only 1 concrete type | **PROHIBITED** | Use the concrete type |
| Wrapper that adds no logic | **PROHIBITED** | Call the wrapped thing directly |

---

## ALWAYS DO THESE

| Required Behavior | Status | Benefit |
|-------------------|--------|---------|
| Show reasoning process step-by-step | **MANDATORY** | Traceable decisions |
| Self-critique and improve before delivering | **MANDATORY** | Higher quality |
| Measure BEFORE and AFTER changes | **MANDATORY** | Proven improvements |
| Follow project patterns strictly | **MANDATORY** | Consistency |
| Quantify ALL improvements with metrics | **MANDATORY** | Verifiable results |
| Validate functionality remains intact | **MANDATORY** | No regressions |
| Take time to be thorough and correct | **MANDATORY** | Reliable output |
| Cite `file:line` for every claim | **MANDATORY** | Verifiable evidence |

---

## Examples

### Reasoning Phase

```
 CORRECT:
"Step 1: Identified slow query in repository.py:89
Step 2: Analyzed query plan - full table scan detected
Step 3: Added index on user_id column
Step 4: Measured: 2.5s -> 0.08s (96.8% improvement)"

 INCORRECT:
"I optimized the database queries."
(No steps, no evidence, no measurements)
```

### Evidence Quality

```
 CORRECT:
"Security vulnerability in auth/jwt.py:45 - token not validated before use"

 INCORRECT:
"There might be a security issue in the auth module."
(No file:line, speculative language)
```

### Scope Control

```
 CORRECT:
User: "Fix the login bug"
Claude: [Fixes only the login bug]

 INCORRECT:
User: "Fix the login bug"
Claude: [Fixes login bug AND refactors auth module AND adds new feature]
(Scope creep - user did NOT request extra work)
```

### Measurement Requirement

```
 CORRECT:
"BEFORE: API response time 1.2s (measured 10 requests, avg)
AFTER: API response time 0.3s (measured 10 requests, avg)
Improvement: 75% faster"

 INCORRECT:
"The API should be faster now."
(No measurements = unverified claim)
```

### Pattern Adherence

```
 CORRECT:
"Following existing pattern from user_service.py:20-45 for new service"

 INCORRECT:
"I used a different approach because I think it's better."
(Violates project consistency without justification)
```

---

## Enforcement

**IF you catch yourself doing ANY anti-pattern:**

1. **STOP** immediately
2. **CORRECT** the behavior
3. **RESTART** the phase properly

**QUALITY > SPEED. ALWAYS.**
