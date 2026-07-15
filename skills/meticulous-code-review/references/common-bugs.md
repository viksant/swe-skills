# Common Bugs This Skill Prevents

### Off-by-One Errors
```python
# WRONG
for i in range(len(items)):
    if i == len(items):  # Never true!

# RIGHT
for i in range(len(items)):
    if i == len(items) - 1:
```

### Null Reference Errors
```python
# WRONG
result = data.get("key").strip()  # Fails if key missing

# RIGHT
value = data.get("key")
result = value.strip() if value else ""
```

### Race Conditions
```python
# WRONG
if file_exists(path):
    read_file(path)  # File might be deleted between check and read

# RIGHT
try:
    content = read_file(path)
except FileNotFoundError:
    handle_missing_file()
```

### Injection Vulnerabilities
```python
# WRONG
query = f"SELECT * FROM users WHERE id = {user_id}"

# RIGHT
query = "SELECT * FROM users WHERE id = $1"
await conn.fetch(query, user_id)
```
