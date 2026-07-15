# Root Cause Tracing

## Overview

Bugs often manifest deep in the call stack (git init in the wrong directory, a file created in the wrong location, a database opened with the wrong path). Your instinct is to fix where the error appears, but that's treating a symptom.

**Core principle:** Trace backward through the call chain until you find the original trigger, then fix at the source.

## When to Use

**Use when:**
- Error happens deep in execution (not at the entry point)
- Stack trace shows a long call chain
- Unclear where invalid data originated
- Need to find which test/code triggers the problem

## The Tracing Process

### 1. Observe the Symptom
```
Error: git init failed in /home/dev/project/packages/core
```

### 2. Find the Immediate Cause
**What code directly causes this?**
```typescript
await execFileAsync('git', ['init'], { cwd: projectDir });
```

### 3. Ask: What Called This?
```typescript
WorktreeManager.createSessionWorktree(projectDir, sessionId)
  → called by Session.initializeWorkspace()
  → called by Session.create()
  → called by test at Project.create()
```

### 4. Keep Tracing Up
**What value was passed?**
- `projectDir = ''` (empty string!)
- Empty string as `cwd` resolves to the process working directory
- That's the source code directory!

### 5. Find the Original Trigger
**Where did the empty string come from?**
```typescript
const context = setupCoreTest(); // Returns { tempDir: '' }
Project.create('name', context.tempDir); // Accessed before beforeEach!
```

## Adding Stack Traces

When you can't trace manually, add instrumentation:

```typescript
// Before the problematic operation
async function gitInit(directory: string) {
  const stack = new Error().stack;
  console.error('DEBUG git init:', {
    directory,
    cwd: process.cwd(),
    env: process.env.NODE_ENV,
    stack,
  });

  await execFileAsync('git', ['init'], { cwd: directory });
}
```

**Critical:** Use a raw stderr write (`console.error()`) in tests, not a logger — a logger may be suppressed.

**Run and capture:**
```bash
<run your test suite> 2>&1 | grep 'DEBUG git init'
```

**Analyze the stack traces:**
- Look for test file names
- Find the line number triggering the call
- Identify the pattern (same test? same parameter?)

## Finding Which Test Causes Pollution

If something appears during tests but you don't know which test, **bisect**: run the suite
one test (or one file) at a time and stop at the first run that reproduces the artifact.
Automate it with a small loop over the test files, aborting on the first failure — the last
file run is the polluter.

## Real Example: Empty projectDir

**Symptom:** `.git` created in `packages/core/` (source code)

**Trace chain:**
1. `git init` runs in the process working directory ← empty cwd parameter
2. WorktreeManager called with empty projectDir
3. Session.create() passed empty string
4. Test accessed `context.tempDir` before beforeEach
5. setupCoreTest() returns `{ tempDir: '' }` initially

**Root cause:** Top-level variable initialization accessing an empty value

**Fix:** Made tempDir a getter that throws if accessed before beforeEach

**Also added defense-in-depth:**
- Layer 1: Project.create() validates the directory
- Layer 2: WorkspaceManager validates it's not empty
- Layer 3: An environment guard refuses git init outside the temp dir during tests
- Layer 4: Stack-trace logging before git init

## Key Principle

**NEVER fix just where the error appears.** Trace back to find the original trigger.

## Stack Trace Tips

**In tests:** Use a raw stderr write, not a logger — a logger may be suppressed.
**Before the operation:** Log before the dangerous operation, not after it fails.
**Include context:** Directory, working directory, environment variables, timestamps.
**Capture the stack:** `new Error().stack` shows the complete call chain.

## Real-World Impact

From a debugging session:
- Found the root cause through a 5-level trace
- Fixed at the source (getter validation)
- Added 4 layers of defense
- Full suite passed, zero pollution
