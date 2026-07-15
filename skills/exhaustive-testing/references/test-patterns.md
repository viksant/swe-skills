# Exhaustive Testing — Test Patterns

Illustrative examples in a common syntax. Translate them to the host project's test
framework (e.g. pytest, vitest/jest, JUnit, Go's `testing`, RSpec). The PATTERNS are
what matter, not the language. Shorthand used below: `Mock()` is a test double,
`returns(...)` / `raises(...)` mean "configure the double to return / raise that".

## File structure

Group tests by intent; one concern per test:

```
"""Tests for [module] - [feature].

Covers:
- Happy path: [main scenarios]
- Edge cases:  [boundary conditions]
- Errors:      [failure modes]
- Concurrency: [race conditions, if any]
"""

# --- FIXTURES: build the world the test needs ---
# --- FACTORIES: build valid inputs, override per test ---

class TestFeatureHappyPath:
    """The feature works with valid input."""
    def test_basic_operation(self):
        # Arrange realistic input -> Act -> Assert output AND side effects.
        ...

class TestFeatureEdgeCases:
    """Boundary conditions, parametrized over the Phase-2 checklist."""
    ...

class TestFeatureErrors:
    """Every failure mode degrades gracefully."""
    ...

class TestFeatureConcurrency:
    """Concurrent access is safe."""
    ...
```

## Factories and parametrized edge cases

A factory keeps inputs DRY; one parametrized test walks the edge-case list in a
single place instead of copy-pasting near-identical tests:

```
def make_valid_input(**overrides):
    """Valid baseline; override one field per edge case."""
    base = {"required_field": "valid", "optional_field": "default"}
    base.update(overrides)
    return base

# One parametrized test drives many boundary inputs:
cases = [
    (None,          "handles null"),
    ("",            "handles empty"),
    ("x" * 10_000,  "handles very long"),
    # ... the rest of the Phase-2 checklist
]
```

## Mock quality (stack-agnostic)

Mocks must simulate REAL behavior. Generic patterns per dependency kind — note that
each has BOTH a success double and a failure double, because the error path is where
untested code hides:

**Datastore / adapter mock** — remembers writes, raises the real error type on the failure path:

```
store = {}
db = Mock()
db.insert = lambda rec: store.__setitem__(rec["id"], rec)
db.get    = lambda id_: store.get(id_)

db_down = Mock(get=raises(ConnectionError("store unavailable")))
```

**Cache mock** — a dict-backed get/set/delete, so staleness and eviction are testable:

```
cache_data = {}
cache = Mock()
cache.get    = lambda k: cache_data.get(k)
cache.set    = lambda k, v, **kw: cache_data.__setitem__(k, v)
cache.delete = lambda k: cache_data.pop(k, None)
```

**Message-queue mock** — records enqueues so you can assert ordering, dedup, payload shape:

```
sent = []
queue = Mock()
queue.enqueue = lambda msg: sent.append(msg)
# then: assert sent == [...expected messages in order...]
```

**External-service mock** (payments, LLM, email, messaging) — a realistic response
(not `{}`) plus an error variant for the failure path:

```
svc              = Mock(call=returns({"status": "ok", "id": "abc", ...}))  # real fields
svc_rate_limited = Mock(call=raises(RateLimitError(retry_after=2)))
```

## Real-data fixtures (REAL DATA mode)

When exercising authenticated endpoints or the real store, keep secrets and ids OUT
of the source and pull them from the project's env/tooling.

**Mint a real auth token** with the project's signing secret and realistic claims:

```
def make_auth_token(user_id, tenant_id, role="owner"):
    secret = os.getenv("AUTH_SIGNING_SECRET")   # from the project's env/secrets
    if not secret:
        skip_test("signing secret not available")
    claims = {
        "sub": user_id,
        "tenant_id": tenant_id,
        "role": role,
        "iat": now(),
        "exp": now() + hours(24),
    }
    return encode_jwt(claims, secret, alg="HS256")
```

**Authenticated client** against the real API:

```
def authed_client(token, tenant_id):
    base_url = os.getenv("TEST_API_BASE_URL", "http://localhost:PORT")
    return HttpClient(base_url=base_url, headers={
        "Authorization": f"Bearer {token}",
        # plus whatever tenant / context headers the project requires
    })
```

**Fetch a real entity** to test against (discover connection details from project config):

```
# Query the primary store via the project's DB client / CLI / MCP server.
# Example intent: SELECT id, name, owner FROM <tenants> LIMIT 1
# Feed the result into the fixtures above; never hardcode a production id.
```

**Internal service-to-service auth** (when a call simulates another service, not a user):

```
def internal_headers(tenant_id):
    secret = os.getenv("INTERNAL_SERVICE_SECRET")
    return {"X-Tenant-Id": tenant_id, "X-Internal-Secret": secret}
```
