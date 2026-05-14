# Implementation Plan: Task #509

- **Task**: 509 - port_missing_core_rules
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: Research on rule differences between .claude/rules/ and .opencode/rules/
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

Port 2 missing core rules from `.claude/rules/` to `.opencode/rules/`: `plan-format-enforcement.md` and `project-overview-detection.md`. These rules provide important format enforcement and project detection capabilities that currently only exist in the Claude Code system. Each rule requires minor path adaptations to work correctly within the OpenCode system structure.

### Research Integration

Research findings confirm:
- 9 Claude rules exist, 6 OpenCode rules (excluding README)
- 5 core rules already have OpenCode equivalents (artifact-formats, error-handling, git-workflow, state-management, workflows)
- 2 extension-specific rules (neovim-lua, nix) should NOT be ported as they are domain-specific
- 2 core rules are missing and need porting

## Goals & Non-Goals

**Goals**:
- Port `plan-format-enforcement.md` to `.opencode/rules/`
- Port `project-overview-detection.md` to `.opencode/rules/`
- Adapt paths in rules to reference `.opencode/` instead of `.claude/`
- Maintain rule functionality and intent

**Non-Goals**:
- Do not port extension-specific rules (neovim-lua.md, nix.md)
- Do not modify existing OpenCode rules
- Do not create new rule functionality beyond path adaptations

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path pattern mismatches | Medium | Low | Review `.opencode/rules/` existing rules for correct path conventions |
| Overwriting existing rules | High | Low | Verify target files don't exist before writing |
| Breaking OpenCode conventions | Medium | Low | Follow existing OpenCode rule format and style |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Port plan-format-enforcement.md [COMPLETED]

**Goal**: Port plan format enforcement rule with path adaptations

**Tasks**:
- [ ] Read source file `.claude/rules/plan-format-enforcement.md`
- [ ] Create `.opencode/rules/plan-format-enforcement.md`
- [ ] Copy YAML frontmatter (`paths: specs/**/plans/**` - same for both systems)
- [ ] Update reference to `.claude/context/formats/plan-format.md` → `.opencode/context/formats/plan-format.md`
- [ ] Verify rule content maintains original intent

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:
- `.opencode/rules/plan-format-enforcement.md` - create new file

**Verification**:
- File exists at `.opencode/rules/plan-format-enforcement.md`
- YAML frontmatter is valid
- Path references point to `.opencode/` not `.claude/`

---

### Phase 2: Port project-overview-detection.md [COMPLETED]

**Goal**: Port project overview detection rule with path adaptations

**Tasks**:
- [ ] Read source file `.claude/rules/project-overview-detection.md`
- [ ] Create `.opencode/rules/project-overview-detection.md`
- [ ] Update YAML frontmatter path from `.claude/context/repo/project-overview.md` → `.opencode/context/repo/project-overview.md`
- [ ] Update all internal references to `.claude/context/` → `.opencode/context/`
- [ ] Update command reference from `/project-overview` to OpenCode equivalent (or note if different)
- [ ] Verify rule content maintains original intent

**Timing**: 25 minutes

**Depends on**: 1

**Files to modify**:
- `.opencode/rules/project-overview-detection.md` - create new file

**Verification**:
- File exists at `.opencode/rules/project-overview-detection.md`
- YAML frontmatter path is correct
- All `.claude/` references updated to `.opencode/`
- Command reference is appropriate for OpenCode system

---

### Phase 3: Verification and Documentation [COMPLETED]

**Goal**: Verify both rules are correctly ported and functional

**Tasks**:
- [ ] List all files in `.opencode/rules/` to confirm new rules present
- [ ] Verify both files have valid YAML frontmatter
- [ ] Spot-check content for correct path references
- [ ] Confirm total rule count is now 8 (6 existing + 2 new)

**Timing**: 15 minutes

**Depends on**: 2

**Files to modify**: None (verification only)

**Verification**:
- Both `.opencode/rules/plan-format-enforcement.md` and `.opencode/rules/project-overview-detection.md` exist
- All path references correctly point to `.opencode/` locations
- Rule count in `.opencode/rules/` is 8 (excluding README)

## Testing & Validation

- [ ] Verify file creation: `ls .opencode/rules/plan-format-enforcement.md`
- [ ] Verify file creation: `ls .opencode/rules/project-overview-detection.md`
- [ ] Check YAML frontmatter validity on both files
- [ ] Confirm no `.claude/` references remain in ported rules
- [ ] Verify rule content is functionally equivalent to source

## Artifacts & Outputs

- `.opencode/rules/plan-format-enforcement.md` - Ported plan format enforcement rule
- `.opencode/rules/project-overview-detection.md` - Ported project overview detection rule

## Rollback/Contingency

If implementation fails:
1. Simply delete the newly created files: `rm .opencode/rules/plan-format-enforcement.md .opencode/rules/project-overview-detection.md`
2. System returns to previous state with 6 rules
3. No other files are modified, so no further rollback needed
