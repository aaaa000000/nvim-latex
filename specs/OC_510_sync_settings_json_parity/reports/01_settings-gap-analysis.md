# Research Report: Task #510 - Sync settings.json for OpenCode Parity

**Task**: OC_510 - sync_settings_json_parity  
**Started**: 2026-05-02T18:10:00Z  
**Completed**: 2026-05-02T18:15:00Z  
**Effort**: 1-2 hours  
**Dependencies**: Task #508 (Port missing core hooks to OpenCode)  
**Sources/Inputs**: 
- `.claude/settings.json` (157 lines) - Source of truth
- `.opencode/settings.json` (161 lines) - Target for synchronization
- Hook files in `.claude/hooks/` and `.opencode/hooks/`
**Artifacts**: 
- `specs/OC_510_sync_settings_json_parity/reports/01_settings-gap-analysis.md` (this report)

## Executive Summary

Analysis of `.opencode/settings.json` against `.claude/settings.json` reveals **2 missing sections** and **1 structural issue** that need to be addressed for feature parity:

1. **Missing `env` section** - SLASH_COMMAND_TOOL_CHAR_BUDGET environment variable not configured
2. **Missing SessionStart '*' matcher** - wezterm-clear-task-number hook should run on every session start, not just 'startup'
3. **Hook path adaptations already complete** - All hook paths correctly use `.opencode/hooks/` instead of `.claude/hooks/`

The following sections are already synchronized:
- memory-nudge hook in Stop (✓ present)
- Notification hook section (✓ present)
- PostToolUse validation hooks (✓ present)
- SubagentStop hooks (✓ present)

## Context & Scope

This research compares the OpenCode settings.json configuration with the Claude Code settings.json to identify gaps and ensure feature parity. Task #508 (porting missing hooks) is a dependency because the hooks referenced in settings.json must exist before they can be configured.

### Files Analyzed

| File | Lines | Purpose |
|------|-------|---------|
| `.claude/settings.json` | 157 | Source configuration (reference) |
| `.opencode/settings.json` | 161 | Target configuration (to update) |

## Findings

### Gap 1: Missing `env` Section

**.claude/settings.json (lines 154-157):**
```json
"env": {
  "SLASH_COMMAND_TOOL_CHAR_BUDGET": "50000"
}
```

**.opencode/settings.json:**
- **MISSING** - No `env` section exists

**Impact:** The SLASH_COMMAND_TOOL_CHAR_BUDGET environment variable controls the character budget for slash command tool usage. Without this setting, OpenCode may use different defaults, potentially affecting performance or behavior.

**Recommendation:** Add the `env` section to `.opencode/settings.json` with the same value.

### Gap 2: Missing SessionStart '*' Matcher

**.claude/settings.json (lines 68-77):**
```json
"SessionStart": [
  {
    "matcher": "*",
    "hooks": [
      {
        "type": "command",
        "command": "bash .claude/hooks/wezterm-clear-task-number.sh 2>/dev/null || echo '{}'"
      }
    ]
  },
  {
    "matcher": "startup",
    "hooks": [
      {
        "type": "command",
        "command": "bash .claude/hooks/log-session.sh 2>/dev/null || echo '{}'"
      },
      {
        "type": "command",
        "command": "bash scripts/claude-ready-signal.sh 2>/dev/null || echo '{}'"
      }
    ]
  }
]
```

**.opencode/settings.json (lines 73-93):**
```json
"SessionStart": [
  {
    "matcher": "startup",
    "hooks": [
      {
        "type": "command",
        "command": "bash .opencode/hooks/log-session.sh 2>/dev/null || echo '{}'"
      },
      {
        "type": "command",
        "command": "bash ~/.config/nvim/scripts/claude-ready-signal.sh 2>/dev/null || echo '{}'",
        "timeout": 5000
      },
      {
        "type": "command",
        "command": "bash .opencode/hooks/wezterm-clear-task-number.sh 2>/dev/null || echo '{}'",
        "timeout": 5000
      }
    ]
  }
]
```

**Issues Identified:**

1. **Missing '*' matcher block** - The `.claude` version has a separate matcher for `"*"` that runs `wezterm-clear-task-number.sh` on every session start. The `.opencode` version only has the `"startup"` matcher and has moved `wezterm-clear-task-number.sh` there.

2. **Behavioral difference** - In Claude Code, `wezterm-clear-task-number.sh` runs on every session start (including resumed sessions). In OpenCode, it only runs on startup.

3. **Timeout additions** - OpenCode added timeouts (5000ms) to the startup hooks, which is actually an improvement over the Claude version.

**Recommendation:** 
- Add a separate `"matcher": "*"` block for `wezterm-clear-task-number.sh` to match Claude behavior
- Keep the `"startup"` matcher with log-session.sh and claude-ready-signal.sh
- Preserve the timeout values as they improve reliability

### Verified Synchronized Sections

The following sections are already correctly synchronized between `.claude/settings.json` and `.opencode/settings.json`:

#### 1. memory-nudge Hook in Stop (✓ PRESENT)

**.claude/settings.json (lines 108-111):**
```json
{
  "type": "command",
  "command": "bash .claude/hooks/memory-nudge.sh 2>/dev/null || echo '{}'"
}
```

**.opencode/settings.json (lines 129-132):**
```json
{
  "type": "command",
  "command": "bash .opencode/hooks/memory-nudge.sh 2>/dev/null || echo '{}'"
}
```

**Status:** ✓ Present and correctly adapted to `.opencode/hooks/` path.

#### 2. Notification Hook Section (✓ PRESENT)

**.claude/settings.json (lines 142-153):**
```json
"Notification": [
  {
    "matcher": "permission_prompt|idle_prompt|elicitation_dialog",
    "hooks": [
      {
        "type": "command",
        "command": "bash .claude/hooks/tts-notify.sh 2>/dev/null || echo '{}'"
      }
    ]
  }
]
```

**.opencode/settings.json (lines 148-160):**
```json
"Notification": [
  {
    "matcher": "permission_prompt|idle_prompt|elicitation_dialog",
    "hooks": [
      {
        "type": "command",
        "command": "bash .opencode/hooks/tts-notify.sh 2>/dev/null || echo '{}'",
        "timeout": 10000
      }
    ]
  }
]
```

**Status:** ✓ Present and correctly adapted. OpenCode adds a timeout (10000ms) which is an improvement.

#### 3. PostToolUse Validation Hooks (✓ PRESENT)

Both files have identical PreToolUse and PostToolUse hooks for:
- State file write validation
- Plan write validation

Paths correctly use `.opencode/hooks/` in the OpenCode version.

#### 4. SubagentStop Hooks (✓ PRESENT)

Both files have the SubagentStop hook for `subagent-postflight.sh` with 30000ms timeout.

### Hook Path Adaptations Status

All hook paths have been correctly adapted from `.claude/hooks/` to `.opencode/hooks/`:

| Hook | Claude Path | OpenCode Path | Status |
|------|-------------|---------------|--------|
| validate-state-sync.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |
| validate-plan-write.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |
| wezterm-clear-task-number.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |
| log-session.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |
| post-command.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |
| tts-notify.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |
| wezterm-notify.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |
| memory-nudge.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |
| wezterm-task-number.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |
| wezterm-clear-status.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |
| subagent-postflight.sh | `.claude/hooks/` | `.opencode/hooks/` | ✓ Adapted |

**Note:** `claude-ready-signal.sh` remains at `scripts/claude-ready-signal.sh` (shared script).

### Permissions Differences

**.claude/settings.json permissions:**
- Task, TaskCreate, TaskUpdate, Skill
- mcp__lean-lsp__*

**.opencode/settings.json permissions:**
- nvim, luac, pnpm, npx (additional Bash permissions)
- TodoWrite (instead of Task/TaskCreate/TaskUpdate)
- mcp__lean-lsp__*, mcp__astro-docs__*, mcp__context7__*, mcp__playwright__*

**Analysis:** The permissions differences are intentional and reflect the different capabilities and tool integrations of each system. These should **NOT** be synchronized - they are system-specific.

## Decisions

### Decision 1: Add `env` Section
**Decision:** Add the `env` section with SLASH_COMMAND_TOOL_CHAR_BUDGET to `.opencode/settings.json`.

**Rationale:** This ensures consistent behavior between Claude Code and OpenCode for slash command tool budgets.

### Decision 2: Fix SessionStart Matcher Structure
**Decision:** Add a separate `"matcher": "*"` block for `wezterm-clear-task-number.sh` to match Claude Code behavior.

**Rationale:** The `"*"` matcher ensures the hook runs on every session start (including resumed sessions), not just initial startup. This maintains the intended wezterm integration behavior.

### Decision 3: Preserve OpenCode-Specific Improvements
**Decision:** Keep the timeout values added in OpenCode (5000ms for most hooks, 10000ms for tts-notify).

**Rationale:** These timeouts improve reliability and prevent hanging. They are enhancements over the Claude Code version.

### Decision 4: Do NOT Synchronize Permissions
**Decision:** Leave permissions differences as-is.

**Rationale:** Permissions are system-specific and reflect different capabilities (OpenCode has additional MCP tools and different command structures).

## Implementation Summary

The following changes are required to achieve parity:

### Changes to `.opencode/settings.json`:

1. **Add `env` section** (after line 160, before closing brace):
   ```json
   "env": {
     "SLASH_COMMAND_TOOL_CHAR_BUDGET": "50000"
   }
   ```

2. **Fix SessionStart structure** (lines 73-93):
   - Add `"matcher": "*"` block with `wezterm-clear-task-number.sh`
   - Keep `"matcher": "startup"` block with log-session.sh and claude-ready-signal.sh
   - Remove `wezterm-clear-task-number.sh` from startup matcher

### Final SessionStart Structure Should Be:

```json
"SessionStart": [
  {
    "matcher": "*",
    "hooks": [
      {
        "type": "command",
        "command": "bash .opencode/hooks/wezterm-clear-task-number.sh 2>/dev/null || echo '{}'",
        "timeout": 5000
      }
    ]
  },
  {
    "matcher": "startup",
    "hooks": [
      {
        "type": "command",
        "command": "bash .opencode/hooks/log-session.sh 2>/dev/null || echo '{}'"
      },
      {
        "type": "command",
        "command": "bash ~/.config/nvim/scripts/claude-ready-signal.sh 2>/dev/null || echo '{}'",
        "timeout": 5000
      }
    ]
  }
]
```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| SessionStart behavior change | Medium - May affect wezterm tab title display | Test wezterm integration after changes |
| Environment variable side effects | Low - Unknown if other tools depend on this var | Monitor for any unexpected behavior |
| JSON syntax errors | Medium - Could break OpenCode configuration | Validate JSON after editing |

## Appendix

### Hook Files Inventory

**`.claude/hooks/` (11 files):**
- log-session.sh
- memory-nudge.sh
- post-command.sh
- subagent-postflight.sh
- tts-notify.sh
- validate-plan-write.sh
- validate-state-sync.sh
- wezterm-clear-status.sh
- wezterm-clear-task-number.sh
- wezterm-notify.sh
- wezterm-task-number.sh

**`.opencode/hooks/` (11 files):**
- log-session.sh
- memory-nudge.sh
- post-command.sh
- subagent-postflight.sh
- tts-notify.sh
- validate-plan-write.sh
- validate-state-sync.sh
- wezterm-clear-status.sh
- wezterm-clear-task-number.sh
- wezterm-notify.sh
- wezterm-task-number.sh

**Status:** All 11 hooks from `.claude/hooks/` are present in `.opencode/hooks/`.

### Related Tasks

- **Task #508** - Port missing core hooks to OpenCode (dependency)
- **Task #510** - Sync settings.json for OpenCode parity (this task)
- **Task #511** - Update AGENTS.md documentation (depends on this task)
