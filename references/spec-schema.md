# Spec Schema Reference

The drift spec (`.drift/spec.yaml`) is the canonical source of truth for all drift detection. This document defines the complete schema.

## Top-Level Structure

```yaml
# Agent-Drift Spec
# Generated: {timestamp}
# Source: {text|file|conversation}

metadata:
  created: "2026-03-20T10:00:00Z"
  source: "text"          # text | file | conversation
  version: 1              # increments on each append
  auto_check: true        # enable auto-check hook
  check_interval: 10      # turns between auto-checks

requirements: []          # list of requirement objects
constraints: []           # list of constraint objects
technology_locks: []      # list of technology lock objects

scope:
  in_scope: []            # list of in-scope items
  out_of_scope: []        # list of out-of-scope items

anchors: []               # list of architecture/style anchors
```

## Requirement Object

```yaml
- id: REQ-001                      # Sequential ID, never reused
  text: "Build a REST API"         # Clear, testable requirement text
  priority: MUST                   # MUST | SHOULD | MAY
  status: NOT_STARTED              # NOT_STARTED | IN_PROGRESS | COMPLETE | DROPPED | MODIFIED
  completion: 0                    # 0-100 percentage
  evidence: []                     # list of evidence strings (populated by drift-check)
  drift_type: null                 # null or drift type if requirement drifted
```

### Priority Levels

| Priority | Meaning | Drift Severity if Missed |
|----------|---------|-------------------------|
| `MUST` | Non-negotiable. Task failure if missing. | critical (SILENT_DROP) or error (REQUIREMENT_DRIFT) |
| `SHOULD` | Expected but not blocking. | warning |
| `MAY` | Optional / nice to have. | info |

### Status Values

| Status | Meaning |
|--------|---------|
| `NOT_STARTED` | No work done toward this requirement |
| `IN_PROGRESS` | Partially implemented (see completion %) |
| `COMPLETE` | Fully implemented with evidence |
| `DROPPED` | Was in progress, now abandoned |
| `MODIFIED` | Implemented differently than specified |

## Constraint Object

```yaml
- id: CON-001                          # Sequential ID, never reused
  text: "Do NOT modify the database"   # Constraint text
  type: negative                       # negative | boundary | style | technology
  severity: critical                   # critical | error | warning
  added_at: "2026-03-20T10:00:00Z"    # When added to spec
  added_turn: 1                        # Conversation turn when added
  violations: []                       # list of violation records
  escalation_count: 0                  # number of severity escalations
```

### Constraint Types

| Type | Meaning | Examples |
|------|---------|---------|
| `negative` | Prohibits a specific action | "Do NOT modify schema", "Never use eval()" |
| `boundary` | Limits scope of work | "Only the API", "Not the frontend" |
| `style` | Enforces a pattern or convention | "Follow PEP 8", "Use camelCase" |
| `technology` | Locks or blocks a technology | "Do not use jQuery", "Must use TypeScript" |

### Violation Record

```yaml
violation:
  detected_at: "2026-03-20T14:30:00Z"
  detected_check: 3
  file: "src/schema.py"
  line: 42
  evidence: "ALTER TABLE statement"
  resolved: false
  resolved_at: null
```

### Severity Escalation

Constraints escalate severity on repeat violations:

```
First violation:  assigned severity
Resolved + re-violated:  severity + 1 (warning → error → critical)
Resolved + re-violated again:  severity + 1 (caps at critical)
```

## Technology Lock Object

```yaml
- technology: "FastAPI"       # Technology name
  role: "web framework"       # What role it fills
  locked: true                # Always true (locked means enforced)
  version: null               # Optional version constraint
```

## Scope Object

```yaml
scope:
  in_scope:
    - "User CRUD endpoints"
    - "Pagination and search"
    - "Error handling"
    - "Input validation"
  out_of_scope:
    - "Authentication and authorization"
    - "Deployment configuration"
    - "Frontend / UI"
    - "Database design"
```

## Anchor Object

```yaml
- type: architecture          # architecture | style | pattern
  text: "RESTful API design"  # Anchor description
```

### Anchor Types

| Type | Meaning | Examples |
|------|---------|---------|
| `architecture` | High-level design decision | "RESTful", "microservice", "monolith" |
| `style` | Code style preference | "PEP 8", "Airbnb style guide" |
| `pattern` | Design pattern to follow | "Repository pattern", "MVC", "CQRS" |

## State File (.drift/state.json)

The state file caches the latest check results for quick access:

```json
{
  "spec_version": 1,
  "last_check": "2026-03-20T14:00:00Z",
  "last_check_turn": 35,
  "last_check_number": 3,
  "drift_score": 18,
  "alert_level": "YELLOW",
  "total_checks": 3,
  "active_alerts": [
    {
      "type": "CONSTRAINT_VIOLATION",
      "severity": "error",
      "related_id": "CON-002",
      "since_check": 2,
      "description": "Auth middleware added"
    }
  ],
  "requirement_status": {
    "REQ-001": { "status": "IN_PROGRESS", "completion": 60 },
    "REQ-002": { "status": "COMPLETE", "completion": 100 }
  },
  "constraint_status": {
    "CON-001": "COMPLIANT",
    "CON-002": "VIOLATED"
  },
  "score_history": [0, 8, 18]
}
```

## Check Log (.drift/checks/check-N.json)

Each check is logged as a separate file:

```json
{
  "check_number": 3,
  "timestamp": "2026-03-20T14:00:00Z",
  "turn": 35,
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

## Directory Structure

```
.drift/
  spec.yaml              # The locked specification
  state.json             # Cached latest state
  checks/
    check-1.json         # Check log #1
    check-2.json         # Check log #2
    check-3.json         # Check log #3
  reports/
    report-2026-03-20.md # Saved session report
```
