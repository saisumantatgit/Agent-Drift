---
name: drift-report
description: End-of-session compliance report
arguments:
  - name: --format
    description: "Format: summary, detailed, json"
    required: false
  - name: --include-timeline
    description: Include drift event timeline
    required: false
  - name: --include-diff
    description: Include file diffs
    required: false
  - name: --save
    description: Save report to .drift/reports/
    required: false
---

Invoke the `session-audit` skill with the provided arguments.

After completion, present the verdict, delivery rates, and recommendations.
