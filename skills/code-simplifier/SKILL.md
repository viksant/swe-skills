---
name: code-simplifier
description: >
  Simplifies and refines code for clarity, consistency, and maintainability while
  preserving all functionality. Use when: after ANY implementation/refactor,
  user says "simplify this", "too complex", "make it cleaner", "hard to read",
  "refine this code", before meticulous-code-review in post-implementation chain.
  NOT for: adding new functionality, fixing bugs, or making behavioral changes.
version: 1.0.0
---

# Code Simplifier

> **Core Philosophy**: "Readable, explicit code over overly compact solutions. Clarity over brevity."

> **Frontend (React / TypeScript / Tailwind v4)?** This skill is language-agnostic. For the
> React/Tailwind-specific slop patterns — giant components, reinvented hooks/primitives, JS
> breakpoints, imperative `style={{animation}}`, dead `@keyframes` — also apply dedicated
> frontend clean-code guidance.

## Why This Skill Exists

Even working code can be unnecessarily complex. This skill ensures code is:
- Clear and maintainable
- Consistent with project standards
- Free of unnecessary complexity
- Readable by future maintainers

---

## The Iron Laws

```
1. PRESERVE FUNCTIONALITY - Never change what code does, only how
2. CLARITY OVER BREVITY - Explicit is better than compact
3. NO NESTED TERNARIES - Use if/else or switch instead
4. FOLLOW PROJECT PATTERNS - Consistency with existing code
```

---

## Refinement Checklist

### 1. Functionality Preservation (CRITICAL)
```
□ All original features remain intact
□ All outputs are identical
□ All behaviors preserved
□ No side effects changed
```

### 2. Project Standards Application
```
□ ES modules with proper import sorting and extensions
□ Prefer `function` keyword over arrow functions
□ Explicit return type annotations for top-level functions
□ React components with explicit Props types
□ Proper error handling patterns (avoid try/catch when possible)
□ Consistent naming conventions
```

### 3. Clarity Enhancement
```
□ Reduced unnecessary complexity and nesting
□ Eliminated redundant code and abstractions
□ Clear variable and function names
□ Consolidated related logic
□ Removed unnecessary comments (code should be self-documenting)
□ NO nested ternary operators
□ Explicit code over dense one-liners
```

### 4. Balance Check (Avoid Over-Simplification)
```
□ Did not reduce code clarity
□ Did not create "clever" solutions that are hard to understand
□ Did not combine too many concerns
□ Did not remove helpful abstractions
□ Did not prioritize "fewer lines" over readability
□ Code remains easy to debug and extend
```

---

## Overengineering Detection (PRIORITY CHECK)

Before checking for code style issues, FIRST check for structural overengineering:

### Structural Red Flags (Fix These FIRST)

```
□ Class with only 1 method → Convert to function
□ Base class with only 1 subclass → Remove hierarchy, use concrete class
□ Factory that creates only 1 type → Replace with direct instantiation
□ Interface/ABC with only 1 implementation → Use concrete type
□ Registry/Plugin system for < 5 items → Use dict literal or if/else
□ Strategy pattern for 2 strategies → Use if/else or function parameter
□ Builder pattern for simple objects → Use constructor with defaults
□ Event system with 1 publisher + 1 subscriber → Direct function call
□ Config class for < 5 values → Use module-level constants
□ Generic<T> used with only 1 type → Use the concrete type
□ Service layer that just proxies to repository → Remove service, call repo directly
□ Middleware chain with 1 middleware → Direct function call
□ 3+ files created for something that fits in 1 → Merge files
```

### The Simplicity Audit
For each abstraction found, ask:
1. **How many concrete consumers exist RIGHT NOW?** (not "might exist")
2. **Is the abstraction simpler than the concrete code it replaced?**
3. **Could a junior dev understand this without explanation?**

If any answer is unfavorable → SIMPLIFY. Remove the abstraction.

### Overengineering Fix Examples

```python
# OVERENGINEERED: Registry pattern for 2 formatters
class FormatterRegistry:
    _formatters: dict[str, type[BaseFormatter]] = {}
    @classmethod
    def register(cls, name: str, formatter: type[BaseFormatter]):
        cls._formatters[name] = formatter
    @classmethod
    def get(cls, name: str) -> BaseFormatter:
        return cls._formatters[name]()

# SIMPLIFIED: Direct dict
FORMATTERS = {
    "json": format_as_json,
    "text": format_as_text,
}
def get_formatter(name: str):
    return FORMATTERS[name]
```

```python
# OVERENGINEERED: Abstract validator hierarchy
class BaseValidator(ABC):
    @abstractmethod
    def validate(self, data: dict) -> bool: ...

class LengthValidator(BaseValidator):
    def __init__(self, max_length: int):
        self.max_length = max_length
    def validate(self, data: dict) -> bool:
        return len(data.get("text", "")) <= self.max_length

# SIMPLIFIED: Plain function
def validate_length(text: str, max_length: int) -> bool:
    """Check if text is within max length."""
    return len(text) <= max_length
```

---

## Anti-Patterns to Fix

### Nested Ternaries
```typescript
// BAD
const result = a ? b ? 'x' : 'y' : c ? 'z' : 'w';

// GOOD
if (a) {
  return b ? 'x' : 'y';
}
return c ? 'z' : 'w';

// OR use switch for multiple conditions
```

### Over-Compact One-Liners
```typescript
// BAD - Dense and hard to read
const data = items.filter(x => x.active).map(x => ({ ...x, processed: true })).reduce((a, b) => ({ ...a, [b.id]: b }), {});

// GOOD - Clear steps
const activeItems = items.filter(item => item.active);
const processedItems = activeItems.map(item => ({ ...item, processed: true }));
const dataById = processedItems.reduce((acc, item) => {
  acc[item.id] = item;
  return acc;
}, {});
```

### Unnecessary Abstraction
```typescript
// BAD - Over-abstracted for single use
const createHandler = (fn) => (e) => fn(e.target.value);
const handleChange = createHandler(setValue);

// GOOD - Direct and clear
function handleChange(e) {
  setValue(e.target.value);
}
```

### Arrow Functions Where Named Functions Are Clearer
```typescript
// BAD - Anonymous and harder to debug
const processData = async (data) => {
  // ...
};

// GOOD - Named, clearer in stack traces
async function processData(data) {
  // ...
}
```

---

## Process

1. **Identify** recently modified code sections
2. **Analyze** for clarity and consistency opportunities
3. **Apply** project-specific best practices
4. **Verify** all functionality remains unchanged
5. **Confirm** refined code is simpler and more maintainable
6. **Document** only significant changes

---

## Output Format

```markdown
## Code Simplification Review

### Files Analyzed
- [file1.ts]: [brief description]
- [file2.py]: [brief description]

### Simplifications Applied

**1. [Location: file:line]**
- Before: [brief description of complex code]
- After: [brief description of simplified code]
- Reason: [why this improves clarity]

**2. [Location: file:line]**
...

### Functionality Verification
- [X] All original behaviors preserved
- [X] No side effects changed
- [X] Tests still pass (if applicable)

### Summary
[Brief summary of improvements made]
```

---

## Integration with Workflow

This skill runs AFTER writing code, BEFORE other reviews:

**Order**:
1. Write/refactor code
2. **code-simplifier** ← YOU ARE HERE (is code CLEAR?)
3. meticulous-code-review (is code GOOD?)
4. meticulous-code-review (does code have BUGS?)
5. verification-before-completion (does code WORK?)

---

## The Bottom Line

**Simplify without sacrificing clarity.**

- Complex code that "works" → Simplify
- Dense one-liners → Expand for readability
- Nested ternaries → Convert to if/else or switch
- Unnecessary abstractions → Remove
- Inconsistent patterns → Align with project standards

The goal is code that future maintainers will thank you for.

## Example Flow

```
User: "Implement the access-level resolver"
→ Claude writes implementation with nested ternary: `const level = user ? user.role === 'admin' ? 'full' : 'limited' : 'none'`
→ code-simplifier activates in post-implementation chain
→ Identifies nested ternary → converts to if/else
→ Identifies dense chained `.filter().map().reduce()` → separates into named steps
→ Verifies: all original behaviors preserved, outputs identical
→ Passes simplified code to next review step
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Simplification changed behavior | Didn't verify outputs match | Always test with same inputs before and after; preserve ALL side effects |
| Code became harder to read after "simplifying" | Over-combined logic or removed helpful abstraction | Balance Check: did simplification reduce clarity? If yes, revert |
| Removed necessary comment | Assumed code was self-documenting | Only remove comments that state WHAT; keep comments that explain WHY |
| Project patterns not followed | Didn't check neighboring files | Read 2-3 similar files first to match conventions |
