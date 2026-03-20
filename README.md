# Agent-Drift

> **"Not on my watch."**
> Continuous drift detection and correction for AI agent workflows.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Commands](https://img.shields.io/badge/Commands-5-orange.svg)](#commands)
[![Platforms](https://img.shields.io/badge/Platforms-5-purple.svg)](#platform-support)

---

## The Problem

You asked for a REST API. You got a GraphQL server with a message queue, a Docker setup you never mentioned, and authentication middleware you explicitly said not to build. The agent did 60% of the work and said it was done. Three of your five requirements were silently dropped. You find out when you test, not when the agent tells you.

**This is agent drift.** And it happens in nearly every non-trivial AI coding session.

The data backs this up:
- **46% of developers** distrust AI-generated code accuracy ([GitHub Survey 2024](https://github.blog/news-insights/research/))
- AI-assisted projects see **1.7x more issues** opened post-merge ([GitClear 2024](https://www.gitclear.com/))
- Agents fail **~70% of real-world tasks** in SWE-bench evaluations ([Princeton NLP 2024](https://www.swebench.com/))
- **9 out of 10 developers** who use AI coding tools have experienced the agent building something different from what was asked

The root cause is simple: **instructions are volatile**. They exist in the conversation, not in a contract. There is no mechanism to track whether requirements were met, constraints were respected, or the scope stayed within bounds. The agent has no persistent memory of what it was told to do vs what it actually did.

---

## Without vs. With Agent-Drift

### What Happens WITHOUT Agent-Drift

| Behavior | Result |
|----------|--------|
| "Please follow my instructions" | Hope-based compliance. No enforcement. |
| No way to track dropped requirements | You discover missing features in testing |
| Constraints forgotten by turn 30 | "Do NOT add auth" violated 40 turns later |
| Agent adds features you never asked for | Scope creeps silently while core work stalls |
| Claims "done" when 3 of 5 requirements are missing | You trust it until you check |
| Next session starts from scratch | No institutional memory of what was promised |

### What Happens WITH Agent-Drift

| Behavior | Result |
|----------|--------|
| **Structured spec** locked with `/drift-lock` | Instructions become a contract, not a request |
| **Per-requirement tracking** with completion % | Every requirement has a status and evidence |
| **Constraints enforced** with `/drift-fence` | Mid-session rules that are immutable and escalate on repeat violations |
| **Scope boundaries** defined in spec | Out-of-scope work is flagged immediately |
| **Completion verification** against code evidence | "Done" is verified against actual files, not just agent claims |
| **Configurable protocol** persists across sessions | `drift-protocol.yaml` carries your standards forward |

### The Analogy

| Domain | Without Tool | With Tool |
|--------|-------------|-----------|
| Testing | "Please write tests" | **Jest/Pytest** — runs them, reports coverage, blocks on failure |
| Linting | "Please format nicely" | **ESLint/Prettier** — enforces rules, auto-fixes, CI gate |
| Evidence | "Please cite sources" | **Agent-Cite** — scans, names violations, blocks on uncited inference |
| **Drift** | **"Please follow instructions"** | **Agent-Drift** — locks spec, tracks requirements, detects deviation, reports compliance |

**Without Agent-Drift, instructions are requests. With it, instructions are contracts.**

---

## The 8 Drift Types

Every deviation is classified into one of 8 types. These aren't theoretical categories — they are things developers experience in every long AI session.

| Drift Type | Severity | What It Catches | The Developer Experience |
|------------|----------|----------------|-------------------------|
| **REQUIREMENT_DRIFT** | error | Built differently than asked | "I asked for REST. I got GraphQL." |
| **SCOPE_CREEP** | warning | Work outside the spec | "Why is there a Docker config? I asked for an API." |
| **CONSTRAINT_VIOLATION** | varies | Explicit rule broken | "I said do NOT modify the schema. There's an ALTER TABLE." |
| **TECHNOLOGY_SWAP** | error | Locked technology replaced | "I said FastAPI. This is Flask." |
| **PRIORITY_INVERSION** | warning | Optional items before required | "The search feature works great. The CRUD endpoints don't exist." |
| **SILENT_DROP** | critical | Requirement abandoned without notice | "Where's pagination? It was in the spec. The agent never mentioned dropping it." |
| **GOLD_PLATING** | info | Unnecessary extras beyond spec | "Who asked for a caching layer? I needed the endpoints first." |
| **COMPLETION_HALLUCINATION** | critical | Claims "done" but evidence says otherwise | "It said all 5 endpoints are done. There are 3 files." |

---

## Commands

| Command | When | What It Does |
|---------|------|-------------|
| **`/drift-lock`** | Session start | Parse instructions into structured spec with requirements, constraints, scope |
| **`/drift-check`** | Mid-session | Analyze work against spec, compute drift score, flag deviations |
| **`/drift-fence`** | When needed | Add an enforceable constraint mid-session (immutable, escalating) |
| **`/drift-status`** | Quick glance | Lightweight status dashboard from cached state |
| **`/drift-report`** | Session end | Full compliance report with verdict and recommendations |

### Examples

```bash
# Lock instructions into a spec
/drift-lock "Build a REST API in Python with FastAPI. Include user CRUD, 
pagination, and search. Do NOT modify the database schema. Do NOT add auth."

# Check for drift mid-session
/drift-check

# Check specific requirements only
/drift-check --focus REQ-001,REQ-003

# Add a constraint mid-session
/drift-fence "Do NOT add Docker configuration — that's a separate task"

# Add a constraint and check existing work retroactively
/drift-fence "Only use standard library for HTTP" --retroactive

# Quick status
/drift-status

# Detailed status
/drift-status --format detailed

# End-of-session report
/drift-report

# Save the report
/drift-report --include-timeline --save
```

---

## How It Works

```
Developer gives instructions
       |
       v
/drift-lock parses into structured spec
  - Requirements (MUST / SHOULD / MAY)
  - Constraints (negative / boundary / style / technology)
  - Technology locks
  - Scope boundaries (in / out)
       |
       v
  .drift/spec.yaml (source of truth)
       |
       v
Agent works on the task...
       |
       v
Auto-check hook fires (every N turns)
  — or —
Developer runs /drift-check manually
       |
       v
Drift Detector analyzes:
  - Per-requirement status (NOT_STARTED → COMPLETE)
  - Constraint compliance (COMPLIANT / VIOLATED)
  - Out-of-scope work detection
  - Technology lock verification
       |
       v
Drift found?
  |           |
  NO          YES
  |           |
  v           v
GREEN       Classify by 8 drift types
score       Assign severity
            Compute drift score (0-100)
            Alert developer
       |
       v
Developer adds constraints with /drift-fence
  (immutable, tracked, escalating)
       |
       v
Session ends → /drift-report
  - Per-requirement delivery with evidence
  - Constraint compliance timeline
  - Drift score with resolution credits
  - Verdict: FULL_COMPLIANCE / PARTIAL_COMPLIANCE / NON_COMPLIANT
  - Recommendations
```

---

## When to Use Agent-Drift

### Use When:

- **Long sessions** (20+ turns) where context fades
- **Complex multi-file tasks** with multiple requirements
- **Specific technology requirements** that must not be substituted
- **Explicit constraints** ("do NOT" rules)
- **Multiple requirements** where some might be dropped
- **Team settings** where accountability matters
- **Session handoffs** where the next session needs to know what was promised

### Do NOT Use When:

- Quick one-off questions ("what does this function do?")
- Simple formatting or refactoring
- Exploratory brainstorming
- Single-file edits with no constraints
- Tasks with no specific requirements

**The rule:** If you have instructions you'd be upset to see ignored, lock them.

---

## Installation

```bash
# Clone
git clone https://github.com/saisumantatgit/Agent-Drift.git

# Install into your project (auto-detects your CLI)
cd your-project/
bash /path/to/Agent-Drift/install.sh
```

Or for Claude Code, install as a plugin:

```bash
cp -r Agent-Drift/ ~/.claude/plugins/agent-drift/
```

### What Gets Installed

| CLI Tool | What Gets Installed |
|----------|-------------------|
| **Claude Code** | `.claude/commands/*.md` + agents + skills + hook |
| **Codex** | Appends to `AGENTS.md` |
| **Cursor** | `.cursor/rules/drift.md` |
| **Aider** | Appends to `.aider.conf.yml` |
| **Generic** | Raw prompt files |

Plus: `drift-protocol.yaml` (configurable rules) and reference docs.

---

## Quick Start

```bash
# 1. Install
cd your-project/
bash /path/to/Agent-Drift/install.sh

# 2. Lock your instructions
/drift-lock "Build a REST API in Python with FastAPI. Include user CRUD,
pagination, and search. Do NOT modify the database schema."

# 3. Let the agent work...
# (Agent-Drift monitors automatically)

# 4. Check for drift (manual or auto)
/drift-check

# 5. Add a constraint mid-session
/drift-fence "Do NOT add authentication — that's a separate task"

# 6. Quick glance at status
/drift-status

# 7. End-of-session report
/drift-report
```

---

## Configuration

Create or customize `drift-protocol.yaml` in your project root (a template is installed automatically):

```yaml
# Severity overrides
severities:
  REQUIREMENT_DRIFT: error
  SCOPE_CREEP: warning
  CONSTRAINT_VIOLATION: error
  TECHNOLOGY_SWAP: error
  PRIORITY_INVERSION: warning
  SILENT_DROP: critical
  GOLD_PLATING: info
  COMPLETION_HALLUCINATION: critical

# Monitoring
monitoring:
  auto_check: true
  check_interval: 10        # turns between auto-checks
  alert_threshold: 25       # score that triggers alert
  interrupt_threshold: 50   # score that interrupts the agent

# Scoring
scoring:
  critical: 25
  error: 10
  warning: 3
  info: 1
  resolution_credit: 0.60   # 60% back for resolved findings

# Verdict thresholds
verdicts:
  full_compliance: 10
  partial_compliance: 40

# Watch/ignore paths
watch_paths:
  - "src/**"
  - "lib/**"
  - "tests/**"

ignore_paths:
  - "node_modules/**"
  - ".git/**"
  - ".drift/**"
```

---

## Platform Support

| Platform | Config | Notes |
|----------|--------|-------|
| Claude Code | `.claude-plugin/plugin.json` | Full support (agents + commands + skills + hooks) |
| Codex | `AGENTS.md` | Prompt-based |
| Cursor | `.cursor/rules/drift.md` | Rules-based |
| Aider | `.aider.conf.yml` | Config-based |
| Generic | `prompts/*.md` | Paste into any LLM |

---

## Part of the Agent Suite

| Tool | What It Does | Tagline |
|------|-------------|---------|
| [**Agent-PROVE**](https://github.com/saisumantatgit/Agent-PROVE) | Makes agents think before they act | "Prove it or it fails." |
| [**Agent-Trace**](https://github.com/saisumantatgit/Agent-Trace) | Makes agents see before they edit | "See the ripple effect before it happens." |
| [**Agent-Scribe**](https://github.com/saisumantatgit/Agent-Scribe) | Makes agents remember what they learned | "Nothing is lost." |
| [**Agent-Cite**](https://github.com/saisumantatgit/Agent-Cite) | Makes agents prove what they claim | "Cite it or it's opinion." |
| **Agent-Drift** | Makes agents follow what they were told | "Not on my watch." |

PROVE validates your thinking. Trace maps your blast radius. Scribe records your decisions. Cite enforces your evidence. **Drift enforces your instructions.** Together: think rigorously, edit safely, remember everything, prove every claim, follow every instruction.

---

## Origin

Built from research across 40+ sources on AI agent drift — the #1 pain point in agentic workflows. The drift taxonomy, severity model, and spec-locking approach emerged from analyzing how agents fail in production developer workflows. The 8 drift types map to the 8 most common ways agents deviate: they build the wrong thing, they build extra things, they break rules, they swap technologies, they do optional work first, they silently drop requirements, they over-engineer, and they claim completion when the evidence says otherwise.

Every drift type in Agent-Drift was observed in real sessions. Every severity level reflects real impact. The goal is not to punish agents — it is to make "follow my instructions" enforceable.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Adding drift types
- Adding CLI adapters
- Modifying severity levels
- Extending the spec schema

---

## License

[MIT](LICENSE)
