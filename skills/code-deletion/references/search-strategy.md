# Search Strategy Reference

### Priority (MANDATORY)
| Tool | When to Use |
|------|-------------|
| 1. **LSP** (cclsp MCP) | Code symbols: definitions, references, semantic search |
| 2. **ast-grep** | Structural patterns when LSP unavailable |
| 3. **grep/rg** | Strings in configs, docs, comments ONLY |

### For Code Symbols (USE LSP FIRST)
```python
# Find symbol definition
find_definition(file_path="path/to/file.py", symbol_name="{name}")

# Find ALL references across workspace
find_references(file_path="path/to/file.py", symbol_name="{name}")

# Workspace-wide symbol search
lsp_workspace_symbols(query="{name}")
```

### For Structural Patterns (ast-grep)
```bash
# Python: Find function definitions
sg -p 'def {name}($$$): $$$' -l python

# Python: Find async functions
sg -p 'async def {name}($$$): $$$' -l python

# Python: Find class definitions
sg -p 'class {name}: $$$' -l python
sg -p 'class {name}($BASE): $$$' -l python

# Python: Find decorator usage
sg -p '@{name}
def $FUNC($$$): $$$' -l python

# Python: Find imports
sg -p 'from $MODULE import {name}' -l python
sg -p 'import {name}' -l python

# TypeScript: Find function components
sg -p 'function {name}($$$) {
  $$$
}' -l tsx

# TypeScript: Find arrow function assignments
sg -p 'const {name} = ($$$) => {
  $$$
}' -l typescript

# TypeScript: Find imports
sg -p 'import { {name} } from $$$' -l typescript
sg -p 'import {name} from $$$' -l typescript

# TypeScript: Find type/interface definitions
sg -p 'interface {name} {
  $$$
}' -l typescript
sg -p 'type {name} = $$$' -l typescript

# TSX: Find React component usage
sg -p '<{name} $$$PROPS />' -l tsx
sg -p '<{name} $$$>$$$</{name}>' -l tsx
```

### For Non-Code Text (grep/rg ONLY)
```bash
# String references in configs
rg "{name}" --type-add "config:*.{yml,yaml,json,ini,cfg,toml}" --type config

# Documentation references
rg "{name}" --type md --type rst --type txt

# Comments (when semantic context not needed)
rg "# .*{name}" --type py
```

**CRITICAL:** Use LSP for ALL code-related searches. Only fall back to ast-grep if LSP fails, and only use grep for plain text.
