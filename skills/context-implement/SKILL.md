---
name: context-implement
description: >
  Context-driven implementation workflow: reads the FULL conversation to extract the
  user's true intent, then plans, executes, self-critiques (Reflexion) and verifies —
  using Chain-of-Thought and ReAct. Use when the user asks to "implement what we
  discussed", "build the feature from this chat", "apply the changes we agreed on",
  "now implement it", or wants code written strictly to the conversation's intent with
  no scope creep. NOT for: greenfield ideas with no prior chat context (brainstorm/plan
  first), pure research or exploration, or debugging an existing bug (use a debugging
  protocol). Do not auto-invoke to write code unless the user asks to implement.
allowed-tools: Read, Write, Bash, Grep, MultiEdit
model: opus
---

# Context-Driven Implementation

**Core:** Analyze chat context -> Plan -> Execute -> Validate -> Deliver

**Request:** "$ARGUMENTS"

> **Cognitive framework:** this workflow runs on Chain-of-Thought + Reflexion + ReAct.
> Read `${CLAUDE_PLUGIN_ROOT}/shared/cognitive-framework.md` for the exact protocol
> (explicit reasoning chain, self-critique phase, reasoning/actions/results with evidence).
>
> **Composed skills** (apply each at its phase, do not re-derive them):
> - `scope-creep-prevention` — active during the whole implementation; ship ONLY what the
>   chat requested, no "while I'm here" extras.
> - `meticulous-code-review` — run over the diff before declaring the work done.
> - `verification-before-completion` — run the real verification commands and confirm
>   output before making any "done/working" claim.

---

## Constraints

| Rule | Description |
|------|-------------|
| Chat Analysis First | Read ALL messages to understand true intent |
| No Assumptions | Never guess what the user wants |
| No Scope Creep | Don't add unrequested features |
| Pattern-Consistent | Follow existing project patterns |

---

## Execution phases

### Phase 1: CHAT CONTEXT ANALYSIS
```markdown
**Message-by-Message:**
- Initial request: [What user first asked]
- Refinements: [How request evolved]
- Constraints mentioned: [Technical preferences]
- Files referenced: [Specific files user mentioned]

**True Request:**
- Explicit: [Direct ask]
- Implicit: [Problem being solved]
- Must NOT have: [Features user rejected]
```

### Phase 2: PROJECT CONTEXT
1. Read relevant project files
2. Understand existing patterns
3. Map integration points
4. Identify dependencies

### Phase 3: IMPLEMENTATION PLANNING
```markdown
**Feature:** [From chat]
**Why:** [User's reason from chat]
**Where:** [Which files]
**How:** [Technical approach]
**Pattern:** [Existing pattern to follow]
```

### Phase 4: IMPLEMENTATION
For each feature:
```typescript
// User requested: [specific feature from chat]
// Following pattern from: [existing-file.ts:line]
[implementation code]
```

### Phase 5: REFLEXION
- Implemented what the user ACTUALLY requested?
- Used the user's preferred technical approach?
- Addressed ALL aspects of the request?
- Added anything the user didn't ask for? (remove it)

### Phase 6: RESULTS
```markdown
## Implementation Summary

**User's Request:** [From chat analysis]

**Implemented:**
- [Feature 1]
- [Feature 2]

**Files Modified:**
- `file.ts` - [Changes]

**Tests:** Passing

**Verification:**
- [Scenario from chat]: Works as expected
```

---

## Success criteria

1. Implements the user's exact request from the conversation
2. Uses the user's preferred technical approach
3. Follows project patterns
4. Contains ONLY requested features
5. All tests passing

**Quality Metric:** "Did I implement EXACTLY what the user asked for in the chat?"

---

Now proceeding with implementation of: **$ARGUMENTS**
