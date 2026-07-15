# Refactor — Execution Phases (full detail)

The SKILL.md carries the safety rules, the MANDATORY safety-net lifecycle, tool priority,
and composition. This file is the step-by-step execution mechanics and the closing
verification of the safety-net cycle.

---

## Step 1: PARSE TAGGED FILES
Extract `@` tagged paths from the arguments. Only process explicitly tagged files.

## Step 2: DEEP ANALYSIS
```markdown
**File:** [path]
**Exports:** [functions, types, constants]
**Dependencies:** [what imports this file]
**Patterns:** [conventions used]
**Risk Areas:** [what could break]
```

## Step 3: STRATEGY DECISION

| Complexity | Indicators | Approach |
|------------|------------|----------|
| Low | <5 importers, clear split points | Direct refactoring |
| Medium | 5-15 importers, specific concerns | Focused analysis (2-3 agents) |
| High | 15+ importers, central code | Comprehensive analysis (4+ agents) |

## Step 4: REFACTORING EXECUTION

**Phase 1: Directory Preparation**
```markdown
1. Create new directories if needed
2. Verify structure matches project patterns
```

**Phase 2: File Creation (Bottom-Up)**
```markdown
1. Type definition files first
2. Constants/enums
3. Utilities/helpers
4. Core functionality
5. Index/barrel files
```

**Phase 3: Content Migration**
```markdown
- Copy code with exact preservation
- Maintain all exports with same signatures
- ⚠️ NO comments about "deprecated", "moved from", "refactored"
- Code must look NATIVE in new location
```

**Phase 4: Import Updates**
```markdown
1. Update internal imports in split files
2. Create proper exports
3. Verify no circular dependencies
4. Update ALL consumers systematically
```

## Step 5: VALUE ASSESSMENT

**✅ Worth Refactoring:**
- File >500 lines (components), >1000 lines (utilities)
- Clear SoC violations
- Mixed UI/business logic
- Poor testability

**❌ NOT Worth Refactoring:**
- Already well-structured despite size
- Splitting creates artificial boundaries
- Over-engineering for current needs

**If NOT worth it:** Ask user before proceeding.

## Step 6: VERIFICATION

Close out the safety-net cycle (AFTER + CLEANUP). Run from your project's environment:

```bash
# 1) Ephemeral characterization suite: must stay 100% green (behavior preserved)
python -m pytest tests/_regression_guard/ -v

# 2) The real repo suite affected by the refactor (do NOT start a dev server)
python -m pytest tests/ -v        # backend tests
# run your frontend test runner too, only if you touched frontend code

# 3) CLEANUP: delete the ephemeral scaffolding and confirm a clean working tree
rm -rf tests/_regression_guard/ && git status --short
```

```markdown
- [ ] Ephemeral characterization suite green BEFORE and AFTER (behavior preserved)
- [ ] `tests/_regression_guard/` deleted; `git status` shows no trace
- [ ] Pre-existing-bug tests graduated to permanent (if applicable)
- [ ] TypeScript compilation: ✅
- [ ] All imports resolve: ✅
- [ ] Tests passing: ✅
- [ ] No circular dependencies: ✅
```

## Step 7: RESULTS
```markdown
## Refactoring Summary

**Files Processed:**
- ✅ [file] - Refactored successfully
- ⚠️ [file] - Skipped (not worth refactoring)

**Structure Changes:**
Before: `original-file.ts (500 lines)`
After:
├── feature-a/
│   ├── component.tsx
│   └── logic.ts
└── index.ts (barrel)

**Dependencies Updated:** [N files]
**Verification:** All checks passed
```
