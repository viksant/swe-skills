---
name: optimize
description: >
  Critical, documentation-validated performance optimization analysis (6-phase protocol)
  that MAY modify source code for speed while preserving behavior. Use when the user
  EXPLICITLY asks to optimize or profile for performance — "optimize this", "make it
  faster", "improve performance", "profile", "reduce latency", "this is slow".
  NOT for: general readability refactoring (use refactor), bug fixing, or read-only
  review; do not auto-invoke to mutate code for performance unless explicitly asked.
allowed-tools: Read, Write, Edit, Bash, Grep, MultiEdit
model: opus
---

> **Core Philosophy:** "Truth over agreement. Excellence over user satisfaction. If the user is wrong, CORRECT THEM."
> **MANDATORY:** All patterns MUST be validated against official documentation.
> **Lens (MCP):** When invoking your sequential-thinking MCP tool, pass `lens: "performance"` (measure P95/baseline before optimizing).

<year_context>
**CURRENT YEAR: 2026**
When searching for documentation, ALWAYS:
- Use "2026" in search queries for current docs
- NEVER search for "2023", "2024", "2025" unless user specifically requests
</year_context>

# ⚡ CRITICAL OPTIMIZATION ANALYSIS

**Request:** "$ARGUMENTS"

---

## 🎯 NON-NEGOTIABLE PRINCIPLES

| Principle | Description |
|-----------|-------------|
| **CRITICAL ANALYSIS** | If user proposes bad optimization → STOP and explain why it's wrong |
| **DOCUMENTATION-FIRST** | ALL recommendations MUST be backed by official docs |
| **ARCHITECTURE REVIEW** | Always analyze system-wide impact |
| **NO SYCOPHANCY** | User is wrong? Say it directly |

---

## 📋 THE 6-PHASE PROTOCOL (MANDATORY)

Run all six phases in order. Each phase has a required output template — the full
templates and per-phase instructions live in **`${CLAUDE_PLUGIN_ROOT}/skills/optimize/references/optimize.md`**.

1. **Codebase Analysis** — understand the current implementation, patterns, deps/dependents, and any existing metrics before proposing changes.
2. **Query Intent Classification** — is the user asking (explore) or asserting (validate strictly)? Unclear → AskUserQuestion.
3. **Official Documentation Research** — MANDATORY. Validate every pattern against official docs via Context7 MCP (`resolve-library-id` → `query-docs`) or Docfork MCP. No assumption-based advice.
4. **Architectural Analysis** — activate the relevant subagents for system-wide impact; for system-wide design consult `comprehensive-review:architect-review` (external, optional).
5. **Critical Unbiased Assessment** — if the proposed optimization is wrong, correct it with evidence. No softening.
6. **Result Presentation** — deliver the structured report with measured recommendations and next steps.

---

## 🤝 COMPOSITION

This skill composes three existing skills — use them, don't reinvent them:
- **meticulous-code-review** — run it on any code you change before presenting results.
- **verification-before-completion** — gate every "done / now faster" claim on real, measured evidence (baseline vs after), never on assumption.
- **consensus-board** — before mutating hot-path code on a CONTESTED bottleneck diagnosis, escalate via `Skill(skill="consensus-board")` so independent lenses (profiling, algorithmic complexity, I/O, memory) must CONVERGE on the real bottleneck first.

---

## ⚠️ BEHAVIOR PRESERVATION GUARANTEE

**Optimization changes ONLY:**
- ✅ Performance (faster execution)
- ✅ Code organization (better structure)
- ✅ Type safety (stricter types)

**Optimization NEVER changes:**
- ❌ Functional behavior (same input → same output)
- ❌ API surface (same exports/signatures)
- ❌ Side effects (identical effects)

**If behavior changes detected → ROLLBACK**

---

## ❌ ANTI-PATTERNS TO AVOID

| Anti-Pattern | Fix |
|--------------|-----|
| Sycophancy | Validate critically, correct if wrong |
| Assumption-Based | Always use Context7/Docfork first |
| Local Optimization Only | Always review architecture |
| Softening Criticism | Be direct: "This won't work because..." |
| Skipping Phases | Complete all 6 phases |

---

## ✅ SUCCESS CRITERIA

1. ✅ **Complete Analysis:** All 6 phases completed
2. ✅ **Documentation-Backed:** All recommendations have official sources
3. ✅ **Architecturally Sound:** System-wide impact reviewed
4. ✅ **Honest Assessment:** User corrected if wrong, validated if right
5. ✅ **Actionable:** Clear recommendations with evidence
6. ✅ **Unbiased:** No sycophancy, direct feedback

---

Now analyzing optimization request: **$ARGUMENTS**
