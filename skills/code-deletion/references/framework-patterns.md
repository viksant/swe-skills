# Framework-Specific Patterns

### Functions That Are ALWAYS Used (Auto-Exclude)

**Python Patterns - Never mark as dead:**
```python
# Pydantic v2 patterns
model_post_init         # Called automatically after __init__
model_dump              # Serialization method
field_validator         # Decorated validators
field_serializer        # Custom serializers
computed_field          # Computed properties

# ABC/Protocol patterns
@abstractmethod         # Must be implemented by subclasses
__class_getitem__       # Generic type support

# Async context managers
__aenter__, __aexit__   # async with support
__aiter__, __anext__    # async for support

# Factory patterns (commonly used dynamically)
create_*, build_*, make_*, from_*
```

**FastAPI Patterns:**
```python
# These functions ARE used even if not directly called
Depends(get_current_user)  # Dependency injection
app.add_api_route(path, handler)  # Route registration
on_event("startup", func)  # Event handlers
BackgroundTasks.add_task(func)  # Background tasks
```

**Discord.py Patterns:**
```python
# Event handlers are called by the framework
@bot.event
async def on_message(message): ...

@bot.command()
async def my_command(ctx): ...

# Cog methods
def cog_load(self): ...
def cog_unload(self): ...
```

### Detection Patterns for Common False Positives

```bash
# FastAPI dependency injection (function IS used)
sg -p 'Depends({name})' -l python

# Pydantic validators (method IS used)
sg -p '@field_validator($$$)
def {name}($$$): $$$' -l python

# Discord event handlers (function IS used)
sg -p '@$BOT.event
async def {name}($$$): $$$' -l python

# SQLAlchemy events (function IS used)
sg -p '@event.listens_for($$$)
def {name}($$$): $$$' -l python

# Celery tasks (function IS used)
sg -p '@app.task
def {name}($$$): $$$' -l python
sg -p '@shared_task
def {name}($$$): $$$' -l python

# pytest fixtures (function IS used)
sg -p '@pytest.fixture
def {name}($$$): $$$' -l python
```

### Inheritance Chain Analysis

**Build inheritance graph BEFORE declaring methods dead:**

```python
# Step 1: Find all class definitions and their bases
sg -p 'class $CLASS($BASES): $$$' -l python

# Step 2: For each method in parent class, check if:
#   a) Any child class overrides it
#   b) Any child class calls super().method()

# Step 3: If either is true, parent method is IN USE

# Example patterns to detect:
sg -p 'super().{method_name}($$$)' -l python
sg -p 'super($CLASS, self).{method_name}($$$)' -l python
```

### String-Based Reference Matching (Intelligent)

**Only flag a string as a reference if it EXACTLY matches a defined function:**

```python
# WRONG: Flag any string containing function name
# rg "get_user" → matches "get_user_data", "please get_user", etc.

# RIGHT: Cross-reference with defined symbols
# 1. Collect all defined function names: {get_user, process_data, ...}
# 2. Collect all string literals that are valid identifiers
# 3. Intersection = strings that might be function references
# 4. Only those strings count as potential usage
```
