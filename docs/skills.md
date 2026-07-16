# Skills

Skills under `.claude/skills/<name>/SKILL.md` are the toolkit's workflows and thinking protocols. Each
declares its own triggers in the frontmatter `description` ("Use when …" / "NOT for …"); Claude invokes a
matching skill automatically via the `Skill` tool, or you invoke one explicitly as `/swe-skills:<name>`.
Skills guide *how to reason* and encode *workflows* (implement, refactor, optimize, hand off),
complementing agents (which *do* the delegated work).

## Drop-in skills (installed by `install.sh`)

### `analytics-cleaner`
Safely removes analytics, tracking, and telemetry code (mixpanel, segment, amplitude, datadog, newrelic,
Google Analytics, `track_event`, `@monitor`, …) with mandatory user approval and zero functionality
impact.
- **Use when:** the user explicitly asks to "remove analytics", "strip tracking", "delete telemetry",
  "get rid of mixpanel/segment/amplitude", or clean out instrumentation.
- **Not for:** general dead-code cleanup (use `code-deletion`), refactoring, or removing critical SYSTEM
  metrics — never auto-invokes without an explicit analytics-removal request.

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

### `consensus-board`
Convenes N independent fresh-context agents on the SAME problem, each through a DIFFERENT lens, and
measures whether they CONVERGE — so a caller can put more weight on a high-stakes conclusion.
`disable-model-invocation`; invoked explicitly or escalated to by another skill.
- **Use when:** "board of experts", "consensus check", "is this diagnosis solid?", "get more
  confidence on this decision"; or another skill escalating a high-stakes / ambiguous call.
- **Not for:** coverage-style multi-domain review (use `deep-review`), a blue-vs-red diff audit (use
  `senior-review`), or a trivial / reversible call (no board needed).
- Convergence, not coverage: divergence is an ALARM (fragile / mis-framed diagnosis); confidence comes
  from INDEPENDENT agreement where each agent brings its own evidence, not from mere agreement.

### `context-implement`
Context-driven implementation: reads the full conversation to extract the user's true intent, then
plans, executes, self-critiques (Reflexion) and verifies — via Chain-of-Thought and ReAct.
- **Use when:** "implement what we discussed", "build the feature from this chat", "apply the changes we
  agreed on", "now implement it".
- **Not for:** greenfield ideas with no prior chat context, pure research, or debugging an existing bug.

### `deliberate-thinking`
Structured reasoning via a sequential-thinking MCP for complex decisions and large implementation
planning.
- **Use when:** changes touch 3+ files or critical paths; architectural decisions; implementation spans
  5+ files or a large implementation is being planned; the user says "think about this", "step by
  step", "plan", "what's the best approach"; `--seq` / `--think` flags.
- **Not for:** trivial changes (<3 files), obvious-cause bug fixes, docs-only changes, pure research.

### `generate-docs`
Generates direct, no-fluff technical documentation as a `.md` file — present-tense "as-is" voice, zero
metadata/changelog/marketing filler.
- **Use when:** "generate docs", "write documentation", "document this system/API/module", "write a
  README for X".
- **Not for:** a session handoff (use `handoff`), marketing copy, or editing non-documentation prose.

### `handoff`
Produces an exhaustive session handoff written to `HANDOFF.md` so a future person or a fresh Claude
session with zero context can resume without asking anything (timeline, files changed, decisions +
rationale, failed approaches, next steps).
- **Use when:** "hand off", "dump the context", "write a handoff", "save the session for later".
- **Not for:** loading/resuming a prior handoff (use `load-handoff`), general documentation (use
  `generate-docs`), or a quick status summary.

### `load-handoff`
Reconstructs the full context of a previous session from a `HANDOFF.md` file and reports any drift
between the handoff and the current repo state (moved files, committed changes, branch switches).
- **Use when:** "load handoff", "resume session", "pick up where we left off", or a fresh session that
  needs the prior context restored.
- **Not for:** writing/dumping the handoff (that is `handoff`).

### `meticulous-code-review`
Detailed code inspection before declaring work complete.
- **Use when:** about to say "done"/"ready"/"finished"; after writing >10 lines; "check my code", "any
  bugs?", "is this safe?"; modifying business logic or touching critical paths.
- **Not for:** pure documentation, config-only changes, trivial typo fixes.
- Re-reads every line, traces data flow, enumerates failure modes, verifies against requirements.

### `optimize`
Critical, documentation-validated performance optimization analysis (6-phase protocol) that may modify
source code for speed while preserving behavior. Measure before optimizing.
- **Use when:** the user explicitly asks to optimize or profile — "optimize this", "make it faster",
  "improve performance", "profile", "reduce latency", "this is slow".
- **Not for:** readability refactoring (use `refactor`), bug fixing, or read-only review.

### `refactor`
Safe refactoring orchestration that mutates source code to improve structure without changing behavior,
guarded by an ephemeral characterization/regression safety net.
- **Use when:** the user explicitly asks to refactor — "refactor this", "restructure", "split this
  file", "extract", "clean up the structure".
- **Not for:** performance optimization (use `optimize`), removing features or dead code (use
  `code-deletion`), or bug fixing.

### `reflect`
Analyzes the current session for your OWN errors and saves generalizable, deduplicated lessons to
`.claude/reflections.md`, filed under the correct category.
- **Use when:** "reflect", "what did you learn", "save lessons", "retrospective", "capture takeaways".
- **Not for:** reviewing code (use `meticulous-code-review`) or writing documentation.

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

### `write-prompt`
Distills the current conversation plus code-anchored research into a self-sufficient, delimited XML
prompt you paste into a fresh Claude Code session (or hand to a subagent) that shares no context.
- **Use when:** "write/give me a prompt for…", building a meta-prompt, handing a task to a new
  session with no shared context, or packaging a task spec for another agent to execute.
- **Not for:** executing the task yourself, or a trivial instruction that needs no context transfer.
- Runs a sufficiency gate first (asks the user on any requirement doubt; abstains only on unverified
  code facts), then selects a startup point from the real discovered catalog with a native fallback
  (`Explore` / `general-purpose` / `Plan`). Detail in `write-prompt/references/template.md`.
