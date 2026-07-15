#!/usr/bin/env bash
# PreToolUse hook - Forces concise, filler-free writing in plan files.
# Only applies to Write on .md files inside a plans/ directory. Outside of
# that, it exits silently.

input="$(cat 2>/dev/null)"
[ -z "$input" ] && exit 0

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"

# --- Filter: only Write on files inside a plans/ dir and ending in .md ---
[ "$tool_name" = "Write" ] || exit 0
printf '%s' "$file_path" | grep -Eq '[\\/]plans[\\/]' || exit 0
printf '%s' "$file_path" | grep -Eq '\.md$' || exit 0

# --- Inject the 4 rules. Quoted (literal) heredoc + a marker for the path, so
# the backticks/`$` in the text are not run via command substitution. ---
reminder="$(cat <<'HOOK_EOF'
<system-context type="plan-mode-style">
## PLAN WRITING STYLE (NON-NEGOTIABLE)

You are about to Write a plan file in ``__FILEPATH__``. Plans are deliverables for
a human reviewer who is tired. Apply these 4 rules. If your draft violates
ANY of them, rewrite BEFORE calling Write.

### Rule 1: No intros, no recaps
Forbidden first lines: "I'll", "Let me", "Let me explain", "We're going to",
"This plan describes", "The following plan". The first heading IS the first
heading. The first sentence delivers technical value.

Forbidden last lines: "In summary", "To summarize", "To recap",
"This plan covers...". The plan ends when the verification section ends. No
closing paragraph.

### Rule 2: As-is voice (present tense, target state)
The plan describes the **target state**, not the migration narrative.

| FORBIDDEN | REQUIRED |
|-----------|----------|
| "I will change X to Y" | "X is Y" |
| "We replace A with B" | "B handles this responsibility" |
| "Previously the code did X, now it will do Y" | "The code does Y" |
| "Before/After" sections | Single description of after state |

No diffs in prose. No comparisons against current code unless **deletion** is
the change (then list what gets deleted explicitly, no narrative).

### Rule 3: Zero ceremony
ABSOLUTE BLACKLIST in plan files - never include any of:

- Authors, contributors, owners
- Dates, "Last updated", "Created on", version stamps
- Status badges or labels ("Status: Draft", "Phase 1 of 3")
- TODOs, FIXMEs, placeholders for future expansion
- Roadmaps, milestones, "What's Next" sections
- Acknowledgments, references to past discussions
- Greeting paragraphs ("Welcome to...", "This plan covers...")
- Closing paragraphs of any kind

If the plan is not ABOUT authorship/dates/roadmaps, none of those words appear.

### Rule 4: Every word earns its place
If a sentence can be deleted without information loss, delete it before Write.

Forbidden filler patterns:
- "It's important to note that..." -> just state it
- "As we can see..." -> the reader sees
- "In essence..." / "Basically..." / "Simply put..." -> say it once
- "This section will cover..." -> just cover it
- "It's worth mentioning..." -> if it is, mention it without preamble
- "Before diving in..." -> dive in

### Required structure of a plan file
```
# Plan: <short imperative title>

## Context
<2-4 sentences max. WHY this change is being made. The problem in plain terms.>

## Changes
<Section per file/area touched. Bullet points or short tables. No prose paragraphs.>

## Critical files to modify
<Table: file | change | LOC delta>

## Files to delete
<Plain bulleted list>

## End-to-end verification
<Numbered steps. Each step ends with the EXACT bash/command the reviewer runs.>
```

Self-check before calling Write:
- First line after the H1 title: is it the Context section header, or did you slip in a preamble?
- Last line of the file: is it the last verification step, or did you add a closing recap?
- Do every paragraph, table row and bullet pass the "earns its place" test?

If ANY answer is no -> rewrite, THEN call Write.
</system-context>
HOOK_EOF
)"

# Replace the marker with the real path (parameter expansion, does not touch backticks).
printf '%s\n' "${reminder//__FILEPATH__/$file_path}"
exit 0
