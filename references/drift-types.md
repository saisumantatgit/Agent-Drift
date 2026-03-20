# Drift Types Reference

Agent-Drift classifies all deviations into 8 drift types. Each type has a default severity, specific triggers, and detection strategy.

## 1. REQUIREMENT_DRIFT

**Default severity:** error (MUST), warning (SHOULD), info (MAY)

**Definition:** A requirement is delivered differently than specified. The agent built something, but it doesn't match what was asked.

**Examples:**
- Asked for a REST API, got a GraphQL server
- Asked for pagination with cursor-based navigation, got offset-only pagination
- Asked for PostgreSQL, got SQLite "for now"

**Detection:** Compare the requirement text against what was actually built. Check file contents, function signatures, API endpoints, and configuration against the spec.

**Why it matters:** The most common drift type. The agent "understood" the requirement but reinterpreted it — often substituting what's easier to build for what was asked.

---

## 2. SCOPE_CREEP

**Default severity:** warning (escalates to error if extensive)

**Definition:** Work was done on items not in the specification. The agent added features, files, or functionality beyond what was asked.

**Examples:**
- Added Docker configuration when only the API was requested
- Built an admin dashboard when only CRUD endpoints were asked for
- Added logging infrastructure when not in scope
- Created a CI/CD pipeline unprompted

**Detection:** List all files created/modified. Map each to a requirement. Flag files that don't map to any in-scope item.

**Why it matters:** Scope creep wastes time, adds complexity, and can introduce bugs in areas the developer didn't ask to touch. It also delays the actual requirements.

---

## 3. CONSTRAINT_VIOLATION

**Default severity:** Inherits from the constraint's own severity (critical/error/warning)

**Definition:** An explicit constraint (negative, boundary, style, or technology) was violated. The agent did something it was specifically told not to do.

**Examples:**
- "Do NOT modify the database schema" — agent adds ALTER TABLE statements
- "Do NOT add authentication" — agent creates auth middleware
- "Only use standard library" — agent adds third-party dependencies
- "Follow existing naming conventions" — agent uses different naming style

**Detection:** For each constraint, search for patterns that would constitute a violation. Use Grep across the codebase and check conversation history.

**Why it matters:** Constraints exist because the developer knows something the agent doesn't. Violating a constraint can break existing systems, create merge conflicts, or trigger cascading issues.

---

## 4. TECHNOLOGY_SWAP

**Default severity:** error

**Definition:** A locked technology was replaced with a different one. The agent substituted the developer's explicit technology choice.

**Examples:**
- Locked FastAPI, agent used Flask "because it's simpler"
- Locked PostgreSQL, agent used SQLite "for development"
- Locked Jest, agent used Vitest "because it's faster"
- Locked CSS Modules, agent used Tailwind

**Detection:** Check technology locks against actual imports, dependencies, and configuration files. Look at package.json, requirements.txt, go.mod, etc.

**Why it matters:** Technology choices are rarely arbitrary. They reflect team standards, existing infrastructure, deployment constraints, and licensing requirements. An agent that swaps technologies creates integration nightmares.

---

## 5. PRIORITY_INVERSION

**Default severity:** warning

**Definition:** Lower-priority items were completed before higher-priority items. SHOULD/MAY requirements are done while MUST requirements are incomplete or dropped.

**Examples:**
- Added "nice to have" search feature (MAY) before completing core CRUD endpoints (MUST)
- Built pagination (SHOULD) before the endpoints that need it (MUST)
- Added comprehensive error handling (SHOULD) but didn't finish the main feature (MUST)

**Detection:** Check completion status of all requirements. If any SHOULD/MAY is COMPLETE while a MUST is NOT_STARTED or IN_PROGRESS, flag as PRIORITY_INVERSION.

**Why it matters:** MUST requirements define the core task. Completing optional items first means the session might end with nice extras but a broken core. It's the "painted the trim but didn't build the walls" problem.

---

## 6. SILENT_DROP

**Default severity:** critical (MUST), error (SHOULD), warning (MAY)

**Definition:** A requirement was silently abandoned. The agent stopped working on it without notifying the developer or explaining why.

**Examples:**
- Five requirements in the spec, agent delivers four and says "done" — never mentions the fifth
- Agent starts implementing search, hits a complexity barrier, moves on to other things, never mentions the issue
- Agent encounters a conflict between requirements, resolves it by dropping one without asking

**Detection:** Check for requirements where:
- Status was IN_PROGRESS in a previous check but is now NOT_STARTED or unchanged
- Agent's conversation statements claim completion but the requirement has no evidence
- All other requirements are addressed but this one is never mentioned

**Why it matters:** Silent drops are the most dangerous drift type because the developer doesn't know it happened. They believe the task is complete. The missing requirement is discovered later — in testing, in production, or in a user complaint.

---

## 7. GOLD_PLATING

**Default severity:** info (escalates to warning if it delays MUST items)

**Definition:** Unnecessary features, complexity, or polish added beyond what the spec requires. The agent over-engineers or adds things the developer didn't ask for.

**Examples:**
- Added comprehensive input validation on every field when only basic validation was requested
- Built a caching layer with Redis when the spec said nothing about caching
- Added WebSocket support to a simple REST API
- Created a plugin architecture for a one-off script

**Detection:** Identify features, files, or code complexity that goes beyond any requirement in the spec. Check if additional complexity maps to a requirement — if not, it's gold plating.

**Why it matters:** Gold plating seems helpful but it adds maintenance burden, increases the attack surface, makes the code harder to understand, and most importantly — it takes time away from the actual requirements. A perfectly polished 3 of 5 features is worse than a working 5 of 5.

---

## 8. COMPLETION_HALLUCINATION

**Default severity:** critical

**Definition:** The agent claims work is complete, but evidence shows otherwise. The agent says "done" when it isn't.

**Examples:**
- "All 5 endpoints are implemented" — but only 3 files exist
- "Tests are passing" — but no test files were created
- "Database migration is complete" — but no migration file exists
- "I've added error handling to all endpoints" — but only 1 of 4 has try/catch

**Detection:** When the agent states completion, verify against actual file evidence:
- Count files/functions that should exist
- Check if claimed features are actually present in the code
- Verify test files exist and contain test cases
- Cross-reference agent's claims with file system reality

**Why it matters:** This is the most damaging drift type. The developer trusts the agent's claim and moves on. The missing work is discovered downstream — in code review, testing, or production. It erodes trust in AI agents entirely.

---

## Severity Summary

| Drift Type | Default Severity | Escalation Trigger |
|------------|-----------------|-------------------|
| REQUIREMENT_DRIFT | error/warning/info (by priority) | N/A |
| SCOPE_CREEP | warning | Extensive out-of-scope work |
| CONSTRAINT_VIOLATION | Inherits from constraint | Repeat violation |
| TECHNOLOGY_SWAP | error | N/A |
| PRIORITY_INVERSION | warning | MUST items at risk |
| SILENT_DROP | critical/error/warning (by priority) | N/A |
| GOLD_PLATING | info | Delays MUST items |
| COMPLETION_HALLUCINATION | critical | N/A |

## Scoring

| Severity | Points |
|----------|--------|
| critical | 25 |
| error | 10 |
| warning | 3 |
| info | 1 |

Resolved findings get 60% of their points credited back.
