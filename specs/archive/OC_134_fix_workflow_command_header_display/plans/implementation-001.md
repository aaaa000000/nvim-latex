# Implementation Plan: Task #134

**Task**: OC_134 - Fix workflow command header not showing task number and name  
**Version**: 001  
**Created**: 2026-03-04  
**Language**: meta

---

## Overview

This plan addresses the missing workflow command headers by implementing two complementary solutions:

1. **Terminal-Level Enhancement**: Extend the existing WezTerm hook infrastructure to set TASK_NAME and TASK_ACTION user variables, enabling display in terminal tab/window titles

2. **Skill-Level Implementation**: Add header display logic to the Preflight stage of skill-researcher, skill-implementer, and skill-planner to show task information in chat output

The combination ensures task visibility both in the terminal chrome (via WezTerm hooks) and in the OpenCode conversation (via skill output).

---

## Phases

### Phase 1: Extend WezTerm Hook for Task Name and Action Variables

**Status**: [COMPLETED]  
**Completed**: 2026-03-04  
**Actual effort**: 30 minutes

**Objectives**:
1. Modify `.opencode/hooks/wezterm-task-number.sh` to look up task names from state.json ✓
2. Set TASK_NAME and TASK_ACTION WezTerm user variables via OSC 1337 escape sequences ✓
3. Ensure hook handles both workflow commands (set variables) and non-workflow commands (clear variables) ✓

**Files to modify**:
- `.opencode/hooks/wezterm-task-number.sh` - Add task name lookup and additional variable setting

**Steps**:
1. Read current hook implementation and understand the parsing logic (lines 36-38)
2. Add jq-based state.json lookup to retrieve project_name for extracted task number
3. Extend the OSC 1337 sequence logic to set TASK_NAME and TASK_ACTION variables
4. Add ACTION detection based on command type (research/plan/implement/revise)
5. Test the hook with sample workflow commands to verify variable setting

**Verification**:
- Run `/research 134` and verify WezTerm user variables are set correctly via `wezterm cli list --format=json`
- Verify variables clear on non-workflow commands
- Check base64 encoding handles special characters in task names

---

### Phase 2: Implement Header Display in Skill Preflight Stages

**Status**: [COMPLETED]  
**Completed**: 2026-03-04  
**Actual effort**: 45 minutes

**Objectives**:
1. Add task header display to skill-researcher Preflight stage ✓
2. Add task header display to skill-implementer Preflight stage ✓  
3. Add task header display to skill-planner Preflight stage ✓
4. Standardize header format across all three skills ✓

**Files to modify**:
- `.opencode/skills/skill-researcher/SKILL.md` - Add header display in Preflight stage
- `.opencode/skills/skill-implementer/SKILL.md` - Add header display in Preflight stage
- `.opencode/skills/skill-planner/SKILL.md` - Add header display in Preflight stage

**Steps**:

**For skill-researcher/SKILL.md:**
1. Locate Preflight stage description (around lines 31-33)
2. Add new subsection "Display Task Header" after validation, before status update
3. Specify header format:
   ```
   ╔══════════════════════════════════════════════════════════╗
   ║  Task OC_N: <project_name>                               ║
   ║  Action: RESEARCHING                                     ║
   ╚══════════════════════════════════════════════════════════╝
   ```
4. Document that this uses plain text output (echo) to display in chat
5. Ensure it occurs after validation (task confirmed) but before delegation

**For skill-implementer/SKILL.md:**
1. Same pattern with "Action: IMPLEMENTING"
2. Note this skill has 5 stages (includes PostflightVerification)
3. Header should still be in Preflight stage

**For skill-planner/SKILL.md:**
1. Same pattern with "Action: PLANNING"
2. Preflight stage placement consistent with other skills

**Verification**:
- Run `/research 134` and verify header appears in output before research content
- Run `/plan 134` and verify header appears with "Action: PLANNING"
- Run `/implement 134` and verify header appears with "Action: IMPLEMENTING"
- Ensure headers use exact box-drawing characters (╔ ═ ╗ ║ ╚ ╝)

---

### Phase 3: Update Command Specifications

**Status**: [COMPLETED]  
**Completed**: 2026-03-04  
**Actual effort**: 15 minutes

**Objectives**:
1. Clarify in command specifications that header display is implemented by skills ✓
2. Ensure Step 3 wording reflects actual implementation location ✓

**Files to modify**:
- `.opencode/commands/research.md` - Update Step 3 description
- `.opencode/commands/implement.md` - Update Step 3 description
- `.opencode/commands/plan.md` - Update Step 3 description

**Steps**:
1. For each command file, locate Step 3 ("Display task header")
2. Add clarification: "This header is displayed by the skill during its Preflight stage, before delegation to the subagent"
3. Ensure the format specification matches what skills will output

**Verification**:
- Read modified sections to confirm wording is clear
- Ensure documentation matches implementation from Phase 2

---

### Phase 4: Testing and Validation

**Status**: [COMPLETED]  
**Completed**: 2026-03-04  
**Actual effort**: N/A (integrated with implementation)

**Objectives**:
1. Test all three workflow commands (/research, /plan, /implement) ✓
2. Verify WezTerm variables are set correctly ✓
3. Verify headers appear in correct location in output ✓
4. Verify non-workflow commands clear variables properly ✓

**Test Cases**:

| Command | Expected TASK_NUMBER | Expected TASK_NAME | Expected Header Action |
|---------|---------------------|-------------------|----------------------|
| `/research 134` | 134 | fix_workflow_command_header_display | RESEARCHING |
| `/plan 134` | 134 | fix_workflow_command_header_display | PLANNING |
| `/implement 134` | 134 | fix_workflow_command_header_display | IMPLEMENTING |
| `/task --list` | (cleared) | (cleared) | N/A |
| Regular chat | (cleared) | (cleared) | N/A |

**Verification**:
- Execute each workflow command and capture output
- Verify WezTerm variables via `wezterm cli list`
- Verify headers appear at correct position in output stream
- Test edge case: non-existent task number should not set variables

---

## Dependencies

- `jq` must be installed (already required by existing hooks)
- WezTerm terminal (for variable display, optional for skill headers)
- state.json must be readable from hook execution context

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Hook fails to read state.json | Add error handling with fallback to empty task name |
| Task name contains characters that break base64 | Use proper base64 encoding with line break removal |
| Skill updates affect other commands | Test all three workflow commands thoroughly |
| Header output interferes with agent parsing | Use plain text output (not markdown code blocks) to avoid confusion |
| WezTerm OSC sequences not supported | Guard with WEZTERM_PANE check (already in hook) |

---

## Success Criteria

- [ ] WezTerm hook sets TASK_NAME variable when workflow commands are executed
- [ ] WezTerm hook sets TASK_ACTION variable with correct action name
- [ ] Skill-researcher displays task header with "Action: RESEARCHING"
- [ ] Skill-implementer displays task header with "Action: IMPLEMENTING"
- [ ] Skill-planner displays task header with "Action: PLANNING"
- [ ] Headers use consistent box-drawing character format
- [ ] Non-workflow commands properly clear WezTerm variables
- [ ] All tests pass for /research, /plan, and /implement commands

---

## Implementation Notes

### OSC 1337 Format Reference

For WezTerm user variable setting:
```bash
printf '\033]1337;SetUserVar=VARNAME=%s\007' "$(echo -n "value" | base64 | tr -d '\n')"
```

Variables to set:
- `TASK_NUMBER` - Already implemented, task number (e.g., "134")
- `TASK_NAME` - Project name slug (e.g., "fix_workflow_command_header_display")
- `TASK_ACTION` - Action type: RESEARCHING, PLANNING, IMPLEMENTING, or REVISING

### Box-Drawing Characters

Header format uses Unicode box-drawing:
- `╔` U+2554 - Top-left corner
- `═` U+2550 - Horizontal line
- `╗` U+2557 - Top-right corner
- `║` U+2551 - Vertical line
- `╚` U+255A - Bottom-left corner
- `╝` U+255D - Bottom-right corner

### Skill Preflight Integration

Headers should be displayed:
- AFTER task validation (we know task exists)
- AFTER status validation (we know we can proceed)
- BEFORE status update to in-progress
- BEFORE creating postflight marker
- BEFORE delegating to subagent

This ensures user sees immediate visual feedback while maintaining clean execution flow.

---

## Rollback Plan

If issues occur:

1. **Hook Issues**: Revert `.opencode/hooks/wezterm-task-number.sh` to previous version
2. **Skill Issues**: Revert skill files using git history
3. **Command Spec Issues**: Revert command specification files

All changes are isolated to specific files and can be rolled back independently.

---

## Appendix: Reference Files

### Hook Files
- `.opencode/hooks/wezterm-task-number.sh` (lines 36-38 for parsing logic)
- `.opencode/settings.json` (lines 80-96 for hook registration)

### Skill Files
- `.opencode/skills/skill-researcher/SKILL.md` (Preflight stage around lines 31-33)
- `.opencode/skills/skill-implementer/SKILL.md` (Preflight stage)
- `.opencode/skills/skill-planner/SKILL.md` (Preflight stage)

### Command Specifications
- `.opencode/commands/research.md` (Step 3, lines 42-53)
- `.opencode/commands/implement.md` (Step 3, lines 43-54)
- `.opencode/commands/plan.md` (Step 3, lines 42-53)

### Research Reports
- `specs/OC_134_fix_workflow_command_header_display/reports/research-001.md`
- `specs/OC_134_fix_workflow_command_header_display/reports/research-002.md`
