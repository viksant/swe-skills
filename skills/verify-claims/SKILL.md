---
name: verify-claims
description: >
  Self-verification of reasoning using information-theoretic approach (EDFL/Strawberry).
  Use when: after generating complex analysis with citations, before high-stakes decisions,
  user says "are you sure?", "verify your claims", "check your reasoning", "prove it",
  debugging why previous analysis was wrong.
  NOT for: simple factual lookups or when claims are directly copy-pasted from code.
version: 1.0.0
---

# Verify Claims (Self-Hallucination Detection)

> **Core Philosophy**: "If a claim would be 'true' even WITHOUT the cited evidence, the citation provides no information gain. You're asserting beyond what the evidence justifies."

## Why This Skill Exists

Claude tends to:
- Assert claims with citations that don't actually support them
- Add "specificity" that sounds authoritative but isn't grounded in evidence
- Pattern-match from training data instead of reasoning from context
- Declare root causes without sufficient evidential backing
- Use citations decoratively rather than informationally

This skill FORCES rigorous verification of every claim against its cited evidence.

---

## Theoretical Basis

This skill applies a simplified EDFL/Strawberry approach to detect claims where citations add no information beyond prior knowledge. For the full mathematical basis, see `references/edfl-theory.md`.

---

## When to Use This Skill

### Mandatory Triggers
- After generating complex reasoning with file:line citations
- Before committing to root cause diagnosis
- When user asks "are you sure?" or "verify your claims"
- After debugging analysis that will drive implementation decisions
- When claiming causal relationships (X causes Y)

### Explicit Triggers
- User says: "verify", "check your reasoning", "are you sure", "prove it"
- User asks: "how do you know?", "what's your evidence?"

### Auto-Detect Triggers
| Condition | Reason |
|-----------|--------|
| Analysis has 5+ claims with citations | Complex reasoning needs verification |
| Root cause diagnosis made | High stakes, often wrong |
| Causal claims ("because", "causes", "leads to") | Easy to hallucinate causation |
| Specific numbers/versions cited | Easy to confabulate specifics |
| Contradicting previous analysis | May be overcorrecting |

---

## The 5-Phase Protocol (MANDATORY)

### Phase 1: Decompose Reasoning into Atomic Claims

Transform your reasoning into structured claims:

```
<trace>
  <step idx="0" kind="copy" cites="S0">
    <claim>The function processData() is defined on line 45</claim>
  </step>
  <step idx="1" kind="deduce" cites="S0,S1">
    <claim>The null pointer exception occurs because userData is not initialized</claim>
  </step>
  <step idx="2" kind="assumption" cites="">
    <claim>This pattern suggests the developer intended lazy initialization</claim>
  </step>
</trace>
```

**Claim Kinds:**
| Kind | Definition | Citation Requirement |
|------|------------|---------------------|
| `copy` | Directly stated in one span | MUST cite exactly one span |
| `deduce` | Follows logically from cited spans | MUST cite supporting spans |
| `arithmetic` | Numeric calculation | Cite source numbers |
| `assumption` | NOT supported by context | cites MUST be empty |

### Phase 2: Extract Context Spans

Create labeled spans from relevant context:

```
<spans>
  <span sid="S0" source="src/data.py:45-46">
    def processData(userData):
        result = userData.transform()
        return result
  </span>
  <span sid="S1" source="main.py:102">
    data = processData(None)
  </span>
</spans>
```

**Span Rules:**
- Include EXACT code/text, not paraphrases
- Include source location (file:line)
- Include enough context for standalone understanding
- Number sequentially (S0, S1, S2...)

### Phase 3: Verify Each Claim (Posterior Check)

For each claim, with FULL context available:

```
CLAIM TO CHECK:
- idx: 1
- kind: deduce
- cites: S0, S1
- claim: "The null pointer exception occurs because userData is not initialized"

CONTEXT SPANS:
[S0] def processData(userData):
         result = userData.transform()
         return result
[S1] data = processData(None)

DECISION CRITERIA:
- ENTAILED: Claim follows from spans (logically or explicitly)
- CONTRADICTED: Spans imply the opposite
- NOT_IN_CONTEXT: Claim asserts facts absent from spans
- UNVERIFIABLE: Too vague or ill-formed to judge

VERDICT: [Choose one]
CONFIDENCE: [0.0-1.0]
NOTES: [Brief justification]
```

### Phase 4: Causal Null Check (Prior Check)

For each claim that received ENTAILED in Phase 3, repeat with cited spans SCRUBBED:

```
CLAIM TO CHECK:
- claim: "The null pointer exception occurs because userData is not initialized"

CONTEXT SPANS:
[S0] [EVIDENCE REMOVED FOR VERIFICATION]
[S1] [EVIDENCE REMOVED FOR VERIFICATION]

QUESTION: Based ONLY on general programming knowledge
(not the removed evidence), would this claim likely be true?

- If YES (ENTAILED): Citation adds NO information - FLAG THIS
- If NO (NOT_IN_CONTEXT): Citation IS informative - PASS
- If UNSURE: Ambiguous - REVIEW MANUALLY
```

### Phase 5: Flag Insufficient Budget

Apply the flagging logic:

```python
def should_flag(post_verdict, prior_verdict, kind):
    if kind == "assumption":
        return False  # Assumptions are explicitly unsupported

    if post_verdict != "ENTAILED":
        return True  # Not even supported with full context

    if prior_verdict == "ENTAILED":
        return True  # Citation adds no information (hallucination risk)

    return False
```

**Interpretation Matrix:**

| post_verdict | prior_verdict | Result | Meaning |
|--------------|---------------|--------|---------|
| ENTAILED | NOT_IN_CONTEXT | PASS | Citation is informative |
| ENTAILED | ENTAILED | FLAG | Citation adds nothing (confabulation) |
| ENTAILED | UNVERIFIABLE | REVIEW | Ambiguous, manual review |
| NOT_IN_CONTEXT | * | FLAG | Unsupported even with evidence |
| CONTRADICTED | * | FLAG | Evidence contradicts claim |

---

## Output Format

```markdown
## Verification Report

### Summary
| Metric | Value |
|--------|-------|
| Total Claims | 5 |
| Flagged | 2 |
| Grounded Fraction | 60% |

### Results

**Claim 0** [PASS]
- Kind: copy
- Claim: "The function processData() is defined on line 45"
- Cites: S0
- Posterior: ENTAILED
- Prior: NOT_IN_CONTEXT
- Status: Citation informative. Claim properly grounded.

**Claim 1** [FLAG]
- Kind: deduce
- Claim: "The null pointer exception occurs because userData is not initialized"
- Cites: S0, S1
- Posterior: ENTAILED
- Prior: ENTAILED
- Status: BUDGET INSUFFICIENT
- Issue: Claim would be considered true even without the cited evidence.
  The citation does not provide information beyond prior knowledge.
- Interpretation:
  - Hallucinated specificity (adding details not in evidence)
  - Over-confident inference
  - Correct claim with wrong/unnecessary citation

**Claim 2** [FLAG]
- Kind: deduce
- Claim: "This is a known issue in version 3.2"
- Cites: S2
- Posterior: NOT_IN_CONTEXT
- Prior: N/A
- Status: UNSUPPORTED - Claim not entailed by cited spans.

### Recommendations

For flagged claims:
1. Find additional evidence that specifically supports the claim
2. Weaken the claim to match available evidence
3. Mark explicitly as assumption/hypothesis
4. Remove the claim from the reasoning chain
```

---

## Quick Verification Checklist

Before finalizing analysis, answer:

```
For each claim I made:
[ ] Did I cite specific evidence (file:line)?
[ ] Does the evidence ACTUALLY say what I claimed?
[ ] Would I believe this claim WITHOUT seeing the evidence?
    - If YES: My citation is decorative, not informative
    - If NO: Good, my reasoning depends on the evidence
[ ] Am I inferring beyond what the text literally says?
[ ] Am I pattern-matching from training data?
```

---

## Common Failure Patterns

For detailed examples of decorative citations, specificity hallucination, causal leaps, and training data bleed, see `references/failure-patterns.md`.

---

## Integration with Workflow

This skill runs:
- AFTER complex analysis or debugging
- BEFORE presenting conclusions to user
- BEFORE code implementation based on analysis

**Order:**
1. Generate analysis with citations
2. **verify-claims** ← YOU ARE HERE (are claims GROUNDED?)
3. Present verified conclusions
4. Implement (if applicable)

---

## Self-Application Example

For a complete worked example of verifying claims before finalizing analysis, see `references/self-application-example.md`.

---

## Limitations (Be Honest About These)

1. **Self-verification bias**: Claude checking Claude has inherent circularity
2. **No true probabilities**: Qualitative verdicts vs Strawberry's KL divergence
3. **Context cost**: Doubles reasoning about each claim
4. **No logprobs**: Cannot calculate exact information contribution

**Mitigations:**
- Conservative flagging (when uncertain, flag for human review)
- Reformulation check (same claim, different phrasing)
- Human-in-the-loop for flagged claims

---

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| All claims flagged as ENTAILED in prior check | Claims too generic / common knowledge | Make claims more specific with file:line evidence |
| Verification takes too long | Too many claims decomposed | Focus on high-stakes claims (causal, root cause, numbers) |
| Flagged claim is actually correct | Prior knowledge happened to match | Mark as REVIEW; correct claim with unnecessary citation |
| Self-verification missed a hallucination | Circular self-checking bias | Use conservative flagging; flag for human review when uncertain |

## The Bottom Line

**Every claim needs to EARN its confidence.**

If you would believe a claim even WITHOUT the cited evidence:
- You're not reasoning from evidence
- You're pattern-matching from training
- Your citation is decorative, not informative
- **FLAG IT AND FIX IT**

The goal is not to sound authoritative.
The goal is to BE correct because your evidence supports your claims.

No confabulation. No decorative citations. No training-data bleed.
