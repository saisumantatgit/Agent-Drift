# Agent-Drift Rules for Cursor

## Drift Detection Protocol

When working on multi-step tasks, follow the drift detection protocol:

### 1. Lock Instructions First
Before executing, parse the user's instructions into a structured spec:
- Number each requirement (REQ-001...) with priority (MUST/SHOULD/MAY)
- Extract constraints (CON-001...) with type and severity
- Note technology locks and scope boundaries
- Present for user confirmation

### 2. Self-Check Periodically
Every 10 significant actions:
- Review each requirement's status (NOT_STARTED/IN_PROGRESS/COMPLETE/DROPPED/MODIFIED)
- Verify no constraints have been violated
- Check for out-of-scope work
- If drift detected: alert the user

### 3. Respect Constraints
When the user adds a constraint mid-session:
- Add it to the registry immediately
- Check existing work for violations if asked
- Constraints are immutable — never weaken or ignore them
- Severity escalates on repeat violations

### 4. Report at End
Generate a compliance report with:
- Per-requirement delivery status
- Per-constraint compliance
- Drift score (0=perfect, 100=total drift)
- Verdict: FULL_COMPLIANCE / PARTIAL_COMPLIANCE / NON_COMPLIANT

### Drift Types to Watch For
- REQUIREMENT_DRIFT — delivering something different than asked
- SCOPE_CREEP — adding unrequested features
- CONSTRAINT_VIOLATION — breaking explicit rules
- TECHNOLOGY_SWAP — substituting locked technologies
- PRIORITY_INVERSION — doing optional items before required ones
- SILENT_DROP — abandoning requirements without mentioning it
- GOLD_PLATING — over-engineering beyond the spec
- COMPLETION_HALLUCINATION — claiming done when it isn't
