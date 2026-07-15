# Senior Review — Mechanical (Layer 2) + Dynamic (Layer 3a) phases

Operational detail for Phases 0, 1, 3, 4, 4.5, 4.6. The SKILL.md carries the pipeline map,
the risk heuristic (Phase 2), and the operation rules. All commands below are written
stack-agnostically: substitute the project's real toolchain (detect it from the repo — the
test runner, type checker, linter, compiler, migration tool).

---

## Phase 0 — Validate the environment (always first)

```bash
# Confirm we are inside a git repo
git rev-parse --show-toplevel || { echo "ABORT: not a git repo"; exit 1; }

# Resolve the base branch
BASE="${ARG_BASE:-main}"
git rev-parse "$BASE" || { echo "ABORT: base branch '$BASE' does not exist"; exit 1; }
```

Then confirm the project's toolchain is available (detect from the repo): the interpreter/compiler,
test runner, type checker and linter the checks below will call. If a required tool is missing,
print its exact install command and mark the corresponding check BLOCKED — do not silently skip it.

**If any of these fail -> stop and report to the user. Do not skip.**

---

## Phase 1 — Snapshot the session diff

### 1.0 Detect state BEFORE snapshotting (uncommitted / contaminated working tree)

`base...HEAD` assumes the session committed its work. A common flow is spec-driven-without-commits
(work stays in the working tree until the user asks for the commit), sometimes on top of a tree
that already carried earlier uncommitted layers. Before taking the diff:

```bash
git status --porcelain
git rev-parse HEAD
git rev-parse "$BASE"
```

1. If `git status --porcelain` is EMPTY and `HEAD` != `$BASE` -> normal flow, `base...HEAD` is the
   source. Continue with 1.1 unchanged.
2. If `git status --porcelain` is NOT empty and/or `HEAD` == `$BASE` (nothing committed) ->
   **the work is UNCOMMITTED**. `base...HEAD` would be EMPTY relative to the real work (a false PASS:
   the review would audit a diff that contains nothing). Use the **working tree** as the source:
   `git diff` (modified tracked) + `git status --short` (for the `??` untracked). Do NOT use
   `base...HEAD` in this case.
3. If the working tree also carries **layers foreign** to the session (`M`/`??` files the session did
   NOT touch) -> WARN "contaminated working tree: `git diff` would mix my work with unrelated
   uncommitted code." Instead of auditing the full diff, **review BY SYMBOL**: ask for or build the
   explicit list of `file:line` / functions / components the session actually touched, and pass THAT
   list (not the raw diff) to the Phase 5 / 5.5 auditors, instructing them to read those directly.
4. Document in the final report (Phase 6) what the real source was (`base...HEAD` / working tree /
   symbol list) — the verdict must not read as "I covered the whole diff" if the source was otherwise.

### 1.1 Snapshot (source per 1.0)

```bash
git status --short
git diff --name-only "$BASE"...HEAD > /tmp/session_files.txt
git diff --stat "$BASE"...HEAD

# Numbers and constants (early detection of magic values)
git diff "$BASE"...HEAD -G '^\s*[A-Z_]+\s*=\s*[0-9]'
git diff "$BASE"...HEAD -G '\b(timeout|ttl|limit|size|max|min|batch|retry|interval)\b'
```

> If 1.0 determined uncommitted-working-tree or symbol-list, substitute `"$BASE"...HEAD` with the
> working tree (bare `git diff`) or with the files from the symbol list, respectively, in every
> command of this section and in Phases 4 / 4.5.

Show the user:
- Number of changed files
- LOC added / deleted
- **If LOC > 800 in a single session -> WARNING `large diff`.** Suggest splitting the audit into
  sub-sessions (intermediate commits).

---

## Phase 3 — Mechanical checks (Layer 2)

Run IN ORDER. If any fails, stop and report (do not continue blindly). Each check shows **the exact
command + output**. Substitute the project's real tools for every generic step below.

### 3.1 Compile / syntax (catch invented syntax)

Run the stack's syntax/compile check on the changed source files (a compiler pass, a bytecode-compile
step, a `--noEmit` typecheck — whatever proves the files parse). This is the cheapest catch for
hallucinated syntax.

### 3.2 Linter — undefined names + dead imports

Run the project's linter over the changed files, focusing on the rules that catch typical LLM
hallucinations: **undefined names**, **unused imports**, **unused locals**, **redefinitions**. These
are what expose invented functions and phantom imports.

### 3.3 Type checker — diff scope (not the whole repo)

Run the project's type checker over the changed files only (not the whole repo). Use the repo's
existing strictness — do not turn on strict mode if the codebase is not fully typed; offer that as an
opt-in flag instead.

### 3.4 Tests — only the touched modules

Run the project's test suite scoped to the modules the diff touched (map changed files -> their test
targets using the repo's test layout). If `--skip-tests` is present, skip this step but mark it
**SKIPPED** in the report.

### 3.4b Regression net for coverage-less refactors (skill `regression-safety-net`)

Step 3.4 runs the tests that **already exist**. If the session diff is a **refactor** (behavior
preserved) of a module **without tests** covering its contract, 3.4 proves nothing about behavior
preservation — it passes because there is nothing to fail.

Detection: for each touched source file, check whether a test file references it; if none does, flag
it as UNCOVERED.

For each refactored module WITHOUT coverage, **invoke `regression-safety-net`** and generate an
ephemeral *characterization* suite (e.g. under `tests/_regression_guard/`) that confirms the diff did
not change observable behavior. Run it against `HEAD` (post-change); for the full guarantee, also run
it against `$BASE` (pre-change) and compare — a good characterization test passes on both. Delete the
scaffolding when done; **graduate to permanent** any test that exposed a bug the diff introduced, and
report it as a high-severity finding.

If the diff is a declared **paradigm change** (behavior MUST change), do NOT characterize the old
behavior: verify tests of the NEW contract exist; their absence IS the finding.

### 3.5 Secondary-project typecheck (if the diff spans one)

If the diff touches a separate typed sub-project (e.g. a frontend package with its own type checker),
run that sub-project's typecheck too. Same principle as 3.1/3.3, different toolchain.

### 3.6 Migrations (if the diff touches DB migrations)

If the diff includes database migrations, dry-run them with the project's migration tool and inspect
the generated SQL/DDL. Grep the migration files for destructive operations (`DROP` / `TRUNCATE`) and
confirm a downgrade/rollback path exists.

### 3.7 Diff coverage (if tooling exists)

If diff-coverage tooling is configured (a prior coverage report exists), check the diff's coverage
against a threshold. If not, suggest the command to generate coverage but do NOT fail the review for it.

---

## Phase 4 — Adversarial grep (by risk category of the touched hotspot)

Run ONLY the greps relevant to the categories the diff actually touched. Use the `Grep` tool
(ripgrep) for performance.

**These are universal risk CATEGORIES, not a fixed pattern list.** The exact symbols/paths differ per
project, so for each category that applies: **discover the host repo's real patterns first** (Grep/Glob
for its config layer, its error boundary, its queue/DB adapters, its money paths) — a discovered map
beats a stale hardcoded one. Preserve the METHODOLOGY: grep for the anti-pattern, report only positive
hits.

| Category (if the diff touches it) | What to hunt for |
|-----------------------------------|------------------|
| **Secrets / config** | Hardcoded secrets/tokens; direct environment access that bypasses the project's config layer. |
| **Error handling / boundary leaks** | Raw framework exceptions raised outside the request/error boundary; raw exception text leaked into a client-facing response instead of a sanitized message. |
| **AuthZ / tenant isolation** | Reads/writes missing the tenant/workspace/owner scope; an ownership check performed AFTER the effect instead of before. |
| **Concurrency / queues** | Oversized batch reads; queue reads without a visibility-timeout/lease; unguarded destructive deletes on a queue/table. |
| **DB / time** | Low-level direct connects that bypass the pool; naive timestamps without timezone; `COALESCE`/casts with a wrong-type literal for the column. |
| **Money / quotas** | Non-atomic increment/decrement of a balance/quota; a reserve/confirm (or debit/credit) pair that is not idempotent under retry. |

Report **only POSITIVE hits** (matches). No hits for a grep = clean for that category.

---

## Phase 4.5 — Dynamic / behavioral analysis (Layer 3a)

Phases 3 and 4 are **static** (they read syntax and patterns). This phase reasons and **executes
behavior**. Depth is proportional to risk (same criterion as Phase 2):

| Risk touched | What 4.5 does |
|--------------|---------------|
| **CRITICAL** | FULL flow trace + edge-case matrix + directed execution |
| **NORMAL** | Flow trace of the change + edge-case matrix (execution only for a cheap pure function) |
| **LOW** | Nothing (skim) |

### 4.5.1 Flow trace (control + data)

For each CRITICAL change, trace the data path across the layers. Do NOT read the file in isolation:
follow the data input -> transformation -> output, citing `file:line` at every hop. Use the skill
`systematic-debugging` and, for branched flows, your sequential-thinking MCP with `lens: "debugger"`
and `thinkingMode: "debugging"`.

Guiding question: **"if I inject a value at the input, which functions does it pass through, what
transforms it, and where does it exit?"** A hop you cannot trace IS a finding (hidden coupling or a
non-obvious side effect).

### 4.5.2 Edge-case + concurrency matrix

Build this systematically (skill `exhaustive-testing`), not from memory:

| Axis | Case to evaluate |
|------|------------------|
| Empty / null | empty list, empty string, None/nil, empty object |
| Boundary | 0, -1, 1, exact limit, limit+1, overflow |
| Concurrency | two requests against the same resource, race on a cache/lock |
| Partial failure | exception mid-way through a multi-step sequence |
| Re-entrancy | retry over already-partially-written state (idempotency) |
| Ordering | out-of-order arrival (async / queues rarely guarantee strict FIFO) |

For each cell relevant to the diff: what does the code do? Reason or execute. Anything you cannot
answer is a gap -> a candidate finding for the red team (Phase 5.5).

### 4.5.3 Directed execution (what makes this phase "non-static")

Invoke a PURE function directly in a one-liner/REPL of the stack (parsing, validation, transformation,
calculation, regex, normalization) with an edge input, and observe the real output.

**Safety guardrail (CRITICAL):** execute directly ONLY pure functions. If the function opens a
pool/socket (imports a DB/HTTP/cache client, acquires a connection, issues a network call), **do NOT
execute it directly** — generate an ephemeral test with mocks (skill `regression-safety-net`) or stay
in the 4.5.1 trace.

**FORBIDDEN:** dev servers, connections to staging/prod databases, mutations, real calls to external
paid/rate-limited APIs. When in doubt whether an execution touches real infra -> do NOT execute, trace.

Report each execution with the **exact command + real output** (do not summarize).

---

## Phase 4.6 — Debt adjacent to the diff (impact x effort)

Phases 4 / 4.5 judge what the session CHANGED. This looks ONE ring outward: the **technical debt
BORDERING the diff** — the symbols the session touched and their immediate neighbors (same file,
direct caller/callee), NOT a sweep of the whole subsystem. That broad sweep is the job of
`/swe-skills:architect-design`; do NOT replicate it here — debt that does not touch what the session
changed is OUT of scope.

Risk-gated (same criterion as Phase 2 / 4.5):

| Risk touched | What 4.6 does |
|--------------|---------------|
| **CRITICAL** | Inventory of adjacent debt + impact x effort prioritization (with `impact-analyzer`) |
| **NORMAL** | Skim the immediate neighbors of the change; only what jumps out |
| **LOW** | Nothing |

### 4.6.1 Identify the adjacent debt

Over the touched symbols and their DIRECT neighbors (no further), hunt the typical smells the diff left
visible: duplication the change enlarged, an over-broad exception swallow, a stale TODO/FIXME the diff
brushes, a bloated function, a name that no longer says what it does, a neighboring contract without a
test. Cite `file:line` for each item.

### 4.6.2 Prioritize by impact x effort (reuse `impact-analyzer`)

Delegate the **impact** axis to the `impact-analyzer` agent (via `Task`): which subsystems benefit if
each item is paid down, and what it risks. Estimate the **effort** axis yourself (trivial / medium /
large). Order best-return first (high impact x low effort).

```
Task:
  subagent_type: impact-analyzer
  description: "Impact of adjacent debt"
  prompt: |
    Estimate the blast radius of these technical-debt items ADJACENT to the session diff
    (do NOT audit the whole subsystem, only these symbols and their direct neighbors):
    <list with file:line from 4.6.1>
    Per item: which subsystems it affects if paid down, what it risks, blast radius.
```

It is an **advisory**, NOT an action: the debt is REPORTED in Phase 6, not fixed here (operation
rule 5). The user decides whether to pay it down.
