# EDFL/Strawberry Theoretical Basis

The original Strawberry system calculates information budgets:
```
Required_bits = KL(Ber(target) || Ber(prior))
Observed_bits = KL(Ber(posterior) || Ber(prior))
Flagged if Required_bits > Observed_bits
```

This skill approximates this qualitatively:
```
post_verdict = VERIFY(claim | full_context)
prior_verdict = VERIFY(claim | do(cited_evidence := SCRUBBED))

Flagged if (post_verdict == ENTAILED) AND (prior_verdict == ENTAILED)
```

**The intuition**: If a claim is "entailed" even WITHOUT the cited evidence, the citation adds nothing. The model is confabulating.
