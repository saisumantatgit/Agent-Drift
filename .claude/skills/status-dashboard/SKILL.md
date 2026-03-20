---
name: status-dashboard
description: >
  Lightweight status display that reads cached state. Shows completion
  percentage, active constraints, unresolved alerts, drift score, and
  next auto-check timing. No re-analysis — reads .drift/state.json only.
license: MIT
metadata:
  domain: drift-detection
  maturity: stable
  primary_use: status
allowed-tools: Read
---

# Status Dashboard

Display a quick summary of drift tracking state without re-running analysis.

## Trigger

Activate this skill when:

- The user invokes `/drift-status`
- The user asks "where are we?" or "what's the status?"
- The user wants a quick glance without a full drift check

Do NOT activate this skill when:

- The user wants a full analysis (use drift-analysis)
- The user wants the final report (use session-audit)
- No spec exists (suggest `/drift-lock` first)

## Arguments

- `--format FORMAT`: One of: `brief`, `detailed`. Default: `brief`.
- `--requirements-only`: Show only requirement statuses.
- `--alerts-only`: Show only unresolved alerts.

## Workflow

### 1. Load State

Read `.drift/state.json`. If it does not exist:
- Check if `.drift/spec.yaml` exists.
  - If spec exists but no state: "Spec is locked but no checks have been run yet. Use `/drift-check` to run the first analysis."
  - If no spec: "No drift spec found. Use `/drift-lock` to get started."
- Do not proceed.

### 2. Load Spec Summary

Read `.drift/spec.yaml` to get:
- Total requirements count (by priority)
- Total constraints count
- Auto-check interval setting

### 3. Check Staleness

Compare `last_check_turn` from state against current conversation position.
If the last check was more than 20 turns ago:
- Set `stale: true`
- Will suggest re-running `/drift-check`

### 4. Display Brief Format (default)

```
## Drift Status

Score: {score}/100 — {ALERT_LEVEL_EMOJI} {ALERT_LEVEL}
Requirements: {complete}/{total} complete ({percent}%)
Constraints: {compliant}/{total} compliant
Alerts: {unresolved_count} unresolved
Last check: {N} turns ago {STALE_WARNING}

{If stale: "Stale data — run /drift-check for current analysis."}
```

Alert level emojis:
- GREEN (0-10): checkmark
- YELLOW (11-25): warning sign
- ORANGE (26-50): caution sign
- RED (51-100): stop sign

### 5. Display Detailed Format (--format detailed)

```
## Drift Status (Detailed)

### Overview
| Metric | Value |
|--------|-------|
| Drift Score | {score}/100 |
| Alert Level | {level} |
| Total Checks | {count} |
| Last Check | {N} turns ago |
| Trend | {improving/stable/worsening} |

### Requirements
| ID | Text | Priority | Status | Completion |
|----|------|----------|--------|------------|
| REQ-001 | Build REST API | MUST | IN_PROGRESS | 60% |
| REQ-002 | User CRUD | MUST | COMPLETE | 100% |
| ... | ... | ... | ... | ... |

MUST: {X}/{Y} complete
SHOULD: {X}/{Y} complete
MAY: {X}/{Y} complete

### Active Constraints
| ID | Constraint | Status | Violations |
|----|-----------|--------|------------|
| CON-001 | No schema changes | COMPLIANT | 0 |
| CON-002 | No auth | VIOLATED | 2 |

### Unresolved Alerts
| # | Type | Severity | Since Check | Description |
|---|------|----------|-------------|-------------|
| 1 | CONSTRAINT_VIOLATION | error | #3 | CON-002 auth middleware |
| 2 | SCOPE_CREEP | warning | #2 | Docker config |

### Score History
Check #1: 0 → Check #2: 8 → Check #3: 18 (trending up)

{If stale: "Data is from {N} turns ago. Run /drift-check for fresh analysis."}
```

### 6. Display Requirements Only (--requirements-only)

Show only the requirements table from the detailed format.

### 7. Display Alerts Only (--alerts-only)

Show only the unresolved alerts table from the detailed format.

## Edge Cases

- **No state file**: Guide to `/drift-lock` or `/drift-check`.
- **State exists but is empty**: Show zeroed dashboard, suggest first check.
- **Very stale data (50+ turns)**: Emphasize staleness warning prominently.
- **All requirements complete, score 0**: Celebrate — "All requirements complete. Zero drift. Clean session."

## References

- [references/spec-schema.md](../../../references/spec-schema.md)
