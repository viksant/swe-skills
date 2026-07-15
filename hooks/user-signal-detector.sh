#!/usr/bin/env bash
# UserPromptSubmit Hook - Detects the user's emotional signals in the prompt.
# Computes a MODE (FRUSTRATED/URGENT/CONFUSED/EXPLORATORY/PRECISE) with precedence
# and emits <user-signal> only if there is a real signal (NEUTRAL = silence).

# --- Read the prompt from stdin (harness JSON) ---
input="$(cat 2>/dev/null)"
[ -z "$input" ] && exit 0
prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)"
[ -z "$prompt" ] && prompt="$input"
[ -z "$prompt" ] && exit 0

prompt_lower="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"
prompt_len="${#prompt}"

mode="NEUTRAL"
signals=""

# Helper: match a case-insensitive ERE regex against the lowercased prompt.
match_lower() { printf '%s' "$prompt_lower" | grep -Eq "$1"; }

# NOTE: keyword lists below are English by default. Add your team's language
# variants to each regex (the detection is a simple ERE alternation).

# --- FRUSTRATED: repeated punctuation, uppercase, negative words ---
frustrated_score=0
printf '%s' "$prompt" | grep -Fq '!!!' && frustrated_score=$((frustrated_score+1))
printf '%s' "$prompt" | grep -Eq '\?\?\?' && frustrated_score=$((frustrated_score+1))
if match_lower "\b(doesnt work|doesn't work|broken|again|i told you|still failing|why not|useless)\b"; then
    frustrated_score=$((frustrated_score+1))
fi
# Whole message in UPPERCASE and long (over the original prompt).
printf '%s' "$prompt" | grep -Eq '^[A-Z[:space:]!?]{20,}$' && frustrated_score=$((frustrated_score+1))
# UPPERCASE words (3+ letters): if there are 2 or more, add 1.
caps_words="$(printf '%s' "$prompt" | grep -oE '\b[A-Z]{3,}\b' | wc -l | tr -d ' ')"
[ "${caps_words:-0}" -ge 2 ] && frustrated_score=$((frustrated_score+1))

if [ "$frustrated_score" -ge 2 ]; then
    mode="FRUSTRATED"
    signals="Multiple frustration indicators detected"
fi

# --- URGENT: time pressure or production incident ---
if match_lower '\b(urgent|asap|now|production|down|critical|hotfix|emergency|users report|blocking)\b'; then
    [ "$mode" != "FRUSTRATED" ] && mode="URGENT"
    if [ -n "$signals" ]; then signals="$signals; Time pressure or production issue detected"; else signals="Time pressure or production issue detected"; fi
fi

# --- CONFUSED: uncertainty (only if mode is still NEUTRAL) ---
confused_score=0
match_lower "\b(dont understand|don't understand|what is|how does|i dont know|confused|lost|what's the difference)\b" && confused_score=$((confused_score+1))
match_lower '\?\s*\?' && confused_score=$((confused_score+1))
match_lower '\b(why)\b.*\b(why)\b' && confused_score=$((confused_score+1))
if [ "$confused_score" -ge 1 ] && [ "$mode" = "NEUTRAL" ]; then
    mode="CONFUSED"
    signals="User shows uncertainty"
fi

# --- EXPLORATORY: open-ended exploration (only if mode is still NEUTRAL) ---
if [ "$mode" = "NEUTRAL" ] && match_lower '\b(how could|what if|explore|possibilities|options|ideas|alternatives|investigate|analyze)\b'; then
    mode="EXPLORATORY"
    signals="Open-ended exploration detected"
fi

# --- PRECISE: short imperative instruction (only if mode is still NEUTRAL) ---
precise_score=0
match_lower '\b(do it|just|skip|directly|implement|execute|create|add|remove|change)\b' && precise_score=$((precise_score+1))
if [ "$precise_score" -ge 1 ] && [ "$prompt_len" -lt 100 ] && [ "$mode" = "NEUTRAL" ]; then
    mode="PRECISE"
    signals="Direct instruction detected"
fi

# --- Output: silence on NEUTRAL or no signals ---
if [ "$mode" = "NEUTRAL" ] || [ -z "$signals" ]; then
    exit 0
fi

printf '%s\n' "<user-signal>"
printf 'MODE: %s\n' "$mode"
printf 'SIGNALS: %s\n' "$signals"
printf '%s\n' "</user-signal>"
exit 0
