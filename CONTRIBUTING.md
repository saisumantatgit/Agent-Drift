# Contributing to Agent-Drift

## Adding Drift Types

Drift types are defined in `references/drift-types.md` and detected by the `drift-detector` agent.

To add a new drift type:

1. Define it in `references/drift-types.md` with: name, default severity, definition, examples, detection strategy
2. Add detection logic to `.claude/agents/drift-detector.md` (classification section)
3. Add scoring for the new type in the drift-analysis skill
4. Update `templates/drift-protocol.yaml` to include the new type in severity overrides
5. Update `references/spec-schema.md` if the type requires new spec fields

## Adding CLI Adapters

1. Create a directory in `adapters/<your-cli>/`
2. Wrap the prompts from `prompts/` in your CLI's native configuration format
3. Update `install.sh` to detect your CLI and install the adapter
4. Add an entry to the Platform Support table in `README.md`

### Adapter checklist:
- [ ] All 5 commands represented (drift-lock, drift-check, drift-fence, drift-status, drift-report)
- [ ] References to drift types and spec schema included
- [ ] Installation instructions in the adapter
- [ ] Detection logic added to `install.sh`

## Modifying Severity Levels

Severity levels are used throughout the system. To modify:

1. Update `references/drift-types.md` with new defaults
2. Update the scoring weights in `templates/drift-protocol.yaml`
3. Update the drift-analysis skill's scoring section
4. Update the drift-detector agent's severity assignment logic
5. Update the compliance-auditor agent's scoring computation

**Important:** Changing severity levels affects drift scores across all projects using Agent-Drift. Consider adding severity overrides to `drift-protocol.yaml` instead of changing defaults.

## Adding Spec Fields

To add new fields to the spec schema:

1. Define the field in `references/spec-schema.md`
2. Add extraction logic to the `spec-extractor` agent
3. Add parsing logic to the `intent-capture` skill
4. Add analysis logic to the `drift-analysis` skill and `drift-detector` agent
5. Update `templates/drift-protocol.yaml` if the field is configurable

## Testing Changes

Since Agent-Drift is a prompt-based plugin (no runtime code), testing is manual:

1. Install the plugin in a test project
2. Run `/drift-lock` with sample instructions
3. Verify the spec is correctly parsed
4. Make changes that should trigger each drift type
5. Run `/drift-check` and verify detection
6. Add a constraint with `/drift-fence` and verify enforcement
7. Run `/drift-report` and verify the verdict

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes following the conventions above
4. Commit with a descriptive message (`git commit -m "Add: description of change"`)
5. Push to your fork (`git push origin feature/your-feature`)
6. Open a Pull Request against `main`

Pull requests should include:
- Description of what changed and why
- Any testing you performed
- Reference to related issues (if applicable)
