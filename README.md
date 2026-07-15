# Claude Code Toolkit

**Engineering rigor for any SWE task on any stack — drop-in skills, agents, and hooks for [Claude Code](https://claude.com/claude-code). The opposite of vibe coding.**

A portable configuration layer: **skills** (invoked automatically when a task matches, or explicitly as `/swe-skills:<name>`), **agents** (specialized subprocesses with clean context), and **hooks** (lifecycle scripts). They enforce epistemic honesty (never guess what isn't in context), simplicity (KISS/YAGNI), verification-before-completion (no "done" without evidence), adversarial code review, and a director/executor orchestration model. Nothing is tied to a product or stack — generic rigor you drop into any repository.

## Install

Pick one. Method 1 gives you everything; method 2 is skills-only; method 3 is a manual copy.

### 1. Plugin — the full toolkit (skills + agents + hooks)

```
/plugin marketplace add viksant/swe-skills
/plugin install swe-skills@swe-skills
```

Installs all three surfaces and wires the hooks via the bundled `hooks/hooks.json`. Run these inside a Claude Code session.

### 2. `npx skills add` — skills only

```
npx skills add viksant/swe-skills
```

Copies all 29 skills into `.claude/skills/`. The `skills` CLI is skills-only, so agents and hooks are **not** installed by this method — use method 1 or 3 for those.

### 3. Manual — `install.sh`

```
./install.sh /path/to/your-project
```

Copies the drop-in dirs (`skills/`, `agents/`, `hooks/`, `shared/`) plus `prompting.md` and `statusline.sh` into `<target>/.claude/`, and drops `settings.example.json` alongside for you to wire the hooks by hand. Existing files are skipped unless you pass `--force` (`--dry-run` previews). The root `CLAUDE.md` / `AGENTS.md` are behavioral reference and are **not** installed. See [docs/getting-started.md](docs/getting-started.md).

## The adversarial review workflow

`/swe-skills:ship-feature` drives a large feature through six phases. Each phase delegates to a skill, then runs an **adversarial review board** — a blue agent produces and defends the artifact, red agents attack it with evidence, and the main session arbitrates — before a human gate. Each phase writes to a dossier under `.claude/features/<slug>/`, so a fresh session resumes at the exact phase.

| Phase | Delegates to | Adversarial board |
|-------|--------------|-------------------|
| Frame | `superpowers-brainstorming` | `general-purpose` (blue) vs `red-team-auditor` + `risk-assessor` |
| Architect | `/swe-skills:architect-design` | `battle-tested-architect` vs `security-guardian` + `async-performance-guardian` + `risk-assessor` + `impact-analyzer` |
| Plan | `/swe-skills:write-plans` | `general-purpose` vs `red-team-auditor` + `impact-analyzer` |
| Build | `/swe-skills:subagent-build` | runs `/swe-skills:senior-review` per task (`senior-code-auditor` vs `red-team-auditor`) |
| Deep-review | `/swe-skills:deep-review` | multi-agent panel vs `red-team-auditor` |
| Close | `verification-before-completion` | final refutation against the frame's success criteria |

Every skill and agent in the chain also runs standalone — the pipeline is their composition, not a monolith.

## Skills

### Workflows

Run a multi-step task. Invoke explicitly as `/swe-skills:<name>`; the heavy pipeline flows are user-invoked by design.

| Skill | Description |
|-------|-------------|
| `ship-feature` | Orchestrate a large feature through frame → architect → plan → build → deep-review → close, with an adversarial board at each step. |
| `architect-design` | Enterprise architecture design over an approved frame — battle-tested patterns, Clean Architecture lens, brutal self-critique. |
| `write-plans` | Author a detailed, executable plan (plan-then-execute, risk tiers, pedigree numbers); feed it to `subagent-build`. |
| `subagent-build` | Execute a plan with one fresh-context subagent per task, a multi-reviewer gate, real per-task verification, and a final `senior-review`. |
| `senior-review` | Review a session's diff — mechanical checks + behavioral analysis + blue (`senior-code-auditor`) vs red (`red-team-auditor`) synthesis. |
| `deep-review` | Feature-focused deep review with a dynamic multi-agent panel. |
| `superpowers-brainstorming` | Turn an idea into an approved design through one-question-at-a-time dialogue. |
| `context-implement` | Implement from the conversation's intent — Chain-of-Thought, Reflexion self-critique, ReAct, no scope creep. |
| `refactor` | Improve structure without changing behavior, guarded by an ephemeral characterization/regression safety net. |
| `optimize` | Documentation-validated performance optimization (6-phase); may modify source for speed while preserving behavior. |
| `code-deletion` | Safe code removal in two modes — surgical feature removal, or dead-code cleanup with 11-level verification. |
| `analytics-cleaner` | Remove analytics/tracking/telemetry code with mandatory user approval and zero functionality impact. |
| `generate-docs` | Generate direct, no-fluff technical documentation as a `.md` — present-tense, zero metadata/marketing filler. |
| `write-prompt` | Distill the conversation + code-anchored research into a self-sufficient XML prompt for a fresh session that shares no context. |
| `handoff` | Write an exhaustive session handoff to `HANDOFF.md` so a zero-context session can resume without asking anything. |
| `load-handoff` | Reconstruct a previous session from `HANDOFF.md` and report drift against the current repo state. |
| `reflect` | Analyze the session for your own errors and save generalizable, deduplicated lessons. |

### Thinking protocols

Auto-loaded to shape reasoning and verification when a task matches their triggers.

| Skill | Description |
|-------|-------------|
| `deliberate-thinking` | Structured reasoning via a sequential-thinking MCP for complex decisions and large implementation planning. |
| `systematic-debugging` | Four-phase debugging — root cause → pattern analysis → hypothesis → fix — before proposing any fix. |
| `battle-tested-patterns` | Verify architectural decisions against battle-tested patterns from open-source projects (AOSA). |
| `code-simplifier` | Simplify code for clarity and consistency while preserving behavior; catches overengineering. |
| `meticulous-code-review` | Detailed self-review before declaring work complete — bugs, edge cases, security. |
| `verification-before-completion` | Require fresh verification-command output before making any success claim. |
| `verify-claims` | Self-verify reasoning and citations to catch ungrounded claims (information-theoretic check). |
| `scope-creep-prevention` | Keep a task within its original scope; resist "while I'm here" additions. |
| `regression-safety-net` | Shield any code change with ephemeral characterization tests captured before, during, and after. |
| `superpowers-test-driven-development` | Write the failing test first, watch it fail, then write minimal code. |
| `exhaustive-testing` | Generate and execute production-grade tests — concurrency, malformed input, failures, edge cases, adversarial scenarios. |
| `superpowers-receiving-code-review` | Process code-review feedback correctly before implementing any of it. |

Full catalog with triggers: [docs/skills.md](docs/skills.md).

## Agents

Specialized subprocesses dispatched with the `Task` tool, each starting with clean context. Read-only agents investigate and review; `security-guardian` can also implement.

| Agent | Access | Description |
|-------|--------|-------------|
| `battle-tested-architect` | read-only | Research battle-tested architectural patterns from open-source projects. |
| `senior-code-auditor` | read-only | Evaluate a session's diff like a senior engineer — tier-aware, adversarial grep by risk category. |
| `red-team-auditor` | read-only | Attack a reviewer's report and its green checks — refute false positives, hunt blind spots, with evidence. |
| `risk-assessor` | read-only | Score a change 0-100 across data safety, tenant isolation, performance regression, and security surface. |
| `impact-analyzer` | read-only | Map the blast radius of a change and identify every affected subsystem. |
| `async-performance-guardian` | read-only | Investigate async and concurrency bottlenecks — admission control, pools, cross-replica coordination, capacity. |
| `security-guardian` | read/write | Security-vulnerability and OWASP-compliance investigator. |

Add your own `<domain>-specialist` agents in `.claude/agents/` for the subsystems you own. Full catalog: [docs/agents.md](docs/agents.md).

## Hooks

Shell scripts the harness runs on lifecycle events. Under the plugin install they are wired automatically via `hooks/hooks.json`; under the manual install you wire them in `settings.json`. One hook — `inject-prompt-forge.sh` — is **opt-in** (not wired by default); see [docs/hooks.md](docs/hooks.md).

| Hook | Event | Description |
|------|-------|-------------|
| `epistemic-honesty.sh` | UserPromptSubmit | Inject the "don't guess what's not in your context" reminder. |
| `cognitive-triage.sh` | UserPromptSubmit | Force sequential thinking on `--seq`; warn on destructive DB operations. |
| `user-signal-detector.sh` | UserPromptSubmit | Detect the user's mode (frustrated/urgent/confused/exploratory/precise) and adapt. |
| `inject-prompt-forge.sh` | UserPromptSubmit — opt-in | Remind to apply the prompting protocol (sufficiency gate, classify, scope, verify). Not wired by default. |
| `simplicity-enforcer.sh` | SessionStart | Inject the anti-overengineering (KISS/YAGNI) doctrine. |
| `code-quality-standards.sh` | SessionStart | Inject code-quality standards (names, comments, docstrings, type hints). |
| `concise-response-enforcer.sh` | SessionStart | Inject the short-response doctrine (zero filler). |
| `concise-plan-mode.sh` | PreToolUse (Write) | Enforce concise, filler-free writing in plan files (`plans/*.md`). |
| `post-write-review-hook.sh` | PostToolUse (Write/Edit) | Brief review reminder after touching source code. |
| `completion-gate.sh` | Stop | Block turn close if source changed but no verification ran after the last change (fail-open). |

Full catalog: [docs/hooks.md](docs/hooks.md).

## CLAUDE.md / AGENTS.md

Two root files carry the behavioral policy: **`CLAUDE.md`** (always-active operating rules — epistemic honesty, language/format, execution and output prohibitions) and **`AGENTS.md`** (code conventions + task discipline). They are behavioral reference, **not installed** by any method — fold their guidance into your own project's `CLAUDE.md` / `.claude/rules/` so it loads every session. For a map of this repo itself, see [CONTEXT.md](CONTEXT.md).

## Repository structure

```
claude-code-toolkit/
├── .claude-plugin/
│   ├── plugin.json          # plugin manifest (for /plugin install)
│   └── marketplace.json     # marketplace entry (for /plugin marketplace add)
├── skills/                  # 29 drop-in skills (<name>/SKILL.md) — workflows + thinking protocols
├── agents/                  # 7 drop-in agents (+ _shared/ XML fragments, references/)
├── hooks/                   # 10 hook scripts (.sh) + hooks.json (plugin wiring)
├── shared/                  # 4 shared reasoning fragments (cognitive-framework used by workflow skills)
├── config/                  # settings.example.json (manual hook wiring)
├── docs/                    # reference docs: agents, architecture, getting-started, hooks, skills
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

- **`comprehensive-review@claude-code-workflows` plugin.** The `optimize` skill references its `architect-review` agent for system-wide design analysis. Install it separately for that path; otherwise the skill falls back to a generic architecture-focused subagent.

## License

MIT — see [LICENSE](LICENSE).
