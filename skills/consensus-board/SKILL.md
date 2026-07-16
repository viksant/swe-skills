---
name: consensus-board
description: >
  Use when a diagnosis or decision needs higher confidence via INDEPENDENT CONVERGENCE — an
  orchestrator runs N fresh-context expert agents attacking the SAME problem from DIFFERENT
  lenses, then measures whether they converge. Triggers: "board of experts", "consensus check",
  "is this diagnosis solid?", "get more confidence on this decision", or another skill escalating
  a high-stakes / ambiguous call. NOT for: coverage-style multi-domain review (use deep-review), a
  blue-vs-red diff audit (use senior-review), or a trivial / reversible call (no board needed).
  Heavy and composed / user-invoked — do not auto-invoke.
allowed-tools: Read, Grep, Glob, Bash, Task, AskUserQuestion
model: opus
disable-model-invocation: true
---

> **Core Philosophy:** confidence comes from INDEPENDENT convergence, not from agreement.
> Divergence is SIGNAL, not noise. A consensus reached by pressure is a FAILURE, not a result.
> **Lens (MCP):** When invoking your sequential-thinking MCP tool, pass `lens: "reviewer"`
> (weigh each thesis against its own evidence; distrust cheap agreement).

# Consensus Board — Independent Convergence Protocol

**You are the orchestrator AND the arbiter.** You convene N fresh-context expert agents on ONE
problem, each through a DIFFERENT lens, and measure whether their independent conclusions converge
— so the caller can put more weight on a high-stakes conclusion.

**Problem / decision under review:** "$ARGUMENTS"

---

## What makes this DISTINCT (never confuse it with its siblings)

| Skill | Semantics | Divergence means | Confidence from |
|-------|-----------|------------------|-----------------|
| `deep-review` / `systematic-debugging` | **COVERAGE** — each agent covers a DIFFERENT domain | GOOD (more blind spots covered) | breadth of domains |
| `senior-review` | **DIALECTIC** — blue defends, red attacks the SAME diff | expected (adversarial by design) | surviving the attack |
| **`consensus-board`** | **CONVERGENCE** — N INDEPENDENT agents, SAME problem, DIFFERENT lenses | **ALARM** (fragile / mis-framed diagnosis) | INDEPENDENT agreement where each agent brings its OWN evidence |

Confidence here is NOT "they all said yes". It is "N agents who could not see each other, each
reasoning from a different angle with its own `[VERIFIED]` evidence, arrived at the same place."
Agreement without independent evidence is a shared hallucination, not a consensus.

---

## The protocol (run in order)

| Phase | What | Skip when |
|-------|------|-----------|
| 0 | **Activation gate** — decide N from the complexity rubric (may be 0) | never (the gate always runs) |
| 1 | **Canonical framing** — write ONE neutral problem statement, identical for all | — |
| 2 | **Independent panel** — dispatch N agents IN PARALLEL, same statement, DIFFERENT lens each | N = 0 |
| 3 | **Convergence measurement** — cluster theses semantically; classify the consensus state | N = 0 |
| 4 | **Reconciliation** — one anonymized round with anti-groupthink safeguards | STRONG CONSENSUS reached |
| 5 | **Aggregated verdict** — consensus level + conclusion + confidence + who-said-what + shared blind spots | — |

---

## Phase 0 — Activation gate (decide N; the board is not free)

Convene ONLY when a single analysis leaves confidence BELOW the "proceed" bar on a high-stakes or
hard-to-reverse call. This aligns with the toolkit's escalation protocol (`docs/architecture.md`:
>80% proceed / 50-80% reinforced quality gate / <50% or Risk CRITICAL → stop and ask) and the
Min/Target/Max agent-count pattern of `systematic-debugging` (its Agent Invocation Rules).

| Situation | Panelists (N) |
|-----------|---------------|
| Trivial / reversible / obvious single cause | **0 — do NOT convene.** The board is pure overhead; resolve directly. |
| Normal / bounded decision / contained blast radius | **2-3** |
| High or CRITICAL (auth · data · money · config) / irreversible / genuinely ambiguous / 3+ subsystems | **3-5 (ceiling 5)** |

More panelists is not more rigor — it is more context to reconcile. Pick the smallest N that gives
you genuinely DIFFERENT lenses on the problem. If N resolves to 0, say so and stop here. At Risk
CRITICAL the board does NOT replace the escalation protocol's "always ask the user" gate — it
produces the evidence-weighted verdict you bring TO that decision.

---

## Phase 1 — Canonical framing (what makes convergence comparable)

Write ONE neutral problem statement + curated evidence, **IDENTICAL for every panelist**. This is
the control variable: if each agent saw a different framing, their agreement would be meaningless.

The framing MUST:
- State the problem / decision in neutral terms — no leading hypothesis, no "I think it's X".
- Attach the SAME curated evidence to every panelist (relevant `file:line`, logs, constraints).
- Define what a conclusion must contain (thesis + confidence + evidence + assumptions — see Phase 2).
- NOT hint at the answer you expect. A biased framing manufactures a fake consensus.

---

## Phase 2 — Independent panel (parallel, fresh context, DIFFERENT lenses)

Dispatch N agents **IN PARALLEL** — single message, multiple `Task` calls (the parallel-dispatch
pattern of `deep-review`, its PARALLEL INVOCATION phase). Every agent gets the IDENTICAL Phase 1
statement; each gets a DIFFERENT lens. Fresh context per agent is what keeps them independent.

### Assign one lens per panelist

Pick N lenses from the catalog matching the work type. Do not overlap two panelists on the same
lens — that wastes an independent seat.

**Debugging**
- Backward data-flow (where does the bad value originate?)
- Invariants / contracts (which guarantee is violated?)
- Edge cases & concurrency (order, reentrancy, boundaries)
- Recent changes (git blame / diff — what changed?)
- First-principles (re-derive the expected behavior from scratch)

**Architecture**
- 10× load / scaling
- Coupling / dependencies (direction, cycles)
- Failure modes (what breaks under partial failure?)
- YAGNI / simplicity (is the complexity earned?)
- Systemic fit (does it match the repo's patterns?)

**Optimization**
- Hot-path / profiling (where is the time actually spent?)
- Algorithmic complexity (Big-O of the core loop)
- I/O & network (round-trips, batching)
- Memory / allocation (churn, retention)

**Generic** (no catalog matches): choose N distinct analytical angles and state each in the brief.

### Reuse existing specialists as a lens (create ZERO new agents)

When a lens matches a specialist's domain, dispatch that specialist as the panelist for that lens
(the same reuse pattern as `architect-design`'s agent-activation table):

| Lens domain | Panelist agent |
|-------------|----------------|
| Security / auth / tenant isolation | `security-guardian` |
| Async / concurrency / pools / latency | `async-performance-guardian` |
| Blast radius / dependency mapping | `impact-analyzer` |
| Risk scoring on a critical change | `risk-assessor` |
| Battle-tested architectural precedent | `battle-tested-architect` |

Any lens with no matching specialist → native `general-purpose` with the lens written into the brief.

### Panelist brief + return contract

Each `Task` prompt = the Phase 1 canonical statement + THIS agent's lens + the return contract.
Each panelist returns in the format of `${CLAUDE_PLUGIN_ROOT}/agents/_shared/response_format.xml`,
using the confidence markers of `${CLAUDE_PLUGIN_ROOT}/agents/_shared/rigor_patterns.xml`
(its confidence-markers legend), and MUST include:
- **Core thesis** — one sentence: the agent's conclusion on the problem.
- **Confidence 0-100** — a thesis under 60 does NOT count as a recommendation (it is a lean).
- **`[VERIFIED]` evidence** — with `file:line`; a thesis with no verified evidence is a guess.
- **Explicit assumptions** — what it took for granted to reach the thesis.

```
Task(
  subagent_type: "<specialist or general-purpose>",
  description: "Panelist: <lens>",
  prompt: |
    <the IDENTICAL Phase 1 canonical statement + curated evidence>

    YOUR LENS: <one lens from the catalog>. Analyze the problem ONLY through this lens.
    You are one of several independent panelists; do NOT try to be comprehensive — go deep on
    your lens and bring your OWN evidence.

    Return: core thesis (1 sentence) + confidence 0-100 + [VERIFIED] evidence (file:line) +
    explicit assumptions. Format per response_format.xml.
)
```

---

## Phase 3 — Convergence measurement (you aggregate; there is no judge agent)

You are the arbiter — the same role as the blue-vs-red synthesis in `senior-review`
(`${CLAUDE_PLUGIN_ROOT}/skills/senior-review/references/adversarial-board.md`, its synthesis phase).

1. Extract each panelist's **core thesis**.
2. Cluster them **SEMANTICALLY** — a qualitative judgment of whether they say the same thing, NOT a
   numeric vote. Two theses with different words but the same claim converge; two with the same word
   but different mechanisms do not.
3. Classify the state:

| State | Definition | Meaning |
|-------|------------|---------|
| **STRONG CONSENSUS** | all core theses coincide | high confidence — go to Phase 5 |
| **MAJORITY + OUTLIER** | N-1 coincide, 1+ dissents | do NOT discard the outlier: it is either noise OR the signal everyone else missed. Go to Phase 4. |
| **DISSENT** | no clear majority | ALARM: the problem is mis-framed or genuinely ambiguous. Go to Phase 4. |

"Majority" means a STRICT majority (> half). An even split with no majority — e.g. N=2 at 1-1 — is
DISSENT, not MAJORITY + OUTLIER. A cluster built on identical weak / decorative evidence is not a
consensus either (see Edge cases: suspicious unanimity).

---

## Phase 4 — Reconciliation (ONLY if not STRONG CONSENSUS)

One round, with anti-groupthink safeguards that exist to prevent a FAKE consensus. Panelists are
stateless — the Phase 2 instances have already returned — so this is a NEW round of parallel `Task`
dispatches (fresh context again). Give each re-dispatched panelist: its OWN prior thesis (so "hold
or move" starts from a real stance), the SAME lens, and the other theses ANONYMIZED (author and
order stripped). Then enforce:

1. **ANONYMIZE.** The foreign theses in each brief carry no author and no fixed order. This kills
   authority pressure ("the security expert said…") and order pressure (first / last bias).
2. **CHANGE ONLY WITH EVIDENCE.** An agent may hold or move its stance, but a move MUST cite WHICH
   foreign evidence changed its mind. "I'll join the consensus" with no new evidence is FORBIDDEN.
3. **PERSISTENT DISSENT IS REPORTED, not crushed.** A stance held with evidence enters the verdict
   as a reasoned minority vote — it is information, not an error to eliminate.
4. **CEILING: max 1 reconciliation round.** Still split → return as DISSENT. That is valid output,
   not a failure of the board.

The failure this phase guards against: agents caving to the majority to look agreeable, which would
convert independent convergence (the whole point) into groupthink.

---

## Phase 5 — Aggregated verdict (return to the caller)

- **Consensus level:** STRONG CONSENSUS / MAJORITY + OUTLIER / DISSENT.
- **Consolidated conclusion:** the thesis the board converged on (or the competing theses if DISSENT).
- **Confidence:** derived from the state + the independence and strength of the underlying evidence,
  NOT from the head-count alone.
- **Who-said-what map:** each panelist → lens → thesis → confidence → agree / disagree.
- **SHARED UNVERIFIED ASSUMPTIONS = the blind spots of the WHOLE panel.** List what EVERY panelist
  took for granted without verifying (modeled on the hidden-assumptions attack in
  `${CLAUDE_PLUGIN_ROOT}/agents/red-team-auditor.md`, its Attack 5). A unanimous board can be
  unanimously wrong about a shared premise — this is where that surfaces.

```markdown
## 🧭 Consensus Board Verdict

**Problem:** <the canonical statement>
**Panelists:** N (<lens1>, <lens2>, …)
**Consensus:** STRONG CONSENSUS | MAJORITY + OUTLIER | DISSENT
**Confidence:** <0-100> — <why: independence + evidence strength, not head-count>

### Consolidated conclusion
<the converged thesis, or the competing theses if DISSENT>

### Who said what
| Panelist | Lens | Thesis | Confidence | Aligns with |
|----------|------|--------|-----------|-------------|

### Reasoned minority (if any)
<the dissent held with evidence, and the foreign evidence it did NOT accept — and why>

### ⚠️ Shared unverified assumptions (whole-panel blind spots)
- <assumption every panelist relied on but none verified> — <how to close it>
```

---

## Edge cases & composition

- **A panelist fails / never returns:** proceed with the responders if **≥ 2** remain. If **< 2**,
  DEGRADE to single-thread analysis and DECLARE that explicitly — a "board" of one is not a board.
- **Suspicious unanimity** (all agree on weak or decorative evidence): before trusting it, hook
  `Skill(skill="verify-claims")` to confirm the core thesis is GROUNDED in real code, not a shared
  training-pattern hallucination. Unanimity is when you should be MOST suspicious, not least.
- **Cost control** is the Phase 0 gate — never convene for trivial work. There is no other throttle.
- **Composition:** consumers invoke this via `Skill(skill="consensus-board")`.
  `disable-model-invocation: true` blocks MODEL auto-trigger, NOT explicit composition — a caller
  skill (e.g. `systematic-debugging`, `architect-design`, `optimize`) escalating a high-stakes call
  can always invoke it deliberately.

---

## Operation rules

1. **Independence is the product.** Anything that lets panelists influence each other before Phase 3
   (a shared scratchpad, sequential dispatch that leaks earlier answers) destroys the measurement.
2. **You do NOT vote.** You cluster and judge evidence. A 3-1 split where the 1 holds the only
   `[VERIFIED]` reproduction is not a "majority win" — weigh evidence, not seats.
3. **Never manufacture consensus.** If the board is split after one reconciliation round, DISSENT is
   the honest answer — return it.
4. **The gate is mandatory.** Never convene a board for trivial / reversible work (Phase 0 = 0).

---

## Example invocation

```
Caller: Skill(skill="consensus-board")  # from systematic-debugging, on a high-stakes root cause
Board:  [Phase 0 → N=3] [Phase 1 canonical framing] [Phase 2 → 3 lenses in parallel]
        [Phase 3 → MAJORITY + OUTLIER] [Phase 4 → 1 anonymized round] [Phase 5 → verdict]
```
