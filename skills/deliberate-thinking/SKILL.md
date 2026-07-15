---
name: deliberate-thinking
description: >
  Structured reasoning via Sequential Thinking MCP for complex decisions AND large
  implementation planning. Use when:
  - Changes affect 3+ files or touch critical paths (core modules, shared services, message queues).
  - Architectural decisions or design patterns are involved.
  - Implementation spans 5+ files or a large implementation is being planned.
  - User says "think about this", "analyze carefully", "step by step", "plan",
    "strategy", "how should I implement", "what's the best approach", "design this".
  - Includes --seq / --think / --sequential flags.
  NOT for: trivial changes (<3 files), simple bug fixes with obvious cause,
  documentation-only changes, or pure research questions.
version: 2.0.0
---

# Deliberate Thinking (via Sequential Thinking MCP)

## Overview

Complex problems require structured reasoning. Ad-hoc analysis misses edge cases, creates blind spots, and leads to regret-driven refactors.

**Core principle:** ALWAYS decompose complex problems into structured thought steps using the Sequential Thinking MCP before implementing.

**Violating this process means shipping unvetted architectural decisions.**

## The Iron Law

```
NO IMPLEMENTATION WITHOUT STRUCTURED ANALYSIS FIRST
```

If you haven't invoked Sequential Thinking MCP, you cannot proceed with implementation on DELIBERATE-classified tasks.

## When to Use

Use for ANY task classified as DELIBERATE:
- Changes affecting 3+ files
- Touching core modules, shared services, or message-queue infrastructure
- Architectural decisions or design changes
- Refactoring with multiple moving parts
- User includes `--seq`, `--think`, or `--sequential` flags
- Performance optimization requiring trade-off analysis
- Security-sensitive changes (auth, JWT, tenant isolation)
- Multi-tenant / tenant isolation changes

**Use this ESPECIALLY when:**
- Multiple valid approaches exist (prevent anchoring bias)
- Trade-offs are non-obvious
- Changes affect critical production paths
- You feel "confident enough to skip analysis" (overconfidence signal)

## Phase 1: Check Schema (MANDATORY FIRST STEP)

Before invoking the MCP tool, you MUST check its schema:

```bash
mcp-cli info sequential-thinking/sequentialthinking
```

This is a HARD REQUIREMENT. Never call the tool without checking schema first.

## Phase 2: Select Thinking Mode

Choose the appropriate `thinkingMode` based on the task:

| Task Type | thinkingMode | Use When |
|-----------|-------------|----------|
| System design, refactoring, module boundaries | `architecture` | Structural decisions |
| Bug investigation, error tracing, root cause | `debugging` | Following data/error flows |
| Latency, throughput, resource optimization | `performance` | Quantified improvements |
| Multi-tenant fairness, resource allocation | `scaling` | Tenant isolation concerns |
| Comparing approaches, selecting libraries | `tradeoff` | Decision with multiple options |
| Auth, JWT, OWASP, input validation | `stability` | Security-sensitive changes |
| SOLID, DRY, KISS, anti-pattern detection | `patterns` | Code quality decisions |
| Retry policies, circuit breakers, fault tolerance | `resilience` | Reliability engineering |

**Default:** `architecture` if no clear match.

## Phase 3: Invoke Sequential Thinking MCP

**Minimum 2 thoughts required.** Recommended structure:

### For Analysis Tasks (2-3 thoughts):

```
Thought 1: Problem definition + current state analysis
Thought 2: Solution design + risk assessment
Thought 3: Implementation plan (if needed)
```

### For Decision Tasks (3-4 thoughts):

```
Thought 1: Problem definition + constraints
Thought 2: Alternative A analysis
Thought 3: Alternative B analysis + comparison
Thought 4: Decision + justification
```

### MCP Call Template:

```bash
mcp-cli call sequential-thinking/sequentialthinking '{
  "thought": "Analysis of [problem]...",
  "nextThoughtNeeded": true,
  "thoughtNumber": 1,
  "totalThoughts": 3,
  "thinkingMode": "[selected-mode]",
  "affectedComponents": ["component1", "component2"],
  "confidence": 70,
  "evidence": "Based on [source]..."
}'
```

### Parameters:

| Parameter | Required | Description |
|-----------|----------|-------------|
| `thought` | YES | The reasoning content |
| `nextThoughtNeeded` | YES | `true` if more steps needed, `false` for final |
| `thoughtNumber` | YES | Current step (1-indexed) |
| `totalThoughts` | YES | Estimated total steps |
| `thinkingMode` | NO | Category from Phase 2 table |
| `affectedComponents` | NO | Components affected by the change |
| `confidence` | NO | 0-100 self-assessment |
| `evidence` | NO | Source: benchmark, docs, metric |
| `sessionId` | NO | Group related thoughts |
| `branchId` | NO | Explore alternatives |
| `lens` | NO | Persona per-session (debugger/architect/...). See Phase 5 |

## Phase 4: Post-Analysis Checklist

**BEFORE implementing, verify:**

- [ ] Root problem is clearly defined (not just symptoms)
- [ ] At least 2 alternatives were considered (or justified why only 1)
- [ ] Trade-offs are explicitly documented
- [ ] Affected components are identified
- [ ] Confidence >= 50% (if lower, open branch with alternative)
- [ ] Evidence cited for key decisions (not just opinions)

**If confidence < 50%:** You MUST open a `branchId` to explore an alternative before proceeding.

## Rules

| Rule | Enforcement |
|------|-------------|
| Check schema before calling MCP | **NEVER SKIP** |
| Minimum 2 thoughts per session | **NEVER SKIP** |
| Cite evidence in decisions | **MANDATORY** |
| Branch if confidence < 50% | **MANDATORY** |
| Don't exceed 1.5x estimated thoughts | **STOP and conclude** |
| No quick-fix proposals | **FORBIDDEN** |
| Quantify improvements (not "faster" but "~200ms P95") | **MANDATORY** |

## Anti-Patterns

| Forbidden Thought | What You MUST Do Instead |
|-------------------|--------------------------|
| "It's obvious, skip the MCP" | STOP -> This skill exists because "obvious" solutions fail |
| "Just one thought is enough" | STOP -> Minimum 2 thoughts, always |
| "I'm confident without evidence" | STOP -> Cite source or admit uncertainty |
| "Quick fix, then proper analysis later" | STOP -> Analysis FIRST, always |
| "Too many thoughts, just decide" | If >1.5x estimate, conclude with current evidence |

## Phase 5: Lens (stance based on the invoker)

The MCP accepts an optional `lens` parameter that adapts the STANCE of the reasoning to
the active command/skill (per-session: sent once and remembered). It is ORTHOGONAL to
`thinkingMode`. The response returns `lensGuidance` (how to attack the problem) and
persona-specific warnings.

| Invoker | lens |
|---------|------|
| a debugging command / systematic debugging | `debugger` |
| an architecture-design command | `architect` |
| a security review / auth/JWT work | `security-auditor` |
| a performance-optimization command | `performance` |
| a refactor / code-simplification command | `refactorer` |
| a code-review command | `reviewer` |
| a test-strategy workflow | `test-strategist` |
| a planning command | `planner` |

With no clear command, omit `lens` — the generic behavior stays intact.

> **Note:** the MCP is **stateless** (no persistence). There is no `record_outcome` nor any
> historical analytics tools; the cognitive engine (depth/bias/confidence/budget) runs
> in-memory per session and is returned in each thought.

## Integration with Other Skills

This skill is typically the FIRST in the chain for complex tasks:

```
deliberate-thinking -> [devils-advocate] -> [implement] -> code-simplifier -> meticulous-code-review -> verification-before-completion
```

## Example Flow

```
User: "Refactor the tenant factory to support lazy initialization"
→ Affects 4 files: factory, dependencies, tests, types
→ deliberate-thinking activates (3+ files, touches shared services)
→ Thought 1: Problem definition — current eager init wastes connections for unused tenants
→ Thought 2: Alternative A (proxy pattern) vs Alternative B (deferred factory)
→ Thought 3: Decision — proxy pattern, reduces cold-start latency ~150ms P95
→ Confidence: 78% with evidence from connection pool metrics
→ Implementation proceeds with structured plan
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Skipped MCP because "obvious" | Overconfidence bias | "Obvious" is the #1 signal you need structured analysis |
| Too many thoughts (>1.5x estimate) | Over-analyzing or circular reasoning | Conclude with current evidence; diminishing returns after 1.5x |
| Low confidence (<50%) but proceeded anyway | Ignored branching rule | Open branchId with alternative approach before proceeding |
| Evidence field left empty | Rushed through steps | Every decision needs a source: benchmark, docs, metric, or code reference |
