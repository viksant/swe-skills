# Claude Code Toolkit

**A universal toolkit that raises engineering rigor for any SWE task on any stack — the opposite of vibe coding.**

A portable, drop-in configuration layer for [Claude Code](https://claude.com/claude-code): reusable
**skills**, **slash commands**, **agents**, and **hooks** that make a coding session more disciplined —
epistemic honesty (never guess what isn't in context), simplicity enforcement (KISS/YAGNI),
verification-before-completion (no "done" without evidence), adversarial code review, and a multi-agent
orchestration model. None of it is tied to a particular product or stack — it is generic engineering
rigor you drop into any repository.

## Install

Pick one. Method 1 gives you everything; method 2 is skills-only; method 3 is a manual copy.

### 1. Plugin — the full toolkit (skills + commands + agents + hooks)

```
/plugin marketplace add viksant/swe-skills
/plugin install swe-skills@swe-skills
```

Installs all four surfaces at once and wires the hooks via the bundled `hooks/hooks.json`. Run these
inside a Claude Code session.

### 2. `npx skills add` — skills only

```
npx skills add viksant/swe-skills
```

Copies the 8 skills into `.claude/skills/`. The `skills` CLI is skills-only, so commands, agents and
hooks are **not** installed by this method — use method 1 or 3 for those.

### 3. Manual — `install.sh`

```
./install.sh /path/to/your-project
```

Copies the drop-in dirs (`skills/`, `commands/`, `agents/`, `hooks/`, `shared/`) plus `prompting.md`
and `statusline.sh` into `<target>/.claude/`, and drops `settings.example.json` alongside for you to
wire the hooks by hand. Existing files are skipped unless you pass `--force` (`--dry-run` previews).
The root `CLAUDE.md` / `AGENTS.md` are behavioral reference and are **not** installed. See
[docs/getting-started.md](docs/getting-started.md) for the full setup.

## Skills

Structured thinking protocols the model invokes automatically when a task matches their triggers.

| Skill | Description |
|-------|-------------|
| `battle-tested-patterns` | Verify architectural decisions against battle-tested patterns from open-source projects (AOSA). |
| `code-deletion` | Safe code removal in two modes — surgical feature removal, or dead-code cleanup with 11-level verification. |
| `code-simplifier` | Simplify code for clarity and consistency while preserving behavior; catches overengineering. |
| `deliberate-thinking` | Structured reasoning via a sequential-thinking MCP for complex decisions and large implementation planning. |
| `meticulous-code-review` | Detailed self-review before declaring work complete — bugs, edge cases, security. |
| `scope-creep-prevention` | Keep a task within its original scope; resist "while I'm here" additions. |
| `verification-before-completion` | Require fresh verification-command output before making any success claim. |
| `verify-claims` | Self-verify reasoning and citations to catch ungrounded claims (information-theoretic check). |

Full catalog with triggers: [docs/skills.md](docs/skills.md).

## Commands

Slash commands (invoke with `/<name>`) that run a specialized workflow.

| Command | Description |
|---------|-------------|
| `/analytics-cleaner` | Safely remove unwanted analytics code with mandatory user approval and zero functionality impact. |
| `/code-cleaner` | Safe code removal — active features or dead code, with full verification. |
| `/context-implement` | Context-driven implementation with Chain-of-Thought, Reflexion and ReAct. |
| `/generate-docs` | Generate direct, no-fluff documentation on any topic. |
| `/handoff` | Exhaustively dump the session context to `HANDOFF.md` so work resumes with zero gaps. |
| `/load-handoff` | Reconstruct the full context of a previous session from `HANDOFF.md`. |
| `/optimize` | Critical optimization analysis — 6-phase protocol with documentation validation. |
| `/refactor` | Safe refactoring orchestration that improves code without breaking behavior. |
| `/reflect` | Analyze session errors and save generalizable reflections. |

Full catalog: [docs/commands.md](docs/commands.md).

## Agents

Specialized subprocesses dispatched with the `Agent`/`Task` tool, each starting with clean context.

| Agent | Description |
|-------|-------------|
| `battle-tested-architect` | Researches battle-tested architectural patterns from open-source projects (architecture research only; read-only). |

The drop-in set ships one archetype; add your own agents in `.claude/agents/` as your project needs
them. Full catalog: [docs/agents.md](docs/agents.md).

## Hooks

Shell scripts the harness runs on lifecycle events. Under the plugin install they are wired
automatically via `hooks/hooks.json`; under the manual install you wire them in `settings.json`.

| Hook | Event | Description |
|------|-------|-------------|
| `epistemic-honesty.sh` | UserPromptSubmit | Inject the "don't guess what's not in your context" reminder. |
| `cognitive-triage.sh` | UserPromptSubmit | Force sequential thinking on `--seq`; warn on destructive DB operations. |
| `user-signal-detector.sh` | UserPromptSubmit | Detect the user's emotional mode (frustrated/urgent/confused/exploratory/precise) and adapt. |
| `inject-prompt-forge.sh` | UserPromptSubmit | Remind to apply the prompting protocol (sufficiency gate, classify, scope, verify). |
| `simplicity-enforcer.sh` | SessionStart | Inject the anti-overengineering (KISS/YAGNI) doctrine. |
| `code-quality-standards.sh` | SessionStart | Inject code-quality standards (names, comments, docstrings, type hints). |
| `concise-response-enforcer.sh` | SessionStart | Inject the short-response doctrine (zero filler). |
| `concise-plan-mode.sh` | PreToolUse (Write) | Enforce concise, filler-free writing in plan files (`plans/*.md`). |
| `post-write-review-hook.sh` | PostToolUse (Write/Edit) | Brief review reminder after touching source code. |
| `completion-gate.sh` | Stop | Block turn close if source changed but no verification ran after the last change (fail-open). |

Full catalog: [docs/hooks.md](docs/hooks.md).

## CLAUDE.md / AGENTS.md

Two root files carry the behavioral policy behind the toolkit: **`CLAUDE.md`** (always-active operating
rules — epistemic honesty, language/format, execution and output prohibitions) and **`AGENTS.md`** (code
conventions + task discipline). They are **behavioral reference, not installed** by any method — fold
their guidance into your own project's `CLAUDE.md` / `.claude/rules/` so it loads every session. For a
map of this repo itself, see [CONTEXT.md](CONTEXT.md).

## Repository structure

```
claude-code-toolkit/
├── .claude-plugin/
│   ├── plugin.json          # plugin manifest (for /plugin install)
│   └── marketplace.json     # marketplace entry (for /plugin marketplace add)
├── skills/                  # 8 drop-in reasoning skills (<name>/SKILL.md)
├── commands/                # 9 drop-in slash commands (<name>.md)
├── agents/                  # 1 drop-in agent (+ _shared/ XML fragments, references/)
├── hooks/                   # 10 hook scripts (.sh) + hooks.json (plugin wiring)
├── shared/                  # 4 shared reasoning fragments (cognitive-framework used by commands)
├── config/                  # settings.example.json (manual hook wiring)
├── docs/                    # reference docs: agents, architecture, commands, getting-started, hooks, skills
├── CLAUDE.md                # always-active behavioral rules (reference, NOT installed)
├── AGENTS.md                # code conventions + task discipline (reference, NOT installed)
├── CONTEXT.md               # repo orientation for agents/contributors
├── install.sh               # manual installer → <target>/.claude/
├── prompting.md             # prompting protocol (read on demand)
├── statusline.sh            # status line script
└── LICENSE                  # MIT
```

## Optional external dependencies

The toolkit works standalone. One integration is optional:

- **`comprehensive-review@claude-code-workflows` plugin.** The `/optimize` command references its
  `architect-review` agent for system-wide design analysis. Install it separately if you want that
  path; otherwise `/optimize` falls back to a generic architecture-focused subagent.

## License

MIT — see [LICENSE](LICENSE).
