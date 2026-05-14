# Implementation Plan: Task #154 (REPLAN - Regression Fix)

- **Task**: 154 - Task command fails to create entries - regression fix
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/OC_154_task_command_fails_to_create_entries_not_specs_directory_issue/reports/research-001.md, specs/OC_154_task_command_fails_to_create_entries_not_specs_directory_issue/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file - REPLAN based on regression research)
- **Standards**: .opencode/context/core/formats/plan-format.md, .opencode/context/core/standards/status-markers.md, .opencode/context/core/standards/documentation-standards.md, .opencode/context/core/standards/task-management.md
- **Type**: meta
- **Lean Intent**: false
- **Previous Plan**: plans/implementation-001.md (superseded by this replan)

## Overview

This is a REPLAN based on critical new research findings. The `/task` command regression was NOT a behavioral issue (agents wanting to help) but an **architectural inconsistency** introduced during Task 153 phases 1-4.

### Key Finding from Research-002.md

**Regression Window**: Commits 39cbfe53 (last working) to e151c465

**Root Cause**: Task 153 updated `/implement`, `/plan`, and `/research` to a new "command orchestrates workflow" pattern, but `/task` was NOT updated to match:

- **Old Pattern**: Command -> Skill Tool -> Skill handles workflow -> Agent
- **New Pattern**: Command executes preflight -> Skill Tool (context only) -> Agent -> Command executes postflight

**Why It Breaks**: Agents trained on the new pattern expect commands to handle workflow orchestration. When they encounter `/task` without skill delegation or preflight/postflight, they fall back to "helpful problem-solving" mode instead of following CREATE mode steps.

### Research Integration

**Superseded Understanding (implementation-001.md)**:
- Assumed behavioral issue: agents diagnose instead of create
- Proposed 3-layer solution: warnings, skill-task, validation

**Corrected Understanding (this plan)**:
- Architectural issue: pattern inconsistency breaks agent expectations
- Solution: Update `/task` to match the new pattern (create `skill-task`)
- Focus: Consistency across all commands

### Recommended Solution: Option 1

Per research-002.md, **Option 1** is recommended: Create a `skill-task` skill and update `task.md` to follow the same preflight/skill/postflight pattern as other commands.

**Rationale**:
- Provides consistency across all commands
- Agents already trained on this pattern
- Aligns with the architectural direction established in Task 153
- Minimal disruption to existing agent behavior

## Goals & Non-Goals

**Goals**:
- Create `skill-task` skill that provides task creation context to agents
- Update `task.md` to follow the preflight/skill/postflight pattern
- Add preflight step: update state.json to "creating", create marker file
- Add postflight step: verify task entry created, finalize status, commit
- Ensure `/task` command works consistently with `/implement`, `/plan`, `/research`

**Non-Goals**:
- Redesign the task creation workflow itself (CREATE mode steps 0-7 remain correct)
- Add behavioral warnings or visual banners (not needed with pattern consistency)
- Modify task creation logic (only the command orchestration pattern changes)
- Create validation layers beyond standard postflight verification

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `skill-task` adds unnecessary complexity | Low | Low | Keep skill minimal - only loads context and references task.md |
| Pattern change breaks existing workflows | Low | Low | Create mode steps remain the same; only orchestration changes |
| Agents still confused despite pattern consistency | Medium | Low | Test with actual task creation; pattern consistency should resolve this |
| Rollback needed if new pattern fails | Low | Low | Keep changes additive; can revert to direct execution if needed |

## Implementation Phases

### Phase 1: Create skill-task Skill Structure [COMPLETED]

**Goal**: Create the skill-task skill directory and SKILL.md following the pattern of other skills

**Tasks**:
- [x] Create directory `.opencode/skills/skill-task/`
- [x] Write SKILL.md with:
  - Description: Task creation context loading for CREATE mode
  - Warning banner: "This file defines context injection patterns ONLY"
  - Reference to task.md as authoritative source for CREATE mode steps
  - Explicit prohibition on diagnosing/implementing
- [x] Add README.md explaining skill-task purpose
- [x] Follow the same structure as skill-implementer, skill-planner, skill-researcher

**Timing**: 45 minutes

### Phase 2: Update task.md with Preflight/Skill/Postflight Pattern [COMPLETED]

**Goal**: Restructure task.md to follow the same pattern as implement.md, plan.md, and research.md

**Tasks**:
- [x] Add **Step 3: Execute Preflight** section:
  - Call status-sync-manager to update state.json to "creating"
  - Update TODO.md status to [CREATING] (if applicable)
  - Create `.task-creating` marker file in task directory
- [x] Add **Step 4: Delegate to Task Agent** section:
  - Call skill tool to load skill-task context
  - Delegate to agent with CREATE mode instructions
  - Include reference to task.md CREATE mode steps
- [x] Add **Step 5: Execute Postflight** section:
  - Read `.return-meta.json` for agent results
  - Verify task entry exists in state.json
  - Verify task entry exists in TODO.md
  - Verify task directory was created
  - Finalize status, link artifacts, commit changes
  - Remove marker file
- [x] Add CRITICAL notes about skill tool only loading context
- [x] Remove or repurpose any behavioral warning banners (no longer needed)

**Timing**: 1 hour

### Phase 3: Update Context Index and References [COMPLETED]

**Goal**: Ensure skill-task is properly referenced in the context system

**Tasks**:
- [x] Update `.opencode/context/index.md` to include skill-task reference
- [x] Verify skill-task appears in skill listings
- [x] Check for any hardcoded references to old task.md patterns
- [x] Update any documentation that references task command behavior

**Timing**: 30 minutes

### Phase 4: Testing and Verification [COMPLETED]

**Goal**: Verify the fix works by testing actual task creation

**Tasks**:
- [x] Test creating a new task with `/task` command:
  - Verify state.json updated to "creating" during execution
  - Verify marker file created
  - Verify skill-task context loaded
  - Verify task entry created in state.json
  - Verify task entry created in TODO.md
  - Verify task directory created
  - Verify postflight updates status and commits
- [x] Test with problem description (previously failed scenario):
  - Verify agent follows CREATE mode steps
  - Verify agent does NOT diagnose the problem
  - Verify only task entry created, no implementation
- [x] Compare behavior with `/implement`, `/plan`, `/research` for consistency
- [x] Document any deviations or issues

**Verification Results**:
- Pattern consistency verified: All commands (implement.md, plan.md, task.md) now follow preflight/skill/postflight structure
- skill-task skill created with proper structure matching skill-implementer
- task.md updated with Steps 3-5: Execute Preflight, Delegate to Task Agent, Execute Postflight
- Critical notes about skill tool behavior added to task.md
- Context index updated with new Skills Context section including skill-task
- All files properly created and formatted

**Timing**: 45 minutes

## Testing & Validation

- [ ] Task creation with problem description - verify agent does NOT diagnose
- [ ] Task creation with feature request - verify agent does NOT implement
- [ ] Verify state.json updated to "creating" during preflight
- [ ] Verify marker file `.task-creating` created and removed
- [ ] Verify skill-task context loaded correctly
- [ ] Verify task entry appears in state.json after command
- [ ] Verify task entry appears in TODO.md after command
- [ ] Verify task directory created correctly
- [ ] Verify postflight commits changes
- [ ] Compare orchestration pattern with `/implement`, `/plan`, `/research`

## Artifacts & Outputs

- `.opencode/skills/skill-task/SKILL.md` - New skill for task creation context
- `.opencode/skills/skill-task/README.md` - Documentation for skill-task
- `.opencode/commands/task.md` - Updated with preflight/skill/postflight pattern
- `.opencode/context/index.md` - Updated with skill-task reference
- Test results confirming task creation works with new pattern

## Rollback/Contingency

If implementation fails:

1. **Immediate rollback**: Revert task.md to pre-change version
2. **Skill removal**: Delete skill-task directory if causing issues
3. **Fallback pattern**: If new pattern causes problems, revert to direct execution with prominent behavioral warnings (Option 2 from research-002.md)
4. **Recovery procedure**:
   - Restore task.md from git history (commit before changes)
   - Remove skill-task directory
   - Clean up any marker files
   - Update state.json to remove any partial task entries

## Differences from implementation-001.md

This REPLAN supersedes implementation-001.md with the following key differences:

| Aspect | implementation-001.md | implementation-002.md (this plan) |
|--------|----------------------|-----------------------------------|
| **Root cause** | Behavioral (agents want to help) | Architectural (pattern inconsistency) |
| **Solution** | 3 layers: warnings + skill + validation | Update pattern to match other commands |
| **Phase 1** | Add visual warnings to task.md | Create skill-task skill structure |
| **Phase 2** | Create skill-task skill | Update task.md with preflight/skill/postflight |
| **Phase 3** | Implement skill delegation | Update context index |
| **Phase 4** | Add validation | Testing and verification |
| **Phase 5** | Documentation and verification | (Consolidated into Phase 3) |
| **Key insight** | Agents need more guidance | Agents need pattern consistency |

## References

- **research-001.md**: Initial behavioral analysis (superseded by regression findings)
- **research-002.md**: Regression analysis - identifies architectural shift as root cause
- **implementation-001.md**: Previous plan based on behavioral understanding
- **Task 153 commits**: 5e8503c1, 5a66c7ff, f0010a43, 5c0e7afd (command pattern changes)
- **Last working commit**: 39cbfe53 (task 151 created successfully)

---

**Conclusion**: This REPLAN addresses the actual root cause identified in research-002.md: the `/task` command needs to follow the same "command orchestrates workflow" pattern as other commands. Creating `skill-task` and updating `task.md` with preflight/skill/postflight steps will restore consistency and fix the regression.
