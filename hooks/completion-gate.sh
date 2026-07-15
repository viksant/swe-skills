#!/usr/bin/env bash
# Stop hook - Verification gate before closing the turn.
# If source code (.py/.ts/.tsx/.js/.jsx) was modified in the current turn and NO
# verification (pytest/ruff/mypy/...) was run AFTER the last change, it blocks
# the close (decision=block) and injects a reminder. FAIL-OPEN design: on any
# doubt (no transcript, no change, already verified) it does not block.

input="$(cat 2>/dev/null)"
[ -z "$input" ] && exit 0

# Anti-loop guard: if we come from a previous Stop-hook block, exit.
stop_active="$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)"
[ "$stop_active" = "true" ] && exit 0

transcript_path="$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)"
# Fail-open: without a readable transcript we do not evaluate.
[ -z "$transcript_path" ] && exit 0
[ -f "$transcript_path" ] || exit 0

# Walk the last 1000 lines (covers the current turn with margin). We filter
# non-JSON lines with fromjson?, assign sequential indices to the valid ones, and
# compute: last real user, last code edit, last verification.
# Since only relative order comparisons matter, compacting indices is safe.
verdict="$(tail -n 1000 "$transcript_path" 2>/dev/null \
  | jq -R 'fromjson? // empty' \
  | jq -rs '
      . as $arr
      | reduce range(0; ($arr | length)) as $i ({u:-1, c:-1, v:-1};
          $arr[$i] as $o
          | (if ($o.type == "user" and ($o.message.content != null) and (
                  ($o.message.content | type == "string") or
                  (($o.message.content | type) == "array" and (($o.message.content | any(.type == "text"))))
                )) then .u = $i else . end)
          | (if ($o.type == "assistant" and (($o.message.content | type) == "array")) then
              reduce ($o.message.content[]) as $b (.;
                if ($b.type == "tool_use") then
                  if ((($b.name == "Edit") or ($b.name == "Write") or ($b.name == "MultiEdit"))
                      and (($b.input.file_path // "") | test("\\.(py|ts|tsx|js|jsx)$"))) then .c = $i
                  elif (($b.name == "Bash")
                      and (($b.input.command // "") | test("pytest|ruff|mypy|py_compile|pyright|\\btsc\\b|vitest|jest|npm (run )?test|bun test|eslint"))) then .v = $i
                  else . end
                else . end)
            else . end)
        )
      | (if .u >= 0 then .u else 0 end) as $turnStart
      | (.c > $turnStart) as $codeInTurn
      | (.v > .c) as $verifiedAfterCode
      | if ($codeInTurn and ($verifiedAfterCode | not)) then "BLOCK" else "OK" end
    ' 2>/dev/null)"

# Fail-open: if jq failed or there is no clear verdict, we do not block.
[ "$verdict" = "BLOCK" ] || exit 0

reason="Completion gate: source code was modified without running verification (pytest/ruff/mypy) after the last change."

additional="$(cat <<'HOOK_EOF'
## COMPLETION GATE - verify before closing

In this turn you modified source code (.py/.ts/.tsx) and NO verification is
recorded AFTER the last change.

Before considering the turn finished:

1. Run the verification for the module you touched. Examples:
   - Python: .venv/bin/python -m pytest <path> -q   (and/or ruff, mypy, py_compile)
   - TS/JS:  tsc --noEmit / vitest / eslint as applicable
2. Show the REAL OUTPUT (do not summarize "it should pass").
3. If the verification fails, fix it before continuing.

LEGITIMATE EXCEPTIONS (if one applies, STATE it explicitly and continue):
- The user EXPLICITLY asked you not to verify yet.
- There is no way to verify the change (explain why).
- You are stopping to ASK the user a QUESTION (ask it now).

This is your "VERIFY YOUR OWN WORK before saying done" rule
(the completion protocol) turned into a real gate.
HOOK_EOF
)"

jq -nc \
    --arg reason "$reason" \
    --arg additional "$additional" \
    '{decision: "block", reason: $reason, hookSpecificOutput: {hookEventName: "Stop", additionalContext: $additional}}'
exit 0
