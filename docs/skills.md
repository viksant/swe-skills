# Skills

Skills are structured thinking protocols under `.claude/skills/<name>/SKILL.md`. Each declares its own
triggers in the frontmatter `description` ("Use when …" / "NOT for …"); Claude invokes a matching skill
automatically via the `Skill` tool. Skills guide *how to reason*, complementing agents (which *do* the
work) and commands (which *run a workflow*).

## Drop-in skills (installed by `install.sh`)

### `battle-tested-patterns`
Verifies architectural decisions against battle-tested patterns from AOSA (Architecture of Open Source
Applications).
- **Use when:** proposing new architecture, "design pattern", "best practice", "how is this done in
  production", "architecture decision".
- **Not for:** simple code changes, bug fixes, or refactoring without architectural impact.
- Produces a verdict (VERIFIED / SUPPORTED / UNVERIFIED / NO PRECEDENT) from a 5-point checklist and
  can hand off to the `battle-tested-architect` agent for deeper research.

### `code-deletion`
Safe code elimination in two modes: (A) surgical removal of an active feature, (B) dead-code cleanup
with an 11-level verification system.
- **Use when:** "remove feature", "delete functionality", "clean dead code", "unused code", "get rid
  of this", "we don't need this anymore".
- **Not for:** refactoring (changing structure without removing functionality).
- Forces mode identification (active vs dead) before any deletion; unclear code is treated as active.

### `code-simplifier`
Simplifies and refines code for clarity, consistency, and maintainability while preserving all
functionality.
- **Use when:** after any implementation/refactor, "simplify this", "too complex", "make it cleaner",
  "hard to read"; runs before `meticulous-code-review` in the post-implementation chain.
- **Not for:** adding functionality, fixing bugs, or behavioral changes.
- Leads with an overengineering audit (a class that should be a function, an abstraction with one
  consumer, a registry for three items).

### `deliberate-thinking`
Structured reasoning via a sequential-thinking MCP for complex decisions and large implementation
planning.
- **Use when:** changes touch 3+ files or critical paths; architectural decisions; implementation spans
  5+ files or a large implementation is being planned; the user says "think about this", "step by
  step", "plan", "what's the best approach"; `--seq` / `--think` flags.
- **Not for:** trivial changes (<3 files), obvious-cause bug fixes, docs-only changes, pure research.

### `meticulous-code-review`
Detailed code inspection before declaring work complete.
- **Use when:** about to say "done"/"ready"/"finished"; after writing >10 lines; "check my code", "any
  bugs?", "is this safe?"; modifying business logic or touching critical paths.
- **Not for:** pure documentation, config-only changes, trivial typo fixes.
- Re-reads every line, traces data flow, enumerates failure modes, verifies against requirements.

### `scope-creep-prevention`
Prevents a task from expanding beyond its original scope.
- **Use when:** implementing, fixing, or refactoring — and tempted to "improve" nearby code, add
  "helpful" features, or do "while I'm here" changes; "stay focused", "just do what I asked". Active
  during all implementation.
- **Not for:** exploratory research, or when the user explicitly asks for broad improvements.

### `verification-before-completion`
Requires running verification commands and confirming their output before any success claim.
- **Use when:** about to claim "complete"/"fixed"/"done"/"passing"/"working"; "prove it works", "show
  me evidence"; before committing or creating PRs.
- **Not for:** pure documentation changes or plan-mode research.
- Iron law: no completion claim without fresh verification evidence in the same message.

### `verify-claims`
Self-verification of reasoning using an information-theoretic approach (EDFL/Strawberry) to catch
citations that add no information beyond prior knowledge.
- **Use when:** after complex analysis with citations; before high-stakes decisions; "are you sure?",
  "verify your claims", "prove it"; debugging why a previous analysis was wrong.
- **Not for:** simple factual lookups, or claims copy-pasted directly from code.
