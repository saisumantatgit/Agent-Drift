---
name: drift-report
description: Generate end-of-session compliance report. Per-requirement delivery status with evidence, constraint timeline, drift score with resolution credits, and FULL_COMPLIANCE / PARTIAL_COMPLIANCE / NON_COMPLIANT verdict.
arguments:
  - name: --format
    description: "Report format: summary, detailed, or json"
    required: false
  - name: --include-timeline
    description: Include full drift event timeline
    required: false
  - name: --include-diff
    description: Include file diffs for each requirement
    required: false
  - name: --save
    description: Save report to .drift/reports/
    required: false
---

Invoke the `session-audit` skill with the provided arguments.

Note: If a spec exists but no checks have been run, this command will automatically trigger a drift-analysis before generating the report.

If no drift data exists, inform the user that no spec was locked or no checks were run.

Pass all arguments through to the skill:
- `--format` if provided (default: detailed)
- `--include-timeline` flag if provided
- `--include-diff` flag if provided
- `--save` flag if provided

After the skill completes:
- Present the verdict prominently
- Show requirement delivery rates
- Show constraint compliance summary
- Present recommendations for the next session
- If `--save` was used, confirm the file path
