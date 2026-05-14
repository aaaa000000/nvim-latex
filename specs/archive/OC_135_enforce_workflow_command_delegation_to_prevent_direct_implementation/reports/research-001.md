# Research Report: Task #135

**Task**: OC_135 - Enforce workflow command delegation to prevent direct implementation  
**Date**: 2026-03-05  
**Language**: meta  
**Focus**: Command routing architecture and delegation enforcement mechanisms

---

## Summary

The root cause of workflow commands being executed directly instead of routed through the skill system is a **missing command interception layer**. While the system has a well-designed three-layer architecture (Commands → Skills → Agents) with proper delegation patterns, there is no mechanism to intercept slash commands (`/plan`, `/research`, `/implement`) and force them through the skill routing path. The current orchestrator is read-only and doesn't handle command routing. The solution requires creating a command router/orchestrator that intercepts workflow commands, validates them, and delegates to the appropriate skill with `context: fork`, preventing the main agent from directly executing command specifications.

---

## Findings

### 1. System Architecture is Correctly Designed

The `.opencode/` system has a proper three-layer architecture:

```
Commands (/.opencode/commands/*.md)
    ↓
Skills (/.opencode/skills/skill-*/SKILL.md)  
    ↓
Agents (/.opencode/agent/subagents/*.md)
```

**Skills are correctly designed** as thin wrappers with:
- `context: fork` for isolated subagent execution
- Preflight/Delegate/Postflight stages
- Task tool delegation to subagents
- Status management and artifact linking

Example from `skill-planner/SKILL.md`:
```yaml
context: fork
agent: planner-agent
```

This creates the proper delegation chain:
1. **Preflight**: Validate task, display header, update status
2. **Delegate**: Task tool → planner-agent (forked context)
3. **Postflight**: Update state, link artifacts

### 2. The Gap: No Command Interception Mechanism

**Current orchestrator** (`agent/orchestrator.md`):
- **Read-only assistant** with write/edit/bash/task permissions denied
- Cannot modify files, run commands, or delegate tasks
- Only answers questions about the repository
- Tools limited to: Read, Glob, Grep

**Missing layer**: There is no component that:
- Detects when user types `/plan 134`, `/research 135`, etc.
- Intercepts the command before it reaches the main agent
- Routes to appropriate skill with proper delegation
- Prevents main agent from executing command steps directly

**Current broken flow**:
```
User: "/plan 134"
  ↓
Main Agent receives prompt directly
  ↓
Agent reads .opencode/commands/plan.md specification  
  ↓
Agent executes all steps (1-9) including implementation
  ↓
Status [PLANNED] but actually fully implemented
```

**Expected working flow**:
```
User: "/plan 134"
  ↓
Command Router detects /plan pattern
  ↓
Validates task 134 exists
  ↓
Routes to skill-planner with delegation context
  ↓
skill-planner Preflight: validation, status → [PLANNING]
  ↓
skill-planner Delegate: Task tool → planner-agent (fork)
  ↓
planner-agent creates plan document ONLY
  ↓
skill-planner Postflight: update state → [PLANNED]
  ↓
User reviews plan, then runs "/implement 134"
```

### 3. Existing Routing Infrastructure is Incomplete

**skill-orchestrator/SKILL.md** exists but:
- Only routes based on task language and status
- Doesn't intercept slash commands from user input
- Returns structured routing results, not actual delegation
- Not integrated into the command execution path

**Routing documentation** (`context/core/orchestration/routing.md`):
- Defines command → agent mapping
- Specifies language-based routing
- Has routing validation logic
- **But**: No enforcement mechanism to prevent direct execution

The routing guide states (line 336): "**DO NOT** update specs/TODO.md or specs/state.json directly. Always delegate to status-sync-manager." But there's no technical enforcement of this rule.

### 4. Command Specifications Are Ambiguous

All workflow command specs say "Do NOT implement anything":
- `plan.md` line 5: "Create an implementation plan for the given task. Do NOT implement anything."
- `research.md` line 5: "Research the given task and write a research report. Do NOT implement anything."

But they also contain detailed implementation steps (Steps 1-9) that look like instructions to execute. This creates confusion where the AI agent treats them as direct execution instructions rather than delegation specifications.

### 5. The Real Solution: Command Router Layer

To properly enforce delegation, the system needs:

**A. Command Detection Pattern Matching**
```
/^\/(research|plan|implement|revise)\s+(\d+)/
```

**B. Router/Interceptor Implementation**
Options:
1. **Hook-based**: `.opencode/settings.json` hooks for UserPromptSubmit
2. **Middleware layer**: New agent/orchestrator that handles commands  
3. **Skill integration**: Extend skill-orchestrator to intercept commands

**C. Enforcement Mechanism**
- Router must have higher priority than main agent
- Must validate commands before delegation
- Must prevent main agent from seeing raw command specs
- Must handle error cases (invalid task numbers, wrong status)

### 6. Recommended Architecture

```
User Input
    ↓
Command Parser (detects /^\/\w+ \d+/)
    ↓
Command Router
    ├─ /plan → skill-planner → planner-agent
    ├─ /research → skill-researcher → general-research-agent  
    ├─ /implement → skill-implementer → general-implementation-agent
    └─ /task, /todo → Handle directly (no delegation needed)
    ↓
Result returned to user
```

The router should be:
- A primary agent (not read-only)
- Have Task tool permission for delegation
- Parse command specifications for validation rules
- Maintain the session/delegation chain

---

## Recommendations

### 1. Create Command Router Agent (Primary Solution)

**New file**: `.opencode/agent/command-router.md`

**Responsibilities**:
- Parse user input for workflow command patterns
- Validate command arguments (task number exists, correct status)
- Route to appropriate skill with delegation context
- Return routing confirmation to user
- Prevent command specifications from reaching main agent

**Tools needed**:
- Read (parse command specs, check task existence)
- Task (delegate to skills)
- Glob/Grep (pattern matching)

**Permissions**:
- read: allow
- task: allow
- write/edit/bash: deny (skills handle implementation)

### 2. Update Command Specifications

Modify all workflow command files to:
- Remove ambiguous "Steps" that look like execution instructions
- Keep only validation rules and delegation targets
- Add explicit "This command is handled by skill-{name}" note

### 3. Extend skill-orchestrator (Alternative)

Modify existing `skill-orchestrator/SKILL.md` to:
- Accept command string as input
- Parse for workflow patterns
- Route to appropriate skill
- Return "Routing to skill-{name} for task {N}..."

### 4. Validation-First Approach

Before any routing:
1. Validate task number exists in specs/state.json
2. Validate task status allows the operation
3. Validate task language for routing decisions
4. Only then delegate to skill

---

## Risks & Considerations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Router bypassed by clever prompts | High | Ensure router has priority in prompt processing chain |
| Skills not properly isolated | Medium | Verify `context: fork` creates true isolation |
| Command validation too strict | Low | Allow overrides with `--force` flag |
| Breaking existing non-workflow commands | High | Only intercept /^\/\w+ \d+/ patterns |
| Router failure blocks all commands | High | Fallback to main agent with warning |
| Task number ambiguity (OC_135 vs 135) | Low | Normalize both forms to task ID |

---

## Next Steps

Run `/plan OC_135` to create an implementation plan that:
1. Designs the Command Router agent architecture
2. Defines command parsing and validation logic
3. Specifies routing table (command → skill mapping)
4. Implements enforcement mechanism to prevent direct execution
5. Updates command specifications to remove ambiguous steps

---

## Appendix: Technical References

### Key Files
- `.opencode/agent/orchestrator.md` - Current read-only orchestrator
- `.opencode/skills/skill-orchestrator/SKILL.md` - Existing routing skill
- `.opencode/skills/skill-planner/SKILL.md` - Proper skill with fork delegation
- `.opencode/context/core/orchestration/routing.md` - Routing patterns and validation
- `.opencode/context/core/orchestration/orchestration-core.md` - Session/delegation standards
- `.opencode/commands/plan.md` - Example workflow command specification
- `.opencode/agent/subagents/planner-agent.md` - Subagent that should receive delegation

### Command Patterns to Route
```regex
/^\/(research|plan|implement|revise)\s+(\d+)/
```

### Skills to Route To
| Command | Skill | Subagent |
|---------|-------|----------|
| /research | skill-researcher | general-research-agent |
| /plan | skill-planner | planner-agent |
| /implement | skill-implementer | general-implementation-agent |
| /revise | skill-planner | planner-agent (for re-planning) |
