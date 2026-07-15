# Senior Review — Output format (Phase 6) + Persistence (Phase 7)

---

## Phase 6 — Consolidated report to the user

Format:

```markdown
# Senior Review — <branch> vs <base>

## Layer 2 (mechanical)
| Check | Status | Notes |
|-------|--------|-------|
| Compile / syntax | PASS / FAIL | <errors if fail> |
| Linter (undefined / dead imports) | PASS / FAIL | <hits if fail> |
| Type checker (diff scope) | PASS / FAIL | <critical errors> |
| Tests (touched modules) | PASS / FAIL / SKIPPED | N tests, X failures |
| Secondary typecheck (if any) | PASS / FAIL / N/A | <hits> |
| Migration dry-run (if any) | PASS / FAIL / N/A | <conflicts> |
| Diff coverage | X% / N/A | <files below threshold> |

## Adversarial grep (Layer 2 — patterns)
[List of POSITIVE hits per touched category, empty = OK]

## Layer 3a (dynamic / behavioral)
- **Flow traces:** <input -> ... -> output chain with file:line, per CRITICAL change>
- **Edge-case matrix:** <cells evaluated + what the code does in each>
- **Directed executions:** <exact command + real output, or "N/A: no safe pure functions">

## Debt adjacent to the diff (Phase 4.6 — impact x effort)
[Prioritized list of debt BORDERING the diff with file:line, impact (via impact-analyzer)
and estimated effort; best return (high impact x low effort) first. Empty / N/A if LOW risk
or no adjacent debt. Advisory only, not fixed here.]

## Layer 3 (semantic) — Senior Code Auditor (BLUE TEAM)
[Full output of the senior-code-auditor agent]

## Layer 3b (counter-weight) — Red Team
[Output of the red-team-auditor + specialists: refutations, new blind spots,
risk/check disputes, hidden assumptions, and findings CONFIRMED after attack]

## Reconciliation (blue vs red)
| Finding | Blue said | Red said | Resolution | Final severity |
|---------|-----------|----------|------------|----------------|
| <title> | BLOCK/PASS | refuted/confirmed/new | <who won + why> | BLOCK/NEEDS_FIX/obs/retracted |

## Final verdict
**[PASS | NEEDS_FIX | BLOCK]**

> Justification citing the reconciliation: a BLOCK requires file:line + repro/trace
> that survived the blue-vs-red cross-check.

### Required actions (if NEEDS_FIX or BLOCK)
1. <concrete fix with file:line>
2. ...
```

---

## Phase 7 — Persist the review to disk (ALWAYS)

After generating the Phase 6 output, **persist it to disk ALWAYS** (not opt-in): leave an auditable
trace of every review.

1. Create the directory (idempotent):

```bash
mkdir -p .claude/reviews
```

2. Derive the `<slug>` from `$ARGUMENTS` (e.g. the `--scope` or free text) or, if none, from the
   current branch. Short kebab-case (lowercase, hyphens, no `/`). The date `<YYYY-MM-DD>` is the
   system date.

3. Write the file with the `Write` tool at:

```
.claude/reviews/senior-review-<slug>-<YYYY-MM-DD>.md
```

   Content = a **metadata header** + the **Phase 6 output exactly as you already generated it** (do
   NOT reinvent or summarize it), preserving ALL `file:line` citations:

```markdown
---
date: <YYYY-MM-DD>
branch: <current branch>
base: <BASE>
scope: <--scope or "the whole session diff">
---

<FULL PHASE 6 OUTPUT, verbatim>
```

4. Tell the user the path written, ALWAYS:

```
Review persisted at: .claude/reviews/senior-review-<slug>-<YYYY-MM-DD>.md
```
