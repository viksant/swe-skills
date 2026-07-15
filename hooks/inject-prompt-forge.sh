#!/usr/bin/env bash
# UserPromptSubmit Hook - auto-forge: reminder of the prompting protocol.
# Adds (stdout -> additionalContext) a short notice on each prompt so Claude
# treats the raw request with the project's protocol (.claude/prompting.md):
# sufficiency gate -> ask if info is missing; if substantive, classify,
# scope the context, decompose, and define verifiable criteria. Trivial prompts
# proceed directly. It does NOT rewrite the user's prompt (UserPromptSubmit
# cannot); the text travels appended to the turn. Cheap: fixed text, no LLM call.
# Fixed text: does not read stdin, only emits.

cat <<'HOOK_EOF'
<prompt-forge>
Before acting on the request above, apply the project's prompting protocol
(.claude/prompting.md): (1) SUFFICIENCY GATE - if you lack info for a key
decision, STOP and ask instead of guessing; (2) if the request is substantive:
classify it (type and complexity), scope the context to what's relevant,
decompose it if complex, and define verifiable success criteria. If the request
is trivial, proceed directly without ceremony.
</prompt-forge>
HOOK_EOF
exit 0
