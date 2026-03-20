---
name: drift-check
description: Analyze current work against the locked spec
arguments:
  - name: --since
    description: Analyze changes since a specific turn
    required: false
  - name: --focus
    description: Focus on specific requirement/constraint IDs
    required: false
  - name: --verbose
    description: Show detailed evidence
    required: false
---

Invoke the `drift-analysis` skill with the provided arguments.

If no spec exists, direct to /drift-lock. After completion, present drift score, statuses, and findings.
