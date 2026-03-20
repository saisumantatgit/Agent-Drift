<!-- Canonical source: .claude/commands/drift-check.md -->
---
name: drift-check
description: Analyze current work against the locked spec. Per-requirement status, constraint compliance, out-of-scope detection, drift scoring.
arguments:
  - name: --since
    description: Only analyze changes since a specific conversation turn
    required: false
  - name: --focus
    description: Focus on specific requirements or constraints (comma-separated IDs)
    required: false
  - name: --verbose
    description: Show detailed evidence for each finding
    required: false
---

Invoke the `drift-analysis` skill with the provided arguments.

If no spec exists (`.drift/spec.yaml` not found), tell the user: "No drift spec found. Use `/drift-lock` to create one first."

Pass all arguments through to the skill:
- `--since` turn number if provided
- `--focus` IDs if provided
- `--verbose` flag if provided

After the skill completes:
- Present the drift score and alert level
- Show requirement statuses and constraint compliance
- List any drift findings with recommended actions
- If score is RED (>50), emphasize: "Major drift detected. Consider course correction before continuing."
