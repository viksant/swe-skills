# Self-Application Example

```markdown
Before finalizing this analysis, I will verify my reasoning:

### My Claims:
1. "The race condition occurs during shutdown" citing S2
2. "This is a known issue in version 3.2" citing S3

### Verification:

**Claim 1**: S2 shows shutdown code but doesn't demonstrate race condition
- Posterior: NOT_IN_CONTEXT (I claimed race, S2 doesn't show race)
- Action: Weakening to "The shutdown sequence may be susceptible to
  race conditions (code shows concurrent access but race not confirmed)"

**Claim 2**: S3 doesn't mention any version
- Posterior: NOT_IN_CONTEXT
- Action: REMOVING this claim - it was pattern-matching, not evidence

### Revised Analysis:
[Present corrected conclusions]
```
