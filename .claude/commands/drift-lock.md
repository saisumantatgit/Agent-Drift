---
name: drift-lock
description: Lock instructions into a structured drift spec — requirements, constraints, technology locks, scope boundaries. The spec becomes the ground truth for all drift detection.
arguments:
  - name: instructions
    description: Natural language instructions, a file path, or --from-conversation
    required: false
  - name: --from-conversation
    description: Extract spec from conversation history instead of explicit text
    required: false
  - name: --append
    description: Add to existing spec instead of creating a new one
    required: false
  - name: --interactive
    description: Walk through each category interactively
    required: false
---

Invoke the `intent-capture` skill with the provided arguments.

If no instructions were given and `--from-conversation` was not specified, ask the user: "What instructions should I lock? Provide text, a file path, or use `--from-conversation` to extract from our chat so far."

Pass all arguments through to the skill:
- The instructions text, file path, or `--from-conversation` flag as INSTRUCTIONS
- `--append` flag if provided
- `--interactive` flag if provided

After the skill completes:
- Confirm the spec was written to `.drift/spec.yaml`
- Show the summary of locked requirements, constraints, and scope
- Remind the user: "Use `/drift-check` to verify compliance. Use `/drift-fence` to add constraints mid-session."
