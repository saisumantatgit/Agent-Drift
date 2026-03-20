---
name: constraint-enforcement
description: >
  Add and enforce constraints mid-session. Parse constraint text into structured
  form, assign IDs and severity, append to the drift spec, and optionally
  retroactively scan existing work for violations. Constraints are immutable
  once added — severity escalates on repeat violations.
license: MIT
metadata:
  domain: drift-detection
  maturity: stable
  primary_use: enforcement
allowed-tools: Read Glob Grep Bash Edit
---

# Constraint Enforcement

Add enforceable constraints to the drift spec at any point during a session. Constraints become part of the spec immediately and are checked on every subsequent drift check.

## Trigger

Activate this skill when:

- The user invokes `/drift-fence` with a constraint
- The user says "don't do X" or "stop doing Y" mid-session
- The user wants to add a boundary after the initial spec was locked

Do NOT activate this skill when:

- The user wants to lock the full spec (use intent-capture)
- The user wants to check existing constraints (use drift-analysis)
- No spec exists yet (suggest `/drift-lock` first)

## Arguments

- **CONSTRAINT** (required): Natural language constraint text
- `--type TYPE`: One of: `negative`, `boundary`, `style`, `technology`. Defaults to auto-detect.
- `--severity LEVEL`: One of: `critical`, `error`, `warning`. Defaults to `error`.
- `--retroactive`: Immediately scan existing work for violations of this new constraint.

## Workflow

### 1. Verify Spec Exists

Read `.drift/spec.yaml`. If it does not exist:
- Stop and say: "No drift spec found. Use `/drift-lock` first, then add constraints with `/drift-fence`."
- Do not proceed.

### 2. Parse Constraint

Analyze the constraint text to determine:

**Type classification:**
- `negative` — "Do NOT", "Never", "Don't", "Avoid" — prohibits an action
- `boundary` — "Only X", "Out of scope", "Not part of this task" — limits scope
- `style` — "Follow pattern X", "Use convention Y" — enforces code style
- `technology` — "Do not use library X", "Must use framework Y" — locks technology choices

If `--type` was provided, use that. Otherwise auto-detect from the constraint text.

**Severity assignment:**
- If `--severity` was provided, use that.
- Otherwise apply defaults:
  - `negative` constraints that modify data or state: `critical`
  - `negative` constraints on features: `error`
  - `boundary` constraints: `error`
  - `style` constraints: `warning`
  - `technology` constraints: `error`

### 3. Assign Constraint ID

Read existing constraints from `.drift/spec.yaml`.
Find the highest CON-XXX number.
Assign the next sequential ID: CON-{N+1}.

### 4. Validate Against Existing Spec

Check for conflicts with existing requirements and constraints:
- Does this constraint contradict any existing requirement?
  - Example: Fencing "no API endpoints" when REQ-001 says "build REST API"
- Does this constraint duplicate an existing constraint?
  - If exact duplicate: inform user and skip.
  - If partial overlap: inform user and ask whether to merge or keep separate.

If conflicts found:
- Present the conflict clearly
- Ask user to confirm or modify before adding

### 5. Append to Spec

Add the constraint to `.drift/spec.yaml` under the `constraints` section:

```yaml
constraints:
  # ... existing constraints ...
  - id: CON-004
    text: "Do NOT add authentication — that's a separate task"
    type: boundary
    severity: error
    added_at: "2026-03-20T14:30:00Z"
    added_turn: 47
    violations: []
    escalation_count: 0
```

### 6. Retroactive Scan (if --retroactive)

If `--retroactive` flag was provided, immediately scan existing work:

1. **File scan**: Use Glob and Grep to search for patterns that violate the constraint
   - For negative constraints: search for the prohibited action/pattern
   - For boundary constraints: search for out-of-scope work
   - For technology constraints: search for prohibited imports/dependencies
   - For style constraints: search for pattern violations

2. **Conversation scan**: Review conversation history for agent statements or actions that violate the constraint

3. **Report findings**:
```
## Retroactive Scan Results for CON-004

Found 2 pre-existing violations:

| # | File | Line | Evidence |
|---|------|------|----------|
| 1 | src/middleware/auth.py | 1 | Auth middleware file exists |
| 2 | requirements.txt | 15 | PyJWT dependency added |

These violations pre-date the constraint.
Action required: remove auth code to comply, or remove the constraint.
```

### 7. Constraint Lifecycle Rules

Once a constraint is added, these lifecycle rules apply:

**Immutability:** Constraints cannot be modified or removed programmatically. Only the user can explicitly revoke a constraint.

**Violation tracking:** Every violation is recorded with:
- Timestamp
- File and line
- Description
- Whether it was resolved

**Severity escalation:** If a constraint is violated, resolved, then violated again:
- First violation: assigned severity
- Second violation (same constraint): severity escalates one level
  - `warning` → `error`
  - `error` → `critical`
  - `critical` stays `critical`
- The escalation count is tracked in the constraint record

**Resolution tracking:** When a violation is resolved (detected in one check, absent in the next):
- The violation is marked `resolved: true`
- The resolution timestamp is recorded
- Drift score gets 60% credit back

### 8. Update State

Update `.drift/state.json`:
- Increment constraint count
- If retroactive violations found, update drift score and active alerts

### 9. Confirm Fence

Present confirmation:

```
## Constraint Added

**CON-004**: Do NOT add authentication — that's a separate task
**Type**: boundary | **Severity**: error

This constraint is now active and will be checked on every /drift-check.

{If retroactive: "Retroactive scan found X violations. See above."}
{If no retroactive: "Use --retroactive to check existing work against this constraint."}
```

## Edge Cases

- **No spec exists**: Direct to `/drift-lock`.
- **Constraint conflicts with requirement**: Present conflict, ask user to resolve.
- **Duplicate constraint**: Inform and skip.
- **Very broad constraint**: Warn that broad constraints may produce false positives (e.g., "don't change anything" is too broad).
- **Retroactive scan finds many violations**: Group by file and present summary, not individual lines.

## References

- [references/drift-types.md](../../../references/drift-types.md)
- [references/spec-schema.md](../../../references/spec-schema.md)
