---
name: intent-capture
description: >
  Parse natural language instructions into a structured drift spec. Extracts
  numbered requirements with MUST/SHOULD/MAY priority, negative constraints,
  technology locks, scope boundaries, and architecture anchors. Writes to
  .drift/spec.yaml as the canonical source of truth for drift detection.
license: MIT
metadata:
  domain: drift-detection
  maturity: stable
  primary_use: spec-capture
allowed-tools: Read Glob Grep Bash Edit
---

# Intent Capture

Lock developer instructions into a structured, machine-readable specification that serves as the ground truth for all drift detection.

## Trigger

Activate this skill when:

- The user invokes `/drift-lock` with instructions (text, file path, or conversation reference)
- The user wants to establish what the agent MUST do, SHOULD do, and MUST NOT do
- The user wants to define scope boundaries for a task

Do NOT activate this skill when:

- The user wants to check for drift (use drift-analysis)
- The user wants to add a single constraint mid-session (use constraint-enforcement)
- The user wants a status update (use status-dashboard)

## Arguments

- **INSTRUCTIONS** (required): Natural language instructions, a file path, or `--from-conversation`
- `--from-conversation`: Extract spec from the conversation history so far
- `--append`: Add to an existing spec instead of creating a new one
- `--interactive`: Walk through each category interactively, asking for confirmation

## Workflow

### 1. Initialize Drift Directory

Check if `.drift/` directory exists. If not, create it with:
- `.drift/spec.yaml` — the spec file (will be written in step 5)
- `.drift/state.json` — runtime state cache (initialize empty)
- `.drift/checks/` — directory for check logs

If `.drift/spec.yaml` already exists and `--append` was NOT passed:
- Warn: "A spec already exists. Use `--append` to add to it, or confirm to overwrite."
- Wait for confirmation before proceeding.

### 2. Gather Raw Instructions

**If INSTRUCTIONS is text:** Use the provided text directly.

**If INSTRUCTIONS is a file path:** Read the file contents.

**If `--from-conversation`:** Analyze the conversation history to extract:
- Explicit instructions the user gave
- Stated requirements and expectations
- Mentioned constraints or restrictions
- Technology choices or preferences
- Scope definitions (what's in, what's out)

### 3. Parse into Structured Spec

Use the `spec-extractor` agent to decompose instructions into these categories:

#### Requirements (REQ-XXX)

Extract each distinct deliverable or behavior. Assign priority:
- **MUST** — Non-negotiable. Failure to deliver = task failure.
- **SHOULD** — Expected but not blocking. Missing = drift warning.
- **MAY** — Nice to have. Only flag if agent claims it was required.

Number each: REQ-001, REQ-002, etc.

Example:
```yaml
requirements:
  - id: REQ-001
    text: "Build a REST API with FastAPI"
    priority: MUST
    status: NOT_STARTED
    completion: 0
  - id: REQ-002
    text: "Include user CRUD operations"
    priority: MUST
    status: NOT_STARTED
    completion: 0
  - id: REQ-003
    text: "Add pagination to list endpoints"
    priority: SHOULD
    status: NOT_STARTED
    completion: 0
```

#### Negative Constraints (CON-XXX)

Extract every "do not", "don't", "avoid", "never", "without" instruction:

```yaml
constraints:
  - id: CON-001
    text: "Do NOT modify the database schema"
    type: negative
    severity: critical
    violations: []
  - id: CON-002
    text: "Do NOT add authentication"
    type: boundary
    severity: error
    violations: []
```

#### Technology Locks

Extract explicit technology choices:

```yaml
technology_locks:
  - technology: "FastAPI"
    role: "web framework"
    locked: true
  - technology: "PostgreSQL"
    role: "database"
    locked: true
```

#### Scope Boundaries

Define what's in and out of scope:

```yaml
scope:
  in_scope:
    - "User CRUD endpoints"
    - "Pagination and search"
    - "Error handling"
  out_of_scope:
    - "Authentication and authorization"
    - "Deployment configuration"
    - "Frontend"
```

#### Architecture and Style Anchors

Extract style preferences, patterns, or architecture decisions:

```yaml
anchors:
  - type: architecture
    text: "RESTful API design"
  - type: style
    text: "Follow existing project conventions"
  - type: pattern
    text: "Repository pattern for data access"
```

### 4. Interactive Review (if --interactive)

If `--interactive` flag was provided, walk through each category:

1. Present extracted requirements. Ask: "Are these requirements correct? Add/remove/modify?"
2. Present constraints. Ask: "Are these constraints correct?"
3. Present technology locks. Ask: "Are these technology choices locked?"
4. Present scope boundaries. Ask: "Is the scope correct?"
5. Present anchors. Ask: "Any architecture or style anchors to add?"

### 5. Conflict Detection

Before writing, check for conflicts:
- Requirement that contradicts a constraint (e.g., REQ says "add auth", CON says "no auth")
- Technology locks that conflict (e.g., "use FastAPI" and "use Django")
- Scope items that appear in both in_scope and out_of_scope

If conflicts found:
- Present each conflict clearly
- Ask the user to resolve before proceeding

### 6. Write Spec

Write the complete spec to `.drift/spec.yaml`:

```yaml
# Agent-Drift Spec
# Generated: {timestamp}
# Source: {text|file|conversation}

metadata:
  created: "{ISO timestamp}"
  source: "{how instructions were provided}"
  version: 1
  auto_check: true
  check_interval: 10  # turns between auto-checks

requirements:
  # ... extracted requirements

constraints:
  # ... extracted constraints

technology_locks:
  # ... extracted locks

scope:
  in_scope:
    # ...
  out_of_scope:
    # ...

anchors:
  # ... architecture/style anchors
```

If `--append`: merge new items with existing spec, incrementing IDs to avoid conflicts.

### 7. Initialize State

Write `.drift/state.json`:

```json
{
  "spec_version": 1,
  "last_check": null,
  "last_check_turn": 0,
  "drift_score": 0,
  "total_checks": 0,
  "active_alerts": [],
  "requirement_status": {},
  "constraint_status": {}
}
```

### 8. Confirm Lock

Present a summary:

```
## Drift Spec Locked

### Requirements: X (Y MUST, Z SHOULD, W MAY)
### Constraints: X
### Technology Locks: X
### Scope: X in / Y out
### Anchors: X

Auto-check: every 10 turns (configurable in .drift/spec.yaml)

Use /drift-check to verify compliance at any time.
Use /drift-fence to add constraints mid-session.
```

## Edge Cases

- **Empty instructions**: Ask the user to provide instructions.
- **Ambiguous instructions**: Use `--interactive` mode or ask clarifying questions. Never assume priority — ask.
- **Very long instructions**: Process in chunks, number requirements sequentially.
- **Existing spec without --append**: Always confirm before overwriting.

## References

- [references/spec-schema.md](../../../references/spec-schema.md)
- [references/drift-types.md](../../../references/drift-types.md)
- [templates/drift-protocol.yaml](../../../templates/drift-protocol.yaml)
