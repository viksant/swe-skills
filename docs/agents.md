# Agents

Agents are specialized subprocesses dispatched with the `Agent`/`Task` tool. Each is a markdown file
with frontmatter (`name`, `description`, `tools`, `model`) and starts in a **fresh context** — free of
the dispatching session's biases — with only the tools its frontmatter grants.

**Read-only vs implementer:** an agent can only WRITE code if its `tools:` line includes `Edit`/`Write`.
Most specialists are read-only (`Read, Grep, Glob, LS, Bash, …`) — they investigate and review.
Implementation goes to an agent armed with `Edit`/`Write` (the native `general-purpose`, or a specialist
you deliberately arm), carrying a brief with the fix already distilled by the read-only specialist.

The orchestration model (director vs player, the 5-layer architecture, escalation) is in
[architecture.md](architecture.md).

## Drop-in agents (installed by `install.sh`)

| Agent | Capability | Description |
|-------|-----------|-------------|
| `battle-tested-architect` | Read-only | AOSA pattern researcher — investigates battle-tested architectural patterns from open-source projects (architecture research only). Pairs with the `battle-tested-patterns` skill. |

You add your own agents in `.claude/agents/` as your project needs them — cross-cutting specialists
(security, performance, testing) or a scoped owner per subsystem. See
[architecture.md](architecture.md) for the orchestration model that routes work to them.

## Shared agent fragments

`agents/_shared/` holds reusable XML fragments (base role, response format, rigor patterns) that agent
definitions include, and `agents/references/` holds a pattern index. These are installed with the
drop-in `agents/` directory.
