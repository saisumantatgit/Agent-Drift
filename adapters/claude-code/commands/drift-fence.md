<!-- Canonical source: .claude/commands/drift-fence.md -->
---
name: drift-fence
description: Add an enforceable constraint mid-session. Constraints are immutable once added, checked on every drift-check, with severity escalation on repeat violations.
arguments:
  - name: constraint
    description: The constraint text (e.g., "Do NOT add authentication")
    required: true
  - name: --type
    description: "Constraint type: negative, boundary, style, technology"
    required: false
  - name: --severity
    description: "Severity level: critical, error, warning"
    required: false
  - name: --retroactive
    description: Immediately scan existing work for violations of this constraint
    required: false
---

Invoke the `constraint-enforcement` skill with the provided arguments.

If no spec exists (`.drift/spec.yaml` not found), tell the user: "No drift spec found. Use `/drift-lock` first, then add constraints with `/drift-fence`."

Pass all arguments through to the skill:
- The constraint text as CONSTRAINT
- `--type` if provided
- `--severity` if provided
- `--retroactive` flag if provided

After the skill completes:
- Confirm the constraint was added with its assigned ID
- Show the constraint type and severity
- If retroactive scan found violations, present them
- Remind: "This constraint will be enforced on every `/drift-check`."
