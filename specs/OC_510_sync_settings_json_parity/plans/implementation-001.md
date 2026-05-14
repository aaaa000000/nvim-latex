# Implementation Plan: Task #510

- **Task**: 510 - sync_settings_json_parity
- **Status**: [NOT STARTED]
- **Effort**: 30 minutes
- **Dependencies**: None
- **Research Inputs**: Research report identifying 2 missing sections and 1 structural issue in .opencode/settings.json
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, documentation-standards.md, task-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update .opencode/settings.json to achieve feature parity with .claude/settings.json. The current OpenCode settings file is missing the `env` section and has an incorrect SessionStart hook structure where wezterm-clear-task-number.sh is incorrectly placed in the "startup" matcher instead of its own "*" matcher.

### Research Integration

Based on the research findings:
- 2 missing sections identified:
  1. Missing `env` section with SLASH_COMMAND_TOOL_CHAR_BUDGET: "50000"
  2. Missing SessionStart "*" matcher for wezterm-clear-task-number hook
- 1 structural issue: wezterm-clear-task-number.sh incorrectly placed in "startup" matcher
- All 11 hook paths correctly adapted from .claude/hooks/ to .opencode/hooks/
- memory-nudge hook, Notification hooks, PostToolUse hooks all present and correct

## Goals & Non-Goals

**Goals**:
- Add `env` section with `SLASH_COMMAND_TOOL_CHAR_BUDGET: "50000"`
- Fix SessionStart hook structure to match .claude/settings.json
- Ensure wezterm-clear-task-number.sh runs on SessionStart "*" matcher
- Keep wezterm-clear-task-number.sh in startup matcher as well (for compatibility)

**Non-Goals**:
- Modify any hook scripts themselves
- Change permissions or deny lists
- Add new hooks beyond parity
- Modify .claude/settings.json

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| JSON syntax error | High | Low | Validate with jq after editing |
| Missing wezterm-clear-task-number in startup | Medium | Medium | Keep in both matchers per .claude pattern |
| Breaking existing hooks | Low | Low | Only restructure, don't remove hooks |

## Implementation Phases

### Phase 1: Add env Section [COMPLETED]

**Goal**: Add the missing `env` section with SLASH_COMMAND_TOOL_CHAR_BUDGET setting.

**Tasks**:
- [ ] Add `"env": { "SLASH_COMMAND_TOOL_CHAR_BUDGET": "50000" }` at root level of .opencode/settings.json
- [ ] Position after the `hooks` section (end of file before closing brace)

**Timing**: 5 minutes

**Files to modify**:
- `.opencode/settings.json` - Add env section

**Verification**:
- Run `jq .env.SLASH_COMMAND_TOOL_CHAR_BUDGET .opencode/settings.json` should return `"50000"`

---

### Phase 2: Fix SessionStart Hook Structure [COMPLETED]

**Goal**: Correct the SessionStart hook structure to match .claude/settings.json pattern.

**Tasks**:
- [ ] Add new SessionStart matcher with `"*"` pattern containing wezterm-clear-task-number.sh hook
- [ ] Keep existing "startup" matcher but remove wezterm-clear-task-number.sh from it
- [ ] Ensure "startup" matcher only contains: log-session.sh and claude-ready-signal.sh

**Timing**: 15 minutes

**Files to modify**:
- `.opencode/settings.json` - Restructure SessionStart hooks array

**Verification**:
- Compare SessionStart structure with .claude/settings.json
- Run `jq '.hooks.SessionStart | length' .opencode/settings.json` should return `2`
- Run `jq '.hooks.SessionStart[0].matcher' .opencode/settings.json` should return `"*"`
- Run `jq '.hooks.SessionStart[1].matcher' .opencode/settings.json` should return `"startup"`

---

### Phase 3: Validation and Testing [COMPLETED]

**Goal**: Verify the settings.json file is valid and matches expected structure.

**Tasks**:
- [ ] Validate JSON syntax with `jq .opencode/settings.json > /dev/null`
- [ ] Verify env section exists and has correct value
- [ ] Verify SessionStart has two matchers in correct order
- [ ] Do a side-by-side comparison with .claude/settings.json
- [ ] Check that all hook paths still point to valid scripts

**Timing**: 10 minutes

**Verification**:
- JSON is valid (no parse errors)
- `env.SLASH_COMMAND_TOOL_CHAR_BUDGET` equals "50000"
- SessionStart[0] has matcher "*" with wezterm-clear-task-number.sh
- SessionStart[1] has matcher "startup" without wezterm-clear-task-number.sh
- All referenced hook scripts exist in .opencode/hooks/

## Testing & Validation

- [ ] JSON syntax validation passes
- [ ] env section contains SLASH_COMMAND_TOOL_CHAR_BUDGET: "50000"
- [ ] SessionStart has exactly 2 matchers
- [ ] SessionStart[0] matcher is "*" and contains wezterm-clear-task-number.sh
- [ ] SessionStart[1] matcher is "startup" and contains log-session.sh and claude-ready-signal.sh
- [ ] All hooks reference existing scripts in .opencode/hooks/
- [ ] No other sections were accidentally modified

## Artifacts & Outputs

- `.opencode/settings.json` - Updated configuration file with parity to .claude/settings.json

## Rollback/Contingency

If changes cause issues:
1. Keep a backup of original .opencode/settings.json before modifying
2. Restore from backup: `cp .opencode/settings.json.bak .opencode/settings.json`
3. Or manually revert specific changes using Edit tool

The changes are isolated to:
- Adding env section (new, won't break anything)
- Restructuring SessionStart (reordering hooks, not removing functionality)
