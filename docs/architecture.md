# Architecture

The toolkit organizes a coding session around one idea: the **main loop is a conductor, not a
player**. It triages the request, delegates heavy work to focused agents, and reviews what comes back.
The drop-in skills, agents, and hooks make that model concrete; this doc explains how they
fit together and how you extend them with your own agents.

## Orchestrator doctrine: director vs player

The main loop is the **conductor, not a player**. Its default is to DIRECT: triage the request → pick
the specialist(s) → write the brief → review/integrate/synthesize the result. It does not carry heavy
domain work itself. The distinction is not "agent yes/no" — it is *directing vs executing*:

| DIRECT → main loop does it | EXECUTE → delegate to a specialist |
|----------------------------|------------------------------------|
| `Grep`/`Glob` to locate a file | Investigate a bug's root cause |
| `Read` to verify an agent's output | Implement a feature / substantial change |
| Judge, compare, synthesize agent results | Multi-file refactor |
| Decide scope/architecture, talk to the user | Audit / review a subsystem |

**Efficiency exception:** delegating isn't free — a fresh agent re-reads context. Don't pay that cost
for mechanically-trivial work (a typo, a rename, a comment); do it directly. Delegate for substantial
or domain-heavy work, adversarial verification, and independent parallel work.

## The layered model

A rigorous session moves through layers, from shaping the request to gating the result:

```
LAYER 1: METACOGNITIVE (hooks + skills)
  cognitive triage, user-signal detection (hooks)
  deliberate/structured reasoning (skills)

LAYER 2: STRATEGIC
  assess impact and risk; decide how much machinery a task needs

LAYER 3: SPECIALISTS (agents)
  battle-tested-architect ships ready
  + one <domain>-specialist per subsystem you own

LAYER 4: QUALITY GATE (skills)
  verification-before-completion + meticulous-code-review
```

- **Layer 1** shapes the request before work starts (force deliberate thinking on complex tasks, detect
  the user's mode, warn on destructive operations). Ships as the drop-in hooks + reasoning skills.
- **Layer 2** decides *how much* machinery a task needs — map the blast radius, weigh the risk, and
  compose an agent set for multi-domain work before committing to a change.
- **Layer 3** does the domain work. `battle-tested-architect` ships ready; you add one
  `<domain>-specialist` per subsystem you own (see [agents.md](agents.md)).
- **Layer 4** is the gate before "done": verification with real command output, then meticulous review.
  Ships as the `verification-before-completion` and `meticulous-code-review` skills.

## Routing: how a task reaches the right agent

Pick the agent by matching the task to a trigger — a keyword, a file path, a phrasing. A custom agent
that matches the domain is strongly preferred over a native one: it carries domain checklists a native
agent lacks. Native agents are fine for genuinely generic work (file search, broad exploration). For
recurring multi-subsystem situations, compose a small agent set (a security-audit set, a performance
set) rather than lean on one generalist — but keep it to a few agents per request; more agents means
more context to reconcile, not more rigor.

## Escalation protocol

```
Confidence > 80%   -> proceed; the quality gate validates
Confidence 50-80%  -> reinforced quality gate (all checks)
Confidence < 50%   -> STOP, ask the user
Risk CRITICAL       -> always ask the user
3+ quality-gate rejects -> STOP, present full analysis
```
