#!/usr/bin/env bash
# Code Quality Standards Hook - Enforces readable, well-documented code.
# Injects quality standards at session start. Fixed text.

cat <<'HOOK_EOF'
<system-context type="code-quality-standards">
## CODE QUALITY STANDARDS ACTIVE

All code you write MUST follow these standards for readability and collaboration.

### 1. Declarative Names
- Functions: verb+noun (`fetch_user_preferences`, `validate_access_token`)
- Variables: descriptive (`remaining_retries`, not `r` or `tmp`)
- Constants: UPPER_SNAKE (`MAX_RETRY_ATTEMPTS`, `DEFAULT_TIMEOUT_MS`)
- Booleans: prefix is/has/should (`is_authenticated`, `has_pending_tasks`)

### 2. Inline Comments
- WHAT + WHY: Each logical block should have a comment explaining:
  - WHAT that block does (narrate the flow)
  - WHY that implementation was chosen (technical decisions, trade-offs)
- Do NOT comment the trivially obvious (x += 1); DO comment the intent of each block
- Use "section markers" in functions >15 lines: `# --- Input validation ---`

### 3. Docstrings
- Required on all public functions/methods/classes
- Include: purpose, parameters with types, return type, raises (if applicable)
- Python: Google style. TypeScript: JSDoc or TSDoc.

### 4. Type Hints (Mandatory)
- Python: ALL function params + return type. Use Optional, Union, TypeVar as needed.
- TypeScript: strict mode. No `any` unless truly unavoidable (with comment explaining why).

### 5. Function Structure
- Max ~30 lines per function. If longer, extract helper.
- Single responsibility: one function = one job.
- Early returns to reduce nesting. Guard clauses first.

### 6. Import Organization
- Order: stdlib -> third-party -> local
- No unused imports. No wildcard imports.
- Group with blank line between sections.

### 7. Reviewable Code (Cardinal Principle)
- Priority: OBVIOUS over ELEGANT. If you must choose, pick what is understood fastest
- FORBIDDEN: list comprehensions with 3+ conditions, nested ternaries, "clever" one-liners
- Every if/else with business logic should have a brief explanatory comment
- Trade-offs: When you choose approach A over B, document WHY in a comment
- Diff-friendly formatting: one element per line in long lists/dicts, trailing commas in Python

### Examples

**Names:**
``````
# BAD: get_data, process, do_thing, temp, x
# GOOD: fetch_user_documents, validate_auth_token, parse_queue_message
``````

**Comments (inline):**
``````python
# BAD: no context
result = query.filter(active=True).exclude(role="admin")

# GOOD: narrate the flow
# We filter active users, excluding admins, because only
# regular users take part in the points system
result = query.filter(active=True).exclude(role="admin")
``````

**Section markers (functions >15 lines):**
``````python
def process_incoming_message(message: IncomingMessage) -> ProcessResult:
    """Process an incoming message through the pipeline."""

    # --- Input validation ---
    if not message.content:
        return ProcessResult.empty()
    if not message.tenant_id:
        raise ValueError("tenant_id is required")

    # --- Tenant context resolution ---
    # Resolve the schema because each tenant has its own database schema
    schema = resolve_tenant_schema(message.tenant_id)

    # --- Message processing ---
    result = pipeline.execute(message, schema=schema)

    return result
``````

**Docstrings (Python):**
``````python
def resolve_tenant_schema(tenant_id: str) -> str:
    """Convert a tenant UUID to a database schema name.

    Args:
        tenant_id: UUID of the tenant (with or without dashes).

    Returns:
        Schema name in the format 'tenant_<uuid_without_dashes>'.

    Raises:
        ValueError: If tenant_id is not a valid UUID.
    """
``````

**Type hints:**
``````python
# BAD
def process(items, flag):
    ...

# GOOD
def process_queue_messages(items: list[QueueMessage], skip_duplicates: bool = False) -> ProcessingResult:
    ...
``````

**Early returns:**
``````python
# BAD: deeply nested
def handle(request):
    if request.is_valid():
        if request.user:
            if request.user.has_permission():
                return do_work(request)
    return error()

# GOOD: guard clauses
def handle(request):
    if not request.is_valid():
        return error("invalid request")
    if not request.user:
        return error("missing user")
    if not request.user.has_permission():
        return error("forbidden")
    return do_work(request)
``````

**Remember:** Code is read 10x more than it is written. Optimize for the reader.
</system-context>
HOOK_EOF
exit 0
