#!/usr/bin/env bash
# PostToolUse Hook - Brief review reminder after touching source code.
# Only acts on .py/.ts/.tsx/.js/.jsx after Write/Edit/MultiEdit.

input="$(cat 2>/dev/null)"
[ -z "$input" ] && exit 0

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"

# --- Filter: only verifiable source code ---
case "$tool_name" in
    Write|Edit|MultiEdit) ;;
    *) exit 0 ;;
esac
printf '%s' "$file_path" | grep -Eq '\.(py|ts|tsx|js|jsx)$' || exit 0

cat <<'HOOK_EOF'
<post-implementation-review>
You touched code. Before closing the turn:
1. SIMPLICITY: a class that should be a function? an abstraction with <3 consumers? -> simplify.
2. BUGS: edge cases, missing null/await, off-by-one. The code is guilty until proven otherwise.
3. EVIDENCE: run the module's verification and show the REAL output (not "it should pass").
Trivial (typo, import) -> fix it now. Design decision -> AskUserQuestion.
</post-implementation-review>
HOOK_EOF
exit 0
