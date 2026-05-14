# Implementation Plan: Port Missing Core Hooks

- **Task**: 508 - port_missing_core_hooks
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: Research findings on 2 missing hooks (memory-nudge.sh, validate-plan-write.sh) and dependency script (validate-artifact.sh)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

Port 2 missing hooks from `.claude/hooks/` to `.opencode/hooks/` and 1 dependency script from `.claude/scripts/` to `.opencode/scripts/`. The hooks provide memory nudging after lifecycle completion and artifact format validation. The dependency script (validate-artifact.sh) validates artifacts against format standards and is required by validate-plan-write.sh.

### Research Integration

From research findings:
- **memory-nudge.sh** (127 lines): Suggests `/learn` after lifecycle completion by pattern-matching last_assistant_message. Has 5-minute cooldown, suppresses for subagent contexts.
- **validate-plan-write.sh** (78 lines): PostToolUse hook that validates artifact writes. Calls validate-artifact.sh for validation logic.
- **validate-artifact.sh** (164 lines): Core validation logic for report/plan/summary artifacts. Checks metadata fields, required sections, and plan-specific phase requirements.
- **settings.json differences**: OpenCode missing PostToolUse Write|Edit matcher for validate-plan-write.sh and one SessionStart hook (wezterm-clear-task-number.sh is already present in OpenCode's SessionStart).

## Goals & Non-Goals

**Goals**:
- Port validate-artifact.sh to .opencode/scripts/ with path adjustments
- Port memory-nudge.sh to .opencode/hooks/ with any necessary adjustments
- Port validate-plan-write.sh to .opencode/hooks/ with path adjustments
- Update .opencode/settings.json to register both hooks
- Ensure all hooks exit cleanly (never block OpenCode execution)

**Non-Goals**:
- Modifying hook functionality beyond path adjustments
- Porting other Claude hooks (9 already exist, only 2 missing)
- Changing validation rules in validate-artifact.sh
- Adding new hooks or features

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path references in scripts point to wrong locations | High | Medium | Search/replace `.claude/` with `.opencode/` in all ported scripts |
| Hook conflicts with existing OpenCode hooks | Medium | Low | Validate settings.json structure before and after changes |
| Script permissions not executable | Medium | Low | chmod +x all ported scripts |
| validate-plan-write.sh fails if validate-artifact.sh missing | High | Low | Port validate-artifact.sh first (Phase 1) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | -- |
| 4 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Port validate-artifact.sh [COMPLETED]

**Goal**: Port the core artifact validation script to .opencode/scripts/

**Tasks**:
- [ ] Copy `.claude/scripts/validate-artifact.sh` to `.opencode/scripts/validate-artifact.sh`
- [ ] Verify script is executable (`chmod +x`)
- [ ] Review script for any Claude-specific paths (none expected - uses relative paths)
- [ ] Test script with sample artifact (optional validation)

**Timing**: 15 minutes

**Depends on**: none

**Verification**:
- Script exists at `.opencode/scripts/validate-artifact.sh`
- Script has execute permissions
- Can run: `bash .opencode/scripts/validate-artifact.sh --help` or basic validation

---

### Phase 2: Port memory-nudge.sh [COMPLETED]

**Goal**: Port memory nudge hook to .opencode/hooks/

**Tasks**:
- [ ] Copy `.claude/hooks/memory-nudge.sh` to `.opencode/hooks/memory-nudge.sh`
- [ ] Update cooldown file path from `specs/tmp/memory-nudge-last` (verify path works in OpenCode)
- [ ] Verify jq dependency check works
- [ ] Ensure script exits 0 in all paths (never blocks)
- [ ] Make script executable

**Timing**: 20 minutes

**Depends on**: 1

**Verification**:
- Script exists at `.opencode/hooks/memory-nudge.sh`
- Script has execute permissions
- Script exits 0 when run manually: `echo '{}' | bash .opencode/hooks/memory-nudge.sh`

---

### Phase 3: Port validate-plan-write.sh [COMPLETED]

**Goal**: Port artifact validation hook to .opencode/hooks/

**Tasks**:
- [ ] Copy `.claude/hooks/validate-plan-write.sh` to `.opencode/hooks/validate-plan-write.sh`
- [ ] Update path to validate-artifact.sh from `.claude/scripts/` to `.opencode/scripts/`
- [ ] Verify script handles stdin input correctly
- [ ] Ensure script exits 0 in all paths (never blocks)
- [ ] Make script executable

**Timing**: 15 minutes

**Depends on**: none

**Verification**:
- Script exists at `.opencode/hooks/validate-plan-write.sh`
- Script has execute permissions
- Script references correct validator path: `.opencode/scripts/validate-artifact.sh`
- Script exits 0 when run manually

---

### Phase 4: Update settings.json [COMPLETED]

**Goal**: Register both hooks in .opencode/settings.json

**Tasks**:
- [ ] Add PostToolUse hook entry for Write|Edit matcher calling validate-plan-write.sh
- [ ] Add Stop hook entry for memory-nudge.sh
- [ ] Verify JSON syntax is valid (`jq . .opencode/settings.json`)
- [ ] Compare with .claude/settings.json to ensure no other hooks missing

**Timing**: 20 minutes

**Depends on**: 2, 3

**Changes Required**:
1. In `PostToolUse` array, add after the existing Write matcher entry:
```json
{
  "matcher": "Write|Edit",
  "hooks": [
    {
      "type": "command",
      "command": "bash .opencode/hooks/validate-plan-write.sh 2>/dev/null || echo '{}'"
    }
  ]
}
```

2. In `Stop` array, add to existing Stop hooks (after wezterm-notify.sh, tts-notify.sh):
```json
{
  "type": "command",
  "command": "bash .opencode/hooks/memory-nudge.sh 2>/dev/null || echo '{}'"
}
```

**Verification**:
- settings.json is valid JSON
- Both hooks are registered in appropriate hook types
- Commands reference correct paths (`.opencode/` not `.claude/`)

## Testing & Validation

- [ ] All 3 scripts exist in correct locations with execute permissions
- [ ] settings.json contains both hook registrations
- [ ] JSON syntax is valid
- [ ] Path references use `.opencode/` not `.claude/`
- [ ] Run manual test: `echo '{"stop_reason":"end_turn","last_assistant_message":"task 123: complete research"}' | bash .opencode/hooks/memory-nudge.sh` (should output nudge or empty JSON)
- [ ] Verify validate-plan-write.sh references `.opencode/scripts/validate-artifact.sh`

## Artifacts & Outputs

- `.opencode/scripts/validate-artifact.sh` - Core artifact validation script
- `.opencode/hooks/memory-nudge.sh` - Memory nudge hook for lifecycle completion
- `.opencode/hooks/validate-plan-write.sh` - Artifact format validation hook
- Updated `.opencode/settings.json` - Hook registrations

## Rollback/Contingency

If implementation fails:
1. Remove newly created files: `rm -f .opencode/scripts/validate-artifact.sh .opencode/hooks/memory-nudge.sh .opencode/hooks/validate-plan-write.sh`
2. Restore settings.json from git: `git checkout .opencode/settings.json`
3. Hooks are additive - OpenCode works without them (graceful degradation via `|| echo '{}'`)

## Post-Implementation Notes

After completion, consider:
- Testing hooks by creating a test plan artifact to verify validate-plan-write.sh triggers
- Monitoring for any cooldown or suppression issues with memory-nudge.sh
- Documenting any OpenCode-specific behavior differences found during porting
