---
name: session-audit
description: >
  Generate an end-of-session compliance report. Aggregates all check results,
  constraint statuses, and drift events into a final audit with per-requirement
  delivery evidence, drift timeline, resolution credits, and a compliance verdict.
license: MIT
metadata:
  domain: drift-detection
  maturity: stable
  primary_use: reporting
allowed-tools: Read Grep Glob Bash
---

# Session Audit

Produce a comprehensive end-of-session report summarizing instruction compliance, drift history, and final delivery status.

## Trigger

Activate this skill when:

- The user invokes `/drift-report`
- The session is ending and the user wants a compliance summary
- The user asks for the "final drift report" or "session summary"

Do NOT activate this skill when:

- The user wants a quick status (use status-dashboard)
- The user wants a mid-session check (use drift-analysis)
- No spec exists (suggest `/drift-lock` first)

## Arguments

- `--format FORMAT`: One of: `summary`, `detailed`, `json`. Default: `detailed`.
- `--include-timeline`: Include full drift event timeline.
- `--include-diff`: Include file diffs for each requirement.
- `--save`: Save report to `.drift/reports/report-{timestamp}.md`.

## Workflow

### 1. Load All Session Data

Gather everything from `.drift/`:

1. **Spec**: Read `.drift/spec.yaml` for all requirements, constraints, scope, locks, anchors
2. **State**: Read `.drift/state.json` for latest status
3. **Checks**: Read all `.drift/checks/check-*.json` for historical check data
4. **Events**: Compile all drift events across all checks

If no spec or no checks exist:
- "No drift data found. Either no spec was locked or no checks were run."
- If spec exists but no checks: Run one final drift-analysis before generating the report.

### 2. Compute Final Requirement Status

For each requirement, determine final delivery status:

| Final Status | Criteria |
|-------------|----------|
| `DELIVERED` | Status is COMPLETE with file/code evidence |
| `PARTIALLY_DELIVERED` | Status is IN_PROGRESS (include completion %) |
| `NOT_DELIVERED` | Status is NOT_STARTED or completion < 10% |
| `DROPPED` | Was started but later abandoned |
| `MODIFIED` | Delivered but different from spec |

**Evidence gathering for each requirement:**
- Use Glob and Grep to find files implementing the requirement
- Check conversation history for agent statements about delivery
- Cross-reference with check history for status changes over time

### 3. Compute Final Constraint Compliance

For each constraint:

| Final Status | Criteria |
|-------------|----------|
| `NEVER_VIOLATED` | No violations in any check |
| `VIOLATED_AND_RESOLVED` | Was violated, then fixed |
| `CURRENTLY_VIOLATED` | Violation exists in latest check |
| `REPEATEDLY_VIOLATED` | Violated, resolved, violated again |

Include timeline for each constraint:
- When it was added (turn number)
- Each violation event (turn, file, evidence)
- Each resolution event (turn)

### 4. Build Drift Timeline

Compile all drift events in chronological order:

```
## Drift Timeline

| Turn | Event | Type | Severity | Detail |
|------|-------|------|----------|--------|
| 1 | SPEC_LOCKED | — | — | 5 requirements, 2 constraints |
| 15 | CHECK_1 | — | GREEN | Score: 0/100 |
| 23 | CONSTRAINT_VIOLATION | error | — | CON-002: auth middleware added |
| 25 | CHECK_2 | — | YELLOW | Score: 18/100 |
| 30 | FENCE_ADDED | — | — | CON-003: no Docker |
| 35 | VIOLATION_RESOLVED | — | — | CON-002: auth removed |
| 40 | CHECK_3 | — | GREEN | Score: 5/100 |
```

### 5. Compute Final Drift Score

Calculate the session's final drift score:

1. Start with the latest check's drift score
2. Apply resolution credits: each resolved drift gets 60% of its points back
3. Apply completion bonus: if all MUST requirements are DELIVERED, subtract 5 points
4. Floor at 0, cap at 100

### 6. Determine Verdict

Based on final drift score:

| Verdict | Score Range | Meaning |
|---------|------------|---------|
| `FULL_COMPLIANCE` | 0-10 | All requirements met, constraints respected |
| `PARTIAL_COMPLIANCE` | 11-40 | Most requirements met, some drift detected and managed |
| `NON_COMPLIANT` | 41-100 | Significant drift from instructions |

### 7. Generate Recommendations

Based on findings, generate actionable recommendations:

**For NON_COMPLIANT sessions:**
- List undelivered MUST requirements that need immediate attention
- List active constraint violations
- Suggest: "Start next session with `/drift-lock` using the remaining requirements"

**For PARTIAL_COMPLIANCE sessions:**
- List items that drifted and suggest corrections
- Note constraints that were violated and resolved (positive pattern)
- Suggest: "Next session, lock constraints earlier to prevent mid-session drift"

**For FULL_COMPLIANCE sessions:**
- Congratulate
- Note any drift that was caught and corrected (shows the system working)
- Suggest: "Consider adding these constraints to your project defaults"

### 8. Format Report

#### Summary Format (--format summary)

```
## Drift Report — Session Summary

Verdict: {VERDICT}
Score: {score}/100
Requirements: {delivered}/{total} delivered
Constraints: {compliant}/{total} compliant
Drift events: {count}
```

#### Detailed Format (--format detailed, default)

```
## Drift Report

### Verdict: {VERDICT} — Score: {score}/100

### Requirement Delivery
| ID | Requirement | Priority | Final Status | Completion | Evidence |
|----|------------|----------|-------------|------------|----------|
| REQ-001 | REST API | MUST | DELIVERED | 100% | src/api/ (5 endpoints) |
| REQ-002 | User CRUD | MUST | DELIVERED | 100% | src/api/users.py |
| REQ-003 | Pagination | SHOULD | PARTIALLY_DELIVERED | 40% | Offset only, no cursor |

MUST delivery rate: {X}/{Y} ({percent}%)
SHOULD delivery rate: {X}/{Y} ({percent}%)
MAY delivery rate: {X}/{Y} ({percent}%)

### Constraint Compliance
| ID | Constraint | Final Status | Violations | Resolutions |
|----|-----------|-------------|------------|-------------|
| CON-001 | No schema changes | NEVER_VIOLATED | 0 | — |
| CON-002 | No auth | VIOLATED_AND_RESOLVED | 1 | 1 |

### Drift Events Summary
| Drift Type | Count | Resolved | Active |
|-----------|-------|----------|--------|
| REQUIREMENT_DRIFT | 1 | 1 | 0 |
| CONSTRAINT_VIOLATION | 2 | 1 | 1 |
| SCOPE_CREEP | 1 | 0 | 1 |

{If --include-timeline: full timeline table}

### Score Breakdown
| Factor | Points |
|--------|--------|
| Constraint violations | +25 |
| Scope creep | +3 |
| Resolution credits | -15 |
| Completion bonus | -5 |
| **Final** | **8** |

### Recommendations
1. {recommendation}
2. {recommendation}
3. {recommendation}
```

#### JSON Format (--format json)

Output the full report as structured JSON for programmatic consumption.

### 9. Save Report (if --save)

If `--save` flag was provided:
- Create `.drift/reports/` directory if it doesn't exist
- Write report to `.drift/reports/report-{ISO-timestamp}.md`
- Confirm: "Report saved to .drift/reports/report-{timestamp}.md"

## Edge Cases

- **No checks were run**: Run a final drift-analysis before generating the report.
- **Spec exists but is empty**: Report with zero requirements, note that no spec was defined.
- **All requirements dropped**: Verdict is NON_COMPLIANT with recommendation to re-scope.
- **Score is exactly 0**: "Perfect compliance. Every requirement delivered, every constraint respected."
- **Very long session with many checks**: Summarize trends rather than listing every check.

## References

- [references/drift-types.md](../../../references/drift-types.md)
- [references/spec-schema.md](../../../references/spec-schema.md)
