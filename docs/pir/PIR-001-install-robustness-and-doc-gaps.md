# PIR-001: Install Robustness and Documentation Gaps

## Metadata

| Field | Value |
|-------|-------|
| **PIR ID** | PIR-001 |
| **Date** | 2026-03-20 |
| **Severity** | P3 |
| **Status** | Final |
| **Incident date** | 2026-03-18 |
| **Detection date** | 2026-03-19 |
| **Resolution date** | 2026-03-20 |

## Zone Check

| Dimension | Status | Notes |
|-----------|--------|-------|
| **Severity** | P3 | Product functions correctly; install UX and docs affected |
| **Containment** | Contained | All issues identified and remediated in same release cycle |
| **Blast Radius** | install.sh, adapters/, docs | No runtime behavior affected |

## 1. Summary

Agent-Drift's install.sh had multiple robustness issues: silent overwrites, non-idempotent Codex/Aider appends that duplicate content on re-run, undocumented severity override in the REQUIREMENT_DRIFT template, and command duplication between `.claude/commands/` and `adapters/` with adapter versions being thinner. All issues were caught during v2 code review before any user impact. Remediation applied across install script, templates, agents, and documentation.

## 2. Timeline

| Time | Event | Actor |
|------|-------|-------|
| 2026-03-18 | install.sh written with minimal overwrite/idempotency logic | Developer |
| 2026-03-19 | v2 test plan caught overwrite issue; code review caught remaining issues | Code review |
| 2026-03-20 | All remediations applied and verified | Developer |

## 3. Five Whys

1. **Why?** -- install.sh overwrites without warning and appends duplicate content on re-run.
2. **Why?** -- No idempotency guards or overwrite prompts were implemented.
3. **Why?** -- Build velocity prioritized shipping; installer was treated as minimal scaffolding.
4. **Why?** -- v2 test plan scope caught overwrite but not the duplication or doc gaps.
5. **Why?** -> **ROOT CAUSE:** install.sh was treated as "write once" throwaway rather than maintained infrastructure. No install-test-reinstall cycle existed.

## 4. Blast Radius

| Radius | Affected | How |
|--------|----------|-----|
| Direct | install.sh | Silent overwrites, duplicated appends on re-run |
| Adjacent | REQUIREMENT_DRIFT template, adapters/ | Severity override contradicts priority-aware defaults; adapter commands thinner than .claude/commands/ versions |
| Downstream | Users re-running install | Duplicated configuration in Codex/Aider setups |
| Potential (if undetected) | User trust in install reliability | Repeated installs silently corrupt config; undocumented severity behavior confuses users |

## 5. Prompt Forensics

### Triggering input
```
./install.sh   # run twice in succession
```

### Expected vs actual
- Expected: Second run is a no-op or prompts before overwriting; Codex/Aider config appended once.
- Actual: Files silently overwritten; Codex/Aider append blocks duplicated. REQUIREMENT_DRIFT template overrides severity without explaining why.

## 6. What Went Well

- Code review caught all five issues before any user encountered them.
- Product runtime behavior was never affected -- all issues confined to install/docs layer.
- Issues were enumerable and independently fixable.

## 7. What Went Wrong

- install.sh lacked overwrite warnings and idempotency guards.
- Codex/Aider adapters used raw appends with no duplicate-content checks.
- REQUIREMENT_DRIFT template hardcodes a severity override that contradicts the priority-aware default behavior, with no documentation explaining the design intent.
- `.claude/commands/` and `adapters/` contained duplicated commands; adapter versions were thinner (missing logic present in the command versions).

## 8. Where We Got Lucky

- No users ran install.sh twice before the fix shipped. Had this reached production installs, debugging duplicated Codex config would have been non-obvious.
- The severity override in REQUIREMENT_DRIFT did not cause misclassification in testing because test cases happened to use priorities that aligned with the override.

## 9. Remediation

### Immediate fix
- Added overwrite confirmation prompts to install.sh.
- Added idempotency guards (grep-before-append) for Codex/Aider configuration blocks.

### Permanent fix
- Documented REQUIREMENT_DRIFT severity override design intent and when it activates.
- Added resolution-matching step in drift agents to reconcile severity with priority-aware defaults.
- Synchronized commands between `.claude/commands/` and `adapters/` -- adapter versions now match command versions.
- Documented drift-report side effect behavior.

### Detection improvement
- Install-reinstall cycle added to test plan for all products with install.sh.
- Template review checklist now includes "verify overrides are documented."

## 10. Action Items

| # | Action | Priority | Owner | Due | Status |
|---|--------|----------|-------|-----|--------|
| 1 | Add overwrite warnings to install.sh | P3 | Dev | 2026-03-20 | Done |
| 2 | Add idempotency guards for Codex/Aider appends | P3 | Dev | 2026-03-20 | Done |
| 3 | Document REQUIREMENT_DRIFT severity override | P3 | Dev | 2026-03-20 | Done |
| 4 | Add resolution-matching step in drift agents | P3 | Dev | 2026-03-20 | Done |
| 5 | Sync .claude/commands/ with adapters/ | P3 | Dev | 2026-03-20 | Done |
| 6 | Document drift-report side effect | P3 | Dev | 2026-03-20 | Done |
| 7 | Add install-reinstall test to all product test plans | P3 | Dev | Next release | Open |

## 11. Lessons Learned

- **Installers are infrastructure, not scaffolding.** Any script users run more than once needs idempotency guards. Treat install.sh with the same rigor as runtime code.
- **Template overrides need inline rationale.** When a template hardcodes behavior that contradicts configurable defaults, the "why" must be documented in the template itself -- not just in the developer's memory.
- **Command duplication across directories is a maintenance trap.** A single canonical source with thin wrappers prevents drift between command versions -- ironically, the exact problem Agent-Drift is designed to detect.
