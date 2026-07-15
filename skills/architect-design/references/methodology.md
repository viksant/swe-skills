# Architect-Design — Methodology (how to reason)

Deep reference for the `architect-design` skill: the Clean Architecture lens, the concurrency
doctrine, trusted-source tiers, the intervention-protocol template, and the absolute-nevers list.
Load this when you reach the phase that needs it.

---

## 1. 🧱 CLEAN ARCHITECTURE LENS (Robert C. Martin)

Use as an **evaluation filter, NOT dogma.** Always pass through the YAGNI gate (the YAGNI-tension table below) before proposing any Clean/SOLID refactor.

### 1.1 The two values

| Value | Priority |
|-------|----------|
| Behavior (today) | Urgent |
| Architecture (tomorrow) | **Important — wins on conflict** |

Working code that cannot change → dies. Push back when the user puts urgency over importance.

### 1.2 SOLID (class / module)

| Principle | Rule | Example application |
|-----------|------|---------------------|
| **SRP** | One module answers to ONE actor | A message processor should not also do billing — billing answers to a different actor |
| **OCP** | Open for extension, closed for modification | A new provider → a new module implementing the provider interface; never edit an existing provider's file |
| **LSP** | Subtypes drop-in replaceable for the base | All adapters honor the same `execute(...) -> Result` contract — no `isinstance(x, ConcreteType)` branches |
| **ISP** | Don't force clients to depend on methods they don't use | Split a fat adapter when callers use only 1-2 of its methods |
| **DIP** | Source dependencies point at ABSTRACTIONS, not concretions | An outer use-case must not import a low-level storage driver directly — go through a core protocol/port |

### 1.3 Component principles

**Cohesion** (which classes belong together): **REP** (release = reuse unit) · **CCP** (things that change for the same reason at the same time → same component) · **CRP** (don't force unused deps on consumers).

**Coupling** (how components interact):

| Principle | Rule |
|-----------|------|
| **ADP** — Acyclic Dependencies | NO cycles. Watch cross-imports between two sibling packages that both reach into each other |
| **SDP** — Stable Dependencies | Volatile depends on Stable, never the reverse (adapters → core ✅) |
| **SAP** — Stable Abstractions | Stable = abstract. The core should be mostly protocols + ABCs |

### 1.4 Concentric layers + the Dependency Rule

```
┌──────────────────────────────────────────────────────┐
│  Frameworks & Drivers                                  │
│    SDK wrappers, config loaders, the web framework,    │
│    DB drivers, message-broker/cache clients            │
│  ┌──────────────────────────────────────────────────┐ │
│  │  Interface Adapters                                │ │
│  │    controllers/routers, repository adapters,       │ │
│  │    gateways to external services, presenters       │ │
│  │  ┌────────────────────────────────────────────┐   │ │
│  │  │  Use Cases                                   │  │ │
│  │  │    application services / orchestrators      │  │ │
│  │  │  ┌────────────────────────────────────────┐ │  │ │
│  │  │  │  Entities                                │ │  │ │
│  │  │  │    core domain model + business rules    │ │  │ │
│  │  │  └────────────────────────────────────────┘ │  │ │
│  │  └────────────────────────────────────────────┘   │ │
│  └──────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
               Dependencies point INWARD only
```

**Verify before proposing:** does the change introduce an inner ring depending on an outer ring? → REJECT.

### 1.5 ⚖️ Tension with YAGNI (apply BEFORE any Clean refactor)

| Tension | Rule |
|---------|------|
| OCP "no modify" vs YAGNI "no abstractions <3 consumers" | <3 consumers → **YAGNI wins**, inline. Refactor when #3 appears |
| DIP "depend on abstractions" vs a use-case importing a driver directly | Acceptable if confined to 1-2 files. If it leaks >5 files → **DIP wins**, introduce a port |
| SRP "one reason to change" vs a processor that does 9 things | If those 9 things change together for the SAME actor → SRP satisfied. Don't split for the sake of splitting |
| LSP "drop-in subtypes" vs one adapter returning `not_performed` | LSP is violated. Fix = redesign the `Result` type for ALL adapters. **YAGNI wins** until a bug surfaces |
| ADP "no cycles" vs factory ↔ service cycles | **ADP always wins.** Cycles cost more long-term than refactoring once. Flag aggressively |

**When Clean Architecture wins (always propose the refactor):**
1. ADP violations (cycles).
2. Cross-layer leaks of inner concerns into outer code (raw SQL in a controller/UI layer).
3. The user treats a **detail** (current DB, current framework) as **architecture**.
4. Testability rotted to <30% on the Use Cases due to framework coupling.

**When YAGNI wins (refuse the refactor):**
1. The proposed abstraction has 1-2 consumers, no third on the horizon.
2. The "Clean refactor" touches >10 files with no measurable behavior/change-cost gain.
3. The current code works in prod with zero bugs in the last 90 days.
4. The user says "because Uncle Bob says so" — no measured pain point.

**Refactor proposal without a measured pain point → ASK "which metric hurts you today?" first.** No answer → no refactor.

### 1.6 Key practices

| Practice | Rule |
|----------|------|
| **Screaming Architecture** | Folder names reveal PURPOSE (sales, billing, moderation), not the framework |
| **Boundaries** | Hard line between business logic and details. Details are plugins |
| **Humble Object** | Separate testable behavior from untestable (UI, framework callbacks) |
| **Details ≠ Architecture** | DB, web, framework are details. Keep options open as long as possible |

---

## 2. ⚡ CONCURRENCY DOCTRINE (NON-NEGOTIABLE)

Design for **10× expected load minimum.**

```yaml
connection_management:
  database:
    - Connection pooling MANDATORY (a pooler in front of the DB)
    - Pool size from a formula (workers × conns_per_worker, capped at the DB max)
    - Connection limits documented
  external_services:
    - Circuit breakers
    - Retry with exponential backoff + honoring Retry-After
    - Explicit timeout config

async_patterns:
  io_bound:
    - async/await for all I/O
    - No blocking calls in an async context
    - Semaphores for concurrency limits

queue_based_processing:
  required_when:
    - Operation > 100ms
    - Batch operations
    - External API calls
  patterns:
    - A durable queue (DB-backed or a broker) for at-least-once delivery
    - An in-memory router for volatile / best-effort streams
    - Dead-letter queues for failures
    - Idempotency keys for retries
```

### Anti-patterns (REJECT)

| Anti-pattern | Why it fails | Do instead |
|--------------|--------------|------------|
| "Just increase max_connections" | RAM explosion | Connection pooling |
| Synchronous external calls | Thread starvation | Async + queue |
| Unbounded worker spawning | Resource exhaustion | Fixed pools + backpressure |
| "It works in dev" | Dev has no concurrency | Load-test FIRST |

---

## 3. 📚 TRUSTED SOURCES

### Tier 0 — Open-source architecture docs (PRIMARY)

| Source | Why |
|--------|-----|
| AOSA Vol 1 & 2 | Architecture written by the creators of 50+ real projects |
| 500 Lines or Less | Complete implementations with rationale |
| POSA | Performance with measured results |

> Index: `${CLAUDE_PLUGIN_ROOT}/agents/references/aosa-patterns-index.txt`
> Agent: `battle-tested-architect` fetches and analyzes chapters on demand.

### Tier 1 — Production-proven at scale
Netflix, Uber, Cloudflare, the Google SRE Book, and comparable large-scale engineering write-ups.

### Tier 2 — Validated open source
PostgreSQL, Redis, mature message brokers, mature web frameworks.

### NOT acceptable
- Blog articles without production validation.
- "I think this would work" patterns.
- Tutorial-only patterns.

---

## 4. 🛑 INTERVENTION PROTOCOL

When the user proposes a bad architecture, respond in this shape:

```markdown
## ARCHITECTURE CONCERN

**Your proposal:** [verbatim]

**Problem 1: [specific]**
- Failure mode: [concrete]
- At what scale: [N RPS / N users]
- Evidence: [AOSA chapter / company case / file:line in this repo]

**Better approach:**
[battle-tested alternative with source]

**Companies using it:**
- [Company A] at [scale]
- [Company B] at [scale]

**Options:**
1. Proceed with my recommendation
2. Discuss your constraints so I can adapt
3. Proceed with your approach — I will document the risks

I will NOT silently design an architecture I know will fail.
```

---

## 5. 🚫 ABSOLUTE NEVERS

- ❌ Propose architecture WITHOUT completing Phase 0 (Discovery).
- ❌ Theoretical architectures without production precedent.
- ❌ "Faster" / "better" without quantifying.
- ❌ Skip trade-offs and risks.
- ❌ Invent file paths, line numbers, or benchmarks.
- ❌ Suggest patterns without sources.
- ❌ Accept a suboptimal request without warning (Cardinal Rule).
- ❌ Start with "Great / Good idea / You're right".
- ❌ Research >7 repos or >3 patterns per component.
- ❌ Design complex (3+ variable) decisions without structured reasoning.
- ❌ Apply Clean Architecture / SOLID AS DOGMA — always pass the YAGNI gate first.
- ❌ Propose abstractions for <3 concrete consumers.
- ❌ Refactor "in the name of Clean Code" without a measured pain point.
- ❌ Treat **details** (current DB, current framework) as if they were **architecture**.
- ❌ Design a correct ISLAND that ignores the repo's existing patterns / vocabulary / seams — systemic fit is not optional.
- ❌ Stay silent about a defect found in the EXISTING system because "it wasn't asked" — surface it; the human can be wrong.
- ❌ Ignore the project's secrets/config protection or bypass its config-access convention in proposed changes.
