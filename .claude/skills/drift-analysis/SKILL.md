---
name: drift-analysis
description: >
  Analyze current session state against the locked spec. Per-requirement status
  tracking, constraint compliance checking, out-of-scope detection, and drift
  scoring. The core analytical engine that detects when an agent deviates from
  instructions.
license: MIT
metadata:
  domain: drift-detection
  maturity: stable
  primary_use: analysis
allowed-tools: Read Glob Grep Bash
---

# Drift Analysis

Compare the current state of work against the locked specification and identify all deviations.

## Trigger

Activate this skill when:

- The user invokes `/drift-check`
- An auto-check hook fires (based on turn interval)
- The user asks "am I on track?" or "what's the drift?"

Do NOT activate this skill when:

- No spec exists (suggest `/drift-lock` first)
- The user wants to add constraints (use constraint-enforcement)
- The user wants the final report (use session-audit)

## Arguments

- `--since TURN`: Only analyze changes since a specific conversation turn
- `--focus REQ-XXX,CON-YYY`: Focus on specific requirements or constraints only
- `--verbose`: Show detailed evidence for each finding

## Workflow

### 1. Load Spec

Read `.drift/spec.yaml`. If it does not exist:
- Stop and say: "No drift spec found. Use `/drift-lock` to create one first."
- Do not proceed.

Parse all requirements, constraints, technology locks, scope boundaries, and anchors.

### 2. Load Previous State

Read `.drift/state.json` for previous check results. This provides:
- Previous requirement statuses (to detect regressions)
- Previous drift score (to detect trending)
- Check count (for auto-check scheduling)

### 3. Analyze Requirements

For each requirement in the spec, determine current status:

| Status | Meaning | How to Determine |
|--------|---------|-----------------|
| `NOT_STARTED` | No work done | No files, code, or conversation evidence |
| `IN_PROGRESS` | Partially complete | Some evidence exists, but not all criteria met. Estimate % |
| `COMPLETE` | Fully delivered | All criteria met with file/code evidence |
| `DROPPED` | Was started, now abandoned | Evidence existed previously but is now missing or reverted |
| `MODIFIED` | Delivered differently than specified | Work done but deviates from spec text |

**How to check:**
- Use `Glob` to find files related to each requirement
- Use `Grep` to search for code implementing each requirement
- Use `Read` to verify file contents match requirement intent
- Check conversation history for agent statements about each requirement

**For each requirement, record:**
```yaml
- id: REQ-001
  status: IN_PROGRESS
  completion: 60
  evidence:
    - "src/api/routes.py exists with 3 of 5 endpoints"
    - "Missing: pagination and search endpoints"
  drift_type: null  # or REQUIREMENT_DRIFT if modified
```

### 4. Check Constraints

For each constraint in the spec:

**Negative constraints ("do NOT"):**
- Search for violations using Grep across the codebase
- Check if forbidden files were created, forbidden packages installed, forbidden patterns used
- Check conversation for agent statements that contradict the constraint

**Boundary constraints ("out of scope"):**
- Check if any work was done on out-of-scope items
- Search for files or code related to out-of-scope topics

**Technology constraints:**
- Verify locked technologies are being used
- Check for unauthorized technology substitutions

**Style constraints:**
- Check for pattern violations in created/modified files

**For each constraint, record:**
```yaml
- id: CON-001
  status: COMPLIANT  # or VIOLATED
  violations:
    - file: "src/models/schema.py"
      line: 42
      evidence: "ALTER TABLE statement modifies schema"
      drift_type: CONSTRAINT_VIOLATION
      severity: critical
```

### 5. Detect Out-of-Scope Work

Compare all files created or modified during the session against the scope boundaries:

- List all files changed (using git diff if available, or conversation history)
- For each changed file, determine if it relates to an in-scope item
- Flag any file that doesn't map to any in-scope requirement

Out-of-scope work triggers `SCOPE_CREEP` drift type.

### 6. Classify Drift Types

Every finding must be classified by one of the 8 drift types:

| Drift Type | Triggers When |
|------------|--------------|
| `REQUIREMENT_DRIFT` | A requirement is delivered differently than specified |
| `SCOPE_CREEP` | Work done on items not in scope |
| `CONSTRAINT_VIOLATION` | An explicit constraint was violated |
| `TECHNOLOGY_SWAP` | A locked technology was replaced with another |
| `PRIORITY_INVERSION` | SHOULD/MAY items done before MUST items, or MUST items dropped |
| `SILENT_DROP` | A requirement was silently abandoned without notification |
| `GOLD_PLATING` | Unnecessary features or complexity added beyond spec |
| `COMPLETION_HALLUCINATION` | Agent claims completion but evidence shows otherwise |

### 7. Compute Drift Score

Calculate a drift score from 0 (perfect compliance) to 100 (total drift):

**Scoring weights:**
- Each `critical` finding: **25 points**
- Each `error` finding: **10 points**
- Each `warning` finding: **3 points**
- Each `info` finding: **1 point**

**Resolution credit:** If a previously detected drift has been resolved since the last check, give back **60%** of its points (e.g., a resolved critical finding removes 15 of its 25 points).

**Score cap:** Maximum 100.

**Severity assignment:**
- `CONSTRAINT_VIOLATION` on a critical constraint: **critical**
- `SILENT_DROP` on a MUST requirement: **critical**
- `COMPLETION_HALLUCINATION`: **critical**
- `TECHNOLOGY_SWAP`: **error**
- `REQUIREMENT_DRIFT` on a MUST: **error**, on SHOULD: **warning**
- `SCOPE_CREEP`: **warning** (escalates to error if extensive)
- `PRIORITY_INVERSION`: **warning**
- `GOLD_PLATING`: **info** (escalates to warning if it delays MUST items)

### 8. Generate Alert Level

Based on drift score:
- **0-10**: GREEN — On track
- **11-25**: YELLOW — Minor drift detected
- **26-50**: ORANGE — Significant drift, intervention recommended
- **51-100**: RED — Major drift, session may need course correction

### 9. Log Check

Write check results to `.drift/checks/check-{N}.json`:

```json
{
  "check_number": 1,
  "timestamp": "2026-03-20T10:30:00Z",
  "drift_score": 18,
  "alert_level": "YELLOW",
  "findings": [...],
  "requirement_summary": {
    "total": 5,
    "complete": 2,
    "in_progress": 2,
    "not_started": 1,
    "dropped": 0
  },
  "constraint_summary": {
    "total": 3,
    "compliant": 2,
    "violated": 1
  }
}
```

### 10. Update State

Update `.drift/state.json` with latest check results, drift score, active alerts.

### 11. Present Results

```
## Drift Check #{N}

### Drift Score: {score}/100 — {ALERT_LEVEL}

### Requirements
| ID | Text | Priority | Status | Completion |
|----|------|----------|--------|------------|
| REQ-001 | Build REST API | MUST | IN_PROGRESS | 60% |
| REQ-002 | User CRUD | MUST | COMPLETE | 100% |

### Constraint Compliance
| ID | Constraint | Status |
|----|-----------|--------|
| CON-001 | No schema changes | COMPLIANT |
| CON-002 | No auth | VIOLATED |

### Drift Findings
| # | Type | Severity | Description | Evidence |
|---|------|----------|-------------|----------|
| 1 | CONSTRAINT_VIOLATION | error | CON-002 violated | auth middleware added in src/middleware/auth.py |
| 2 | SCOPE_CREEP | warning | Docker config added | docker-compose.yml not in scope |

### Trend
Previous score: {prev} → Current: {current} ({direction})

### Recommended Actions
1. Remove auth middleware (CON-002 violation)
2. Confirm Docker config is desired (scope creep)
```

## Edge Cases

- **No spec exists**: Direct user to `/drift-lock`.
- **First check (no previous state)**: Skip trend analysis, establish baseline.
- **No files changed**: Report requirement statuses based on conversation only.
- **Agent claims "done"**: Verify against actual file evidence. Flag `COMPLETION_HALLUCINATION` if evidence does not support the claim.
- **--focus with invalid IDs**: Warn about unrecognized IDs, check the valid ones.

## References

- [references/drift-types.md](../../../references/drift-types.md)
- [references/spec-schema.md](../../../references/spec-schema.md)
