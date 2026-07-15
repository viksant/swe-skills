---
name: verification-before-completion
description: >
  Requires running verification commands and confirming output before making ANY
  success claims. Use when: about to claim "complete"/"fixed"/"done"/"passing"/"working",
  user says "prove it works", "show me evidence", "verify", before committing or
  creating PRs.
  NOT for: pure documentation changes or plan-mode research.
version: 1.0.0
---

# Verification Before Completion

## Why Verification Matters

This is PRODUCTION code. Claiming "done" without verification:
- Wastes user time when bugs are found
- Erodes trust in your work
- Creates 3AM incidents for on-call engineers
- Affects real people with real problems

Evidence before claims. Always. No exceptions.

---

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Why This Matters

- Trust is irreplaceable - once broken, hard to rebuild
- Undefined functions shipped = crashes in production
- Missing requirements shipped = incomplete features
- Time wasted on false completion → redirect → rework

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.

## Example Flow

```
User: "Fix the import error in user_service.py"
→ Claude implements the fix
→ About to say "Done" — verification skill activates
→ Runs: python -c "from app.services.user_service import get_user"
→ Output: ImportError on line 12 — fix was incomplete!
→ Fixes remaining issue, reruns verification
→ Output: clean import, no errors
→ NOW declares: "Fixed. Verification: `python -c 'from app.services.user_service import get_user'` — imports clean."
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Claimed "done" without running tests | Skipped verification under time pressure | Re-read Iron Law; run command THEN claim |
| Tests pass but feature doesn't work | Insufficient test coverage | Verify against original requirement, not just test suite |
| Verification command itself fails | Wrong command or environment issue | Fix environment first; use `.venv` for Python |
| Said "should work" instead of proving it | Softening language habit | Replace ALL hedging words with actual command output |
