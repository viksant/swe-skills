# Common Failure Patterns

### Pattern 1: Decorative Citations
```
BAD:  "The bug is in processData() [S0]"
      (when S0 just shows the function exists, not that it's buggy)

GOOD: "The bug is in processData() - specifically, line 46 calls
      userData.transform() without null check [S0], and main.py
      passes None [S1]"
```

### Pattern 2: Specificity Hallucination
```
BAD:  "This is a known issue in version 3.2.1"
      (no evidence mentions version)

GOOD: "This appears to be a null handling issue"
      (or find actual version evidence)
```

### Pattern 3: Causal Leap
```
BAD:  "The race condition causes the crash [S0]"
      (when S0 shows concurrent code but not the race)

GOOD: "The code has concurrent access [S0], which could cause
      race conditions (hypothesis, needs verification)"
```

### Pattern 4: Training Data Bleed
```
BAD:  "This is the standard pattern for handling X in Django"
      (asserting from training, not context)

GOOD: "The codebase uses this pattern for X [S0, S1, S2]"
      (citing actual examples in THIS codebase)
```
