# write-prompt — full XML template & reference

Fill this template with REAL content (no unresolved `[...]` placeholders). Prose is English;
XML tags stay in English (convention). No `<?xml?>` header — Claude Code reads the block as
structured text, it does not validate it, so a header is just noise.

## Output template

```xml
<claude_code_prompt>

<role>
You are a senior software engineer in [CONCRETE STACK/DOMAIN]. You have full access to the
codebase and development tools. You work autonomously but ANCHORED: you never assert or use
anything you have not verified in the code. If you lack info for a decision, you say so and
ask — you never fill the gap with a plausible guess.
</role>

<mission>
[Single, specific, verifiable objective, in 1-2 sentences. This bounds everything else.]
</mission>

<scope>
<in>[What IS included — a concrete, closed list]</in>
<out>[What must NOT be touched — explicit. This stops the session from wandering.]</out>
</scope>

<context>
<!-- Everything the destination session CANNOT infer, because it never saw this conversation. -->
<current_state>[Verifiable current state of the relevant system/code]</current_state>
<decisions_already_made>[Decisions taken + why, so they are NOT reopened]</decisions_already_made>
<domain_facts>[Business/domain facts not deducible from the code]</domain_facts>
<assumed_done>[Multi-prompt sequences ONLY: what earlier prompts left ready]</assumed_done>
</context>

<code_anchors>
<!-- Objective anchoring: REAL, verified paths/symbols/patterns. Nothing abstract. -->
<primary_files>[path:line — what it holds and why it matters for this task]</primary_files>
<patterns_to_reuse>[path:line — an existing pattern to mirror, not reinvent]</patterns_to_reuse>
<do_not_touch>[files/modules that must stay intact]</do_not_touch>
</code_anchors>

<constraints>
<technical>[Versions, compatibility, allowed/forbidden libraries]</technical>
<conventions>[Conventions to respect: naming, comment language, style, error patterns]</conventions>
</constraints>

<entry_point>
<!-- Which AVAILABLE element the destination session STARTS with, chosen from the REAL
     discovered catalog (verify it exists). If it is a slash-invocable command/skill, that
     invocation ALSO goes as the FIRST LITERAL LINE of the output, OUTSIDE the XML (see the
     skill's Delivery format): a slash command is only interpreted when it OPENS the pasted
     message; inside the XML it is dead text. Here you document WHY, plus the agents/skills
     invoked DURING execution. Omit this whole block only when the start is native or the
     target has no fitting installed element. -->
Start flow: [real element, e.g. `/swe-skills:refactor`, or native `Explore`] — emitted as the
first output line when slash-invocable. During execution, delegate to [native `general-purpose`
/ `Explore`, or a project/pack agent you confirmed exists] + [protocol skills, e.g.
`code-simplifier`, `verification-before-completion`]. Rationale: [type+domain fit, 1 line].
</entry_point>

<subagent_delegation>
<!-- You are the ORCHESTRATOR (director), not the executor: triage, brief, verify, synthesize. -->
<model>Launch every subagent with model: "opus". No exception — this is max-capability work with fresh context.</model>
<when_to_delegate>
- Investigate/map unknown code → an exploration subagent (native `Explore`)
- Implement a substantial or multi-file change → an implementer subagent (native `general-purpose`)
- Diagnose a bug's root cause → a debugging subagent
- ADVERSARIAL review of the diff before closing → a subagent that tries to REFUTE that it is correct
- Prefer a specific project/pack agent you CONFIRMED exists (e.g. `battle-tested-architect`) over a
  generic one; only if none fits → `general-purpose` / `Explore`.
</when_to_delegate>
<when_direct>
Do it YOURSELF, no delegation: locate a file, read to verify an agent's output, decide scope,
integrate/synthesize results, a trivial closing edit. Delegating mechanical work costs more than doing it.
</when_direct>
<communication_contract>
- Each subagent gets a SELF-SUFFICIENT brief (the context it needs, not "go read X") and returns:
  STATUS (DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED) + result with evidence (file:line) + what it could not verify.
- The subagent does NOT delegate upward nor re-plan the whole; it executes its bounded brief and REPORTS.
- You verify its output (never accept blindly), integrate it, and decide the next step. Resolve conflicts between agents with code evidence.
</communication_contract>
</subagent_delegation>

<task_breakdown>
<!-- Include ONLY if the task is complex/architectural. If simple, delete this whole block. -->
<step id="1">
  <goal>[specific objective]</goal>
  <success>[binary condition: pass/fail]</success>
  <verify>[how it is verified: exact command/test/inspection]</verify>
  <depends_on>none</depends_on>
</step>
<step id="2">
  <goal>[...]</goal>
  <success>[...]</success>
  <verify>[...]</verify>
  <depends_on>step_1</depends_on>
</step>
</task_breakdown>

<execution_protocol>
0. Start by invoking the <entry_point> (the chosen command/skill/agent) as the FIRST act, if the block exists.
1. Load ONLY the files in <code_anchors>. Expand to direct dependencies only if needed; do not pre-load everything.
2. Verify you understand the current state BEFORE modifying anything.
3. Delegate per <subagent_delegation>. Implement the MINIMAL change that satisfies <mission>.
4. Verify each <success_criteria> with <verification_commands> and show the REAL output.
5. On failure: iterate (max 3 attempts). If the failure is insufficient info → report what is missing, do NOT guess.
</execution_protocol>

<anti_hallucination>
- Verify files/functions/APIs EXIST before referencing or using them.
- Respect the installed versions; do not use methods that don't exist in them.
- STOP and report (don't invent) if: an edge case is unspecified, a design decision not covered here is
  required, several valid solutions exist with no criterion to choose, or a success criterion is ambiguous.
</anti_hallucination>

<abstention>
<!-- CODE FACTS ONLY that the destination session can verify (a path/signature you could not
     confirm). NEVER a doubt about the user's requirement — that is asked up front with
     AskUserQuestion, not deferred here (the destination can't read the user's mind either).
     The destination session must STOP and verify each point here. Delete the block if none. -->
[- uncertain point 1: what needs verifying]
</abstention>

<success_criteria>
<!-- Binary and verifiable. No "works well" / "is fast". -->
- [criterion 1 — pass/fail]
- [criterion 2 — pass/fail]
</success_criteria>

<verification_commands>
[EXACT commands the destination session runs to prove success, with the expected output.]
</verification_commands>

</claude_code_prompt>
```

## Quality rules for the generated prompt

| Rule | What it demands |
|------|-----------------|
| **Density** | Only info that affects execution. Irrelevant context competes for attention and degrades precision. |
| **Objective anchoring** | Real paths/symbols/patterns (`path:line`). Zero abstract references. |
| **Self-sufficiency** | The destination saw nothing. Everything needed is IN the prompt, not in "the earlier conversation". |
| **Delimitation** | Explicit `<scope><out>` + `<do_not_touch>`. A single `<mission>`. Keeps it from wandering. |
| **Verifiability** | Binary `<success_criteria>` + exact `<verification_commands>`. Without criteria there is no self-correction. |
| **Forced delegation** | Opus subagents for investigation/fix/implementation/review, in contact with the orchestrator. |
| **Real startup** | The prompt starts with the most relevant AVAILABLE element (`<entry_point>`, chosen from the real discovered catalog), not cold — native fallback when nothing fits. |
| **Honesty** | Anything unverified is NOT stated as fact: it goes in `<abstention>`. |

## Anti-patterns (do NOT do these when generating)

| Anti-pattern | Why it fails |
|--------------|--------------|
| Vague references ("the main file", "the relevant function") | The destination infers wrong → edits the wrong thing |
| Dumping the whole conversation verbatim | Noise; the session can't tell what is relevant |
| Inventing paths/functions/flags to "fill in" | Fabrication → the prompt points somewhere that doesn't exist |
| Non-verifiable success criteria ("make it nice") | No self-correction mechanism |
| Multiple objectives in one prompt | Diluted focus; decompose into a sequence instead |
| Pseudo-mathematical numbers (ISR=1.2, "nats", confidence scores) | Theater; the gate is qualitative, not a calculation |
| Naming a command/agent you did NOT confirm exists | Points the destination at a non-existent element → the startup line no-ops |
| A prompt that assumes another's state without declaring it in `<assumed_done>` | Breaks the multi-prompt sequence |
| Omitting `<subagent_delegation>` when the task is substantial | Loses the fresh-context Opus subagent work |

## Pre-delivery checklist

- [ ] Sufficiency gate passed — ZERO requirement doubt left unasked (every intent ambiguity resolved with `AskUserQuestion`; `<abstention>` used only for code facts)
- [ ] `<mission>` is single, specific, and verifiable
- [ ] `<scope><out>` and `<do_not_touch>` bound the task explicitly
- [ ] Every referenced `path:line`/symbol EXISTS (verified, not invented)
- [ ] `<context>` holds what the destination cannot infer (decisions + why)
- [ ] `<subagent_delegation>` present with `model: "opus"` if the task is substantial
- [ ] Binary `<success_criteria>` + exact `<verification_commands>`
- [ ] Uncertain items live in `<abstention>`, not asserted as fact
- [ ] `<entry_point>` chosen from the REAL discovered catalog (or omitted if native/none fits) — no unconfirmed command/agent name
- [ ] Zero unresolved `[...]` placeholders in the final output
- [ ] Output opens with the startup slash-command on the FIRST literal line (if applicable), then the ```xml block(s); nothing else — no preamble, no research recap, no post-summary
