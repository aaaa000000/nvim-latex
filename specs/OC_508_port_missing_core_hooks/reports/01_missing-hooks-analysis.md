# Research Report: Task #508

**Task**: OC_508 - Port Missing Core Hooks
**Started**: 2025-05-02T00:00:00Z
**Completed**: 2025-05-02T00:00:00Z
**Effort**: 1 hour
**Dependencies**: None
**Sources/Inputs**: - Codebase analysis of .claude/hooks/ and .opencode/hooks/, settings.json comparison
**Artifacts**: - specs/OC_508_port_missing_core_hooks/reports/01_missing-hooks-analysis.md
**Standards**: report-format.md

## Executive Summary

- **Gap Identified**: 2 hooks missing from OpenCode: `memory-nudge.sh` and `validate-plan-write.sh`
- **Verification Complete**: All 11 Claude hooks accounted for; 9 exist in OpenCode, 2 need porting
- **Additional Dependency Discovered**: `validate-artifact.sh` script also required for validate-plan-write.sh
- **Path Differences**: Most existing hooks differ only in `.claude/` vs `.opencode/` path references
- **Hook Registration**: Differences in settings.json hook configurations between systems

## Context & Scope

This research analyzes the hook parity between Claude Code (.claude/) and OpenCode (.opencode/) systems. Hooks are shell scripts triggered by lifecycle events (SessionStart, Stop, PostToolUse, etc.) defined in settings.json.

### Hook Categories
- **Lifecycle hooks**: SessionStart, Stop, SubagentStop
- **Tool hooks**: PreToolUse, PostToolUse
- **Interaction hooks**: UserPromptSubmit, Notification

## Findings

### Claude Hooks Inventory (11 total)

| # | Hook Name | Event | Purpose | OpenCode Status |
|---|-----------|-------|---------|-----------------|
| 1 | log-session.sh | SessionStart startup | Log session start | EXISTS |
| 2 | memory-nudge.sh | Stop* | Suggest /learn after lifecycle completion | **MISSING** |
| 3 | post-command.sh | Stop* | Post-command cleanup | EXISTS |
| 4 | subagent-postflight.sh | SubagentStop* | Subagent completion handling | EXISTS |
| 5 | tts-notify.sh | Stop*, Notification | Text-to-speech notifications | EXISTS |
| 6 | validate-plan-write.sh | PostToolUse Write\|Edit | Validate artifact format standards | **MISSING** |
| 7 | validate-state-sync.sh | PostToolUse Write | Validate state.json writes | EXISTS |
| 8 | wezterm-clear-status.sh | UserPromptSubmit* | Clear WezTerm status | EXISTS |
| 9 | wezterm-clear-task-number.sh | SessionStart*, UserPromptSubmit* | Clear task number display | EXISTS |
| 10 | wezterm-notify.sh | Stop* | WezTerm desktop notifications | EXISTS |
| 11 | wezterm-task-number.sh | UserPromptSubmit* | Display task number | EXISTS |

*Event triggers on matcher "*" (all)

### Missing Hook Analysis

#### 1. memory-nudge.sh
- **Lines**: 127
- **Purpose**: Detects lifecycle completion signals in assistant messages and suggests `/learn --task N` for memory capture
- **Key Features**:
  - 5-minute cooldown to prevent nudge fatigue
  - Pattern matching for: task completion, status updates, archive operations, review completion
  - Suppresses output for subagent contexts
  - Outputs JSON: `{"systemMessage": "..."}`
- **Integration**: Registered in Stop hook (line 110 in Claude settings.json)
- **Porting Complexity**: Low - no Claude-specific dependencies, only uses jq

#### 2. validate-plan-write.sh
- **Lines**: 78
- **Purpose**: PostToolUse hook that validates artifact writes against format standards
- **Key Features**:
  - Triggers on Write/Edit to specs/*/plans/, specs/*/reports/, specs/*/summaries/
  - Calls external validator script: `validate-artifact.sh`
  - Returns additionalContext with validation results
  - Exit codes: 0=valid, 1=errors, 2=auto-fixed
- **Integration**: Registered in PostToolUse Write|Edit (lines 58-66 in Claude settings.json)
- **Porting Complexity**: Medium - requires porting validate-artifact.sh dependency

### Dependency Analysis

#### validate-artifact.sh Script
- **Location**: `.claude/scripts/validate-artifact.sh` (164 lines)
- **Status in OpenCode**: **MISSING** - .opencode/scripts/ exists but lacks this file
- **Purpose**: Validates report/plan/summary artifacts against format standards
- **Validation Criteria**:
  - Required metadata fields per artifact type
  - Required section headings
  - Plan-specific: Phase headings, Dependency Analysis table
- **Porting Required**: Yes, for validate-plan-write.sh to function

### Hook Differences Analysis

Comparing existing hooks between systems:

| Hook | Status | Difference Type |
|------|--------|-----------------|
| log-session.sh | Different | LOG_DIR path only |
| post-command.sh | Different | TBD - likely paths |
| subagent-postflight.sh | Different | TBD - likely paths |
| tts-notify.sh | Different | TBD |
| validate-state-sync.sh | Same | Identical |
| wezterm-clear-status.sh | Different | TBD |
| wezterm-clear-task-number.sh | Same | Identical |
| wezterm-notify.sh | Different | TBD |
| wezterm-task-number.sh | Different | TBD |

### settings.json Hook Registration Comparison

#### Event Coverage

| Event | Claude | OpenCode | Gap |
|-------|--------|----------|-----|
| PreToolUse | Write matcher | Write matcher | None |
| PostToolUse | Write, Write\|Edit | Write only | **Missing Write\|Edit** |
| SessionStart | *, startup | startup only | **Missing * matcher** |
| Stop | * | * | None (but missing memory-nudge.sh) |
| UserPromptSubmit | * | * | None |
| SubagentStop | * | * | None |
| Notification | permission_prompt\|idle_prompt\|elicitation_dialog | Same | None |

#### Key Configuration Differences

1. **PostToolUse**: Claude has two matchers (Write, Write|Edit), OpenCode only has Write
2. **SessionStart**: Claude has both wildcard (*) and startup matchers, OpenCode only has startup
3. **Stop hooks**: Claude has 4 hooks including memory-nudge.sh, OpenCode has 3
4. **Timeouts**: OpenCode adds explicit timeouts (5000ms, 10000ms, 30000ms) not present in Claude

## Decisions

### Porting Strategy

1. **memory-nudge.sh**: Direct port with path updates only
   - No functional changes required
   - Add to .opencode/hooks/
   - Register in settings.json Stop event

2. **validate-plan-write.sh**: Port with dependency
   - Port validate-artifact.sh to .opencode/scripts/
   - Update hook path references
   - Register in settings.json PostToolUse Write|Edit

3. **settings.json Updates Required**:
   - Add memory-nudge.sh to Stop hooks
   - Add validate-plan-write.sh to PostToolUse Write|Edit matcher
   - Add PostToolUse Write|Edit matcher entry

### Verification Checklist

- [ ] memory-nudge.sh copied to .opencode/hooks/
- [ ] validate-plan-write.sh copied to .opencode/hooks/
- [ ] validate-artifact.sh copied to .opencode/scripts/
- [ ] settings.json updated with missing hook registrations
- [ ] All hooks made executable (chmod +x)
- [ ] Test hook execution manually

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hook path errors break system | High | Low | Thorough testing after port |
| validate-artifact.sh dependencies unknown | Medium | Medium | Audit script for other deps |
| Event timing differences between systems | Low | Medium | Add timeouts if needed |
| Missing specs/tmp/ directory for cooldown file | Medium | Low | Ensure directory exists or create it |

## Implementation Notes

### Files to Create/Port

```
.opencode/hooks/
├── memory-nudge.sh          (NEW - port from .claude/hooks/)
└── validate-plan-write.sh   (NEW - port from .claude/hooks/)

.opencode/scripts/
└── validate-artifact.sh     (NEW - port from .claude/scripts/)
```

### settings.json Changes

Add to Stop hooks (after tts-notify.sh):
```json
{
  "type": "command",
  "command": "bash .opencode/hooks/memory-nudge.sh 2>/dev/null || echo '{}'",
  "timeout": 5000
}
```

Add PostToolUse Write|Edit matcher (after Write matcher):
```json
{
  "matcher": "Write|Edit",
  "hooks": [
    {
      "type": "command",
      "command": "bash .opencode/hooks/validate-plan-write.sh 2>/dev/null || echo '{}'",
      "timeout": 5000
    }
  ]
}
```

## Context Extension Recommendations

None - this is a straightforward porting task with no new patterns to document.

## Appendix

### Search Queries Used
- ls -la .claude/hooks/ and .opencode/hooks/
- diff comparisons between hook files
- settings.json structure analysis

### References
- .claude/hooks/memory-nudge.sh
- .claude/hooks/validate-plan-write.sh
- .claude/scripts/validate-artifact.sh
- .claude/settings.json (hook configuration)
- .opencode/settings.json (hook configuration)
