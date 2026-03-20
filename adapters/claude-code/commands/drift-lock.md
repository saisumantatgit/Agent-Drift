---
name: drift-lock
description: Lock instructions into a structured drift spec
arguments:
  - name: instructions
    description: Natural language instructions, file path, or --from-conversation
    required: false
  - name: --from-conversation
    description: Extract spec from conversation history
    required: false
  - name: --append
    description: Add to existing spec
    required: false
  - name: --interactive
    description: Walk through categories interactively
    required: false
---

Invoke the `intent-capture` skill with the provided arguments.

If no instructions and no --from-conversation flag, ask: "What instructions should I lock? Provide text, a file path, or use --from-conversation."

After completion, confirm the spec was written and show the summary.
