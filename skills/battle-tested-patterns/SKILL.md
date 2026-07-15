---
name: battle-tested-patterns
description: >
  Verifies architectural decisions against battle-tested patterns from AOSA
  (Architecture of Open Source Applications). Use when: user proposes new architecture,
  says "design pattern", "best practice", "how is this done in production",
  "architecture decision", "AOSA".
  NOT for: simple code changes, bug fixes, or refactoring without architectural impact.
version: 1.0.0
---

# Battle-Tested Pattern Verification

> **The Iron Law:** Every architectural decision MUST have precedent in production open-source software.
> "It works in theory" is NEVER sufficient. "It works in [Project] at [Scale]" IS.

## Why This Skill Exists

Architectural decisions without production precedent carry hidden risk:
- "Novel approaches" often rediscover known failure modes
- Blog posts describe aspirational architecture, not battle-tested reality
- AOSA documents architecture BY the creators who built and maintained it at scale
- Known anti-patterns save months of debugging in production

---

## When to Activate

| Trigger | Activation |
|---------|------------|
| Proposing new architectural patterns | **MANDATORY** |
| Evaluating design alternatives | **MANDATORY** |
| User asks about architecture best practices | **RECOMMENDED** |
| Reviewing existing architecture for improvement | **RECOMMENDED** |

---

## Verification Protocol

### Step 1: IDENTIFY the Decision

Extract the architectural decision being made:
- What component or system is being designed?
- What problem is it solving?
- What are the constraints (scale, latency, consistency)?

### Step 2: CLASSIFY the Domain

Map the decision to one or more domains:

| Domain | Keywords |
|--------|----------|
| Concurrency | async, workers, threads, event-loop, non-blocking |
| Storage | database, persistence, key-value, btree, WAL |
| Messaging | queue, pub/sub, broker, message-passing, message-queue |
| Caching | cache, eviction, TTL, distributed-cache, in-memory-store |
| Multi-tenant | namespace, isolation, schema, tenant, shared-nothing |
| Distributed | replication, partitioning, consistency, fault-tolerance |
| Pipeline | filter-chain, stages, transformation, streaming |
| Plugin/Extension | module, hook, extension-point, registry |
| Connection Management | pool, connection-limit, keepalive, coalescing |

### Step 3: SEARCH the AOSA Index

Read `agents/references/aosa-patterns-index.txt` and match:
- Domain keywords against chapter keywords
- Problem description against pattern descriptions
- At least 2 keyword matches required for a CANDIDATE

### Step 4: EVALUATE Matches

For each candidate chapter:

```
RELEVANCE = (keyword_overlap * domain_match * scale_similarity)

If RELEVANCE >= HIGH:
  -> Invoke battle-tested-architect agent for deep analysis
If RELEVANCE == MEDIUM:
  -> Note as supporting evidence, fetch only if primary is insufficient
If RELEVANCE == LOW:
  -> Mention in references, do not fetch
```

### Step 5: VERIFY or FLAG

Apply the verification checklist (below) and produce a verdict.

---

## Verification Checklist

For each architectural decision, verify:

- [ ] **Production precedent:** Has this pattern been used in a real AOSA-documented project?
- [ ] **Scale validation:** What load did the original project handle with this pattern?
- [ ] **Failure modes documented:** Are known failure scenarios identified?
- [ ] **Anti-patterns avoided:** Are documented anti-patterns explicitly NOT present?
- [ ] **Alternatives considered:** Were other AOSA patterns evaluated and rejected with reason?

### Verdict Scale

| Verdict | Criteria | Action |
|---------|----------|--------|
| **VERIFIED** | All 5 checks pass, AOSA evidence strong | Proceed with confidence |
| **SUPPORTED** | 3-4 checks pass, some gaps | Proceed with noted caveats |
| **UNVERIFIED** | 1-2 checks pass | Warn: limited battle-tested evidence |
| **NO PRECEDENT** | 0 checks pass | Flag: "novel approach" - recommend extra scrutiny |

---

## Red Flags (STOP and Warn)

| Signal | Warning |
|--------|---------|
| "This is a novel approach" | No battle-tested evidence exists - HIGH RISK |
| "I read about this in a blog" | Blog != production evidence - INSUFFICIENT |
| "It should work in theory" | Theory != production - REJECT without evidence |
| "Let's try this pattern" | "Try" implies unproven - require precedent first |
| No AOSA chapter matches at all | Domain may be too niche - acknowledge gap explicitly |

---

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| No AOSA matches found | Domain too niche or wrong keywords | Broaden search terms; acknowledge gap explicitly |
| Match found but irrelevant | Keyword overlap without semantic match | Verify RELEVANCE using domain + scale + problem similarity |
| Agent returns generic advice | Chapter not deeply analyzed | Ensure battle-tested-architect agent fetches full chapter |
| User disagrees with AOSA pattern | Different constraints or scale | Document user's constraints; AOSA is evidence, not mandate |

## Example Flow

```
User: "Design a queue-based document processing pipeline"

Step 1: Decision = queue-based pipeline for document processing
Step 2: Domains = messaging, pipeline, async/concurrency
Step 3: Index matches:
  - ZeroMQ (messaging, push-pull, lock-free) -> HIGH
  - Sendmail (queue processing, retry policies) -> HIGH
  - Twisted (async, reactor, deferred) -> MEDIUM
  - nginx (filter-chain pipeline) -> MEDIUM
Step 4: Invoke battle-tested-architect for ZeroMQ + Sendmail chapters
Step 5: Checklist:
  [x] Production precedent: ZeroMQ + Sendmail both production-proven
  [x] Scale: ZeroMQ handles millions msgs/sec, Sendmail handles internet email
  [x] Failure modes: ZeroMQ documents slow subscriber, Sendmail documents queue storms
  [x] Anti-patterns: Unbounded queues, synchronous processing
  [x] Alternatives: Asterisk (rejected - telephony-specific)

Verdict: VERIFIED - Strong battle-tested evidence from multiple sources
```
