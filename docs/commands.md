# Commands

Commands are slash-invoked workflows under `.claude/commands/<name>.md`, run as `/<name>`. Each file is
an executable protocol the model follows. Commands encode *a workflow*; skills encode *how to reason*;
agents *do* delegated work.

## Drop-in commands (installed by `install.sh`)

| Command | What it does |
|---------|--------------|
| `/analytics-cleaner` | Safely removes unwanted analytics code with mandatory user approval and zero functionality impact. |
| `/code-cleaner` | Safe code removal — active features or dead code — with full verification (the command form of the `code-deletion` skill). |
| `/context-implement` | Context-driven implementation using Chain-of-Thought, Reflexion, and ReAct. For features where the path is known and you want disciplined execution. |
| `/generate-docs` | Generates direct, no-fluff documentation on any topic. Tables over prose, no marketing filler, no invented facts. |
| `/handoff` | Exhaustively dumps the session context to `HANDOFF.md` so another session can resume with zero gaps. |
| `/load-handoff` | Reconstructs the full context of a previous session from `HANDOFF.md` (a fresh session with no prior context). |
| `/optimize` | Critical optimization analysis — a 6-phase protocol with documentation validation. Measure before optimizing. |
| `/refactor` | Safe refactoring orchestration that improves code without breaking functionality. |
| `/reflect` | Analyzes the session's errors and saves generalizable reflections. |
