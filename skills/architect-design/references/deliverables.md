# Architect-Design — Deliverables (output templates & checklists)

Deep reference for the `architect-design` skill: the discovery block, the per-phase output
templates, the final deliverable format, and the production-readiness checklist. Fill these in
order; produce nothing downstream until the block above it is complete.

---

## 1. 🔍 DISCOVERY OUTPUT (Phase 0 — MANDATORY before any proposal)

```markdown
## Discovery — files read
- docs read: [paths]
- code read: [file:line ranges]

## Discovery — current behavior
- Component affected: [concern-category mapping]
- Layer (Clean Arch): [Entities / Use Cases / Interface Adapters / Frameworks]
- Current implementation summary: [3-5 lines]
- Known smells / sharp edges: [from the project's lessons-learned notes or docs]
- Dependencies that would change: [list]

## Discovery — systemic fit (how the new piece connects)
- Sibling pattern to imitate: [existing files that set the precedent + path]
- Vocabulary / naming to reuse: [domain terms already in use — no synonyms]
- Canonical seams it plugs into: [config access / error handling / queues / telemetry / tenant factories]

## Discovery — existing-system findings (unsolicited — see the existing-system-findings block below)
- [file:line] — [defect / inconsistency / risk] — severity [LOW/MED/HIGH] · effort [LOW/MED/HIGH] — why it matters — suggested direction (NOT fixed here)
- "(none — existing system coherent for this change)" if clean
```

---

## 2. 🧩 SYSTEMIC FIT — the two questions

**A) Does the new piece FIT, or is it an island?** (the user's #1 concern)

| Ask | Where to look |
|-----|---------------|
| What pattern do the SIBLINGS follow? (mirror them) | the touched layer's files + its module docs |
| Am I inventing a style / abstraction the repo doesn't use? | the project's convention docs (reuse > create; mimic neighbors) |
| Does my naming / vocabulary match terms already in use? | the master docs index + sibling code |
| Does it use the CANONICAL seams? | central config access · the error-handling module · the queue layer · the telemetry layer · the tenant-isolation factories |
| After this lands: system MORE coherent or MORE fragmented? | second-order — what must the next dev learn that didn't exist before? |

> Correct but ignoring the repo's patterns = a DEFECT, not a feature. Flag it on yourself before a reviewer does.

## 3. ⚠️ EXISTING-SYSTEM FINDINGS (the human can be wrong — say it CLEARLY, do NOT bury or soften)

```markdown
## ⚠️ EXISTING-SYSTEM FINDINGS (unsolicited — you asked for X, I also found Y)
- **[file:line]** — [what is wrong] — severity [LOW/MED/HIGH] · effort [LOW/MED/HIGH]
  - Why it matters: [concrete failure mode / inconsistency / future cost]
  - Suggested direction: [1-2 lines — NOT implemented here; out of scope]
  - Relation to your feature: [blocks it / makes it harder / independent]
```

Rank on the **impact × effort** matrix — get the IMPACT axis (blast radius) from `Task(subagent_type="impact-analyzer")` and pressure-test the debt against the proven pattern via `Skill(skill="battle-tested-patterns")`; `effort` is your fix-cost estimate. Report quick wins first (high impact + low effort). Surface, do NOT silently fix (scope). Evidence-first (`file:line`). Nothing wrong → "coherent — no findings". Inventing findings to look thorough = noise.

---

## 4. 📋 PER-PHASE OUTPUT TEMPLATES

### Phase 1 — Validate the problem

```markdown
## Problem Validation
**User said:** [verbatim]

**Critical questions:**
1. Real problem or symptom?
2. Did the user correctly diagnose the bottleneck?
3. Are they proposing a solution before understanding the problem?

**My analysis:**
- Root-cause hypothesis: [...]
- Evidence needed to confirm: [what to measure / check in metrics or logs]

**Clean Architecture lens:**
- Layer affected: [Entities / Use Cases / Interface Adapters / Frameworks]
- Direction of impact: inward (preserves) / outward (rejects)
- New abstractions proposed: [list] → each must justify ≥3 concrete consumers (YAGNI)
- ADP risk (cycles): [yes/no + where]
```

### Phase 2 — Solution research

```markdown
## Solution Research
**AOSA patterns:** [from battle-tested-architect]
**Industry validation:** [companies + scale]

### Pattern 1: [name]
- AOSA: [project + chapter URL]
- Industry: [Company] at [scale]
- Concurrency: [how]
- Failure modes: [from AOSA]

**REJECTED patterns:**
- [X]: no production evidence (not in AOSA, no industry case)
- [Y]: AOSA documents failure at scale (cite chapter)
```

### Phase 3 — Concurrency analysis

```markdown
## Concurrency Analysis
**Expected load:** N concurrent users, N RPS, peak ×N

### DB connections
- Workers: N · Conns/worker: N · Pooled: N · Headroom: N%

### Queue capacity
- Ops/s: N · Processing: N ms · Depth needed: N

**Bottlenecks:**
1. [bottleneck]: [mitigation, with file:line if existing]
2. [bottleneck]: [mitigation]
```

### Phase 4 — Design output (per component)

```markdown
## Component: [name]

**Layer (Clean Arch):** Entities / Use Cases / Interface Adapters / Frameworks
**Battle-tested source:** [Company / AOSA chapter — scale numbers]

**Why this component:**
- Problem solved: [specific bottleneck, with current file:line]
- Concurrency: [mechanism]
- Alternatives considered: [3-4 max, with reason for rejection]

**Configuration:**
    # Source: [where this config comes from]
    [actual config]

**Metrics to monitor (project telemetry conventions):**
- [metric]: alert if > [threshold]

**Trade-offs:**
- ✅ [benefit with number]
- ⚠️ [cost with number, mitigation]

**Files touched:**
- [path:line range] — [why]
```

### Phase 5 — Self-critique (brutal)

```markdown
## Self-Critique

**Trade-off honesty:**
- Hidden costs: [list]
- Complexity added: [assessment vs current code]
- Skills required: [what the team must learn]

**Production survival:**
- 10× load: [yes/no — reasoning with numbers]
- Component failure: [graceful degradation? blast radius?]
- Rollback path: [how to revert if it breaks]

**Bias check — am I recommending this because:**
- [ ] Battle-tested (GOOD)
- [ ] Familiar to me (CHECK BIAS — look for alternatives)
- [ ] User asked for it (VERIFY IT'S CORRECT — Cardinal Rule)
- [ ] Trendy (REJECT)

**Clean Architecture audit:**
- Dependency Rule respected (inward only)? [yes/no — evidence]
- New cycles (ADP)? [list or none]
- Volatile → Stable (SDP)? [yes/no]
- Every new abstraction has ≥3 consumers (YAGNI)? [list each]
- Details treated as plugins, not architecture? [yes/no]
- If this is a Clean-Code refactor — did the user articulate a measured pain point? [quote]
```

---

## 5. 📦 FINAL DELIVERABLE FORMAT

```markdown
# PROPOSED ARCHITECTURE: <name>

## 1. EXECUTIVE SUMMARY
- Problem: <primary bottleneck — verified, not assumed>
- Solution: <top 3 changes>
- Impact: <quantified — throughput, latency P95, $/month>
- Timeline: <phases / weeks>
- Clean Architecture verdict: preserves / improves / requires dependency-direction change
- Systemic fit verdict: native to the repo / justified new pattern (why)
- Existing-system findings: <N surfaced — see final section / none>
- Files affected: <count + key paths>

## 2. DISCOVERY (the discovery-output block above — files read, current behavior, systemic fit, existing-system findings)

## 3. RESEARCH
- AOSA chapters: <list>
- Repos analyzed (5-7 max): <list with links>
- Industry validation: <companies + scale>

## 4. PROPOSED ARCHITECTURE
### Diagram (text / mermaid) — show layer boundaries explicitly
### Components — each: Why + Evidence + Trade-offs + Config + Layer + Files touched
### Data flow — Step 1 (X ms) → Step 2 (Y ms) → ...

## 4.5 SYSTEMIC FIT & CONSISTENCY
- Sibling patterns imitated: <files that set the precedent>
- Vocabulary reused (not invented): <terms>
- Canonical seams used: <config / errors / queues / telemetry / factories>
- Abstractions deliberately NOT introduced (kept uniform): <list>
- Verdict: reads as <native to the repo / a justified new pattern because Z>

## 5. KEY DECISIONS (structured-reasoning excerpts)
Each: context + alternatives + reasoning + verdict + confidence

## 6. MEASURED IMPACT
| Metric | Before | After | Δ | Source |
|--------|--------|-------|---|--------|

## 7. CLEAN ARCHITECTURE COMPLIANCE
- Dependency Rule respected? <yes/no + evidence>
- SOLID applied (only where ≥3 consumers)? <list>
- New cycles (ADP)? <none / list>
- Boundary clarity (business vs detail)? <evidence>
- YAGNI compliance — every abstraction justified by current consumers? <list>

## 8. IMPLEMENTATION PLAN
- Phase 1 — Core (Weeks 1-2): tasks with quantified impact
- Phase 2 — Optimization (Weeks 3-4): trigger condition + tasks
- Phase 3 — Scale-out (Months 2-3): trigger condition + tasks

## 9. DEPLOYMENT (respect the project's current deploy model)
- Runtime / orchestration: <config snippet>
- Public route / reverse-proxy entry (if a new one): <snippet>
- Schema migration (if a schema change): <migration path + revision>
- Monitoring: metrics to add + alert thresholds

## 10. TRADE-OFFS
✅ Advantages (numbers)
⚠️ Disadvantages (numbers + mitigation)

## 11. SUCCESS CRITERIA
- Metric reaches target X
- Trigger to Phase 2: <measurable real condition>
- Trigger to pivot: <when to abandon the design>

## 12. NEXT STEPS
1. Immediate action (often: instrument + measure baseline)
2. Validation (load-test command + thresholds)
3. Decision based on measurement
4. Hand the approved design to `/swe-skills:write-plans` to author the executable plan

## 13. EXISTING-SYSTEM FINDINGS (unsolicited — the existing-system-findings block)
Labeled and SEPARATE from the design above, ranked by the **impact × effort** matrix (quick wins first). Each: `file:line` + severity + effort + why it matters + suggested direction + relation to this feature. You do NOT fix them here — the user decides. None → "Existing system coherent for this change — no findings."
```

---

## 6. ✅ PRODUCTION-READINESS CHECKLIST (validate BEFORE sending)

```markdown
### Discovery
- [ ] Master docs index + relevant summaries read
- [ ] Affected per-module docs read
- [ ] Current behavior summarized with file:line
- [ ] Metrics / observability state inspected (if relevant)

### Concurrency
- [ ] Connection pooling configured + pool sizes calculated
- [ ] Async patterns for all I/O
- [ ] Queue-based for ops > 100ms
- [ ] Backpressure / semaphores documented

### Reliability
- [ ] Circuit breakers for external calls
- [ ] Retry with backoff + Retry-After honoring
- [ ] Dead-letter queues
- [ ] Graceful degradation paths
- [ ] Rollback procedure documented

### Observability
- [ ] Metrics defined (following the project's telemetry conventions)
- [ ] Alerts configured with thresholds
- [ ] Structured log labels declared (tenant / request-type / subsystem)
- [ ] SLO/SLI explicit

### Clean Architecture
- [ ] Dependency Rule (inward only) respected
- [ ] No new ADP cycles
- [ ] SDP: volatile depends on stable
- [ ] Every new abstraction has ≥3 concrete consumers (else YAGNI)
- [ ] Details (DB, framework) kept pluggable where reasonable
- [ ] If a refactor: the user articulated a measured pain point

### Systemic fit
- [ ] New piece mirrors its siblings' pattern + vocabulary (not an island)
- [ ] Uses canonical seams (config / errors / queues / telemetry / factories)
- [ ] Existing-system defects (if any) surfaced in a labeled channel, not buried

### Anti-sycophancy
- [ ] Challenged user assumptions where evidence required
- [ ] Proposed a better alternative when one existed
- [ ] No flattery in the opening
- [ ] Contradicted the user with a citation when warranted

### Evidence
- [ ] Every pattern: production source (AOSA / company / repo file:line)
- [ ] Scale validated against requirements
- [ ] Load-test plan defined (command + thresholds)
- [ ] Benchmarks have explicit sources

### Project-specific constraints (discover from the host repo)
- [ ] Compatible with the project's deploy / networking model
- [ ] Respects tenant isolation if the system is multi-tenant
- [ ] Uses the project's central config-access convention (no ad-hoc env reads if config is centralized)
- [ ] Any protected production identifier touched → flagged for manual review
- [ ] Schema-migration path identified if there is a schema change
- [ ] Secrets / config protection respected
```
