#!/usr/bin/env bash
# UserPromptSubmit Hook - MINIMAL cognitive triage (deterministic signals only).
# Emits two actionable signals and nothing else (silence = less noise):
#   1. Explicit --seq/--think/--sequential flag -> forces Sequential Thinking.
#   2. Destructive textual DB operation (drop/truncate table, delete from) -> warning.

# --- Read the user's prompt from stdin (harness JSON) ---
input="$(cat 2>/dev/null)"
[ -z "$input" ] && exit 0

# Extract .prompt if it is valid JSON; otherwise use the raw content (fallback).
prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)"
[ -z "$prompt" ] && prompt="$input"
[ -z "$prompt" ] && exit 0

# Lowercase to match regardless of case.
prompt_lower="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

# --- Signal 1: explicit deep-reasoning flag (deterministic) ---
seq_flag=0
if printf '%s' "$prompt_lower" | grep -Eq -- '(--seq|--think|--sequential)\b'; then
    seq_flag=1
fi

# --- Signal 2: destructive DB operation written in the prompt ---
# Only the destructive verb ATTACHED to a DB object, so it does not fire on
# "delete this function" (which does not touch data).
destructive_db=0
if printf '%s' "$prompt_lower" | grep -Eq '\b(drop|truncate)[[:space:]]+(table|schema|database)\b' \
   || printf '%s' "$prompt_lower" | grep -Eq '\bdelete[[:space:]]+from\b'; then
    destructive_db=1
fi

# --- If there is no signal at all, exit silently ---
[ "$seq_flag" -eq 0 ] && [ "$destructive_db" -eq 0 ] && exit 0

# --- Emit only the signals that fired ---
printf '%s\n' "<cognitive-triage>"
if [ "$seq_flag" -eq 1 ]; then
    printf '%s\n' "SEQUENTIAL_THINKING: MANDATORY (--seq/--think flag detected)"
fi
if [ "$destructive_db" -eq 1 ]; then
    printf '%s\n' "DB_DESTRUCTIVE: the prompt mentions a destructive DB operation."
    printf '%s\n' "  -> Confirm with the user before executing (destructive DB ops require explicit approval)."
fi
printf '%s\n' "</cognitive-triage>"
exit 0
