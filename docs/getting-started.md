# Getting started

## 1. Install

Three methods. Method 1 delivers the full toolkit; method 2 is skills-only; method 3 is a manual copy.

### Method 1 — Plugin (skills + commands + agents + hooks)

Run inside a Claude Code session:

```
/plugin marketplace add viksant/swe-skills
/plugin install swe-skills@swe-skills
```

Installs all four surfaces and wires the hooks automatically via the bundled `hooks/hooks.json`, so you
can **skip step 2** below.

### Method 2 — `npx skills add` (skills only)

```
npx skills add viksant/swe-skills
```

Copies the 8 skills into `.claude/skills/`. The `skills` CLI is skills-only — commands, agents and hooks
are **not** installed. Use method 1 or 3 for those.

### Method 3 — Manual (`install.sh`)

From the toolkit root:

```bash
./install.sh /path/to/your-project
```

This copies into `<target>/.claude/`:

- `skills/`, `commands/`, `agents/`, `hooks/`, `shared/` (recursively)
- `prompting.md`, `statusline.sh`
- `settings.example.json` (dropped alongside, not merged)

Existing destination files are skipped. Flags:

| Flag | Effect |
|------|--------|
| `--dry-run` | Print what would be copied; write nothing. |
| `--force` | Overwrite existing files. |

`docs/` (and the root `CLAUDE.md` / `AGENTS.md`) are reference material — they are **not** installed.
You read them and fold their guidance into your own project by hand.

## 2. Wire the hooks and status line

This step is for the **manual install** (method 3) — the plugin install wires the hooks for you via
`hooks/hooks.json`.

The hooks are inert until registered in `settings.json`. Merge the shipped example into your project's
`.claude/settings.json` (or copy it if you don't have one):

```
<target>/.claude/settings.example.json  ->  <target>/.claude/settings.json
```

`settings.example.json` registers, by event:

| Event | Hooks |
|-------|-------|
| `UserPromptSubmit` | `epistemic-honesty`, `cognitive-triage`, `user-signal-detector`, `inject-prompt-forge` |
| `SessionStart` (startup/clear/compact/resume) | `simplicity-enforcer`, `code-quality-standards`, `concise-response-enforcer` |
| `PreToolUse` (Write) | `concise-plan-mode` |
| `PostToolUse` (Write/Edit/MultiEdit) | `post-write-review-hook` |
| `Stop` | `completion-gate` |

It also sets a `statusLine` command and a few `env` defaults. Each hook path uses `$CLAUDE_PROJECT_DIR`,
so it resolves relative to the target project. Verify the scripts are executable
(`chmod +x .claude/hooks/*.sh`).

If your Claude Code runs with hooks **disabled** (e.g. an enterprise managed configuration), the hook
scripts still double as plain guidance: each `SessionStart` / `UserPromptSubmit` hook just prints
text, so you can paste the relevant script's output into your system prompt at launch instead.

## 3. How the pieces work

### Skills

A skill is a `SKILL.md` under `.claude/skills/<name>/`. Its frontmatter `description` declares WHEN it
applies ("Use when: …" / "NOT for: …"). Claude reads the descriptions and invokes a matching skill via
the `Skill` tool before acting — no manual step required. Skills encode *how to think* about a class of
task (verify before claiming done, simplify after implementing, review before finishing).

### Commands

A command is a markdown file under `.claude/commands/<name>.md`, invoked as `/<name>`. It contains an
executable protocol the model follows step by step. Commands encode *a workflow* (plan, refactor,
optimize, review, hand off a session).

### Agents

An agent is a markdown file under `.claude/agents/<name>.md` with frontmatter (`name`, `description`,
`tools`, `model`). Dispatched with the `Agent`/`Task` tool, it runs in a **fresh context** with only
the tools its frontmatter lists. Read-only agents (`Read, Grep, Glob, …`) investigate and review;
agents with `Edit`/`Write` can implement. The main loop's job is to **direct** — pick the specialist,
write its brief, integrate the result — not to do heavy domain work itself. See
[architecture.md](architecture.md).

### Hooks

A hook is a shell script the harness runs on a lifecycle event. Hooks write to stdout, which the
harness appends to the context (for injection hooks) or uses to allow/block a tool call or turn close
(for gate hooks like `completion-gate`). Gates are **fail-open**: on any doubt (no transcript, nothing
to verify) they allow the action. The hook script is the source of truth for its text — edit the script
to change the behavior.

### Rules

The toolkit's behavioral policy — absolute rules, code conventions, task discipline — lives in the root
`CLAUDE.md` and `AGENTS.md`. These are **not** installed; fold their guidance into your own project's
`CLAUDE.md` / `.claude/rules/*.md`, which Claude Code auto-loads into context every session. Keep such
rules tight — every line is a per-turn tax.

## 4. First steps

1. Start a session in the target project. The `SessionStart` hooks fire; you should see the simplicity,
   code-quality, and concise-response doctrines injected.
2. Ask for a small change. Watch `epistemic-honesty` and `user-signal-detector` shape the prompt, and
   `post-write-review-hook` remind you to review after an edit.
3. Try a command: `/refactor`, `/optimize`, or `/generate-docs`.
4. When you finish real work, `completion-gate` blocks the turn close until you run verification — run
   the tests and show the output.

## 5. Fold in the root reference (optional but recommended)

The drop-in pieces are generic. For the behavioral policy behind them, read the root `CLAUDE.md`
(identity, guiding principles) and `AGENTS.md` (code conventions + task discipline), and merge the
parts you want into your own project's `CLAUDE.md` / `.claude/rules/`. Add one `<domain>-specialist`
agent per subsystem you own (see [agents.md](agents.md)) so the orchestration model in
[architecture.md](architecture.md) has specialists to route to.
