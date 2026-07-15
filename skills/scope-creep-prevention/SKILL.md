---
name: scope-creep-prevention
description: >
  Prevents tasks from expanding beyond original scope. Use when: implementing features,
  fixing bugs, refactoring, or when tempted to "improve" nearby code, add "helpful"
  features, do "while I'm here" changes. User says "stay focused", "just do what I asked",
  "don't add extras". ALWAYS active during implementation.
  NOT for: exploratory research tasks or when user explicitly asks for broad improvements.
version: 1.0.0
---

# Scope Creep Prevention

## Overview

Simple tasks become massive refactors through unchecked scope expansion. Each "small improvement" compounds into hours of unplanned work.

**Core principle:** Do exactly what was asked. Nothing more. Nothing less.

## The Iron Law

```
COMPLETE THE REQUESTED TASK BEFORE CONSIDERING ANY ADDITIONS
```

If you haven't finished the original request, you cannot add "improvements".

## Scope Creep Red Flags

**STOP immediately when you think:**
- "While I'm here, I should also..."
- "This would be better if I also..."
- "I noticed this nearby code could use..."
- "Let me just clean up this..."
- "It would be incomplete without..."
- "Best practice says I should also..."
- "Future-proofing requires..."
- "This is technically related..."

**ALL of these = scope creep. STOP.**

## The Decision Gate

```
BEFORE making ANY change not explicitly requested:

1. STATE: What was the original request?
2. CHECK: Is this change REQUIRED to complete that request?
   - If NO → DON'T DO IT
   - If YES → Proceed
3. If tempted: Note it for later, continue with original task

"Nice to have" ≠ "Required"
```

## Common Scope Creep Patterns

| Original Task | Scope Creep | Stay Focused |
|--------------|-------------|--------------|
| Fix bug in function X | Refactor entire file | Fix only the bug |
| Add endpoint Y | Restructure API | Add only endpoint Y |
| Update component Z | Add new features | Update only what's needed |
| Fix typo | Rewrite documentation | Fix only the typo |
| Add logging | Implement observability platform | Add only requested logs |
| Update dependency | Upgrade entire stack | Update only that dependency |

## Complexity Creep (Related Anti-Pattern)

Scope creep's cousin is **complexity creep**: implementing the right feature with unnecessary complexity.

**Complexity Creep Red Flags:**
- "Let me create a proper architecture for this..." (a function would suffice)
- "This needs a base class..." (it has 1 subclass)
- "I'll make it configurable..." (3 hardcoded values)
- "For extensibility..." (YAGNI)
- Creating 3+ files for something that fits in 1
- Adding abstraction layers that just proxy to the layer below

**The Fix:** After implementing, ask "Can I make this simpler without losing functionality?" If yes, DO IT.

## Why Scope Creep Happens

1. **Perfectionism**: "While I'm here, might as well make it perfect"
2. **Fear of revisiting**: "I might not come back to fix this"
3. **Over-engineering**: "This might be needed later"
4. **Boredom with simple tasks**: Complex work feels more valuable
5. **Loss of focus**: Forgetting what was originally asked

## The Cost of Scope Creep

- **Time**: 30-minute task → 4-hour rabbit hole
- **Risk**: More changes = more potential bugs
- **Review burden**: Larger PRs = harder to review
- **Context loss**: Original goal gets buried
- **Trust erosion**: "Simple fix" becomes day-long project

## Staying In Scope

### Before Starting
1. **Write down** the exact request
2. **Define done**: What SPECIFIC outcome marks completion?
3. **Set boundaries**: What is explicitly OUT of scope?

### During Work
1. **Check each change**: Is this required for the original task?
2. **Note tangents**: Write down improvements for later, don't act
3. **Timebox**: If task exceeds estimate, STOP and reassess

### When Tempted
1. **Ask**: "Did the user ask for this?"
2. **If no**: Note it, don't do it
3. **If unclear**: Ask the user before proceeding

## Handling Discovered Issues

When you find problems while working:

```
DISCOVERED ISSUE PROTOCOL:

1. Is it blocking the original task?
   - YES → Fix minimally to unblock, note for proper fix later
   - NO → Note it, continue with original task

2. After completing original task:
   - Report discovered issues
   - Let user prioritize
   - Don't assume they want fixes
```

## Valid Scope Extensions

Scope CAN expand when:
- User explicitly requests addition
- Original task is IMPOSSIBLE without the change
- Security vulnerability discovered (report, don't auto-fix)
- Breaking change required (get approval first)

**Always get explicit approval before expanding scope.**

## Quick Reference

| Situation | Action |
|-----------|--------|
| "This code nearby is messy" | Note it, don't touch |
| "I could add X feature too" | Complete task first, then ask |
| "Tests could be better" | Only add tests for changed code |
| "Documentation is outdated" | Only update what you changed |
| "This pattern is old" | Use new pattern for new code only |
| "Found unrelated bug" | Report it, don't fix |

## The Bottom Line

**Do what was asked. Stop when done.**

- Complete the original request
- Report any discovered issues
- Let the user decide what's next

Expanding scope without permission = making decisions that aren't yours to make.

## Example Flow

```
User: "Fix the timeout bug in the worker"
→ While fixing, Claude notices the error handling nearby is messy
→ Scope creep prevention activates: "Did the user ask to refactor error handling? NO"
→ Claude notes the issue for later, completes only the timeout fix
→ Reports: "Timeout fixed. Also noticed error handling in worker.py:89 could be improved — want me to address that separately?"
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Kept adding "small improvements" | Perfectionism override | Re-read original request; ask "did user ask for this?" |
| Task took 3x longer than expected | Scope expanded silently | Timebox check — if exceeding estimate, reassess scope |
| User complained about extra changes | Expanded without permission | Always ask before extending; report discoveries separately |
| Missed a genuinely required change | Over-strict scope control | If change BLOCKS original task, fix minimally and note it |
