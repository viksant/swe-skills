---
name: senior-review
description: >
  Use when reviewing the full diff of a work session with senior-SWE rigor before
  declaring it done: mechanical verification (compile / lint / typecheck / tests / grep)
  PLUS dynamic-behavioral analysis PLUS a semantic audit (blue team) counter-weighted by
  an adversarial red team, reconciled into one verdict. Triggers: "review this session",
  "senior review", "is this diff safe to merge", after finishing a multi-file change.
  NOT for: reviewing a single small file inline (use meticulous-code-review), authoring a
  plan (use /swe-skills:write-plans), or debugging a known bug (use systematic-debugging).
  Heavy and user-invoked — do not auto-invoke.
allowed-tools: Read, Grep, Glob, Bash, Task, AskUserQuestion, Write
model: opus
disable-model-invocation: true
---

> **Philosophy:** "If you reach the big diff without having passed layers 1 and 2, you
> already lost." This skill runs Layer 2 (mechanical) + Layer 3 (semantic). Layer 1
> (up-front containment) is covered by planning (`/swe-skills:write-plans`).
> **Lens (MCP):** When invoking your sequential-thinking MCP tool, pass `lens: "reviewer"`
> (guilty until proven innocent; edge cases + `file:line`).
> **Layers 3a/3b (review is NOT only static):** Layer 3a runs dynamic analysis (flow
> tracing + edge-case matrix + real directed execution). Layer 3b is an adversarial
> counter-weight: `red-team-auditor` + specialists ATTACK the blue team
> (`senior-code-auditor`) to break its comfort zone. The synthesis (Phase 5.6) reconciles
> blue vs red with evidence. Depth is proportional to the risk level.

# Senior Review — SWE Senior Workflow (Layer 2 + 3)

**Args (optional):** `$ARGUMENTS`

Supported flags:
- `--base <branch>` (default: `main`)
- `--scope <path>` (default: the whole session diff)
- `--skip-tests` (skip the test suite if it takes too long)

---

## The pipeline (run in order; never PASS without every applicable phase)

Depth is proportional to the highest risk level touched (see Phase 2). The deep operational
detail for each phase lives in the reference files — read them as you reach each phase.

| Phase | What | Detail |
|-------|------|--------|
| 0 | Validate the environment (git repo, base branch, toolchain present) | `references/mechanical-and-dynamic.md` |
| 1 | Snapshot the session diff (detect uncommitted / contaminated working tree) | `references/mechanical-and-dynamic.md` |
| 2 | Classify each changed file by risk (CRITICAL / NORMAL / LOW) | inline below |
| 3 | Mechanical checks: compile, lint, typecheck, tests, regression net, migrations, coverage — Layer 2 | `references/mechanical-and-dynamic.md` |
| 4 | Adversarial grep by risk category — Layer 2 patterns | `references/mechanical-and-dynamic.md` |
| 4.5 | Dynamic / behavioral analysis: flow trace + edge-case matrix + directed execution — Layer 3a | `references/mechanical-and-dynamic.md` |
| 4.6 | Adjacent technical debt (impact x effort) | `references/mechanical-and-dynamic.md` |
| 5 | Semantic audit via `senior-code-auditor` — BLUE TEAM (Layer 3) | `references/adversarial-board.md` |
| 5.5 | Adversarial counter-board via `red-team-auditor` + specialists — RED TEAM (Layer 3b) | `references/adversarial-board.md` |
| 5.6 | Synthesis & reconciliation (blue vs red) — you are the arbiter | `references/adversarial-board.md` |
| 6 | Consolidated report to the user | `references/output-format.md` |
| 7 | Persist the report to disk (always) | `references/output-format.md` |

Full paths: `${CLAUDE_PLUGIN_ROOT}/skills/senior-review/references/<file>.md`.

---

## Phase 2 — Classify by risk (the single knob that scales the whole review)

**Classify each changed file.** If the host project defines `<project>/.claude/REVIEW_TIERS.md`,
use its tier assignments. Otherwise fall back to this neutral heuristic:

- **CRITICAL** — touches security/auth, data-loss/destructive operations, money/billing,
  boot/config, or a public API/contract.
- **NORMAL** — standard business logic.
- **LOW** — docs, tests, cosmetic changes.

| Risk touched | What the review does |
|--------------|----------------------|
| **CRITICAL** | ALARM. Verify the user acknowledged the risk with a literal `[CRITICAL CONFIRM]` during the session — if NOT, report a PROTOCOL VIOLATION. Activate line-by-line review + the adversarial grep for the subsystem + load any convention/playbook the host documents for it. Full dynamic analysis (4.5) + adjacent-debt pass (4.6) + full counter-board (5.5). |
| **NORMAL** | Standard: linter + type checker + tests for the touched module. Flow trace of the change + edge-case matrix. `red-team-auditor` alone as counter-weight. |
| **LOW** | Skim. No adversarial grep, no dynamic pass, no counter-board. |

This risk level gates Phases 4, 4.5, 4.6 and 5.5 — the reference files repeat the same
CRITICAL / NORMAL / LOW columns so each phase knows how deep to go.

---

## Composition — skills this review leans on

Use these as thinking protocols where the phases call for them (do not reinvent them):

- **regression-safety-net** — for a refactor of a module WITHOUT tests, Phase 3.4b generates
  an ephemeral characterization suite so "the existing tests pass" cannot mask a behavior change.
- **systematic-debugging** — Phase 4.5.1 flow tracing of a branched data path.
- **exhaustive-testing** — Phase 4.5.2 builds the edge-case matrix systematically, not from memory.
- **verify-claims** — self-verify any `file:line` citation before it enters the report.

Delegated to fresh-context agents (each starts clean, without this session's biases):

- **`senior-code-auditor`** (blue team, Phase 5) — defends a verdict by reading the diff.
- **`red-team-auditor`** (red team, Phase 5.5) — attacks the blue verdict with evidence.
- **`impact-analyzer`** (Phase 4.6) — scores the blast radius of adjacent debt.
- Counter-board specialists (Phase 5.5, CRITICAL only) — `security-guardian`,
  `async-performance-guardian`, and, for any other domain hotspot, a matching
  `<domain>-specialist` agent if the host project defines one, else native `general-purpose`.

---

## Operation rules

1. **NEVER** declare PASS without having run ALL applicable phases in order (0 -> 6, including
   4.5 / 4.6 / 5.5 / 5.6 per the highest risk level touched). Phase 7 (persist the report) runs
   ALWAYS after the verdict — it is not a PASS gate.
2. If a tool is not installed, print the exact install command and mark that check BLOCKED (not PASS).
3. If the diff is huge (> ~1500 LOC), suggest the user split it into intermediate commits and
   re-run `/swe-skills:senior-review` on each.
4. **NEVER** run `git commit` / `git push` automatically. This skill is audit-only, not merge.
5. **NEVER** modify production code. An obvious fix is REPORTED, not applied. Ephemeral tests
   from Phases 4.5 / 5.5 go in a throwaway dir (e.g. `tests/_regression_guard/`, `tests/_redteam_repro/`)
   and are deleted after reporting — graduate to permanent only the one that exposed a real bug.
6. **Output is evidence** (commands + real outputs), NOT optimistic summaries. If tests FAIL, show
   the first ~40 lines of the actual output.
7. **Safe directed execution (Phases 4.5 / 5.5):** run only PURE functions directly. Anything that
   opens a pool/socket -> ephemeral test with mocks or a trace. NEVER dev servers, staging/prod DBs,
   or real external APIs.
8. **The red team does NOT decide the verdict** (Phase 5.6 reconciles). It is also not contrarian by
   reflex: every dispute needs `file:line` + repro/trace, and whatever survives the attack is
   CONFIRMED explicitly.
9. **The counter-weight is proportional to risk.** Do not invoke the red team or specialists for a
   diff that is 100% LOW — that is cost with no return.

---

## Example invocation

```
User: /swe-skills:senior-review
Assistant: [Runs Phases 0-7 in order, shows the report, and persists it to .claude/reviews/]

User: /swe-skills:senior-review --base develop --skip-tests
Assistant: [Same, but base=develop and the test suite is SKIPPED]

User: /swe-skills:senior-review --scope src/payments/
Assistant: [Reviews only files under src/payments/]
```
