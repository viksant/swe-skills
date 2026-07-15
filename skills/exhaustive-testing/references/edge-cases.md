# Exhaustive Testing — Edge-Case Checklist

The BICEP table in `SKILL.md` gives you the categories. This is the exhaustive
enumeration: walk every item that applies to the feature under test. "Exhaustive"
means you do not cherry-pick — an untested category is a bug waiting to ship.

## Input edge cases

- [ ] None / null / undefined
- [ ] Empty string `""`
- [ ] Empty list / array
- [ ] Empty object / map
- [ ] Whitespace-only string `"   "`
- [ ] Very long string (10,000+ chars)
- [ ] Special characters: unicode, emoji, injection attempts (SQL / NoSQL / command / template)
- [ ] Negative number where positive is expected
- [ ] Zero where nonzero is expected
- [ ] Integer overflow / very large values
- [ ] Float precision edges (`0.1 + 0.2`)
- [ ] Duplicate values in a collection
- [ ] Object missing required keys
- [ ] Object with extra unexpected keys
- [ ] Wrong types (string where a number is expected, etc.)

## State edge cases

- [ ] Operation on an already-deleted resource
- [ ] Duplicate operation (idempotency: the second call must be safe)
- [ ] Operation during concurrent modification
- [ ] Operation with expired credentials / tokens
- [ ] Operation with permissions revoked mid-execution
- [ ] Operation when a dependency is unavailable (store down, API timeout)
- [ ] Operation when the cache is stale or empty
- [ ] Operation after a partial failure (half-written state)

## Async / concurrency edge cases

- [ ] The same operation invoked twice simultaneously
- [ ] Dependent operations arriving out of order
- [ ] Operation cancelled mid-execution
- [ ] Timeout during a long operation
- [ ] Connection pool exhausted
- [ ] Read-modify-write race condition

## Multi-tenant isolation edge cases

For any system that isolates data per tenant / account / organization, the highest-severity
bugs are cross-tenant leaks. Test them explicitly:

- [ ] Operation with an invalid or malformed tenant identifier
- [ ] Operation that tries to reach another tenant's data (must be denied)
- [ ] Tenant-id format variations (prefix present/absent, upper/lower case, delimiters)
- [ ] Operation after the tenant was deleted
- [ ] Explicit cross-tenant leakage check: seed data for tenant A and tenant B, then
      assert a tenant-A request can NEVER see a tenant-B record
