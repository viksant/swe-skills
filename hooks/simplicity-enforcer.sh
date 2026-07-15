#!/usr/bin/env bash
# SessionStart Hook - Enforces simplicity-first mindset for all implementations.
# Injects the anti-overengineering doctrine at session start. Fixed text.

cat <<'HOOK_EOF'
<system-context type="simplicity-enforcer">
## SIMPLICITY DOCTRINE (NON-NEGOTIABLE)

You have a documented tendency to OVERCOMPLICATE implementations. This causes:
- Code that is harder to maintain, debug, and understand
- Unnecessary abstractions that add cognitive load without value
- "Enterprise-grade" solutions to simple problems
- Hours of rework simplifying what should have been simple from the start

### THE GOLDEN RULE

> "Could a junior developer understand this in 5 minutes?"
> If NO -> You are overcomplicating it. Simplify.

### BEFORE WRITING ANY CODE, ASK:

1. **Is this the SIMPLEST solution that works?** (not the most elegant, not the most extensible)
2. **Am I creating abstractions that only have ONE consumer?** (if yes, INLINE IT)
3. **Am I adding layers of indirection?** (Service -> Manager -> Handler -> Processor = TOO MANY)
4. **Am I solving problems that DON'T EXIST YET?** (YAGNI - You Ain't Gonna Need It)
5. **Would a FLAT, DIRECT implementation work?** (if yes, use it)

### OVERENGINEERING RED FLAGS (STOP IMMEDIATELY)

| Pattern | What You're Doing Wrong | What To Do Instead |
|---------|------------------------|-------------------|
| Creating a base class for 1 subclass | Premature abstraction | Just write the concrete class |
| Factory pattern for 1 product type | Unnecessary indirection | Direct instantiation |
| Registry/Plugin system for 3 items | Framework mentality | Simple dict or if/else |
| Strategy pattern for 2 strategies | Over-patterning | Simple if/else or function |
| Builder pattern for simple objects | Ceremony over substance | Constructor with defaults |
| Event system for 1 publisher + 1 subscriber | Invisible control flow | Direct function call |
| Config system for 3 values | Premature generalization | Constants or simple dict |
| Abstract interfaces for concrete needs | Java-brain syndrome | Concrete implementation |
| Middleware chain for 1 middleware | Unnecessary pipeline | Direct function call |
| Generic<T> for 1 type | Type-system theater | Use the concrete type |

### COMPLEXITY BUDGET

Every piece of code has a complexity budget. Spend it wisely:

| Lines of Code | Max Acceptable Complexity |
|---------------|--------------------------|
| < 20 lines | Flat, linear, no abstractions |
| 20-50 lines | 1 level of abstraction max |
| 50-100 lines | Extract helpers, but no class hierarchies |
| 100-200 lines | Consider splitting into 2-3 modules |
| > 200 lines | Split into focused modules with clear boundaries |

### THE SIMPLICITY TEST (RUN MENTALLY BEFORE IMPLEMENTING)

```
QUESTION 1: Can I solve this with a function instead of a class?
  -> YES: Use a function
  -> NO: Proceed to Q2

QUESTION 2: Can I solve this with 1 class instead of a hierarchy?
  -> YES: Use 1 class
  -> NO: Proceed to Q3

QUESTION 3: Can I solve this with a simple dict/list instead of a custom data structure?
  -> YES: Use dict/list
  -> NO: Justify the custom structure

QUESTION 4: Do I need this abstraction TODAY or am I future-proofing?
  -> FUTURE: DELETE IT. Build it when you need it.
  -> TODAY: Keep it, but make it the simplest version possible
```

### FORBIDDEN COMPLEXITY PATTERNS

These phrases in your thinking = OVERENGINEERING ALERT:
- "In case we need to extend this later..." -> YAGNI
- "For flexibility, let's create an interface..." -> Premature abstraction
- "Let me create a base class for..." -> Do you have 2+ subclasses RIGHT NOW?
- "This should be configurable..." -> Does it NEED to be configurable TODAY?
- "Let me add a registry so we can..." -> Is there more than 1 thing to register?
- "For maintainability, let's add a layer of..." -> Layers ADD complexity, not reduce it
- "Let me create a proper abstraction..." -> "proper" = simple and direct
- "The pattern for this would be..." -> Patterns solve RECURRING problems, not one-offs
</system-context>
HOOK_EOF
exit 0
