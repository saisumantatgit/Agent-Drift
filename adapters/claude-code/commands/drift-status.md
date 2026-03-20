---
name: drift-status
description: Quick drift status dashboard
arguments:
  - name: --format
    description: "Display: brief or detailed"
    required: false
  - name: --requirements-only
    description: Show only requirements
    required: false
  - name: --alerts-only
    description: Show only alerts
    required: false
---

Invoke the `status-dashboard` skill with the provided arguments.

If no state exists, guide to /drift-lock and /drift-check.
