# Optimize — The 6-Phase Protocol (full detail)

Full templates and per-phase instructions for the optimization analysis. The SKILL.md
carries the summary and the non-negotiable principles; this file is the operational
reference for each phase's output.

---

## Phase 1: Codebase Analysis

**Objective:** Understand current implementation before suggesting changes.

```markdown
## Current Implementation Analysis

**Target:** [Component/System]
**Files:** [List with line counts]
**Patterns Used:** [Current patterns]
**Dependencies:** [What it depends on]
**Dependents:** [What depends on it]
**Performance Characteristics:** [Current metrics if available]
```

**Questions to answer:**
- How does this codebase handle similar cases?
- What patterns are established?
- Are there existing optimizations?
- What anti-patterns exist?

---

## Phase 2: Query Intent Classification

**Objective:** Determine if user is asking or asserting.

| User Phrasing | Intent | Response |
|---------------|--------|----------|
| "Should I...?" | Question | Explore together |
| "I think..." | Assertion (needs validation) | Validate critically |
| "Let's optimize..." | Assertion | Review approach critically |
| "Is this good?" | Question | Provide honest assessment |
| "We should..." | Assertion | Challenge if wrong |

**CRITICAL RULE:**
- Assertions require STRICT validation
- Questions require EXPLORATION
- Unclear? → AskUserQuestion

---

## Phase 3: Official Documentation Research

**MANDATORY: Use ONE of these approaches:**

### Option A: Context7 MCP (Preferred)
```yaml
# Step 1: Resolve library/framework
Tool: mcp__context7__resolve-library-id
Input: [Library name]

# Step 2: Query official documentation
Tool: mcp__context7__query-docs
Input:
  library_id: [from step 1]
  topic: [optimization topic]
  tokens: 5000-8000
```

### Option B: Docfork MCP
```yaml
Tool: mcp__docfork__docfork_search_docs
Input: [Library + topic]
```

**Documentation Analysis Output:**
```markdown
## Official Documentation Analysis

**Source:** [Context7/Docfork]
**Library:** [Name and version]
**Topic:** [Optimization area]

**Official Patterns Found:**
- Pattern 1: [Name] - [Description from docs]
- Pattern 2: [Name] - [Description from docs]

**Best Practices:**
- [Practice 1 from docs]
- [Practice 2 from docs]

**Anti-Patterns Identified:**
- ❌ [Anti-pattern 1 from docs]
- ❌ [Anti-pattern 2 from docs]
```

---

## Phase 4: Architectural Analysis

**MANDATORY: Activate relevant agents**

| Concern | Agent to Activate |
|---------|-------------------|
| System-wide design | `comprehensive-review:architect-review` |
| Async/Performance | a performance-focused subagent |
| Security | a security-focused subagent |
| Multi-domain | a coordination/orchestration subagent |

**Output:**
```markdown
## Architectural Analysis

**Agents Activated:**
- [Agent]: [What they analyzed]

**System-Wide Impact:**
- Components Affected: [List]
- Dependencies: [Map]
- Risk Areas: [List]

**Scalability Assessment:**
- Current Capacity: [Assessment]
- Optimization Impact: [How it affects scale]

**Pattern Compliance:**
- Follows Established Patterns: [Yes/No with evidence]
- Pattern Violations: [List if any]
```

---

## Phase 5: Critical Unbiased Assessment

**CRITICAL: If User is Wrong → CORRECT THEM**

```markdown
## CRITICAL ASSESSMENT

**Your Proposed Optimization:** [What user suggested]

### Problems Identified:

#### Problem 1: [Specific Issue]
- **What's Wrong:** [Clear explanation]
- **Why It's Wrong:** [Evidence from docs/architecture]
- **Impact:** [What will happen]
- **Evidence:** [Documentation/pattern reference]

**Correct Approach:**
[What should be done instead, with evidence]

**I cannot recommend your approach because [specific reasons].**
```

**Anti-Sycophancy Rules:**
- ❌ Don't say "great idea" if it's not
- ❌ Don't validate bad approaches
- ❌ Don't soften criticism
- ✅ Say "this won't work" if it won't
- ✅ Provide evidence for all claims
- ✅ Propose better alternatives

---

## Phase 6: Result Presentation

```markdown
## Optimization Analysis Report

### Executive Summary
- **Target:** [What was analyzed]
- **User Query Type:** [Question/Assertion]
- **Overall Assessment:** [Valid/Needs Correction/Invalid]
- **Recommendation:** [Clear directive]

### Phase 1: Current State Analysis
[Summary]

### Phase 2: Query Intent
[Classification]

### Phase 3: Documentation Research
[Official patterns and validation]

### Phase 4: Architectural Review
[System-wide impact]

### Phase 5: Critical Assessment
[Honest evaluation]

### Final Recommendation
[Clear, evidence-based recommendation]

### Next Steps
[Actionable items]
```
