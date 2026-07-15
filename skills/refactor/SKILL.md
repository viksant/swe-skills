---
name: refactor
description: >
  Safe refactoring orchestration that mutates source code to improve structure WITHOUT
  changing behavior, guarded by an ephemeral characterization/regression safety net.
  Use when the user EXPLICITLY asks to refactor — "refactor this", "restructure", "split
  this file", "extract", "clean up the structure" (typically with @-tagged paths).
  NOT for: performance optimization (use optimize), removing features or dead code (use
  code-deletion), or bug fixing; do not auto-refactor code unless explicitly asked.
allowed-tools: Read, Write, Bash, Grep, MultiEdit
model: opus
---

> **Framework:** See `${CLAUDE_PLUGIN_ROOT}/shared/cognitive-framework.md` for CoT/Reflexion/ReAct details.
> **Lens (MCP):** When invoking your sequential-thinking MCP tool, pass `lens: "refactorer"` (preserve behavior; regression safety net before touching code).

# ♻️ SAFE REFACTORING PROTOCOL

**Core:** IMPROVE CODE WITHOUT BREAKING ANYTHING

**Files to refactor:** "$ARGUMENTS"

---

## 🎯 SAFETY RULES (Non-Negotiable)

| Rule | Enforcement |
|------|-------------|
| Preserve ALL functionality | Zero breaking changes allowed |
| Maintain type safety | All TypeScript types intact |
| Verify imports | Every import resolves correctly |
| Follow project patterns | Use existing conventions |
| Incremental validation | Check each step before proceeding |

---

## 🛡️ MANDATORY SAFETY NET

A refactor ALWAYS mutates source code → a regression safety net is **MANDATORY**. Characterize the
code's observable behavior with ephemeral tests BEFORE touching it, keep them green DURING the change,
confirm end-to-end AFTER, then delete the scaffolding. Lifecycle you MUST execute:

| Phase | Action | Required state |
|-------|--------|----------------|
| **BEFORE** | Write an ephemeral *characterization* suite in `tests/_regression_guard/` capturing the current observable behavior (contract, not implementation; attack edges and failure paths) | **GREEN** on the untouched code. If you can't get to green, you don't yet understand the behavior → study more before refactoring |
| **DURING** | One atomic change at a time; run the relevant subset after each change and the full suite at every phase boundary | Never proceed on red |
| **AFTER** | Ephemeral suite 100% green + the affected real repo suite + fail-first discipline (revert and confirm the test would catch it) | Behavior preserved E2E |
| **CLEANUP** | Delete `tests/_regression_guard/` (verify `git status` clean) | If a test uncovered a PRE-EXISTING bug, **graduate it to permanent** and tell the user |

**Escape hatch:** if the user asks for a paradigm change (behavior MUST change), don't
characterize the old behavior — write tests for the new contract. When in doubt, **ask** before touching code.

---

## 🔧 TOOL PRIORITY

| Purpose | Tool |
|---------|------|
| Code analysis | LSP first (`lsp_find_references`, `lsp_goto_definition`) |
| Structural patterns | ast-grep second |
| Docs/configs only | grep last |
| File discovery | `Glob(pattern="**/*.py")` |

---

## 📋 EXECUTION PHASES

Execute the seven steps in order — full templates and per-step detail live in
**`${CLAUDE_PLUGIN_ROOT}/skills/refactor/references/refactor.md`**:

1. **Parse tagged files** — extract the `@`-tagged paths from the arguments; process only those.
2. **Deep analysis** — exports, dependencies (who imports it), patterns, risk areas.
3. **Strategy decision** — Low / Medium / High complexity by importer count → how many agents to enlist.
4. **Refactoring execution** — directory prep → bottom-up file creation → content migration (code looks NATIVE, no "moved from" comments) → import updates (no circular deps, update ALL consumers).
5. **Value assessment** — confirm it's worth refactoring; if not, ask the user before proceeding.
6. **Verification** — close the safety-net cycle (ephemeral suite green, real suite green, delete `tests/_regression_guard/`, `git status` clean).
7. **Results** — report files processed, structure changes, dependencies updated.

---

## 🤝 COMPOSITION

This skill composes three existing skills — use them, don't reinvent them:
- **scope-creep-prevention** — refactor ONLY the tagged files; resist "while I'm here" improvements.
- **meticulous-code-review** — review the migrated code before declaring it done (native, correct, no regressions).
- **verification-before-completion** — gate any "done / tests pass" claim on the real verification output above, never on assumption.

---

## 🚨 ROLLBACK TRIGGERS
- TypeScript compilation fails
- Build process breaks
- Import resolution errors
- Circular dependencies created
- Tests fail

---

## ✅ SUCCESS CRITERIA

1. Zero breaking changes to API surface
2. All exports maintain exact signatures
3. All imports resolve correctly
4. TypeScript compilation successful
5. All tests passing
6. Code looks native in new locations (no "moved from" comments)

---

Now proceeding with safe refactoring of: **$ARGUMENTS**
