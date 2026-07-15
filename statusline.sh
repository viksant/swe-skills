#!/usr/bin/env bash
# Claude Code Status Line - receives JSON via stdin and emits a status line:
#   dir | branch | model | context% | +added/-removed | agentName

input="$(cat 2>/dev/null)"

cwd="$(printf '%s' "$input" | jq -r '.workspace.current_dir // empty' 2>/dev/null)"
model="$(printf '%s' "$input" | jq -r '.model.display_name // empty' 2>/dev/null)"
# Round with jq (not bash printf): printf %.0f fails on comma-decimal locales,
# whereas jq round is locale-independent.
used="$(printf '%s' "$input" | jq -r '.context_window.used_percentage | if . == null then empty else (. | round) end' 2>/dev/null)"
agent_name="$(printf '%s' "$input" | jq -r '.agent.name // empty' 2>/dev/null)"

dir="$(basename "$cwd" 2>/dev/null)"

# Branch + diff stats only if the cwd is a git repo.
branch=""
added=0
removed=0
if [ -n "$cwd" ] && [ -d "$cwd/.git" ]; then
    branch="$(git -C "$cwd" branch --show-current 2>/dev/null)"
    # numstat: col1=added col2=removed ('-' for binaries, ignored).
    while IFS=$'\t' read -r a r _; do
        [ "$a" != "-" ] && [ -n "$a" ] && added=$((added + a))
        [ "$r" != "-" ] && [ -n "$r" ] && removed=$((removed + r))
    done < <(git -C "$cwd" diff --numstat 2>/dev/null)
fi

# Assemble the present parts.
parts=()
[ -n "$dir" ] && parts+=("$dir")
[ -n "$branch" ] && parts+=("$branch")
[ -n "$model" ] && parts+=("$model")
if [ -n "$used" ] && [ "$used" != "null" ]; then
    parts+=("${used}%")
fi
if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
    parts+=("+$added/-$removed")
fi
[ -n "$agent_name" ] && parts+=("$agent_name")

# join with " | "
out=""
for p in "${parts[@]}"; do
    if [ -z "$out" ]; then out="$p"; else out="$out | $p"; fi
done
printf '%s\n' "$out"
