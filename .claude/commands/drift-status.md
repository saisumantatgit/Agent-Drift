---
name: drift-status
description: Quick status dashboard — drift score, completion percentage, active alerts, constraint compliance. Reads cached state only (no re-analysis).
arguments:
  - name: --format
    description: "Display format: brief or detailed"
    required: false
  - name: --requirements-only
    description: Show only requirement statuses
    required: false
  - name: --alerts-only
    description: Show only unresolved alerts
    required: false
---

Invoke the `status-dashboard` skill with the provided arguments.

If no drift state exists, guide the user to `/drift-lock` and `/drift-check`.

Pass all arguments through to the skill:
- `--format` if provided (default: brief)
- `--requirements-only` flag if provided
- `--alerts-only` flag if provided

After the skill completes:
- Display the dashboard
- If data is stale (>20 turns since last check), suggest: "Run `/drift-check` for fresh analysis."
