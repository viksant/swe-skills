# Hooks

Hooks are shell scripts the harness runs on lifecycle events. They write to stdout, which the harness
either appends to the context (injection hooks) or reads to allow/block an action (gate hooks). Register
them in `.claude/settings.json` (see `config/settings.example.json`). The script is the source of truth
for its text — edit the script to change the behavior. When the toolkit is installed as a plugin, the
hooks are wired automatically via the bundled `hooks/hooks.json` — no manual `settings.json` step.

Gate hooks are **fail-open**: on any doubt (no transcript, nothing changed, already verified) they allow
the action rather than block it.

## Drop-in hooks (installed by `install.sh`)

| Hook | Event | Role |
|------|-------|------|
| `epistemic-honesty.sh` | UserPromptSubmit | Injects the "don't guess what's not in your context" reminder: compare what's asked (X) against what your context covers (Y); if X > Y, read or ask — never assume. Fixed text. |
| `cognitive-triage.sh` | UserPromptSubmit | Emits two deterministic signals only: `--seq`/`--think`/`--sequential` → force sequential thinking; a destructive DB operation (drop/truncate/`delete from`) → warn to confirm first. Silent otherwise. |
| `user-signal-detector.sh` | UserPromptSubmit | Detects the user's dominant emotional mode (FRUSTRATED / URGENT / CONFUSED / EXPLORATORY / PRECISE) with precedence and emits a `<user-signal>` only on a real signal (neutral = silence). |
| `inject-prompt-forge.sh` | UserPromptSubmit | Reminds the model to apply the prompting protocol (`prompting.md`): sufficiency gate → ask if info is missing; else classify, scope the context, decompose, define verifiable criteria. Trivial prompts proceed directly. |
| `simplicity-enforcer.sh` | SessionStart | Injects the anti-overengineering doctrine (KISS, YAGNI, the "could a junior understand this in 5 minutes?" test, overengineering red flags). Fixed text. |
| `code-quality-standards.sh` | SessionStart | Injects code-quality standards (declarative names, inline comments, docstrings, type hints, early returns, import order). Fixed text. |
| `concise-response-enforcer.sh` | SessionStart | Injects the short-response doctrine: every word must add value; no intros, no closing recaps, tables over prose. Fixed text. |
| `concise-plan-mode.sh` | PreToolUse (Write) | Applies only to `Write` on `.md` files inside a `plans/` directory: injects the 4 plan-writing rules (no intros/recaps, as-is voice, zero ceremony, every word earns its place). Silent elsewhere. |
| `post-write-review-hook.sh` | PostToolUse (Write/Edit/MultiEdit) | After touching source (`.py`/`.ts`/`.tsx`/`.js`/`.jsx`), injects a brief review reminder (simplicity, bugs, run verification). |
| `completion-gate.sh` | Stop | If source code was modified this turn and no verification (tests/lint/type-check) ran after the last change, blocks the turn close and injects a reminder. Fail-open; anti-loop guard. |
