---
name: deep-review
description: >
  Feature-focused deep review with dynamic multi-agent analysis: resolve which specialists a
  change genuinely needs, run them in parallel, then synthesize a prioritized, evidence-based
  report saved to disk. Use when the user says "deep review", "review this feature", "review
  before done", "any bugs / is it safe / will it scale", or after a non-trivial change lands.
  NOT for: a quick single-file glance (apply meticulous-code-review directly), pure docs/config
  changes, or writing the plan (use /swe-skills:write-plans).
disable-model-invocation: true
allowed-tools: Read, Write, Bash, Grep, Task
model: opus
---

> **Framework:** See `${CLAUDE_PLUGIN_ROOT}/shared/cognitive-framework.md` for CoT/Reflexion/ReAct details.

# 🔬 FEATURE-FOCUSED DEEP REVIEW — Multi-Agent Dynamic Analysis

**Core:** Review what the user asked for using the minimum set of specialized perspectives that
genuinely add signal — no blind spots, no padding.

**Request:** "$ARGUMENTS"

**Composed quality skills (always on):** this review applies `meticulous-code-review` (the
quality floor for any non-trivial code change) and `scope-creep-prevention` as protocol skills —
apply them directly, don't dispatch them as agents.

---

## 🎯 SCOPE DISCIPLINE

| Do | Don't |
|----|-------|
| Review ONLY the files/features mentioned | Expand to the entire codebase |
| Deep analysis with the agents that genuinely add signal | Pad the agent list to look thorough, OR skip an agent that would catch a real blind spot |
| Specific `file:line` references | Generic advice |
| Quantified impact metrics | Vague concerns |

> **Default = no sweep.** Scope discipline is the default: review only the files/features named.
> The opt-in flag `--sweep` is the sole exception — with it, the review ALSO surfaces technical
> debt ADJACENT to the reviewed files, prioritized by impact×effort (see the **"Adjacent Debt
> Sweep"** section below). Without the flag, this table governs unchanged.

---

## 🧹 ADJACENT DEBT SWEEP (opt-in `--sweep`)

**Off by default — SCOPE DISCIPLINE governs.** Only when `$ARGUMENTS` carries the `--sweep` flag
does the review reach PAST the named files into the technical debt ADJACENT to the reviewed
diff/feature (its callers, siblings in the same module, shared helpers it touches).

**How the sweep works (only under `--sweep`):**
1. **Impact axis** — reuse the `impact-analyzer` agent (already in the PHASE 1 resolution table)
   to map the blast radius of the reviewed change and rank adjacent debt by how many consumers /
   critical paths it touches.
2. **Effort axis** — estimate each adjacent item's fix cost (LOC, files, risk).
3. **Prioritize by impact×effort** — surface high-impact / low-effort items first; park
   high-effort / low-impact ones as noted-only.
4. **Contrast with `battle-tested-patterns`** — run the adjacent findings through the skill to
   confirm the proposed direction matches a production-proven pattern before recommending it.

Report sweep findings in a clearly separated **"Adjacent Debt (swept)"** block so they never
dilute the requested review. **Without `--sweep`, skip this section entirely — SCOPE DISCIPLINE
stays intact.**

---

## 🧠 PHASE 1: DYNAMIC AGENT RESOLUTION (MANDATORY)

**YOU MUST resolve which perspectives to invoke BEFORE any analysis.**

### Step 1: Extract Signals from Request

Parse `$ARGUMENTS` for:
- **Keywords** (e.g., "security", "performance", "queue", "database")
- **File paths** (e.g., an auth module, a queue module, a UI component)
- **Features** (e.g., "the checkout flow", "message processing", "the search index")
- **Concerns** (e.g., "is it safe?", "can it scale?", "is it correct?")

### Step 2: Match Against the Resolution Table

**Scan every row, then select by CONTRIBUTION, not by keyword match.** A matched signal makes a
perspective a *candidate*; invoke it only if it would genuinely find something a careful
generalist read would miss. One stray keyword is not a mandate. Right-sizing the set IS the
skill: three sharp perspectives beat seven overlapping ones.

| Domain | Signals (keywords / files / concerns) | Perspective | Type | Focus |
|--------|---------------------------------------|-------------|------|-------|
| **Code Quality** | any non-trivial code review, "bugs", "patterns", "code smell", >50 lines | `meticulous-code-review` | skill | Bugs, patterns, maintainability |
| **Simplicity** | "complex", "hard to read", "simplify", "too many files" | `code-simplifier` | skill | Unnecessary abstractions, over-engineering |
| **Security** | "auth", "JWT", "OWASP", "injection", "XSS", "permission", user-input handling | `security-guardian` | agent | Vulnerabilities with severity scoring |
| **Performance** | "slow", "async", "latency", "throughput", "connection pool", "bottleneck" | `async-performance-guardian` | agent | Async bottlenecks, capacity ceilings |
| **Architecture** | "pattern", "design", "architecture", "coupling", "cohesion" | `battle-tested-architect` (+ `battle-tested-patterns` skill) | agent + skill | Production-proven pattern validation |
| **Blast Radius** | refactors, shared modules, core changes, changes affecting 3+ consumers | `impact-analyzer` | agent | Dependency mapping, affected files |
| **Risk** | critical paths, production data, tenant isolation, auth changes | `risk-assessor` | agent | Risk score 0-100 |
| **Truthfulness** | claims without evidence, "verify", "fact-check", assertions about behavior | `verify-claims` | skill | Verify claims against real code |
| **Domain-specific** | any subsystem with a dedicated expert — database, queue, frontend, LLM, telemetry, testing, external API, etc. | a matching `<domain>-specialist` agent **if the host project defines one**; otherwise native `general-purpose` / `Explore` | agent | Subsystem-specific correctness |

### Step 3: Discover Additional Perspectives via File Inspection

After identifying the files in scope:
1. **Read the imports** of the target files.
2. **Map dependencies** to domains.
3. **Add a perspective** for each undiscovered domain (a matching host specialist if one exists,
   else native `general-purpose` / `Explore`).

```
Example:
  Target: a module in scope
  Its imports pull in a queue client → add the host's queue specialist, else general-purpose
  Its imports pull in the core engine → add the host's core specialist, else general-purpose
```

### Step 4: Final Selection

- **Baseline:** `meticulous-code-review` for any non-trivial code change (quality floor).
- **Add specialists by contribution**, up to ~7 (beyond that, diminishing returns and
  overlapping noise).
- **A single-domain, contained change may warrant just the baseline** — that is a valid,
  non-lazy outcome. Don't conjure a second perspective to feel thorough.
- **`verify-claims`** when your synthesis makes a large body of claims (~100+ lines) worth
  cross-checking — not as a reflex.

```markdown
## Agent Resolution Result

**Request signals:** [keywords, files, concerns extracted]

**Perspectives selected (N):**
| # | Perspective | Type | Reason for Selection |
|---|-------------|------|---------------------|
| 1 | meticulous-code-review | skill | Baseline ONLY if the diff touches source code — docs/config don't need it |
| 2 | [perspective] | [skill/agent] | [Matched keyword/file/dependency] |
| ... | ... | ... | ... |

**Perspectives NOT selected:** [List with reason why they're not relevant]
```

---

## ⚡ PHASE 2: PARALLEL INVOCATION

**Dispatch every selected AGENT row IN PARALLEL using the Task tool** (single message, multiple
Task calls). **Apply every SKILL row as a protocol skill** (meticulous-code-review,
code-simplifier, verify-claims, battle-tested-patterns) — those are not agents.

For EACH agent, provide:
```
Task(
  subagent_type="[agent-name]",
  prompt="Deep review of: [feature/files]

  SCOPE: [exact files and lines]
  FOCUS: [what to analyze within your domain]
  REQUEST CONTEXT: $ARGUMENTS

  Return: findings with file:line, severity, and specific recommendations."
)
```

**Parallelization rules:**
- Independent agents → ALL in parallel (single message with multiple Task calls).
- Dependent results (e.g., `impact-analyzer` needs the file list first) → sequential where needed.

---

## 📊 PHASE 3: CHAIN-OF-THOUGHT ANALYSIS (Your Own)

While the agents work, perform your own analysis:

**For each aspect:**
```markdown
**Question:** Is [aspect] handled correctly?

**Reasoning:**
1. Data comes from: [source at file:line]
2. Validation at: [location] - [sufficient/insufficient] because [reason]
3. Risk level: [X] because [evidence]

**Conclusion:** [Verdict with reasoning]
```

---

## 🔄 PHASE 4: REFLEXION & SYNTHESIS

### Merge Findings

1. **Collect** all agent reports.
2. **Deduplicate** issues found by multiple perspectives (note consensus).
3. **Cross-validate** conflicting findings.
4. **Prioritize** by severity: CRITICAL > HIGH > MEDIUM > LOW.
5. **Add your own** findings from Phase 3.

### Self-Critique
- Did I invoke ALL relevant perspectives? (Re-scan the resolution table.)
- Did any agent find something I missed?
- Are there conflicts between findings? → Resolve with evidence.
- Does every finding have a `file:line`?
- Did I explain WHY, not just WHAT?

---

## 📋 PHASE 5: UNIFIED REPORT

```markdown
## 🔬 Deep Review Report: [Feature Name]

**Scope:** [Files analyzed]
**Perspectives Consulted:** [N]
| Perspective | Domain | Key Finding |
|-------------|--------|-------------|
| [name] | [domain] | [1-line summary] |

**Overall Health:** 🟢 Healthy / 🟡 Concerns / 🔴 Critical Issues

---

### 🚨 Critical Issues (IMMEDIATE)
| # | Issue | Location | Found By | Impact | Fix |
|---|-------|----------|----------|--------|-----|
| 1 | [Issue] | `file:line` | [who found it] | [Impact] | [Specific fix] |

### ⚠️ High Priority (THIS SPRINT)
| # | Issue | Location | Found By | Impact | Fix |
|---|-------|----------|----------|--------|-----|

### 💡 Medium Priority (IMPROVEMENT)
| # | Issue | Location | Found By | Impact | Fix |
|---|-------|----------|----------|--------|-----|

### ⚡ Performance Issues
| Bottleneck | Location | Current | Optimized | Found By |
|------------|----------|---------|-----------|----------|

### 🔒 Security Issues
| Vulnerability | Location | Severity | Mitigation | Found By |
|---------------|----------|----------|------------|----------|

### ✅ Positive Findings (What's Done Well)
- [Good pattern at file:line]: [Why it's good] — found by [perspective]

### 📊 Consensus
| Finding | Perspectives That Agree | Confidence |
|---------|-------------------------|------------|
| [Finding] | [name1, name2] | HIGH/MEDIUM |

### 🎯 Action Plan (Prioritized)
1. [ ] **CRITICAL** — [fix] at `file:line`
2. [ ] **HIGH** — [fix] at `file:line`
3. [ ] **MEDIUM** — [improvement] at `file:line`
```

---

## 💾 PHASE 6: PERSIST REPORT TO DISK (ALWAYS)

**Always run — not opt-in.** After producing the PHASE 5 UNIFIED REPORT, serialize it to disk so
the review survives the session.

1. **Derive the slug** from `$ARGUMENTS`: short kebab-case (e.g. `add rate limiting` →
   `add-rate-limiting`).
2. **Ensure the directory exists:**
   ```
   mkdir -p .claude/reviews
   ```
3. **Write** `.claude/reviews/deep-review-<slug>-<YYYY-MM-DD>.md` (`<YYYY-MM-DD>` = system date)
   with the SAME UNIFIED REPORT generated in PHASE 5 — do NOT regenerate or re-summarize it —
   prefixed with a metadata header:
   ```markdown
   ---
   date: <YYYY-MM-DD>
   scope: $ARGUMENTS
   perspectives_consulted: [N]
   ---
   ```
   Preserve EVERY primary-source citation already in the report verbatim: `file:line`
   references, plus any severity / pattern evidence.
4. **Tell the user the path written** (e.g. `Report saved to
   .claude/reviews/deep-review-<slug>-<YYYY-MM-DD>.md`).

---

## ✅ SUCCESS CRITERIA

1. **Multi-perspective:** Invoked exactly the perspectives the change needed (target 3-7,
   minimum the baseline).
2. **Feature-focused:** Only analyzed what was requested.
3. **Chain-of-Thought:** Reasoning visible for each finding.
4. **Evidence-based:** Every finding has a `file:line` reference.
5. **Quantified:** Metrics where applicable, not guesses.
6. **Actionable:** Another engineer can implement the fixes without asking questions.
7. **Deduplicated:** No redundant findings across perspectives.
8. **Prioritized:** Clear severity ordering.

**Quality Metric:** "Did I bring exactly the perspectives this feature needed — no blind spots,
no padding — and converge on what matters rather than on a head-count?"

---

Now proceeding with deep review of: **$ARGUMENTS**
