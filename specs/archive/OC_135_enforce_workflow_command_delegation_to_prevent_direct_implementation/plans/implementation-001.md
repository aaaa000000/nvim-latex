# Implementation Plan: Enforce Workflow Command Delegation to Prevent Direct Implementation

- **Task**: OC_135 - enforce_workflow_command_delegation_to_prevent_direct_implementation
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None
- **Research Inputs**: specs/OC_135_enforce_workflow_command_delegation_to_prevent_direct_implementation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/standards/documentation-standards.md
  - .opencode/context/core/standards/task-management.md
- **Type**: markdown

---

## Overview

This implementation plan addresses the root cause of workflow commands being executed directly by the main agent instead of being routed through the skill system with proper delegation. The issue is a missing command interception layer that should detect slash commands (`/plan`, `/research`, `/implement`, `/revise`) and route them to appropriate skills with `context: fork` delegation.

The solution involves creating a Command Router agent that intercepts workflow commands, validates them, and delegates to the appropriate skill, preventing direct command execution by the main agent.

## Research Integration

**Integrated Research Report**: [research-001.md](../reports/research-001.md)

Key research findings integrated into this plan:
- System architecture is correctly designed (Commands → Skills → Agents)
- Skills already use `context: fork` for proper subagent delegation
- Missing layer: No command interception mechanism
- Command specifications are ambiguous (look like execution instructions)
- Need validation-first approach before routing

## Goals & Non-Goals

### Goals
- Create Command Router agent to intercept workflow commands
- Implement command parsing and validation logic
- Define routing table for command → skill mapping
- Enforce delegation boundaries to prevent direct execution
- Update command specifications to remove ambiguity

### Non-Goals
- Modifying the existing skill architecture (it's already correct)
- Changing the subagent implementations
- Adding new workflow commands
- Modifying the read-only orchestrator
- Breaking existing non-workflow commands

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Router bypassed by clever prompts | Implement router at prompt processing entry point with highest priority |
| Skills not properly isolated | Verify `context: fork` creates true process isolation |
| Breaking existing non-workflow commands | Only intercept `/^\/\w+ \d+/` patterns, pass through all other input |
| Router failure blocks all commands | Implement fallback to main agent with warning message |
| Task number ambiguity (OC_135 vs 135) | Normalize both forms to integer task ID during validation |
| Command validation too strict | Document validation rules clearly; allow `--force` override flag |

## Implementation Phases

### Phase 1: Design Command Router Architecture [NOT STARTED]

**Goal**: Define the command router structure, interfaces, and integration points

**Tasks:**
- [ ] Analyze existing routing infrastructure (skill-orchestrator, routing.md)
- [ ] Define command router agent interface and responsibilities
- [ ] Design command parsing regex patterns
- [ ] Specify validation logic for task existence and status
- [ ] Define routing table: command → skill → subagent mapping
- [ ] Design error handling and fallback mechanisms

**Timing**: 1.5 hours

**Verification**:
- [ ] Architecture document created
- [ ] Routing table defined with all 4 workflow commands
- [ ] Validation rules documented
- [ ] Integration points identified

---

### Phase 2: Create Command Router Agent [NOT STARTED]

**Goal**: Implement the command router agent that intercepts and routes workflow commands

**Tasks:**
- [ ] Create `.opencode/agent/command-router.md` agent definition
- [ ] Define agent permissions (read: allow, task: allow, write/edit/bash: deny)
- [ ] Implement command detection regex: `/^\/(research|plan|implement|revise)\s+(\d+)/`
- [ ] Implement task validation (check state.json for existence and status)
- [ ] Implement routing logic to delegate to appropriate skill
- [ ] Add error handling for invalid commands
- [ ] Add fallback to main agent for non-workflow commands

**Timing**: 2 hours

**Files to modify**:
- `.opencode/agent/command-router.md` (new file)

**Verification**:
- [ ] Agent file created with proper structure
- [ ] Command detection working for all 4 patterns
- [ ] Task validation rejects non-existent tasks
- [ ] Routing delegates to correct skill with fork context
- [ ] Non-workflow commands pass through to main agent

---

### Phase 3: Update Command Specifications [NOT STARTED]

**Goal**: Remove ambiguity from command specifications to prevent direct execution

**Tasks:**
- [ ] Review all workflow command specs (plan.md, research.md, implement.md, revise.md)
- [ ] Remove detailed "Steps" sections that look like execution instructions
- [ ] Add explicit "Delegation Target" section to each command
- [ ] Add warning: "This command is handled by skill-{name} via command router"
- [ ] Keep only: validation rules, routing targets, error handling
- [ ] Update examples to show router delegation pattern

**Timing**: 1.5 hours

**Files to modify**:
- `.opencode/commands/plan.md`
- `.opencode/commands/research.md`
- `.opencode/commands/implement.md`
- `.opencode/commands/revise.md`

**Verification**:
- [ ] All 4 command specs reviewed and updated
- [ ] No ambiguous execution steps remain
- [ ] Each spec has clear delegation target
- [ ] Examples show router → skill → agent flow

---

### Phase 4: Integrate Router with Entry Point [NOT STARTED]

**Goal**: Connect command router to the prompt processing entry point

**Tasks:**
- [ ] Identify where user prompts are first processed
- [ ] Add router invocation before main agent receives prompt
- [ ] Ensure router has priority over main agent
- [ ] Implement router result handling (route vs pass-through)
- [ ] Add logging for routing decisions
- [ ] Test with various command formats

**Timing**: 1.5 hours

**Files to modify**:
- `.opencode/agent/orchestrator.md` (or entry point configuration)
- Integration configuration files

**Verification**:
- [ ] Router invoked before main agent
- [ ] Workflow commands intercepted and routed
- [ ] Non-workflow commands pass through
- [ ] Logging shows routing decisions

---

### Phase 5: Testing & Validation [NOT STARTED]

**Goal**: Comprehensive testing of the command routing system

**Tasks:**
- [ ] Test all 4 workflow commands with valid task numbers
- [ ] Test with invalid/non-existent task numbers
- [ ] Test with wrong status transitions
- [ ] Test non-workflow commands still work
- [ ] Test edge cases: extra spaces, OC_ prefix, multiple commands
- [ ] Verify delegation creates isolated subagent context
- [ ] Test error messages are clear and helpful

**Timing**: 1 hour

**Verification**:
- [ ] All workflow commands route correctly
- [ ] Invalid tasks rejected with clear errors
- [ ] Non-workflow commands unaffected
- [ ] Edge cases handled gracefully
- [ ] Subagent isolation confirmed

---

### Phase 6: Documentation & Rollout [NOT STARTED]

**Goal**: Document the new routing system and update relevant guides

**Tasks:**
- [ ] Document command router in `.opencode/agent/README.md`
- [ ] Update routing.md with new command routing layer
- [ ] Add troubleshooting section for routing issues
- [ ] Create examples of correct vs incorrect flows
- [ ] Update system architecture diagrams

**Timing**: 0.5 hours

**Files to modify**:
- `.opencode/agent/README.md`
- `.opencode/context/core/orchestration/routing.md`
- Architecture documentation

**Verification**:
- [ ] Router documented in agent README
- [ ] Routing guide updated
- [ ] Troubleshooting section added
- [ ] Examples show correct usage

---

## Testing & Validation

### Unit Tests
- [ ] Command regex matches all workflow patterns
- [ ] Task validation correctly identifies existing/non-existing tasks
- [ ] Routing table returns correct skill for each command
- [ ] Error handling returns appropriate messages

### Integration Tests
- [ ] End-to-end: `/plan 135` routes to skill-planner → planner-agent
- [ ] End-to-end: `/research 135` routes to skill-researcher → general-research-agent
- [ ] End-to-end: `/implement 135` routes to skill-implementer → general-implementation-agent
- [ ] End-to-end: `/revise 135` routes to skill-planner → planner-agent

### Manual Testing
- [ ] Run each workflow command on a test task
- [ ] Verify main agent does not execute commands directly
- [ ] Verify skills properly delegate to subagents
- [ ] Verify status transitions work correctly

## Artifacts & Outputs

- `.opencode/agent/command-router.md` - New command router agent
- `.opencode/commands/plan.md` - Updated specification
- `.opencode/commands/research.md` - Updated specification
- `.opencode/commands/implement.md` - Updated specification
- `.opencode/commands/revise.md` - Updated specification
- `.opencode/agent/README.md` - Updated with router documentation
- `.opencode/context/core/orchestration/routing.md` - Updated routing guide

## Rollback/Contingency

If the command router causes issues:
1. Disable router integration at entry point
2. Revert to direct main agent processing
3. Fall back to read-only orchestrator mode
4. Debug router validation logic
5. Re-enable after fixes

**Rollback time**: < 5 minutes by commenting out router invocation

## Dependencies

- None (self-contained within .opencode/ system)

## Total Estimate

**Time**: 8 hours
**Complexity**: High
**Phases**: 6 phases
**Risk Level**: Medium (changes core routing infrastructure)

---

**Created**: 2026-03-05
**Plan Version**: 001
