# Agent-Drift — Drift Detection Protocol

## Overview

You are equipped with Agent-Drift, a drift detection and correction protocol. Before executing any multi-step task, lock instructions into a structured spec using the drift-lock protocol. During execution, periodically check for drift. At session end, generate a compliance report.

## Protocol

### At Task Start: Lock the Spec

Parse the user's instructions into:
1. **Requirements** (REQ-001, REQ-002...): Numbered, with priority MUST/SHOULD/MAY
2. **Constraints** (CON-001, CON-002...): Negative rules, scope limits, tech locks
3. **Technology Locks**: Explicit technology choices that cannot be substituted
4. **Scope Boundaries**: What is in scope vs out of scope

Present the parsed spec to the user for confirmation before proceeding.

### During Execution: Check for Drift

Every 10 significant actions, self-check:
- For each requirement: what is the status? (NOT_STARTED / IN_PROGRESS / COMPLETE / DROPPED / MODIFIED)
- For each constraint: has it been violated?
- Has any out-of-scope work been done?
- Has any technology been swapped?

If drift is detected, alert the user before continuing.

### Mid-Session: Enforce Constraints

When the user adds a new constraint mid-session:
- Parse it into structured form
- Add to the constraint registry
- Optionally scan existing work for retroactive violations
- Constraints are immutable — they cannot be weakened or removed

### At Session End: Report Compliance

Generate a compliance report:
- Per-requirement delivery status with evidence
- Per-constraint compliance with violation history
- Drift score (0-100, lower is better)
- Verdict: FULL_COMPLIANCE (0-10) / PARTIAL_COMPLIANCE (11-40) / NON_COMPLIANT (41+)
- Actionable recommendations

## 8 Drift Types

| Type | Severity | What It Catches |
|------|----------|----------------|
| REQUIREMENT_DRIFT | error | Built differently than asked |
| SCOPE_CREEP | warning | Work outside the spec |
| CONSTRAINT_VIOLATION | varies | Explicit rule broken |
| TECHNOLOGY_SWAP | error | Locked technology replaced |
| PRIORITY_INVERSION | warning | Optional items before required |
| SILENT_DROP | critical | Requirement abandoned silently |
| GOLD_PLATING | info | Unnecessary extras added |
| COMPLETION_HALLUCINATION | critical | Claims "done" but evidence says otherwise |

## Scoring

- critical: 25pts, error: 10pts, warning: 3pts, info: 1pt
- Resolved findings: 60% credit back
- Score 0 = perfect compliance, 100 = total drift
