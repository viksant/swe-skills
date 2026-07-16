# CONTEXT.md — repo orientation

Orientation for an agent or contributor working **inside** this repo. For the user-facing front door
(what to install and how), read [README.md](README.md) instead.

## What this repo is

A universal, **product-agnostic** Claude Code configuration layer: reusable skills, agents, and hooks
that raise engineering rigor (epistemic honesty, simplicity, verification, adversarial
review, multi-agent orchestration). It is published at `github.com/viksant/swe-skills` and ships as both
a native Claude Code plugin and an `npx skills add` package.

## Hard invariant — ZERO domain, ZERO PII

Nothing here may be tied to any specific product, company, stack, service, or dataset. No secrets, no
names, no environment specifics, no domain logic. Every piece must read as generic engineering guidance
that works in any repository. **Anything you add or edit must stay generic** — if it only makes sense for
one product, it does not belong here.

## Tree map

```
.claude-plugin/   plugin.json + marketplace.json — the plugin/marketplace manifests
skills/           30 skills, each <name>/SKILL.md (thinking protocols + workflows)
agents/           1 agent (battle-tested-architect.md) + _shared/ XML fragments + references/
hooks/            10 hook scripts (.sh) + hooks.json (the plugin's hook wiring)
shared/           4 shared reasoning fragments (cognitive-framework used by workflow skills)
config/           settings.example.json (manual hook wiring for install.sh users)
docs/             reference docs: agents, architecture, getting-started, hooks, skills
install.sh        manual installer → <target>/.claude/
prompting.md      prompting protocol (read on demand)
statusline.sh     status line script
CLAUDE.md         always-active behavioral rules (reference, not installed)
AGENTS.md         code conventions + task discipline (reference, not installed)
```

## Three install surfaces — and what each delivers

| Surface | Command | Delivers |
|---------|---------|----------|
| Plugin | `/plugin marketplace add viksant/swe-skills` + `/plugin install swe-skills@swe-skills` | Everything: skills + agents + hooks (hooks wired via `hooks/hooks.json`) |
| `npx skills add` | `npx skills add viksant/swe-skills` | Skills only → `.claude/skills/` (the CLI is skills-only) |
| Manual | `./install.sh /path/to/your-project` | `skills/`, `agents/`, `hooks/`, `shared/` + `prompting.md` + `statusline.sh` → `<target>/.claude/`, plus `settings.example.json` alongside |

Keep all three consistent when you change what ships: the plugin surface is defined by `.claude-plugin/`
+ `hooks/hooks.json`, the manual surface by `install.sh`, and every install command is documented in
`README.md` and `docs/getting-started.md`.

## Where behavioral rules live

- **[CLAUDE.md](CLAUDE.md)** — the always-active operating rules (epistemic honesty, language/format,
  execution and output prohibitions).
- **[AGENTS.md](AGENTS.md)** — code conventions before editing + task discipline + verification.

Both are reference content folded into a consuming project by hand, not installed by any method. Edit the
rule bodies there, not here.
