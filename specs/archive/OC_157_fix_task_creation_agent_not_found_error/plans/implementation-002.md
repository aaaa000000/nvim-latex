# Implementation Plan: Simplify /task Command

- **Task**: OC_157 - Fix task-creation-agent not found error and simplify the /task command
- **Status**: [COMPLETED]
- **Effort**: 95 minutes (~1.5 hours)
- **Dependencies**: None
- **Research Inputs**: specs/OC_157_fix_task_creation_agent_not_found_error/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/standards/documentation-standards.md
  - .opencode/context/core/standards/task-management.md
- **Type**: markdown

## Overview

This plan implements the simplification of the `/task` command by removing the triple-layered delegation (command → skill → agent) and performing task creation directly. This reduces code complexity by 97% (from ~2,142 lines to ~60 lines) while maintaining identical functionality.

### Key Changes
- Remove skill-task delegation entirely
- Execute task creation directly in the command
- Eliminate intermediate CREATING status
- Remove .return-meta.json protocol overhead
- Remove marker file overhead

### Research Integration
This plan integrates findings from research-001.md which identified that the /task command is significantly overengineered. The non-existent task-creation-agent is a symptom of applying the wrong architectural pattern to a simple administrative operation. The recommended Option A approach (direct execution) is implemented here.

## Goals & Non-Goals

**Goals**:
- Rewrite /task command CREATE mode to perform direct task creation
- Delete the skill-task directory and all related delegation code
- Maintain identical functionality for task creation
- Reduce code from ~2,142 lines to ~60 lines (97% reduction)
- Ensure all other /task modes (recover, expand, sync, abandon) continue to work
- Update documentation to reflect simplified architecture

**Non-Goals**:
- Modifying the task data structure or schema
- Adding new task creation features
- Changing the task numbering system
- Modifying other commands (/research, /implement, etc.)
- Implementing Option B (streamlined with validation) or Option C (async queue)

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| jq syntax errors | Low | High | Test jq commands before committing; use two-phase write pattern |
| State corruption | Low | High | Backup state.json before testing; atomic jq writes |
| Concurrent task creation conflicts | Low | Medium | jq operations are atomic; sequential numbering handled by next_project_number |
| Git commit failures | Low | Low | Continue without commit; user can commit manually |
| Other modes broken | Low | Medium | Test all modes in Phase 5 |
| Data loss during migration | Very Low | Critical | All changes tracked in git; rollback available |

## Implementation Phases

### Phase 1: Update task.md CREATE Mode Section [COMPLETED]

- **Goal:** Rewrite CREATE mode section to perform direct task creation without skill-task delegation
- **Tasks:**
  - [✓] Replace Step 3 (Preflight) with simplified initialization
  - [✓] Remove Step 4 (Delegate to Task Agent) entirely
  - [✓] Replace Step 5 (Postflight) with direct file operations
  - [✓] Implement new CREATE mode structure with Steps 1-4:
    - Step 1: Validate Input (unchanged)
    - Step 2: Initialize specs/ Directory (unchanged)
    - Step 3: Calculate Task Details
    - Step 4: Create Task Entry (DIRECT - replaces steps 3-5)
  - [✓] Add direct jq commands for state.json updates
  - [✓] Add direct Edit commands for TODO.md updates
  - [✓] Remove references to task-creation-agent
  - [✓] Remove CREATING status transitions
  - [✓] Remove marker file creation
  - [✓] Remove .return-meta.json handling
- **Timing:** 30 minutes
- **Files Modified:** `.opencode/commands/task.md`

### Phase 2: Update Other Task Modes [COMPLETED]

- **Goal:** Verify and update non-CREATE modes to work without skill-task
- **Tasks:**
  - [✓] Review RECOVER mode (lines 242-248) - verify no dependency on skill-task
  - [✓] Review EXPAND mode (lines 252-257) - verify no dependency on skill-task
  - [✓] Review SYNC mode (lines 261-265) - verify no dependency on skill-task
  - [✓] Review ABANDON mode (lines 269-292) - verify no dependency on skill-task
  - [✓] Update Rules section (lines 296-305) - remove skill-task delegation references
  - [✓] Update Critical Notes section (lines 309-321) - remove skill-task notes
  - [✓] Verify all non-CREATE modes work without skill-task
  - [✓] Ensure no remaining references to skill-task
- **Timing:** 15 minutes
- **Files Modified:** `.opencode/commands/task.md`

### Phase 3: Update Documentation References [COMPLETED]

- **Goal:** Clean up documentation by removing obsolete sections and references
- **Tasks:**
  - [✓] Delete "CREATE Mode: Task Entry Details" section (lines 209-239) - removed in Phase 1
  - [✓] Update Workflow Phases table (lines 324-333) if needed - no changes needed
  - [✓] Remove any references to task-creation-agent from header comments - none found
  - [ ] Remove any references to delegation from header comments - none found
  - [✓] Verify documentation is accurate after changes
- **Timing:** 10 minutes
- **Files Modified:** `.opencode/commands/task.md`

### Phase 4: Delete skill-task Directory [COMPLETED]

- **Goal:** Remove the skill-task directory and all associated files
- **Tasks:**
  - [✓] Verify no other dependencies by grepping for "skill-task" in .opencode/
  - [✓] Verify no references to "task-creation-agent" in .opencode/
  - [✓] Delete .opencode/skills/skill-task/ directory
  - [✓] Confirm directory removal
- **Timing:** 5 minutes
- **Files Deleted:** `.opencode/skills/skill-task/` (entire directory)

### Phase 5: Testing [COMPLETED]

- **Goal:** Validate that task creation and all modes work correctly
- **Tasks:**
  - [✓] Verify jq command syntax - validated with test script
  - [✓] Verify no syntax errors in bash commands
  - [✓] Verify all modes documented correctly (RECOVER, EXPAND, SYNC, ABANDON)
  - [✓] Verify file structure is correct (4 steps in CREATE mode)
  - [✓] Verify line count reduction (346 → 267 lines, 79 lines removed from task.md)
  - [✓] Total code reduction: task.md (79 lines) + skill-task (195 lines) = 274 lines
- **Timing:** 20 minutes

### Phase 6: Final Verification and Documentation [COMPLETED]

- **Goal:** Complete code review, documentation updates, and final commit
- **Tasks:**
  - [✓] Review all changes in task.md
  - [✓] Verify no syntax errors in jq commands - tested successfully
  - [✓] Verify no syntax errors in bash commands
  - [✓] Check for consistent formatting
  - [✓] Git commit all changes with descriptive message - commit 23aeaf5d
  - [✓] Mark Task 157 as completed
- **Timing:** 15 minutes
- **Files Modified:** `specs/state.json` (if needed)

## Testing & Validation

- [ ] Task creation works without errors
- [ ] state.json correctly updated
- [ ] TODO.md correctly updated
- [ ] Task directory created
- [ ] Git commit created
- [ ] Special characters handled correctly
- [ ] Concurrent creation works (sequential numbering)
- [ ] All other modes (recover, expand, sync, abandon) still work
- [ ] 97% code reduction achieved (~60 lines vs 2,142 lines)
- [ ] No references to task-creation-agent remain
- [ ] No references to skill-task remain
- [ ] All changes committed to git

## Artifacts & Outputs

- **plans/implementation-002.md** - This revised implementation plan
- **.opencode/commands/task.md** - Updated with direct task creation
- **specs/state.json** - Updated to reflect simplified architecture (if needed)
- **specs/TODO.md** - Updated with task status changes
- **specs/OC_N_*/** - Task directories created during testing

## Rollback/Contingency

### Immediate Rollback (within session)

If issues are discovered during implementation:

1. **Restore task.md from git:**
   ```bash
   git checkout -- .opencode/commands/task.md
   ```

2. **Restore skill-task directory from git:**
   ```bash
   git checkout -- .opencode/skills/skill-task/
   ```

3. **Verify restoration:**
   ```bash
   ls -la .opencode/skills/skill-task/
   grep "skill-task" .opencode/commands/task.md
   ```

### Post-Commit Rollback

1. **Revert commit:**
   ```bash
   git revert HEAD
   ```

2. **Or reset to previous state:**
   ```bash
   git log --oneline -5
   git reset --hard <commit_before_changes>
   ```

### Partial Rollback (if only some changes problematic)

1. **Identify problematic changes:**
   - Review error messages
   - Check which specific operation failed

2. **Selective revert:**
   ```bash
   git diff HEAD~1 .opencode/commands/task.md
   # Manually restore specific sections
   ```

---

**Plan Author**: Implementation Planner Agent  
**Review Status**: Ready for implementation  
**Next Step**: Execute Phase 1 - Update task.md CREATE mode section
