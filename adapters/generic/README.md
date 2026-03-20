# Agent-Drift — Generic Integration

If your AI coding tool is not Claude Code, Codex, Cursor, or Aider, use the raw prompt files directly.

## Setup

1. Copy the `prompts/` directory into your project
2. Copy the `references/` directory into your project
3. Copy `templates/drift-protocol.yaml` to your project root

## Usage

At the start of a session, paste or reference `prompts/drift-lock.md` and provide your instructions.

During the session:
- Reference `prompts/drift-check.md` to check for drift
- Reference `prompts/drift-fence.md` to add constraints
- Reference `prompts/drift-status.md` for a quick status

At session end, reference `prompts/drift-report.md` for a compliance report.

## Reference Material

Include `references/drift-types.md` and `references/spec-schema.md` in your AI tool's context for full drift type definitions and spec schema documentation.

## Configuration

Customize `drift-protocol.yaml` for your project:
- Severity overrides for drift types
- Auto-check intervals
- Scoring weights
- Watch/ignore paths
