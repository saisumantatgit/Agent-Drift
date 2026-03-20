# ADR-002: Five Commands, Not Three — Drift Operates on Six Axes

**Status:** Accepted
**Date:** 2026-03-20
**Context:** Scoping Agent-Drift's command set. Initial proposal was 3 commands (start, check, report). Research proved this insufficient.

## Decision

Agent-Drift ships 5 commands (`/drift-lock`, `/drift-check`, `/drift-fence`, `/drift-status`, `/drift-report`) because drift operates across 6 axes that 3 commands cannot cover.

## The Six Axes

| Axis | What 3 Commands Miss | Required Capability |
|------|---------------------|-------------------|
| Positive requirements | Partially covered by baseline | Numbered requirement tracking with MUST/SHOULD/MAY priority |
| Negative constraints | NOT captured by a baseline | Dedicated "DO NOT" registry (`/drift-fence`) |
| Scope boundaries | NOT captured | Explicit in-scope/out-of-scope definition |
| Structural/style anchoring | NOT captured | Pattern and convention locking |
| Automated monitoring | Manual-only checking | Hook-based periodic checks |
| Granular requirement tracking | Prose baselines lose items | Structured spec with per-item status |

## Context

The initial proposal mirrored Agent-Cite's 3-command pattern (audit, fix, report). A product architecture analysis mapped 10 real-world drift scenarios against the 3-command set and found:

- "Don't modify the database schema" → **Not captured** (negative constraints need a separate mechanism)
- "After turn 30 it forgot my constraints" → **Not caught** (manual checking = too late)
- "It added authentication I never asked for" → **Not detected** (scope boundaries aren't requirements)

## The Five Commands

| Command | Why It Exists | What 3 Commands Would Miss |
|---------|-------------|---------------------------|
| `/drift-lock` | Captures intent as structured spec (requirements + constraints + scope + tech + style) | A prose "baseline" loses individual items and can't distinguish requirements from constraints |
| `/drift-check` | Compares current state against spec | This existed in the 3-command proposal — kept |
| `/drift-fence` | Adds constraints MID-SESSION ("DO NOT touch the schema") | 3-command model has no way to add constraints after the initial lock |
| `/drift-status` | Quick dashboard — completion %, alerts, drift score | 3-command model forces a full re-analysis just to check "where are we?" |
| `/drift-report` | End-of-session comprehensive report | This existed in the 3-command proposal — kept and enhanced |

## Alternatives Considered

### Option A: 3 commands (start, check, report)
**Rejected.** Covers temporal comparison only. Misses negative constraints, scope boundaries, mid-session fences, and lightweight status checks. The product architect's analysis was definitive: 10 user stories, 6 axes, 3 commands can't cover them.

### Option B: 5 commands (current design)
**Accepted.** Each command serves a distinct purpose that cannot be folded into another without losing functionality.

### Option C: 7+ commands (add /drift-style, /drift-scope, etc.)
**Rejected.** Over-segmentation. Style anchoring and scope boundaries are captured in `/drift-lock` and enforced in `/drift-check`. Separate commands for each would fragment the user experience.

## Evidence

Research backing this decision:
- 10 real-world drift scenarios mapped against commands (product architecture analysis)
- 12 drift types identified across developer complaints (Stack Overflow, Reddit, HN)
- 46% of developers distrust AI accuracy (Stack Overflow 2025)
- Agent-Drift's design exceeds Agent-Cite's substance (5 vs 3 commands, 8 vs 6 violation types, 4 vs 3 agents)

## Consequences

**Good:**
- Every documented drift scenario maps to at least one command
- `/drift-fence` is the unique differentiator — no other tool does mid-session constraint addition
- The structured spec (`/drift-lock`) is the foundation that makes everything else possible

**Bad:**
- 5 commands is a higher learning curve than 3
- More commands = more skill files, more agents, more maintenance
- The product is the largest in the suite (40 files)

**How to apply:** When proposing changes to Drift's command set, map the change against the 6 axes and 10 user stories. If a new command doesn't cover an axis that existing commands miss, it shouldn't exist. If an existing command can be folded into another without losing an axis, fold it.
