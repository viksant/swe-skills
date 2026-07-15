---
name: analytics-cleaner
description: >
  Safely removes analytics, tracking, and telemetry code (mixpanel, segment, amplitude,
  datadog, newrelic, google analytics, track_event, log_user_action, send_telemetry,
  @track_performance, @monitor, log_metric) with MANDATORY user approval and zero
  functionality impact. Use when the user explicitly asks to "remove analytics",
  "strip tracking", "delete telemetry", "get rid of mixpanel/segment/amplitude", or
  clean out instrumentation code. NOT for: general dead-code cleanup (use the
  code-deletion skill), refactoring, or removing critical SYSTEM metrics — and do NOT
  auto-invoke to delete any code unless the user explicitly asks for analytics/tracking
  removal.
allowed-tools: Read, Write, Bash, Grep, MultiEdit
model: opus
---

# Analytics & Telemetry Cleaner

**Core:** Safely remove unwanted analytics/tracking/telemetry code with MANDATORY user approval.

**Target:** "$ARGUMENTS"

> **REQUIRED SUB-SKILL — removal mechanics:** the general "map 100% of references, then
> delete surgically" machinery lives in the `code-deletion` skill (Mode A for active
> features, the 11-level verification for dead code). This skill does NOT re-derive it —
> it applies that discipline to the analytics domain and adds the pattern catalog below.
> **REQUIRED CLOSE-OUT:** run the `verification-before-completion` discipline before
> claiming the cleanup is done (imports resolve, tests pass, system still runs).

---

## Safety first

**NEVER delete without explicit user approval. Always preserve system functionality.**

Analytics/telemetry is often tangled with code that is NOT tracking (a `metrics.py` may
hold both user-tracking AND critical system health gauges). One false positive — deleting
a metric the system depends on — is worse than leaving instrumentation in place.

---

## Target patterns (the analytics catalog)

Use these lists to seed the reference search. They are the domain asset of this skill;
map every hit to the code-deletion reference-mapping discipline before removing anything.

```python
# Analytics imports to eliminate
ANALYTICS_IMPORTS = [
    "analytics", "mixpanel", "segment", "amplitude",
    "google.analytics", "datadog", "newrelic"
]

# Tracking functions to remove
TRACKING_FUNCTIONS = [
    "track_event", "log_user_action", "send_telemetry",
    "record_interaction", "analytics.track"
]

# Monitoring patterns (non-critical)
MONITORING_PATTERNS = [
    "@track_performance", "@monitor", "@measure",
    "performance.measure", "log_metric"
]
```

---

## Cleanup protocol

### Step 1: DISCOVERY
```markdown
**Analytics Code Found:**
- [ ] `file.py:line` - [Function/import] - [Purpose]
- [ ] `file.py:line` - [Function/import] - [Purpose]

**Dependencies:**
- [What else uses this code]

**Impact Assessment:**
- Functionality affected: [None/Minor/Major]
```

### Step 2: PRESENT TO USER (MANDATORY)
```markdown
## Proposed Removals

**Will Remove:**
- [ ] `file.py:50-80` - Analytics tracking function
- [ ] `file.py:10` - Import statement

**Will Preserve:**
- `metrics.py` - Critical system metrics (NOT user tracking)

**Impact:** Zero functionality loss

WAITING FOR USER APPROVAL
```

### Step 3: EXECUTE (only after approval)
1. Remove approved items
2. Verify no broken imports
3. Run tests
4. Confirm system still works

---

## Success criteria

1. User approved all removals
2. Zero functionality impact
3. System tests pass
4. No orphaned references

---

Now analyzing analytics code in: **$ARGUMENTS**
