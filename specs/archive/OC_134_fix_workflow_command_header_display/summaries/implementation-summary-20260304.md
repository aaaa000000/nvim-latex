# Implementation Summary: Task #134

**Task**: Fix workflow command header not showing task number and name  
**Completed**: 2026-03-04  
**Duration**: ~1.5 hours  
**Status**: [COMPLETED]

---

## Summary

Fixed the missing workflow command headers by implementing a two-tier solution that addresses both terminal-level visibility (via WezTerm hooks) and conversation-level visibility (via skill Preflight stages). The issue was a specification-to-implementation gap where command specifications documented header display but the actual execution chain through skills never implemented it.

---

## Changes Made

### Phase 1: Extended WezTerm Hook Infrastructure

**File**: `.opencode/hooks/wezterm-task-number.sh`

**Enhancements**:
- Added capture of command type (research/plan/implement/revise) as TASK_ACTION
- Added jq-based lookup to retrieve project_name from specs/state.json
- Extended OSC 1337 sequence logic to set three WezTerm user variables:
  - `TASK_NUMBER` - Task number (e.g., "134")
  - `TASK_NAME` - Project name slug (e.g., "fix_workflow_command_header_display")  
  - `TASK_ACTION` - Action in present participle form (RESEARCHING, PLANNING, IMPLEMENTING, REVISING)
- Added proper clearing of all three variables on non-workflow commands

**Key Implementation Details**:
- Uses base64 encoding for variable values to handle special characters
- Converts action verbs to present participle form (research → RESEARCHING)
- Guards against missing state.json or non-existent tasks with empty string fallbacks

---

### Phase 2: Skill Preflight Header Display

**Files Modified**:
- `.opencode/skills/skill-researcher/SKILL.md`
- `.opencode/skills/skill-implementer/SKILL.md`
- `.opencode/skills/skill-planner/SKILL.md`

**Implementation**:
Each skill's Preflight stage now displays a standardized task header:

```
╔══════════════════════════════════════════════════════════╗
║  Task OC_{N}: {project_name}                             ║
║  Action: {RESEARCHING|IMPLEMENTING|PLANNING}              ║
╚══════════════════════════════════════════════════════════╝
```

The header is displayed:
- AFTER task validation (task confirmed to exist)
- BEFORE status update to in-progress
- BEFORE creating postflight marker file
- BEFORE delegating to subagent

This ensures users see immediate visual feedback identifying the task being processed.

---

### Phase 3: Command Specification Updates

**Files Modified**:
- `.opencode/commands/research.md` (Step 3)
- `.opencode/commands/implement.md` (Step 3)
- `.opencode/commands/plan.md` (Step 3)

**Changes**:
Clarified that header display is implemented by the skill during its Preflight stage, not as a separate step. Each specification now explicitly states:
- "The skill displays a visual header during its Preflight stage"
- "Header appears after validation, before delegation"
- "Displayed by skill-{name} before invoking the {agent} subagent"

---

## Testing Results

All workflow commands now display headers correctly:

| Command | Header Action | WezTerm Variables |
|---------|--------------|-------------------|
| `/research N` | RESEARCHING | TASK_NUMBER, TASK_NAME, TASK_ACTION |
| `/plan N` | PLANNING | TASK_NUMBER, TASK_NAME, TASK_ACTION |
| `/implement N` | IMPLEMENTING | TASK_NUMBER, TASK_NAME, TASK_ACTION |
| Non-workflow | N/A | All variables cleared |

---

## Files Changed

```
.opencode/
├── hooks/
│   └── wezterm-task-number.sh          # Extended with TASK_NAME and TASK_ACTION
├── skills/
│   ├── skill-researcher/SKILL.md        # Added RESEARCHING header
│   ├── skill-implementer/SKILL.md       # Added IMPLEMENTING header
│   └── skill-planner/SKILL.md           # Added PLANNING header
└── commands/
    ├── research.md                      # Clarified Step 3
    ├── implement.md                     # Clarified Step 3
    └── plan.md                          # Clarified Step 3
```

---

## Technical Details

### OSC 1337 User Variables

WezTerm supports custom user variables via OSC escape sequences:
```bash
printf '\033]1337;SetUserVar=VARNAME=%s\007' "$(echo -n "value" | base64 | tr -d '\n')"
```

These variables can be accessed in WezTerm configuration for tab titles, status bars, etc.

### Skill Preflight Integration

Skills follow a 4-5 stage execution flow:
1. **LoadContext**: Read context files
2. **Preflight**: Validate, display header, update status
3. **Delegate**: Invoke subagent
4. **Postflight**: Update state and link artifacts
5. **PostflightVerification** (implementer only): Verify phase consistency

Headers are now displayed in stage 2 (Preflight), providing immediate visual feedback.

---

## Verification Checklist

- [x] WezTerm hook sets TASK_NAME variable for workflow commands
- [x] WezTerm hook sets TASK_ACTION variable with correct present participle form
- [x] All three variables clear on non-workflow commands
- [x] Skill-researcher displays header with "Action: RESEARCHING"
- [x] Skill-implementer displays header with "Action: IMPLEMENTING"
- [x] Skill-planner displays header with "Action: PLANNING"
- [x] Headers use consistent Unicode box-drawing character format
- [x] Command specifications updated to clarify skill implementation

---

## Impact

**Before**: Users saw "# New session - 2026..." in the OpenCode TUI header with no indication of which task was being processed.

**After**: 
1. **Terminal Level**: WezTerm users can configure their terminal to display task info in tab/window titles using the OSC 1337 variables
2. **Conversation Level**: Each workflow command now clearly shows the task number and name at the start of execution
3. **Documentation**: Command specifications now accurately reflect the actual implementation

---

## Future Enhancements

1. **WezTerm Configuration**: Add example WezTerm Lua configuration showing how to display task info in tab titles
2. **Neovim Integration**: Create opencode.nvim autocmd handler to display task info in Neovim's status line
3. **OpenCode Plugin**: When OpenCode exposes session title API (issues #4539, #8436), create a plugin to automatically set session titles

---

## References

- Research Report 1: `specs/OC_134_fix_workflow_command_header_display/reports/research-001.md`
- Research Report 2: `specs/OC_134_fix_workflow_command_header_display/reports/research-002.md`
- Implementation Plan: `specs/OC_134_fix_workflow_command_header_display/plans/implementation-001.md`
- OpenCode Issue #4539: "Add an option to set the terminal window title"
- OpenCode Issue #8436: "Feature Request: Editable session names with auto-generated titles"
