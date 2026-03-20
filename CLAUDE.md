# Agent-Drift

Agent-Drift is a Claude Code plugin for continuous drift detection and correction in AI agent workflows. It locks developer instructions into structured specs and monitors for deviations throughout the session.

## Architecture

Five command journeys, each with a skill and supporting agent:

| Command | Skill | Agent | Purpose |
|---------|-------|-------|---------|
| `/drift-lock` | intent-capture | spec-extractor | Parse instructions into structured spec |
| `/drift-check` | drift-analysis | drift-detector | Analyze work against spec, compute drift score |
| `/drift-fence` | constraint-enforcement | constraint-monitor | Add enforceable constraints mid-session |
| `/drift-status` | status-dashboard | — | Quick status from cached state |
| `/drift-report` | session-audit | compliance-auditor | End-of-session compliance report |

## 8 Drift Types

| Type | Default Severity | What It Catches |
|------|-----------------|----------------|
| `REQUIREMENT_DRIFT` | error | Requirement delivered differently than specified |
| `SCOPE_CREEP` | warning | Work on items not in spec |
| `CONSTRAINT_VIOLATION` | varies | Explicit constraint broken |
| `TECHNOLOGY_SWAP` | error | Locked technology replaced |
| `PRIORITY_INVERSION` | warning | MAY/SHOULD items done before MUST items |
| `SILENT_DROP` | critical | Requirement abandoned without notification |
| `GOLD_PLATING` | info | Unnecessary features beyond spec |
| `COMPLETION_HALLUCINATION` | critical | Claims "done" but evidence says otherwise |

## Severity Levels

| Severity | Points | Meaning |
|----------|--------|---------|
| `critical` | 25 | System-breaking, data-corrupting, or trust-destroying |
| `error` | 10 | Scope violation, wrong technology, missed MUST requirement |
| `warning` | 3 | Preference violation, minor scope creep, priority issue |
| `info` | 1 | Gold plating, minor deviation |

## Drift Score

- 0-10: GREEN (on track)
- 11-25: YELLOW (minor drift)
- 26-50: ORANGE (significant drift)
- 51-100: RED (major drift)

Resolution credit: resolved findings get 60% of their points back.

## Verdicts

| Verdict | Score Range |
|---------|------------|
| `FULL_COMPLIANCE` | 0-10 |
| `PARTIAL_COMPLIANCE` | 11-40 |
| `NON_COMPLIANT` | 41-100 |

## State Management (.drift/ directory)

```
.drift/
  spec.yaml              # Locked specification (requirements, constraints, scope)
  state.json             # Cached latest state for quick access
  checks/
    check-1.json         # Individual check logs
    check-2.json
  reports/
    report-{timestamp}.md  # Saved session reports
```

- `.drift/spec.yaml` is created by `/drift-lock` and is the source of truth
- `.drift/state.json` is updated by every `/drift-check` and read by `/drift-status`
- Check logs provide historical data for trending and the final report
- The `.drift/` directory is gitignored (session-specific state)

## Hook Architecture

- **SessionStart**: Announces Agent-Drift is loaded with available commands
- **Auto-check**: Configurable interval (default: every 10 turns) triggers drift-analysis

## Configuration

`drift-protocol.yaml` in project root:
- Severity overrides per drift type
- Monitoring settings (auto-check interval, alert/interrupt thresholds)
- Scoring weights
- Verdict thresholds
- Watch/ignore paths
- Constraint defaults
- Report settings

## Constraint Lifecycle

1. User adds constraint via `/drift-fence`
2. Constraint is parsed, assigned ID and severity, added to spec
3. Constraint is **immutable** — cannot be modified or removed programmatically
4. Every `/drift-check` evaluates all constraints
5. Violations are tracked with file/line evidence
6. Resolved violations get 60% score credit
7. Repeat violations trigger **severity escalation** (warning -> error -> critical)
