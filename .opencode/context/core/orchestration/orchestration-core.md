# Orchestration Core

**Version**: 1.0
**Created**: 2026-01-19
**Purpose**: Essential orchestration patterns for delegation, session tracking, and routing
**Consolidates**: orchestrator.md, delegation.md (partial), routing.md (partial), sessions.md (partial)

---

## Overview

This document defines the core orchestration patterns for Logos/Theory's command-skill-agent architecture:

- **Session Tracking**: Unique identifiers for delegation chains
- **Delegation Safety**: Depth limits, cycle detection, timeouts
- **Return Format**: Standardized JSON structure for all agent returns
- **Routing**: Command to agent mapping and language-based routing

---

## Session Tracking

### Session ID Format

```
sess_{timestamp}_{random_6char}
Example: sess_1735460684_a1b2c3
```

**Generation** (portable, works on Linux/macOS):
```bash
session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
```

**Lifecycle**:
1. Generated at CHECKPOINT 1 (GATE IN) before delegation
2. Passed through delegation to skill/agent
3. Returned by agent in metadata for validation
4. Included in git commits for correlation

### Session Registry

Active delegations tracked in memory:

```json
{
  "sess_1735460684_a1b2c3": {
    "session_id": "sess_1735460684_a1b2c3",
    "command": "implement",
    "agent": "general-implementation-agent",
    "task_number": 191,
    "language": "meta",
    "start_time": "2026-01-19T10:00:00Z",
    "timeout": 3600,
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "general-implementation-agent"]
  }
}
```

---

## Delegation Safety

### Depth Limits

**Maximum delegation depth**: 3 levels

```
Level 0: User -> Orchestrator (not counted)
Level 1: Orchestrator -> Command -> Skill
Level 2: Skill -> Agent
Level 3: Agent -> Utility (rare)
Level 4+: BLOCKED
```

**Enforcement**: Check depth before delegating:
```bash
if [ "$delegation_depth" -ge 3 ]; then
  echo "Error: Max delegation depth exceeded"
  exit 1
fi
```

### Cycle Detection

Before delegating, verify target is not already in delegation path:

```python
def check_cycle(delegation_path, target):
    if target in delegation_path:
        raise CycleError(f"Cycle detected: {delegation_path} -> {target}")
```

### Timeout Configuration

| Command | Default Timeout | Max Timeout |
|---------|----------------|-------------|
| /research | 3600s (1 hour) | 7200s (2 hours) |
| /plan | 1800s (30 min) | 3600s (1 hour) |
| /implement | 7200s (2 hours) | 14400s (4 hours) |
| /revise | 1800s (30 min) | 3600s (1 hour) |

**Timeout Handling**:
- Return partial results if available
- Mark task as [PARTIAL] not failed
- Provide actionable recovery message

---

## Return Format

All agents MUST return this standardized JSON structure:

```json
{
  "status": "implemented|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "research|plan|implementation|summary",
      "path": "relative/path/from/root",
      "summary": "One-sentence description"
    }
  ],
  "metadata": {
    "session_id": "sess_{timestamp}_{random}",
    "duration_seconds": 123,
    "agent_type": "agent_name",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "command", "agent"]
  },
  "errors": [
    {
      "type": "timeout|validation|execution",
      "message": "Human-readable description",
      "recoverable": true,
      "recommendation": "Suggested fix"
    }
  ],
  "next_steps": "Recommended next actions"
}
```

### Status Values

| Status | Meaning | Artifacts |
|--------|---------|-----------|
| `implemented` | Work finished successfully | Required |
| `partial` | Some work completed | Optional |
| `failed` | No usable results | Empty |
| `blocked` | Cannot proceed | Empty |

**CRITICAL**: Never use "completed" or "done" as status values - use contextual terms like "implemented", "researched", "planned".

---

## Delegation Context

Every delegation MUST include this context:

```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "command", "agent"],
  "timeout": 3600,
  "task_context": {
    "task_number": 191,
    "language": "meta",
    "description": "Task description"
  }
}
```

---

## Routing

### Command -> Agent Mapping

| Command | Language-Based | Agent(s) |
|---------|---------------|----------|
| /research | Yes | lean4: lean-research-agent, extensions: {lang}-research-agent, formal/logic/math/physics: formal-research-agent, default: general-research-agent |
| /plan | No | planner-agent |
| /implement | Yes | lean4: lean-implementation-agent, extensions: {lang}-implementation-agent, default: general-implementation-agent |
| /revise | No | planner-agent |
| /review | No | reviewer-agent |
| /meta | No | meta-builder-agent |

### Language Extraction

Priority order for extracting task language:

1. **specs/state.json** (fast, ~12ms):
   ```bash
   language=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber)) | .language // "general"' \
     specs/state.json)
   ```

2. **specs/TODO.md** (fallback, ~100ms):
   ```bash
   language=$(grep -A 20 "^### ${task_number}\." specs/TODO.md | grep "Language" | sed 's/.*: //')
   ```

3. **Default**: "general"

### Routing Validation

Validate language/agent compatibility before delegation:

```bash
# Core language routing validation
if [ "$language" == "lean4" ] && [[ ! "$agent" =~ ^lean- ]]; then
  echo "Error: Lean task must route to lean-* agent"
  exit 1
fi

# Extension language routing validation (includes neovim, z3, nix, etc.)
for lang_agent in "neovim:neovim-" "z3:z3-" "nix:nix-" "python:python-" "latex:latex-" "typst:typst-" "web:web-" "epidemiology:epidemiology-"; do
  lang="${lang_agent%%:*}"
  prefix="${lang_agent##*:}"
  if [ "$language" == "$lang" ] && [[ ! "$agent" =~ ^${prefix} ]]; then
    echo "Error: ${lang} task must route to ${prefix}* agent"
    exit 1
  fi
done

# Formal extension: logic, math, physics all map to formal-*-agent or their own *-agent
if [[ "$language" =~ ^(formal|logic|math|physics)$ ]] && [[ ! "$agent" =~ ^(formal|logic|math|physics)- ]]; then
  echo "Error: ${language} task must route to ${language}-* or formal-* agent"
  exit 1
fi
```

---

## Quick Reference

### Preflight Checklist
- [ ] Parse task number from arguments
- [ ] Validate task exists in specs/state.json
- [ ] Extract language for routing
- [ ] Generate session_id
- [ ] Prepare delegation context
- [ ] Update status to in-progress via skill-status-sync

### Postflight Checklist
- [ ] Validate return is valid JSON
- [ ] Check required fields present
- [ ] Verify session_id matches
- [ ] Validate artifacts exist (if status=implemented)
- [ ] Update status and link artifacts
- [ ] Create git commit

---

## Extension Registration

When adding a new language extension to the system, follow these steps to ensure proper routing:

### Step 1: Create Extension Directory Structure

```
.opencode/extensions/{language}/
  manifest.json           # Extension metadata and merge targets
  index-entries.json      # Context entries for main index
  EXTENSION.md            # Extension documentation for OPENCODE.md
  agents/
    {language}-research-agent.md
    {language}-implementation-agent.md
  skills/
    skill-{language}-research/SKILL.md
    skill-{language}-implementation/SKILL.md
  context/project/{language}/
    README.md
    domain/               # Language-specific domain knowledge
    patterns/             # Common patterns
    standards/            # Style guides and conventions
    tools/                # Tool documentation
```

### Step 2: Run Index Merge Utility

Merge extension context entries into the main index:

```bash
# Preview changes
.opencode/scripts/merge-extensions.sh --dry-run

# Verify completeness (returns exit 1 if missing entries)
.opencode/scripts/merge-extensions.sh --verify

# Manual merge: Copy entries from extension's index-entries.json
# to .opencode/context/index.json
```

### Step 3: Update Command Routing Tables

Add language routing in `/research` and `/implement` commands:

1. **research.md Step 6**: Add skill routing entry
   ```markdown
   | {language} | skill-{language}-research |
   ```

2. **research.md Step 7a-verify**: Add agent verification entry
   ```markdown
   | {language} | `{language}-research-agent` |
   ```

3. **implement.md Step 5**: Add skill routing entry
   ```markdown
   | {language} | skill-{language}-implementation |
   ```

4. **implement.md Step 7a-verify**: Add agent verification entry
   ```markdown
   | {language} | `{language}-implementation-agent` |
   ```

### Step 4: Add Routing Validation

Update `orchestration-core.md` Routing Validation section:

```bash
# Add to extension validation loop
for lang_agent in "...:...-" "{language}:{language}-"; do
```

### Step 5: Verify Extension

1. Create a test task with the new language
2. Run `/research N` and verify correct skill/agent is invoked
3. Run `/implement N` and verify correct skill/agent is invoked
4. Check `.return-meta.json` contains expected `agent_type`

### Extension Manifest Schema

```json
{
  "name": "{language}",
  "version": "1.0.0",
  "description": "Extension description",
  "language": "{language}",
  "dependencies": [],
  "provides": {
    "agents": ["{language}-research-agent.md", "{language}-implementation-agent.md"],
    "skills": ["skill-{language}-research", "skill-{language}-implementation"],
    "commands": [],
    "rules": [],
    "context": ["project/{language}"],
    "scripts": [],
    "hooks": []
  },
  "merge_targets": {
    "opencode_md": {
      "source": "EXTENSION.md",
      "target": ".opencode/OPENCODE.md",
      "section_id": "extension_oc_{language}"
    },
    "index": {
      "source": "index-entries.json",
      "target": ".opencode/context/index.json"
    }
  },
  "mcp_servers": {}
}
```

---

## Related Documentation

- `orchestration-validation.md` - Return validation details
- `preflight-pattern.md` - Preflight execution steps
- `postflight-pattern.md` - Postflight execution steps
- `state-management.md` - Task state and status markers
- `architecture.md` - Three-layer delegation architecture
