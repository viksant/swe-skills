---
name: systematic-debugging
description: >
  Four-phase debugging protocol with dynamic multi-agent investigation:
  Root Cause -> Pattern Analysis -> Hypothesis -> Fix.
  Use when: user says "debug this", "fix this bug", "why is this failing", "investigate
  this error", "find root cause", "it's broken", "not working", or you hit test failures,
  flaky tests, or unexpected behavior. CRITICAL: use BEFORE proposing ANY fix.
  NOT for: implementing new features or refactoring working code.
allowed-tools: Read, Grep, Glob, Bash
model: opus
---

# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue:
- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Someone wants it fixed NOW (systematic is faster than thrashing)

## Dynamic Agent Resolution (BEFORE Phase 1)

**Resolve which specialized agents to invoke BEFORE starting the investigation.** Fresh,
domain-scoped context finds root causes your primed session would rationalize away.

### Agent Resolution Steps

1. **Extract bug signals** from the error report: keywords, file paths, stack traces, symptoms.
2. **Match signals** to a risk domain (table below).
3. **Route to a specialist:** if the host project defines a matching `<domain>-specialist`
   agent, use it; otherwise use a native general-purpose / exploration agent scoped to that
   domain. **Discover the real files at runtime** with your own Grep/Glob — a fresh grep beats
   a stale map.
4. **Discover additional agents** by tracing imports / call chains in the affected files.
5. **Invoke the selected agents IN PARALLEL** during Phase 1 (single message, multiple calls).

### Debug Domain Resolution Table

Map the signal to a domain, then route to a matching specialist (host-defined) or a
general-purpose agent scoped to that domain.

| Domain | Error signals / keywords |
|--------|--------------------------|
| Code logic | Logic errors, wrong output, null/undefined reference |
| Security / auth | "auth", "token/JWT", "403", "401", "permission denied" |
| Performance / concurrency | "slow", "timeout", "deadlock", "memory leak", "pool exhaustion" |
| Database | "query error", "schema", "connection refused", data-access layer paths |
| Frontend / UI | Render error, "hydration", "render loop", component paths |
| Data pipeline / core | "bad results", "stale index", "cache", core-engine paths |
| External model / LLM | "provider error", "model timeout", "token limit" |
| Message queue | "message lost", "queue error", "worker crash" |
| Background jobs / integrations | "job stuck", "circuit breaker", third-party API errors |
| Observability | "metric wrong", "alert firing", "dashboard empty" |
| Billing / money | "quota exceeded", "billing error", payment webhooks |
| Blast radius | Bug could affect multiple systems, cascade failure |
| Risk | Fix touches a critical path (auth, DB, tenant isolation) |
| Testing | "flaky test", "test failure", "regression" |
| Truthfulness | Verify root-cause claims after Phase 2 → `verify-claims` skill |

### Agent Invocation Rules

- **Minimum:** 1 agent for single-domain bugs.
- **Target:** 2-4 agents for a typical debugging session.
- **Maximum:** 5 agents for complex cross-domain bugs.
- **ALWAYS** run the `verify-claims` skill to verify root-cause claims after Phase 2.
- **ALWAYS** run a risk assessment if the fix touches a critical path.
- Invoke domain agents **IN PARALLEL** during Phase 1 (single message, multiple calls).
- Run `verify-claims` **AFTER Phase 2** (it needs your conclusions to verify).
- Run the risk / blast-radius assessment **AFTER Phase 4** (it needs your fix to evaluate).
- Cross-domain bugs (3+ domains) → have one coordinating agent orchestrate the rest.

### Agent Prompt Template

```
DEBUG INVESTIGATION: [bug description]

ERROR: [exact error / stack trace]
AFFECTED FILES: [files identified]
SYMPTOMS: [observed behavior]

Investigate within YOUR domain for potential root causes.
Return: findings with file:line, evidence, and causal chain.
```

---

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix (agents work IN PARALLEL with your investigation):**

1. **Read Error Messages Carefully**
   - Don't skip past errors or warnings
   - They often contain the exact solution
   - Read stack traces completely
   - Note line numbers, file paths, error codes

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What are the exact steps?
   - Does it happen every time?
   - If not reproducible → gather more data, don't guess

3. **Check Recent Changes**
   - What changed that could cause this?
   - Git diff, recent commits
   - New dependencies, config changes
   - Environmental differences

4. **Gather Evidence in Multi-Component Systems**

   **WHEN the system has multiple components (CI → build → signing, API → service → database):**

   **BEFORE proposing fixes, add diagnostic instrumentation:**
   ```
   For EACH component boundary:
     - Log what data enters the component
     - Log what data exits the component
     - Verify environment/config propagation
     - Check state at each layer

   Run once to gather evidence showing WHERE it breaks
   THEN analyze the evidence to identify the failing component
   THEN investigate that specific component
   ```

5. **Trace Data Flow**

   **WHEN the error is deep in the call stack:**

   See `references/root-cause-tracing.md` in this directory for the complete backward-tracing technique.

   **Quick version:**
   - Where does the bad value originate?
   - What called this with the bad value?
   - Keep tracing up until you find the source
   - Fix at the source, not at the symptom

### Phase 2: Pattern Analysis (Enhanced with Agent Findings)

**Merge agent findings, THEN find the pattern before fixing:**

0. **Integrate Agent Reports**
   - Collect all agent investigation reports from Phase 1
   - Deduplicate findings (consensus from 2+ agents = higher confidence)
   - Cross-validate conflicting findings between agents
   - Use the `verify-claims` skill to verify your top hypothesis
   - Escalate to `Skill(skill="consensus-board")` when the root-cause hypothesis is high-stakes (auth · data · money · config) or the agents DISAGREE: it runs independent lenses on the SAME bug and measures whether they CONVERGE, before you commit to a fix

1. **Find Working Examples**
   - Locate similar working code in the same codebase
   - What works that's similar to what's broken?

2. **Compare Against References**
   - If implementing a pattern, read the reference implementation COMPLETELY
   - Don't skim — read every line
   - Understand the pattern fully before applying

3. **Identify Differences**
   - What's different between working and broken?
   - List every difference, however small
   - Don't assume "that can't matter"

4. **Understand Dependencies**
   - What other components does this need?
   - What settings, config, environment?
   - What assumptions does it make?

### Phase 3: Hypothesis and Testing

**Scientific method:**

1. **Form a Single Hypothesis**
   - State clearly: "I think X is the root cause because Y"
   - Write it down
   - Be specific, not vague

2. **Test Minimally**
   - Make the SMALLEST possible change to test the hypothesis
   - One variable at a time
   - Don't fix multiple things at once

3. **Verify Before Continuing**
   - Did it work? Yes → Phase 4
   - Didn't work? Form a NEW hypothesis
   - DON'T add more fixes on top

4. **When You Don't Know**
   - Say "I don't understand X"
   - Don't pretend to know
   - Ask for help
   - Research more

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

1. **Create a Failing Test Case**
   - Simplest possible reproduction
   - Automated test if possible
   - One-off test script if no framework
   - MUST have it before fixing

2. **Implement a Single Fix**
   - Address the root cause identified
   - ONE change at a time
   - No "while I'm here" improvements
   - No bundled refactoring

3. **Verify the Fix**
   - Test passes now?
   - No other tests broken?
   - Issue actually resolved?

4. **Post-Fix Risk Assessment**
   - If the fix touches a critical path → run a risk assessment
   - If the fix affects multiple systems → run a blast-radius / impact assessment
   - Evaluate: data safety, tenant isolation, performance regression

5. **If the Fix Doesn't Work**
   - STOP
   - Count: how many fixes have you tried?
   - If < 3: return to Phase 1, re-analyze with the new information
   - **If >= 3: STOP and question the architecture (step 6 below)**
   - DON'T attempt Fix #4 without an architectural discussion

6. **If 3+ Fixes Failed: Question the Architecture**

   **Pattern indicating an architectural problem:**
   - Each fix reveals new shared state/coupling/problem in a different place
   - Fixes require "massive refactoring" to implement
   - Each fix creates new symptoms elsewhere

   **STOP and question fundamentals:**
   - Is this pattern fundamentally sound?
   - Are we "sticking with it through sheer inertia"?
   - Should we refactor the architecture vs. continue fixing symptoms?

   **Escalate to a coordinating cross-domain analysis, then discuss with the user before more attempts.**

   This is NOT a failed hypothesis — this is a wrong architecture.

## Red Flags — STOP and Follow Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**
- **Each fix reveals a new problem in a different place**

**ALL of these mean: STOP. Return to Phase 1.**

**If 3+ fixes failed:** question the architecture (see Phase 4, step 6).

## User Signals You're Doing It Wrong

**Watch for these redirections:**
- "Is that not happening?" — you assumed without verifying
- "Will it show us...?" — you should have added evidence gathering
- "Stop guessing" — you're proposing fixes without understanding
- "Think harder about this" — question fundamentals, not just symptoms
- "We're stuck?" (frustrated) — your approach isn't working

**When you see these:** STOP. Return to Phase 1.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | The first fix sets the pattern. Do it right from the start. |
| "I'll write the test after confirming the fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms != understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question the pattern, don't fix again. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **0. Agents** | Resolve agents, invoke in parallel | Domain experts investigating |
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence + agent reports | Understand WHAT and WHY |
| **2. Pattern** | Merge agent findings, find working examples, compare, verify with `verify-claims` | Identify differences with multi-agent consensus |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify, risk-assess | Bug resolved, tests pass, risk evaluated |

## When Process Reveals "No Root Cause"

If systematic investigation reveals the issue is truly environmental, timing-dependent, or external:

1. You've completed the process
2. Document what you investigated
3. Implement appropriate handling (retry, timeout, error message)
4. Add monitoring/logging for future investigation

**But:** 95% of "no root cause" cases are incomplete investigation.

## Supporting Techniques

These techniques are part of systematic debugging and available in this directory:

- **`references/root-cause-tracing.md`** — trace bugs backward through the call stack to find the original trigger.
- **`references/defense-in-depth.md`** — add validation at multiple layers after finding the root cause.
- **`references/condition-based-waiting.md`** — replace arbitrary timeouts with condition polling.

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Jumped to a fix without investigation | Time pressure, "obvious" bug | Return to Phase 1 — systematic is faster than thrashing |
| Same fix attempted 3+ times | Treating symptoms, not root cause | Question the architecture (Phase 4 step 6) |
| Can't reproduce the bug | Inconsistent environment or timing | Add diagnostic instrumentation at component boundaries |
| Root cause found but the fix breaks other tests | Fix was at symptom, not source | Trace further up the call chain |

## Real-World Impact

From debugging sessions:
- Systematic approach: 15-30 minutes to fix
- Random fixes approach: 2-3 hours of thrashing
- First-time fix rate: 95% vs 40%
- New bugs introduced: near zero vs common
