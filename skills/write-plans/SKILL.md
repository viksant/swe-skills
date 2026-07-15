---
name: write-plans
description: >
  Strategic planner that turns a request into a detailed, executable plan (Plan-then-Execute):
  classify → ask → explore → risk-tier/invariants → structured plan saved to disk, then hand the
  plan off to an implementation flow. Use when the user says "plan", "how should I implement X",
  "design approach", "strategy", "write a plan", or before any large / multi-file change.
  NOT for: trivial one-line edits with an obvious fix, pure research questions, or actually
  writing the code (this skill stops at the plan and hands off). Feed the saved plan to
  /swe-skills:subagent-build to implement.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Task, AskUserQuestion
model: opus
---

> **Core Principle:** Minimum high-signal tokens that maximize outcome probability.
> **Final Test:** "If I remove all context and give this plan to a fresh Claude, will it succeed without asking questions?"

# 📋 STRATEGIC PLANNER (Plan-then-Execute)

**Request:** "$ARGUMENTS"

---

## PHASE 0: CLASSIFY TASK (ALWAYS FIRST)

| Size | Signals | Phases to Use |
|------|---------|---------------|
| **TRIVIAL** | <5 files, localized change, clear pattern | 0 → 3 → Execute |
| **STANDARD** | 5-15 files, new feature, simple integration | 0 → 1 → 2 → 3 → Execute |
| **COMPLEX** | >15 files, architecture, multi-system | All phases + structured reasoning |

**Classify BEFORE doing anything else.**

---

## PHASE 1: ASK (NO LIMIT)

**BEFORE exploring code, use `AskUserQuestion` for:**

| Category | Typical Questions |
|----------|-------------------|
| Requirements | What exactly should it do? What should it NOT do? |
| Scope | What is IN scope? What is OUT? |
| Assumptions | Verify EACH assumption before proceeding |
| Preferences | Technologies, patterns, conventions? |
| Constraints | Time, resources, dependencies? |

```yaml
CRITICAL_RULES:
  - If in doubt → ASK
  - No limit on questions
  - "I assume that..." → STOP → Ask first
  - One question is worth more than 10 wrong assumptions
```

---

## PHASE 2: EXPLORE (JUST-IN-TIME)

**DO NOT pre-load all context. Load dynamically:**

1. `Glob` to find relevant files
2. `Grep` to search for specific patterns
3. `Read` ONLY the critical identified files
4. Document: `path:line - what it does`

```yaml
DOCUMENT:
  files_explored: [path:line - description]
  patterns_found: [path:line - pattern to follow]
  reusable_code: [path:line - existing reusable code]
```

**Principle:** Explore the minimum necessary to plan with confidence.

---

## PHASE 2.5: DELIBERATE THINKING (For COMPLEX Tasks)

**When a `--seq` flag is used OR the task is COMPLEX, work through this framework** (see the
`deliberate-thinking` skill for the structured-reasoning protocol):

### Understanding Phase
```
□ What EXACT problem am I solving?
□ What is current vs desired behavior?
□ Do I have all necessary information?
□ Should I ask the user before continuing?
```

### Exploration Phase
```
□ Does similar code exist that I can REUSE? (search first)
□ What patterns does the codebase use for similar cases?
□ What files/modules will be affected?
□ Are there hidden dependencies I must consider?
```

### Design Phase
```
□ What are the implementation alternatives? (minimum 2)
□ What trade-offs does each alternative have?
□ Which is most aligned with the existing architecture?
□ Does it introduce technical debt? Is it acceptable?
```

### Pre-Implementation Validation
```
□ Does it break tenant / data isolation?
□ Does it negatively affect performance?
□ Are there security risks?
□ Would the user understand and approve my decision?
```

### Implementation Plan
```
□ Specific order of changes (which file first)
□ Intermediate verification points
□ How to verify it works (tests, manual, logs)
□ Rollback plan if something fails
```

---

## PHASE 2.6: RISK TIER & INVARIANTS

**Run whenever the plan touches code. Skip only for pure-docs plans.**

### Step A — Tier check

If the host project defines `<project>/.claude/REVIEW_TIERS.md`, use its tier assignments.
Otherwise apply this neutral heuristic:

- **CRITICAL** — touches security/auth, data-loss/destructive operations, money/billing,
  boot/config, or a public API/contract.
- **NORMAL** — standard business logic.
- **LOW** — docs, tests, cosmetic.

Match each file on the change list against the tiers:

| File | Tier | Friction |
|------|------|----------|
| `<path>` | CRITICAL/NORMAL/LOW | `[CRITICAL CONFIRM]` if CRITICAL |

### Step B — `[CRITICAL CONFIRM]` gate

If ANY file is CRITICAL, **stop and show the user:**

```
ATTENTION — this plan touches CRITICAL files:
  - <path>

CRITICAL = security breach / data loss / broken boot / money path.

To proceed, reply literally:
    [CRITICAL CONFIRM]

To rescope:
    [RESCOPE]
```

Do not advance until you receive the literal `[CRITICAL CONFIRM]` from the user.

### Step C — Load the subsystem's real invariants

If the project documents invariants for a touched subsystem (a playbook, an ADR, a design
doc, a README), load it into context BEFORE planning — discover it via `Grep`/`Glob` if you
don't already know it exists. Without the subsystem's real invariants in context, the plan
will invent them. Mandatory for CRITICAL/NORMAL work in an unfamiliar subsystem.

### Step D — Numbers with a pedigree

If the plan introduces or changes any constant (timeouts, TTLs, limits, sizes, retries,
thresholds, pool sizes), a table is mandatory:

| Number | Current | Proposed | Citable source |
|--------|---------|----------|----------------|
| `<name>` | 300s | 600s | measured p99 = 250s + rule "timeout ≥ 2×p99" (official docs / own benchmark / ADR / incident) |

A number with no source (official docs, own benchmark, ADR, incident) is an automatic
reject — it is a silent bug waiting to explode.

### Step E — Untouchable invariants

List explicitly what the change MUST NOT break. This list becomes the lens for the
post-implementation `/swe-skills:senior-review`. Frame by universal category and keep only
the ones the plan actually touches:

- **Auth / authorization:** fail-closed on the deny path; no privilege escalation; identity
  and permissions derived from a verified source, never from client-supplied data.
- **Tenant / data isolation:** every query and mutation scoped to the correct tenant; no
  cross-tenant leakage.
- **Concurrency / ordering:** idempotency where retried; correct locking/serialization; no
  lost updates or reordering.
- **Config / secrets:** config read through the project's config layer (not ad-hoc reads);
  secrets never logged or exposed.
- **Data layer:** correct serialization/types at the boundary; migrations idempotent with a
  real down path.

---

## PHASE 3: PLAN AS JSON

Generate a structured plan. Each step MUST have:

| Field | Requirement |
|-------|-------------|
| `location` | Exact path with approximate line |
| `depends_on` | IDs of required previous steps |
| `contract` | Explicit input → output |
| `pattern_ref` | Reference to existing code to follow |
| `verification` | Exact command + expected output |
| `rollback` | How to undo if it fails |

### Save the plan:
```
# Plan location
docs/PLAN.json

# NOT in conversation context — gets lost in compaction
```

---

## PHASE 4: PERSISTENT PROGRESS

When finishing planning:
1. Save `docs/PLAN.json`.
2. Create/update `claude-progress.txt` in the project root.
3. Descriptive commit ONLY if the user explicitly asks (never auto-commit).

---

## PHASE 5: EXECUTION HANDOFF

After the plan is saved and presented, OFFER execution — do not start implementing on your own.

> "Plan saved to `docs/PLAN.json`. How do you want to implement it?
>
> 1. **/swe-skills:subagent-build** (recommended) — runs the plan task-by-task with a fresh
>    subagent per task + exhaustive review (spec → quality → adversarial red-team →
>    domain/security) + per-task verification + a final /swe-skills:senior-review. Zero
>    margin for error.
> 2. I implement inline in this session (/swe-skills:context-implement)
> 3. Stop here — I'll implement later
>
> Which?"

If the user picks (1), `/swe-skills:subagent-build` consumes this same `docs/PLAN.json`. Use
`AskUserQuestion` for the choice when appropriate.

---

## FORBIDDEN ANTI-PATTERNS

| Forbidden | Why | Instead |
|-----------|-----|---------|
| "We'll improve it later" | There is no "later" | Do it right now |
| Pseudo code | Executor cannot infer | Complete code |
| Vague paths "in src/" | Executor gets lost | `src/exact/path.ext:~line` |
| Skip questions | Assumptions = bugs | AskUserQuestion first |
| Plan only in context | Gets lost in compaction | Save as a file |
| Pre-load everything | Wastes tokens | Just-in-time context |

---

## INCREMENTAL WORK

```yaml
ALWAYS:
  1. Plan ONE feature
  2. Implement that feature
  3. Verify that feature
  4. Commit that feature (only if the user asks)
  5. Next feature

NEVER:
  - Plan 10 features at once
  - Implement without verifying
  - Giant multi-feature commits
```

---

## FINAL VERIFICATION CHECKLIST

The plan is ready ONLY if:

- [ ] Another Claude can execute it without asking
- [ ] Each step has `verification` with an exact command
- [ ] Each step has `pattern_ref` to existing code
- [ ] Plan saved as an external file (JSON)
- [ ] All questions asked and answered
- [ ] Scope clearly defined (IN/OUT)
- [ ] At least 2 alternatives considered (COMPLEX tasks)
- [ ] Rollback plan defined

---

## DELIVERY TEMPLATE

```markdown
## PLAN: [Task Name]

| Aspect | Value |
|--------|-------|
| Size | TRIVIAL/STANDARD/COMPLEX |
| Files | N files |
| Steps | N steps |
| Risk | Low/Medium/High |

### Context Gathered
- Documentation reviewed: [list]
- Patterns found: [list with path:line]
- Reusable code: [list with path:line]

### Questions Resolved
- Q: [question] → A: [answer]

### Alternatives Considered (COMPLEX only)
1. [Alternative 1]: [Pros/Cons]
2. [Alternative 2]: [Pros/Cons]
**Selected:** [Which and why]

### Steps (see docs/PLAN.json for full detail)
1. [Step 1] - [file:line]
2. [Step 2] - [file:line]

### Final Verification
- Command: `[command]`
- Expected: [output]

### Rollback
[How to undo everything if needed]
```

---

## PLANNING PRINCIPLES APPLIED

| # | Principle | Application |
|---|-----------|-------------|
| 1 | Minimum high-signal tokens | Only critical information |
| 2 | Plan-then-Execute | Plan as an external file |
| 3 | JSON for lists | `PLAN.json`, not Markdown |
| 4 | Incremental work | 1 feature at a time |
| 5 | Persistent progress | `claude-progress.txt` |
| 6 | Just-in-time context | Don't pre-load everything |
| 7 | Size estimator | Classify BEFORE proceeding |
| 8 | Deep reasoning | Use deliberate thinking for COMPLEX |

---

Starting Phase 0: Classify the task for: **$ARGUMENTS**
