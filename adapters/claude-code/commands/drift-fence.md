---
name: drift-fence
description: Add an enforceable constraint mid-session
arguments:
  - name: constraint
    description: The constraint text
    required: true
  - name: --type
    description: "Type: negative, boundary, style, technology"
    required: false
  - name: --severity
    description: "Severity: critical, error, warning"
    required: false
  - name: --retroactive
    description: Scan existing work for violations
    required: false
---

Invoke the `constraint-enforcement` skill with the provided arguments.

If no spec exists, direct to /drift-lock. After completion, confirm the constraint was added.
