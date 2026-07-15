---
name: code-deletion
description: >
  Safe code elimination with two modes: (A) Surgical removal of active features,
  (B) Dead code cleanup with 11-level verification. Use when: user says "remove feature",
  "delete functionality", "clean dead code", "unused code", "eliminate",
  "get rid of", "we don't need this anymore", or any code removal task.
  NOT for: refactoring (changing code structure without removing functionality).
  ALWAYS identify mode (active vs dead) BEFORE proceeding.
version: 2.0.0
---

# Code Deletion

> **Core Philosophy**: "Deletion is permanent. Verification is mandatory. Every removal must be surgical and safe."

> **Frontend dead code after a library migration** — orphaned `@keyframes`, removed
> hooks/primitives (e.g. migrating a UI to a new animation library) — is a Mode-B case. A
> frontend clean-code pass flags them; map 100% of references here before deleting.

## Why This Skill Exists

Code deletion is one of the most dangerous operations:
- Removing active code breaks the system
- Removing dead code that isn't actually dead breaks the system
- Incomplete removal leaves orphaned references
- Hasty deletion introduces bugs

This skill FORCES proper analysis, verification, and user approval before ANY deletion.

---

## The Iron Laws

### For Active Code (Feature Removal)
```
NO FEATURE REMOVAL WITHOUT COMPLETE DEPENDENCY MAPPING
```

### For Dead Code (Cleanup)
```
NO DELETION WITHOUT 100% VERIFICATION THAT CODE IS TRULY UNUSED
```

---

## CRITICAL WARNING: Reference Mapping

**Claude Code has a dangerous tendency to OMIT references when analyzing code to delete.**

### The Problem
When tasked with deletion, Claude often:
- Finds 5 references but there are actually 15
- Misses string-based references (dynamic imports, config keys)
- Ignores test files that import the target
- Skips documentation references
- Overlooks indirect callers (A calls B calls Target)

### The Mandatory Rule
```
MAP 100% OF REFERENCES. NOT 80%. NOT 90%. 100%.

If you think you found all references, YOU PROBABLY DIDN'T.
Search again with different patterns. Search in ALL file types.
```

### Required Search Strategy (DO ALL OF THESE)
1. **Direct imports**: `from X import target` / `import { target }`
2. **String references**: `"target"` / `'target'` in ALL files
3. **Dynamic access**: `getattr(*, "target")` / `obj["target"]`
4. **Partial matches**: `*target*` pattern in case of naming variations
5. **Test files**: Search `tests/` and `*_test.*` explicitly
6. **Config files**: `.json`, `.yaml`, `.yml`, `.env`, `.toml`
7. **Documentation**: `.md`, `.rst`, `.txt` files
8. **Comments**: References in code comments
9. **Database**: Column names, table names, stored procedures
10. **Frontend**: Component names, route definitions, i18n keys

### Verification Checkpoint
Before proceeding with ANY deletion:
```
[ ] I searched with at least 5 different patterns
[ ] I searched in ALL file types, not just code
[ ] I found X references (document exact count)
[ ] I verified each reference manually
[ ] I am 100% confident this is the complete list
```

**If you cannot check ALL boxes, DO NOT PROCEED.**

---

## Critical First Step: Mode Identification

**BEFORE ANY ACTION**, determine the deletion mode:

```
DECISION GATE:

1. Is this code currently being used by the system?
   - YES → MODE A: Feature Removal (Surgical Extraction)
   - NO  → MODE B: Dead Code Cleanup

2. If UNCLEAR → Treat as Active (Mode A) until proven dead
```

### Mode Indicators

| Indicator | Mode A (Active) | Mode B (Dead) |
|-----------|-----------------|---------------|
| User says | "remove feature X", "eliminate functionality" | "clean unused", "dead code", "not used" |
| Code state | Has active callers | Zero references found |
| Impact | Will change behavior | Should change nothing |
| Risk | System instability | False positive deletion |

---

## MODE A: Feature Removal (Active Code)

### When to Use
- User explicitly wants to remove a working feature
- User says: "remove", "eliminate", "delete feature", "don't need X anymore"
- Code IS actively used but user wants it gone

### The Three-Phase Protocol

#### Phase 1: Complete Analysis [MANDATORY - DO NOT SKIP]

```markdown
## Feature Analysis: [Feature Name]

### 1. Entry Points (How users/system access this)
- UI elements: [list]
- API endpoints: [list]
- Background jobs: [list]
- Event handlers: [list]

### 2. Core Implementation
- Main files: [list with line counts]
- Models/schemas: [list]
- Services: [list]

### 3. Data Flow
[Diagram or description of how data moves through feature]

### 4. Database Footprint
- Tables: [list]
- Columns: [list]
- Triggers: [list]
- Data volume: [estimate]

### 5. Integration Points
- Tightly coupled: [components that REQUIRE this feature]
- Loosely coupled: [components that USE this feature]
- Event publishers: [what triggers this feature]

### 6. Hidden References
- String-based references: [list]
- Dynamic imports: [list]
- Config keys: [list]
```

#### Phase 2: Cleanup Plan [PRESENT TO USER - WAIT FOR FEEDBACK]

```markdown
## Cleanup Plan: [Feature Name]

### Files to DELETE completely (X files)
1. `path/to/file.py` - [reason]
2. `path/to/component.tsx` - [reason]

### Files to MODIFY (Y files)
1. `path/to/service.py`
   - Line 45: Remove import
   - Line 123: Remove function call

### Database changes
- Archive table X (preserve data)
- Remove trigger Y

### Configuration cleanup
- Remove env vars: [list]
- Update config files: [list]

### Impact summary
- Lines to remove: X
- Files to delete: Y
- Files to modify: Z

**YOUR FEEDBACK NEEDED:**
1. Proceed with full plan?
2. Preserve any files?
3. Any concerns?
```

#### Phase 3: Execution [ONLY AFTER USER APPROVAL]

```
EXECUTION CHECKLIST:
[ ] User approved the plan
[ ] Backup created
[ ] Sever connections first (event handlers, routes)
[ ] Remove components in dependency order
[ ] Clean up references
[ ] Verify system still works after each major cut
[ ] Run tests
[ ] Archive data (don't delete)
```

### Rollback Plan (Always Ready)
```
- Git branch preserved: feature/[name]-backup-[date]
- Database backup: [name]_data_[date].sql
- Rollback script: rollback_[name].sh
```

---

## MODE B: Dead Code Cleanup

### When to Use
- User wants to clean unused/obsolete code
- User says: "dead code", "unused", "cleanup", "not used anymore"
- Code appears to have NO active references

### The 11-Level Verification System (Enhanced)

**ALL 11 levels must pass before deletion is safe:**

```python
# ===== CORE LEVELS (1-7) =====

# Level 1: Direct References
- Search: exact function/class name usage
- Tool: LSP find_references FIRST, then ast-grep
- Pattern: sg -p '{name}($$$)' -l python
- Pass if: Zero matches outside definition

# Level 2: Indirect References (Inheritance/Composition)
- Search: classes that inherit or compose
- Tool: AST analysis of class hierarchies
- Pattern: sg -p 'class $CLASS({name}): $$$' -l python
- Pass if: Not extended or composed anywhere

# Level 3: Dynamic References
- Search: getattr(), __import__(), importlib, globals(), eval()
- Tool: ast-grep for dynamic patterns
- Patterns:
  - sg -p 'getattr($OBJ, "{name}")' -l python
  - sg -p 'globals()["{name}"]' -l python
  - sg -p '__import__("{name}")' -l python
- Pass if: Not accessed dynamically

# Level 4: String References (ENHANCED)
- Search: name in strings that match DEFINED function names
- Tool: Cross-reference strings with defined symbols
- CRITICAL: Only flag if string EXACTLY matches a defined function
- Pass if: No string literal equals the function name

# Level 5: Test References
- Search: usage in test files
- Tool: grep in tests/ directory
- Pass if: Not tested OR tests are for this specific code

# Level 6: Documentation References
- Search: mentioned in docs, comments, README
- Tool: grep in *.md, *.rst, *.txt
- Pass if: Not documented as public API

# Level 7: External API Exposure
- Search: exported in __init__.py, public APIs
- Tool: check module exports
- Pass if: Not part of public interface

# ===== ADVANCED LEVELS (8-11) - NEW =====

# Level 8: Dict/List/Tuple Values (NEW)
- Search: functions used as values in data structures
- Tool: ast-grep for assignment patterns
- Patterns:
  - sg -p '{"$KEY": {name}}' -l python     # Dict value
  - sg -p '[{name}, $$$]' -l python        # List element
  - sg -p '({name}, $$$)' -l python        # Tuple element
  - sg -p 'handlers = {$$$: {name}}' -l python  # Handler maps
- Pass if: Not assigned as value in any data structure

# Level 9: Callback/Argument Patterns (NEW)
- Search: functions passed as arguments to other functions
- Tool: ast-grep for call patterns
- Patterns:
  - sg -p 'Depends({name})' -l python      # FastAPI dependency
  - sg -p 'register({name})' -l python     # Registration patterns
  - sg -p 'add_handler({name})' -l python  # Event handlers
  - sg -p 'callback={name}' -l python      # Callback args
  - sg -p 'on_event($$$, {name})' -l python # Event listeners
  - sg -p 'app.add_api_route($$$, {name})' -l python  # Route handlers
- Pass if: Not passed as argument to any function

# Level 10: Inheritance Chain (NEW)
- Search: methods that might be called via super() or polymorphism
- Tool: Build inheritance graph, track super() calls
- Analysis:
  1. Build class_bases dict: {ChildClass: [ParentClass, ...]}
  2. Find all super().method() calls in child classes
  3. If method exists in parent AND child overrides it → parent method IN USE
- Patterns:
  - sg -p 'super().{name}($$$)' -l python  # Direct super call
  - sg -p 'class $CHILD($PARENT): $$$' -l python  # Inheritance
- Pass if: Method not called via super() and no child overrides it

# Level 11: Type Annotation References (NEW)
- Search: functions/classes referenced in type hints
- Tool: ast-grep for annotation patterns
- Patterns:
  - sg -p 'def $FUNC($$$) -> {name}:' -l python     # Return type
  - sg -p 'def $FUNC($ARG: {name}):' -l python      # Param type
  - sg -p '$VAR: {name} = $$$' -l python            # Variable annotation
  - sg -p 'Callable[[$$$], {name}]' -l python       # Callable return
  - sg -p 'List[{name}]' -l python                  # Generic type
  - sg -p 'Optional[{name}]' -l python              # Optional type
  - sg -p 'Union[$$$, {name}]' -l python            # Union type
- Pass if: Not referenced in any type annotation
```

### Verification Report Format

```markdown
## Dead Code Verification: [Element Name]

### Element Details
- Type: [file/class/method/variable]
- Location: `path/to/file.py:line`
- Size: X lines

### Verification Results (11 Levels)
| Level | Check | Result |
|-------|-------|--------|
| 1 | Direct references | PASS (0 found) |
| 2 | Indirect references (inheritance) | PASS (0 found) |
| 3 | Dynamic references (getattr/globals) | PASS (0 found) |
| 4 | String references (exact match) | PASS (0 found) |
| 5 | Test references | PASS (0 found) |
| 6 | Documentation | PASS (0 found) |
| 7 | API exposure (__init__.py) | PASS (not exported) |
| 8 | Dict/List/Tuple values | PASS (0 found) |
| 9 | Callback/Argument patterns | PASS (0 found) |
| 10 | Inheritance chain (super calls) | PASS (0 found) |
| 11 | Type annotation references | PASS (0 found) |

### Confidence: 100% - SAFE TO REMOVE
```

### What to Do If Any Level Fails

```
Level 1-2 fails  → Code is ACTIVE, use Mode A (Feature Removal)
Level 3 fails    → Investigate dynamic usage, may be active
Level 4 fails    → Check if string reference is active code (exact match only)
Level 5 fails    → Consider if tests should be removed too
Level 6 fails    → Update documentation after removal
Level 7 fails    → This is public API, requires deprecation process
Level 8 fails    → Function is used in data structure (handler map, etc.)
Level 9 fails    → Function is passed as callback/dependency - ACTIVE CODE
Level 10 fails   → Method is used via inheritance/super() - ACTIVE CODE
Level 11 fails   → Type is used in annotations - may indicate active usage
```

---

## Search Strategy

For detailed search tool hierarchy and patterns, see `references/search-strategy.md`.

---

## Framework-Specific Patterns

For auto-exclude patterns, false positive detection, inheritance chain analysis, and string-based reference matching, see `references/framework-patterns.md`.

---

## Red Flags - STOP and Verify More

### Mode A (Feature Removal)
- "I think I found all the references" → Search more
- "This looks like all of it" → Verify systematically
- "We can fix any breakage later" → NO, verify NOW

### Mode B (Dead Code)
- "It's probably not used" → Verify ALL 7 levels
- "No one calls this anymore" → Search the ENTIRE codebase
- "Tests will catch it" → Tests might not cover all usage

---

## Anti-Patterns to Avoid

### "Delete now, fix later"
**Problem**: Broken code ships to users.
**Fix**: Complete verification before ANY deletion.

### "I searched and found nothing"
**Problem**: Incomplete search patterns.
**Fix**: Use ALL search methods (direct, dynamic, string).

### "It's old code, must be dead"
**Problem**: Old != unused.
**Fix**: Verify with evidence, not assumptions.

### "Just delete the whole folder"
**Problem**: May contain shared utilities.
**Fix**: Analyze each component individually.

### "The feature is disabled, safe to remove"
**Problem**: Disabled code may still be imported.
**Fix**: Verify zero references, not just disabled flags.

---

## Output Formats

### Feature Removal Complete
```markdown
## Feature Removed: [Name]

### Summary
- Files deleted: X
- Files modified: Y
- Lines removed: Z
- Data archived: [location]

### System Status
- All tests passing
- No broken imports
- APIs return appropriate responses

### Rollback Available
- Branch: feature/[name]-backup-[date]
- Expires: [date]
```

### Dead Code Cleanup Complete
```markdown
## Dead Code Cleaned: [Scope]

### Removed
- [X] `file1.py` - entire file (unused)
- [X] `Class.method()` in `file2.py` - never called
- [X] Unused imports in `file3.py`

### Verification
- All 7 levels passed for each removal
- Confidence: 100%

### Impact
- Lines removed: X
- Bundle size: -Y KB
- No functionality affected
```

---

## Invoking This Skill

Invoke this skill directly as `/swe-skills:code-deletion` — it drives both modes:
Mode A (surgical feature removal) and Mode B (verified dead-code cleanup with the
11-level verification). Or apply its principles directly in any code-deletion scenario.

---

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Deleted code that was actually used | Incomplete reference search | Use ALL 11 verification levels; search with 5+ patterns |
| Mode B (dead) code was actually active | Framework-specific usage missed | Check `references/framework-patterns.md` auto-exclude list |
| Orphaned references after deletion | Didn't search all file types | Search configs, docs, tests, comments — not just code |
| User rejected cleanup plan | Insufficient impact analysis | Always present plan with file counts and wait for approval |

## The Bottom Line

**For Active Code**: Map everything → Plan everything → Get approval → Execute carefully

**For Dead Code**: Verify 7 levels → 100% confidence → Then delete

**When in doubt**: Treat as active code and use Mode A.

One false positive (deleting used code) is worse than leaving dead code.
