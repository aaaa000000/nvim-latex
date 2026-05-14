# Research Report: Task #135 - Comparative Analysis

**Task**: OC_135 - enforce_workflow_command_delegation_to_prevent_direct_implementation  
**Date**: 2026-03-05  
**Language**: meta  
**Focus**: Compare .claude/ agent system with .opencode/, investigate command routing best practices

---

## Summary

This research compares the .claude/ and .opencode/ agent systems to understand why .claude/ commands work correctly while .opencode/ commands suffer from direct execution instead of proper skill routing. The key difference is **explicit delegation via Skill tool invocation** in .claude/ versus **ambiguous step-by-step instructions** in .opencode/. Best practices from industry sources confirm that orchestrators should never execute, command specifications should clearly indicate delegation targets, and router patterns with proper interception layers are essential for reliable multi-agent systems.

---

## Findings

### 1. System Comparison: .claude/ vs .opencode/

#### Architecture Differences

| Aspect | .claude/ (Works Correctly) | .opencode/ (Has Issues) |
|--------|---------------------------|-------------------------|
| **Command Specification** | High-level orchestration with explicit Skill tool calls | Detailed step-by-step implementation instructions |
| **Skill Invocation** | `Skill(skill-planner)` with structured args | Implicit delegation pattern |
| **Delegation Clarity** | "Invoke the Skill tool NOW" - explicit | "Steps 1-9" - looks like instructions to execute |
| **Postflight Pattern** | Skill handles all postflight internally | Skill is thin wrapper, unclear responsibility |
| **Marker Files** | `.postflight-pending` prevents premature termination | No marker file pattern |
| **Internal Postflight** | Skill manages status, artifacts, commits before return | Skill only validates, unclear postflight timing |

#### .claude/plan.md - Correct Pattern

The .claude/ command uses a **3-checkpoint execution model**:

```markdown
## Execution

### CHECKPOINT 1: GATE IN
1. Generate Session ID
2. Lookup Task
3. Validate
4. Load Context

**On GATE IN success**: Task validated. **IMMEDIATELY CONTINUE** to STAGE 2.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Invoke the Skill tool NOW** with:
```
skill: "skill-planner"
args: "task_number={N} research_path={path} session_id={session_id}"
```
```

Key features:
- Explicit "Invoke the Skill tool NOW" instruction
- Clear separation: orchestrator validates, skill implements
- Skill handles all postflight internally (status, artifacts, commits)
- Returns brief summary only after full completion

#### .opencode/plan.md - Problematic Pattern

The .opencode/ command uses a **step-by-step implementation model**:

```markdown
## Steps

### 1. Look up task
Strip `OC_` prefix, find task in `specs/state.json`...

### 2. Validate status
- `researched`, `not_started`, `partial`: proceed
- `planning`: warn "already planning, proceeding"

### 3. Display task header
...

### 6. Create implementation plan
Decompose the task into phases...

### 7. Update status to PLANNED
...

### 8. Commit changes
...
```

Key issues:
- Steps look like instructions to execute directly
- No explicit "Use Skill tool" directive
- Main agent interprets this as implementation guide
- Skill is mentioned as thin wrapper, but delegation is implicit

### 2. .claude/skill-planner/SKILL.md - Robust Delegation

The .claude/ skill has an **11-stage execution flow**:

```markdown
## Execution Flow

### Stage 1: Input Validation
### Stage 2: Preflight Status Update
### Stage 3: Create Postflight Marker
### Stage 4: Prepare Delegation Context
### Stage 5: Invoke Subagent (CRITICAL: Use Task tool)
### Stage 6: Parse Subagent Return
### Stage 7: Update Task Status (Postflight)
### Stage 8: Link Artifacts
### Stage 9: Git Commit
### Stage 10: Cleanup
### Stage 11: Return Brief Summary
```

**Key patterns**:
1. **Postflight marker file** (`.postflight-pending`) prevents premature termination
2. **Skill-internal postflight** handles all cleanup before returning to orchestrator
3. **Explicit Task tool usage**: "You MUST use the **Task** tool to spawn the subagent"
4. **Metadata file exchange**: Subagent writes `.return-meta.json`, skill reads it
5. **Atomic operations**: Status updates, artifact linking, and commits happen within skill

### 3. .opencode/skill-planner/SKILL.md - Thin Wrapper

The .opencode/ skill has a **4-stage execution flow**:

```markdown
## Execution Flow

1. **Load Context**
2. **Preflight**
3. **Delegate**
4. **Postflight**
```

**Critical differences**:
1. No postflight marker file pattern
2. No mention of skill-internal postflight handling
3. Delegation description is vague: "Call `Task` tool with `subagent_type`"
4. Postflight is listed as a stage but implementation unclear
5. No explicit cleanup or metadata file handling

### 4. Best Practices from Industry Research

#### Pattern 1: Orchestrator-Worker Separation (Mikhail Rogov, 2026)

> "The orchestrator must never execute. Not mostly delegate. Never. It decomposes, delegates, validates, and escalates. It does not write code. That boundary held across every provider, every agent topology, and every failure mode we hit — and it is the single rule that separates systems that scale from systems that collapse."

**Application to our problem**:
- The .claude/ command is a proper orchestrator: it validates and delegates
- The .opencode/ command looks like a worker implementation guide
- Need to make .opencode/ commands clear orchestrators, not implementers

#### Pattern 2: Router Agent Pattern (AI Skill Market, 2026)

Router agents should:
- Examine input and decide where to send it
- Work with defined paths (bounded choice)
- Use explicit options, not invented routes
- Be the single entry point for command routing

**Application to our problem**:
- Need explicit router layer at prompt entry point
- Router should intercept `/command N` patterns
- Router validates and delegates, never executes

#### Pattern 3: Command as Routing Signal (LangChain Command, 2024)

LangGraph's `Command` type allows nodes to specify:
- State updates (as usual)
- Which node to go to next (dynamic routing)

This creates "edgeless graphs" where routing logic lives in the nodes themselves.

**Application to our problem**:
- Commands should be pure routing signals
- No implementation logic in command specifications
- Dynamic routing based on command type + task state

#### Pattern 4: Skill-First Architecture (Claude Code Docs)

Claude Code's approach:
> "Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit. Claude uses skills when relevant, or you can invoke one directly with `/skill-name`."

> "Custom commands have been merged into skills. A file at `.claude/commands/review.md` and a skill at `.claude/skills/review/SKILL.md` both create `/review` and work the same way."

**Application to our problem**:
- Commands and skills should converge
- Commands should be thin routing specifications
- Skills contain all implementation logic
- Subagents handle the actual work

### 5. Root Cause Analysis

**Why .claude/ works:**
1. Command spec explicitly says "Invoke the Skill tool NOW"
2. Skill has comprehensive 11-stage flow with internal postflight
3. Postflight marker prevents premature termination
4. Clear separation: orchestrator validates, skill delegates, agent implements
5. No ambiguity - every layer has clear responsibilities

**Why .opencode/ fails:**
1. Command spec looks like implementation instructions (Steps 1-9)
2. Skill is thin wrapper without clear postflight ownership
3. No marker file pattern
4. Ambiguity about who handles status updates and commits
5. Main agent sees spec and implements directly instead of delegating

### 6. Key Insight: The Interception Gap

The missing layer is not just a router - it's **explicit delegation signaling**:

**Current broken flow:**
```
User: "/plan 135"
  ↓
Main Agent reads .opencode/commands/plan.md
  ↓
Sees Steps 1-9 (looks like implementation guide)
  ↓
Executes all steps directly
  ↓
Status [PLANNED] but actually implemented
```

**Required working flow:**
```
User: "/plan 135"
  ↓
Command Router detects /plan pattern
  ↓
Validates task 135
  ↓
Explicitly invokes Skill(skill-planner, args)
  ↓
Skill-planner handles preflight, delegates to planner-agent
  ↓
planner-agent creates plan
  ↓
Skill-planner handles postflight, returns to router
  ↓
Router returns result to user
```

---

## Recommendations

### 1. Redesign Command Specifications

**Change .opencode/ commands from step-by-step instructions to routing specifications:**

```markdown
---
description: Create implementation plan for a task
description: Create a phased implementation plan for a task
---

Route to skill-planner for implementation plan creation.

**Command Pattern**: `/plan <OC_N> [notes]`

**Routing**:
- Target: skill-planner
- Subagent: planner-agent
- Context: fork

**Validation**:
- Task exists in state.json
- Status allows planning: researched, not_started, partial

**Skill Arguments**:
- task_number: {N}
- notes: {optional notes}

**DO NOT** implement directly. Always delegate via Skill tool.
```

### 2. Implement Command Router Layer

Create `.opencode/agent/command-router.md`:

```markdown
# Command Router Agent

Intercepts workflow commands and routes to appropriate skills.

## Detection Pattern
```regex
/^\/(research|plan|implement|revise)\s+(\d+)/
```

## Routing Table
| Command | Skill | Subagent |
|---------|-------|----------|
| /research | skill-researcher | general-research-agent |
| /plan | skill-planner | planner-agent |
| /implement | skill-implementer | general-implementation-agent |
| /revise | skill-planner | planner-agent |

## Execution
1. Parse command and extract task number
2. Validate task exists and status allows operation
3. Invoke Skill tool with routing target
4. Return skill result to user

## Permissions
- read: allow
- task: allow (for Skill tool)
- write/edit/bash: deny (skills handle implementation)
```

### 3. Enhance Skills with Internal Postflight

**Update skill-planner and other skills to match .claude/ pattern:**

1. Add postflight marker file creation (`.postflight-pending`)
2. Implement 11-stage execution flow
3. Handle all status updates internally
4. Link artifacts before returning
5. Create commit before returning
6. Clean up marker files
7. Return only brief summary

### 4. Add Explicit Delegation Directives

**In all command specifications, add:**

```markdown
## Execution Rule

**CRITICAL**: This command MUST be handled by skill delegation.

**DO NOT**:
- Execute steps directly
- Modify files yourself
- Run git commands yourself
- Update state.json or TODO.md yourself

**DO**:
- Validate inputs
- Invoke Skill tool with proper arguments
- Return skill result to user
```

### 5. Implement Context Fork Enforcement

**Ensure all skills use `context: fork`:**

```yaml
---
name: skill-planner
context: fork
agent: planner-agent
---
```

This creates true isolation between main agent and subagent.

---

## Risks & Considerations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Router bypass via creative prompts | High | Implement router at entry point with priority enforcement |
| Breaking existing command behavior | High | Gradual migration; test thoroughly before rollout |
| Skill postflight complexity | Medium | Reuse .claude/ patterns; they're proven |
| Task number format ambiguity | Low | Normalize both "135" and "OC_135" to integer |
| Command router failure | High | Fallback to main agent with clear error message |
| Context size increase | Low | Router is small; skills/subagents handle heavy lifting |

---

## Implementation Approach

### Phase 1: Command Specification Updates (1-2 hours)
- Redesign all workflow commands to be routing specifications
- Remove step-by-step instructions
- Add explicit delegation directives

### Phase 2: Skill Enhancement (2-3 hours)
- Add postflight marker pattern to all skills
- Implement internal postflight handling
- Add explicit Task tool invocation requirements

### Phase 3: Command Router (2-3 hours)
- Create command-router agent
- Implement detection and routing logic
- Add validation layer

### Phase 4: Integration (1-2 hours)
- Connect router to prompt entry point
- Test all workflow commands
- Verify proper delegation chains

### Total Effort: 6-10 hours (aligned with existing plan)

---

## Next Steps

1. **Revise existing implementation plan** to incorporate findings:
   - Emphasize command specification redesign
   - Add explicit delegation directives
   - Include skill postflight pattern adoption

2. **Run `/revise OC_135`** to update implementation plan with comparative insights

3. **Priority order**:
   - First: Update command specifications (biggest impact)
   - Second: Enhance skills with postflight pattern
   - Third: Implement command router layer
   - Fourth: Integration and testing

---

## References

### Internal Files Compared
- `.claude/commands/plan.md` vs `.opencode/commands/plan.md`
- `.claude/skills/skill-planner/SKILL.md` vs `.opencode/skills/skill-planner/SKILL.md`
- `.claude/agents/planner-agent.md`

### External Research
- "Why Your AI Orchestrator Should Never Write Code" - Mikhail Rogov (2026)
- "Level 2 Agents: Router Pattern Deep Dive" - AI Skill Market (2026)
- "Router-Based Agents: The Architecture Pattern That Makes AI Systems Scale" - Towards AI (2025)
- "Claude Code Skills: Complete Guide" - ClaudeWorld (2026)
- "Command: A new tool for building multi-agent architectures in LangGraph" - LangChain (2024)
- "Spring AI Agentic Patterns (Part 4): Subagent Orchestration" - Spring.io (2026)

---

**Research Status**: [COMPLETED]  
**Next Action**: `/revise OC_135` to incorporate findings into implementation plan
