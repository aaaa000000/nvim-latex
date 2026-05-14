# Implementation Plan: Task #507

- **Task**: 507 - port_missing_core_scripts
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: Research findings identifying 14 missing scripts across 4 categories
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

Port 14 utility scripts from `.claude/scripts/` to `.opencode/scripts/` to maintain feature parity between the two systems. These scripts support extension management, task management, validation, and linting operations. The porting requires adapting path references from `.claude/agents/` to `.opencode/agent/subagents/` and from `.claude/context/` to `.opencode/context/core/`.

### Research Integration

Research identified the following 14 scripts across 4 categories:

**Extension Management (3 scripts)**:
- `check-extension-docs.sh` - Validates extension READMEs and manifests
- `install-extension.sh` - Installs extensions from git URLs
- `uninstall-extension.sh` - Uninstalls extensions by name

**Task Management (5 scripts)**:
- `link-artifact-todo.sh` - Links artifacts to TODO.md entries
- `memory-retrieve.sh` - Retrieves relevant memories for tasks
- `migrate-directory-padding.sh` - Migrates directory numbering format
- `update-recommended-order.sh` - Updates recommended task execution order
- `export-to-markdown.sh` - Exports .claude/ contents to markdown

**Validation (5 scripts)**:
- `validate-artifact.sh` - Validates artifact file formats
- `validate-context-index.sh` - Validates context/index.json
- `validate-extension-index.sh` - Validates extension manifests
- `validate-index.sh` - General index validation
- `validate-wiring.sh` - Validates agent/skill wiring

**Lint (1 script)**:
- `lint/lint-postflight-boundary.sh` - Validates postflight boundary compliance

## Goals & Non-Goals

**Goals**:
- Port all 14 scripts from `.claude/scripts/` to `.opencode/scripts/`
- Adapt all path references to new directory structure
- Maintain original script functionality and behavior
- Ensure consistent error handling and output formatting
- Add brief documentation headers to ported scripts

**Non-Goals**:
- Rewriting script logic or adding new features
- Port scripts that already exist in `.opencode/scripts/`
- Modifying the original `.claude/scripts/` versions
- Creating comprehensive documentation (only brief headers)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path adaptation errors | High | Medium | Systematic search/replace with verification per script |
| Script dependencies on .claude-specific files | Medium | Medium | Identify dependencies during Phase 1, adapt or document |
| Silent failures in validation scripts | High | Low | Add test runs after each phase |
| Breaking changes in shared utilities | Medium | Low | Test affected scripts after all phases |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Extension Management Scripts [COMPLETED]

**Goal**: Port 3 extension management scripts with path adaptations

**Scripts**:
1. `check-extension-docs.sh`
2. `install-extension.sh`
3. `uninstall-extension.sh`

**Tasks**:
- [ ] Copy scripts from `.claude/scripts/` to `.opencode/scripts/`
- [ ] Adapt path references:
  - `.claude/extensions/` → `.opencode/extensions/`
  - `.claude/agents/` → `.opencode/agent/subagents/`
- [ ] Add brief documentation header with description and usage
- [ ] Verify scripts are executable (`chmod +x`)
- [ ] Run each script with `--help` or dry-run to verify basic functionality

**Timing**: 1 hour

**Depends on**: none

**Files to modify/create**:
- `.opencode/scripts/check-extension-docs.sh` (create)
- `.opencode/scripts/install-extension.sh` (create)
- `.opencode/scripts/uninstall-extension.sh` (create)

**Verification**:
- All 3 scripts exist in `.opencode/scripts/`
- Path adaptations applied correctly
- Scripts execute without syntax errors
- Documentation headers present

---

### Phase 2: Task Management Scripts [COMPLETED]

**Goal**: Port 5 task management scripts with path adaptations

**Scripts**:
1. `link-artifact-todo.sh`
2. `memory-retrieve.sh`
3. `migrate-directory-padding.sh`
4. `update-recommended-order.sh`
5. `export-to-markdown.sh`

**Tasks**:
- [ ] Copy scripts from `.claude/scripts/` to `.opencode/scripts/`
- [ ] Adapt path references:
  - `.claude/` → `.opencode/`
  - `specs/TODO.md` → `specs/TODO.md` (no change)
  - `specs/state.json` → `specs/state.json` (no change)
- [ ] Add brief documentation header with description and usage
- [ ] Verify scripts are executable
- [ ] Test basic execution for each script

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify/create**:
- `.opencode/scripts/link-artifact-todo.sh` (create)
- `.opencode/scripts/memory-retrieve.sh` (create)
- `.opencode/scripts/migrate-directory-padding.sh` (create)
- `.opencode/scripts/update-recommended-order.sh` (create)
- `.opencode/scripts/export-to-markdown.sh` (create)

**Verification**:
- All 5 scripts exist in `.opencode/scripts/`
- Path adaptations applied correctly
- Scripts execute without syntax errors
- Documentation headers present

---

### Phase 3: Validation and Lint Scripts [COMPLETED]

**Goal**: Port 6 validation and lint scripts (5 validation + 1 lint)

**Scripts**:
1. `validate-artifact.sh`
2. `validate-context-index.sh`
3. `validate-extension-index.sh`
4. `validate-index.sh`
5. `validate-wiring.sh`
6. `lint/lint-postflight-boundary.sh`

**Tasks**:
- [ ] Copy scripts from `.claude/scripts/` to `.opencode/scripts/`
- [ ] Create `.opencode/scripts/lint/` directory if not exists
- [ ] Adapt path references:
  - `.claude/context/` → `.opencode/context/core/`
  - `.claude/agents/` → `.opencode/agent/subagents/`
  - `.claude/skills/` → `.opencode/skills/`
- [ ] Add brief documentation header with description and usage
- [ ] Verify scripts are executable
- [ ] Run validation scripts to verify they work correctly
- [ ] Run lint script on a sample file to verify functionality

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify/create**:
- `.opencode/scripts/validate-artifact.sh` (create)
- `.opencode/scripts/validate-context-index.sh` (create)
- `.opencode/scripts/validate-extension-index.sh` (create)
- `.opencode/scripts/validate-index.sh` (create)
- `.opencode/scripts/validate-wiring.sh` (create)
- `.opencode/scripts/lint/lint-postflight-boundary.sh` (create)

**Verification**:
- All 6 scripts exist in `.opencode/scripts/` (or `lint/` subdirectory)
- Path adaptations applied correctly
- Validation scripts run without errors on current codebase
- Lint script runs without errors
- Documentation headers present

## Testing & Validation

- [ ] All 14 scripts exist in `.opencode/scripts/` after porting
- [ ] All path references updated correctly (`.claude/` → `.opencode/`, etc.)
- [ ] All scripts have executable permissions
- [ ] All scripts have documentation headers
- [ ] Spot-check: Run 3 scripts to verify functionality (one from each category)
- [ ] No syntax errors in any ported script
- [ ] Scripts that reference each other maintain proper relationships

## Artifacts & Outputs

- `.opencode/scripts/check-extension-docs.sh`
- `.opencode/scripts/install-extension.sh`
- `.opencode/scripts/uninstall-extension.sh`
- `.opencode/scripts/link-artifact-todo.sh`
- `.opencode/scripts/memory-retrieve.sh`
- `.opencode/scripts/migrate-directory-padding.sh`
- `.opencode/scripts/update-recommended-order.sh`
- `.opencode/scripts/export-to-markdown.sh`
- `.opencode/scripts/validate-artifact.sh`
- `.opencode/scripts/validate-context-index.sh`
- `.opencode/scripts/validate-extension-index.sh`
- `.opencode/scripts/validate-index.sh`
- `.opencode/scripts/validate-wiring.sh`
- `.opencode/scripts/lint/lint-postflight-boundary.sh`

## Rollback/Contingency

If porting causes issues:
1. Identify problematic script(s) through error messages or test failures
2. Remove or rename the problematic script in `.opencode/scripts/`
3. Document the issue in task notes
4. Create a new sub-task to fix the specific script if needed
5. Continue with remaining scripts that work correctly

For complete rollback:
1. Delete all newly created scripts in `.opencode/scripts/`
2. Task can be retried with adjusted approach
