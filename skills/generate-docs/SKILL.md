---
name: generate-docs
description: >
  Generates direct, no-fluff technical documentation as a .md file — present-tense
  "as-is" voice, zero metadata/changelog/marketing filler, every word earns its place.
  Use when the user asks to "generate docs", "write documentation", "document this
  system/API/module", "write a README for X", or produce a technical .md on a given
  topic. NOT for: writing a session handoff (use the handoff skill), user-facing
  marketing copy, or editing prose that is not documentation. Do not auto-invoke to
  write files unless the user asks for documentation.
allowed-tools: Read, Write, MultiEdit
model: opus
---

# Documentation Generation

Generate technical documentation in `.md` format on the topic provided. **Always write to a `.md` file.** Every word must earn its place.

---

## CRITICAL WRITING RULES (READ FIRST — NON-NEGOTIABLE)

These rules override everything else. Violating any of them = the documentation is wrong.

### Rule 1: As-Is Voice Only
Write the doc as if the system has **always been this way**. The reader does not care what existed before.

| FORBIDDEN | REQUIRED |
|-----------|----------|
| "Previously the function returned a string, now it returns a dict" | "The function returns a dict with keys `status` and `data`" |
| "We replaced X with Y" | "Y handles this responsibility" |
| "Used to be in `/old/path`, moved to `/new/path`" | "Lives in `/new/path`" |
| "Old behavior: ... New behavior: ..." | "Behavior: ..." |

**No diffs. No comparisons. No history.** The doc is a snapshot of the present, not a changelog.

### Rule 2: Integrate Decisions, Never Quote Them
User decisions are **inputs to the doc**, not part of the doc.

| FORBIDDEN | REQUIRED |
|-----------|----------|
| "The user decided to use an in-memory cache" | "Caching uses an in-memory store with a 60s TTL" |
| "As requested, we removed the retry logic" | (Just describe the current flow without retries) |
| "Per user preference, the limit is 100" | "The limit is 100" |
| "User specified that auth must be JWT-based" | "Authentication uses JWT tokens validated against..." |

The reader does **not know who made decisions** and does **not need to know**. Only the resulting state matters.

### Rule 3: No Metadata, No Ceremony
**ABSOLUTE BLACKLIST** — never include any of the following:

- Authors, contributors, owners
- Dates, "last updated", version stamps
- "What's Next", roadmaps, planned features
- Timelines, milestones, phases, sprints
- Acknowledgments, credits, references to discussions/meetings
- "TODO", "FIXME", placeholders for future expansion
- Status badges, build badges (unless the topic IS CI/CD itself)
- Greeting paragraphs ("Welcome to...", "This document covers...")
- Closing paragraphs ("In conclusion...", "We hope this helps...")

If the topic isn't about authorship, dates, or roadmaps — **none of those words should appear**.

### Rule 4: Single Home for Each Piece of Information
When adding new information to an existing doc, it goes in **exactly one section** — the section that owns that concept.

| FORBIDDEN | REQUIRED |
|-----------|----------|
| Mention rate limits in Intro, Auth, AND API sections | Rate limits live in ONE "Rate Limits" section |
| Repeat config flags across multiple sections | Config flags belong in "Configuration" only |
| Sprinkle the new constraint across 3 places | Find the right home, put it there once |

**Before writing**: identify the section that owns the concept. If no section owns it, create one. **Never** scatter.

### Rule 5: Every Word Earns Its Place
If a sentence can be deleted without information loss, **delete it**. If a paragraph restates the previous one, **delete it**.

Forbidden filler patterns:
- "It's important to note that..." -> just state it
- "As we can see..." -> the reader can see
- "In essence..." / "Basically..." / "Simply put..." -> say the thing once
- "This section will cover..." -> just cover it
- "It's worth mentioning..." -> if it's worth it, mention it without preamble
- "Before diving in..." -> dive in

---

## CONTENT TO INCLUDE

- **Technical specifications** with the WHY behind non-obvious decisions
- **Code examples**: complete, runnable, with explanations only where the code is non-obvious
- **Architecture**: components, data flow, interfaces — described in present tense
- **Configuration**: each option's effect, valid values, common pitfalls
- **API references**: signatures, parameters, return values, error cases
- **Edge cases and gotchas**: real failure modes, not hypothetical concerns
- **Error handling**: actual errors users encounter and how to resolve them

---

## ABSOLUTE PROHIBITIONS (zero exceptions, zero overrides)

Even if the user's prompt seems to suggest these, **do not include**:

- Authors, dates, contributors, version history
- "What's Next", "Future Work", "Roadmap", "TODO"
- "We covered...", "In summary...", recap sections
- Timelapses, phases, milestones
- Marketing language, buzzwords, "leverages", "best-in-class", "seamless"
- Empty "Overview" / "Introduction" sections that don't add technical content
- Repetition across sections
- Quotes of the user's prompt or decisions
- Comparisons of "old vs new" / "before vs after"

---

## OUTPUT FORMAT

```markdown
# [Topic Name]

## [Direct Technical Section 1]
[Immediate technical content — first sentence delivers value]

## [Direct Technical Section 2]
[Immediate technical content]

### Code Example
```language
[actual code]
```

### Configuration
```language
[actual config]
```
```

**No preamble before `## [Section 1]`.** The first heading is the first heading.

---

## SELF-CHECK BEFORE DELIVERING

For each of these, the answer must be **yes**:

- [ ] Does the first paragraph deliver technical value (not introduction/welcome)?
- [ ] Is every section written in present tense, as-is voice (no "previously", "now", "we changed")?
- [ ] Are all user decisions integrated as facts, never quoted or attributed?
- [ ] Zero authors, dates, "What's Next", roadmaps, timelines?
- [ ] Each concept lives in exactly one section (no scatter)?
- [ ] Every sentence survives the "can I delete this?" test?
- [ ] No closing summary, no "In conclusion", no recap?

If any answer is **no** -> rewrite that part before delivering.

---

**User's documentation topic:**
