# Research Report: Task #159

**Task**: 159 - Require planner agent for /plan command and similar workflow commands  
**Started**: 2026-03-06T03:50:00Z  
**Completed**: 2026-03-06T04:00:00Z  
**Effort**: 1 hour  
**Dependencies**: None  
**Sources/Inputs**: 
- `.opencode/commands/plan.md` - Plan command specification
- `.opencode/commands/research.md` - Research command specification  
- `.opencode/commands/implement.md` - Implement command specification
- `.opencode/skills/skill-planner/SKILL.md` - Planner skill definition
- `.opencode/skills/skill-researcher/SKILL.md` - Researcher skill definition
- `.opencode/skills/skill-implementer/SKILL.md` - Implementer skill definition
- `.opencode/agent/subagents/planner-agent.md` - Planner agent specification
- `.opencode/agent/subagents/general-research-agent.md` - Research agent specification
- `.opencode/agent/subagents/general-implementation-agent.md` - Implementation agent specification
- `.opencode/context/index.md` - Context discovery index
**Artifacts**: specs/OC_159_require_planner_agent_for_plan_command/reports/research-001.md (this file)  
**Standards**: report-format.md, status-markers.md  

---

## Executive Summary

**Root Cause Identified**: The workflow commands (/plan, /research, /implement) are not properly delegating to their specialized agents. While the commands specify calling the skill tool, the skill tool only loads skill definitions but does NOT automatically execute the delegation to subagents via the Task tool.

**Key Finding**: Commands must explicitly call the Task tool with `subagent_type="planner-agent"`, `subagent_type="general-research-agent"`, or `subagent_type="general-implementation-agent"` after loading skill context. The skill's `agent:` frontmatter field is documentation only and does not trigger automatic delegation.

**Recommendation**: Update all three command files to explicitly invoke the Task tool with the correct subagent type, passing the skill-injected context as part of the prompt.

---

## Context & Scope

This research investigates why the /plan command uses the general agent instead of the planner agent, and ensures other workflow commands (/research, /implement) properly route to their respective specialized agents.

**Scope**:
- Analyze command-to-skill delegation pattern
- Examine skill-to-agent delegation mechanism
- Identify the gap causing general agent usage instead of specialized agents
- Document the correct delegation pattern

---

## Findings

### 1. Current Command Structure

All three workflow commands follow a similar pattern:

**From plan.md lines 73-84**:
```markdown
**Call skill tool** to load skill context and delegate to planning agent:

```
→ Tool: skill
→ Name: skill-planner
→ Prompt: Create implementation plan for task {N} with language {language} and research context from {research_content}
```

The skill-planner will:
1. Load context files (plan-format.md, status-markers.md, task-breakdown.md)
2. **Call Task tool with `subagent_type="planner-agent"`** to create the plan
3. Return results (subagent writes .return-meta.json)
```

### 2. Skill Structure Analysis

**From skill-planner/SKILL.md frontmatter**:
```yaml
---
name: skill-planner
description: Create phased implementation plans from research findings. Invoke when a task needs an implementation plan.
allowed-tools: Task, Bash, Edit, Read, Write
context: fork
agent: planner-agent
---
```

The skill file includes:
- `agent: planner-agent` in frontmatter (informational)
- Context injection patterns for plan-format.md, status-markers.md, etc.
- Detailed execution flow documentation

**Critical Note** (line 11): 
> "**WARNING**: This file defines context injection patterns ONLY. Commands must execute status updates themselves — this skill does NOT execute workflows."

### 3. The Delegation Gap

**Current Flow** (problematic):
1. Command calls `skill` tool with `Name: skill-planner`
2. Skill tool loads skill-planner/SKILL.md content into context
3. **MISSING**: Explicit Task tool call with `subagent_type="planner-agent"`
4. Result: Primary agent (general) processes the request instead of specialized agent

**Correct Flow** (required):
1. Command calls `skill` tool with `Name: skill-planner` to load context
2. Command explicitly calls `Task` tool with `subagent_type="planner-agent"`
3. Planner agent receives skill-injected context
4. Planner agent executes and writes .return-meta.json
5. Command reads metadata and executes postflight

### 4. Agent Routing Requirements

**From context/index.md lines 522-555**:
```markdown
**Available Skills** (thin wrapper pattern):
- **skill-implementer** - Execute implementation tasks via general-implementation-agent
  - Path: `.opencode/skills/skill-implementer/SKILL.md`
  - Agent: general-implementation-agent
  - Trigger: /implement command

- **skill-planner** - Create implementation plans via planner-agent
  - Path: `.opencode/skills/skill-planner/SKILL.md`
  - Agent: planner-agent
  - Trigger: /plan command

- **skill-researcher** - Conduct research via researcher-agent
  - Path: `.opencode/skills/skill-researcher/SKILL.md`
  - Agent: researcher-agent
  - Trigger: /research command
```

The index confirms the expected agent mapping:
- /plan → planner-agent
- /research → general-research-agent
- /implement → general-implementation-agent

### 5. Required Agent Specifications

**planner-agent** (from planner-agent.md):
- Mode: subagent
- Temperature: 0.2
- Tools: Read, Write, Edit, Glob, Grep, Bash
- Purpose: Create phased implementation plans

**general-research-agent** (from general-research-agent.md):
- Mode: subagent
- Temperature: 0.3
- Tools: Read, Write, Edit, Glob, Grep, Bash, WebSearch, WebFetch
- Purpose: Research general tasks using web search and codebase exploration

**general-implementation-agent** (from general-implementation-agent.md):
- Mode: subagent  
- Temperature: 0.2
- Tools: Read, Write, Edit, Glob, Grep, Bash
- Purpose: Implement general, meta, and markdown tasks from plans

---

## Decisions

### Decision 1: Command-Level Agent Invocation
**Decision**: Each workflow command must explicitly invoke the Task tool with the correct subagent type after loading skill context.

**Rationale**: 
- The skill tool only loads context definitions
- The `agent:` field in skill frontmatter is informational
- Explicit Task tool invocation is required for actual delegation
- This matches the documented pattern in command files (lines 73-84 of plan.md)

### Decision 2: Context Pass-Through
**Decision**: Skill-loaded context must be passed to the subagent via the Task tool prompt.

**Rationale**:
- Skills use `context: fork` for lazy loading
- Context is injected into the skill's conversation
- Must be explicitly passed to subagent via prompt variables

### Decision 3: No Skill Logic Changes Required
**Decision**: The skill files themselves are correct as documentation/context sources. Only command files need updates.

**Rationale**:
- Skills correctly define context injection patterns
- Skills correctly specify target agents in frontmatter
- The issue is at the command level where delegation should occur

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multiple delegation points cause confusion | Medium | Medium | Document the single correct pattern: skill loads context, command delegates to agent |
| Context not properly passed to subagent | High | Low | Verify context variables are included in Task tool prompt |
| Subagent type mismatch | High | Low | Verify agent names match exactly: planner-agent, general-research-agent, general-implementation-agent |
| Breaking existing workflows | Medium | Low | Test with actual task execution after implementation |

---

## Implementation Approach

### Phase 1: Update plan.md
**Changes Required**:
1. After skill tool call, explicitly call Task tool with `subagent_type="planner-agent"`
2. Pass skill-injected context (plan_format, status_markers, task_breakdown) in prompt
3. Ensure delegation context includes session_id, task_context, metadata

### Phase 2: Update research.md  
**Changes Required**:
1. After skill tool call, explicitly call Task tool with `subagent_type="general-research-agent"`
2. Pass skill-injected context (report_format, status_markers) in prompt
3. Include memory search results if --remember flag was used

### Phase 3: Update implement.md
**Changes Required**:
1. After skill tool call, explicitly call Task tool with `subagent_type="general-implementation-agent"`
2. Pass skill-injected context in prompt
3. Include plan_path for resume capability

### Phase 4: Verification
**Test Cases**:
1. Create test task with /task
2. Run /research and verify "General Task" doesn't appear in output
3. Run /plan and verify "General Task" doesn't appear in output  
4. Run /implement and verify "General Task" doesn't appear in output
5. Verify each command shows correct agent type in output

---

## Appendix: Context Knowledge Candidates

**None identified** - This research is specific to the workflow command routing issue and doesn't reveal domain-general knowledge suitable for context files.

---

## Next Steps

1. **Create Implementation Plan**: Use /plan OC_159 to create detailed implementation phases
2. **Update Commands**: Implement the three-phase approach outlined above
3. **Test**: Verify agent routing works correctly with actual task execution
4. **Document**: Update any relevant documentation with the correct delegation pattern

**Expected Outcome**: After implementation, running /plan OC_N should show "Planning Task" or "Planner Agent" in output instead of "General Task", confirming proper agent routing.
