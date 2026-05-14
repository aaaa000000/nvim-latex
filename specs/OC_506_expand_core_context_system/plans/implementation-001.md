# Implementation Plan: Expand Core Context System

- **Task**: 506 - expand_core_context_system
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: Analysis showing 6 missing directories, 18 files to copy (~3,185 lines)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Expand the `.opencode/context/core/` directory structure to match `.claude/extensions/core/context/` by creating 6 missing directories and copying 18 documentation files (~3,185 lines total). This aligns the OpenCode context system with the Claude Code context structure, ensuring consistent agent behavior across both systems. Path references within copied files will be reviewed and adapted as needed.

### Research Integration

Research identified the following gaps:
- **6 missing directories**: guides/, meta/, processes/, reference/, repo/, troubleshooting/
- **18 files to copy**: Distributed across the missing directories
- **Existing structure**: orchestration/, patterns/, formats/, workflows/ already present in target
- **Path adaptation required**: Files may contain relative paths referencing `.claude/` that need adjustment for `.opencode/`

## Goals & Non-Goals

**Goals**:
- Create 6 missing directories in `.opencode/context/core/`
- Copy 18 files from `.claude/extensions/core/context/` to corresponding locations
- Adapt path references in copied files (e.g., `.claude/` → `.opencode/`)
- Verify all files are correctly placed and readable
- Ensure directory structure mirrors source exactly

**Non-Goals**:
- Modifying content beyond path adaptations
- Creating new documentation not in source
- Copying files from other context layers (project/, architecture/, etc.)
- Updating index.json (separate task)
- Removing or renaming existing directories

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path references break after copying | Medium | High | Review each file for `.claude/` references; adapt to `.opencode/` |
| Files depend on non-existent directories | Low | Medium | Verify referenced paths exist; create follow-up task if needed |
| Content drift between systems | Low | Low | Document this as a synchronization point for future updates |
| Missing files in count | Low | Low | Verify file count after copy; compare directory listings |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Create Missing Directories [COMPLETED]

**Goal**: Create the 6 missing directories in `.opencode/context/core/`

**Tasks**:
- [ ] Create `.opencode/context/core/guides/` directory
- [ ] Create `.opencode/context/core/meta/` directory
- [ ] Create `.opencode/context/core/processes/` directory
- [ ] Create `.opencode/context/core/reference/` directory
- [ ] Create `.opencode/context/core/repo/` directory
- [ ] Create `.opencode/context/core/troubleshooting/` directory

**Timing**: 15 minutes

**Depends on**: none

**Verification**:
- Run `ls -la .opencode/context/core/` and confirm all 6 directories exist
- Total directory count should be 18 (12 existing + 6 new)

---

### Phase 2: Copy guides/ Directory Files [COMPLETED]

**Goal**: Copy 2 files from guides/ directory with path adaptations

**Tasks**:
- [ ] Copy `extension-development.md` from `.claude/extensions/core/context/guides/` to `.opencode/context/core/guides/`
- [ ] Copy `loader-reference.md` from `.claude/extensions/core/context/guides/` to `.opencode/context/core/guides/`
- [ ] Review and adapt path references in both files (e.g., `../../docs/` paths)

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `.opencode/context/core/guides/extension-development.md` - Copy from source
- `.opencode/context/core/guides/loader-reference.md` - Copy from source

**Verification**:
- `ls .opencode/context/core/guides/` shows 2 files
- Files are readable and paths are adapted

---

### Phase 3: Copy meta/ and processes/ Directory Files [COMPLETED]

**Goal**: Copy 6 files from meta/ and processes/ directories

**Tasks**:
- [ ] Copy 3 files from `.claude/extensions/core/context/meta/` to `.opencode/context/core/meta/`
  - `context-revision-guide.md`
  - `domain-patterns.md`
  - `meta-guide.md`
- [ ] Copy 3 files from `.claude/extensions/core/context/processes/` to `.opencode/context/core/processes/`
  - `implementation-workflow.md`
  - `planning-workflow.md`
  - `research-workflow.md`
- [ ] Review and adapt any path references

**Timing**: 45 minutes

**Depends on**: 2

**Files to modify**:
- `.opencode/context/core/meta/context-revision-guide.md`
- `.opencode/context/core/meta/domain-patterns.md`
- `.opencode/context/core/meta/meta-guide.md`
- `.opencode/context/core/processes/implementation-workflow.md`
- `.opencode/context/core/processes/planning-workflow.md`
- `.opencode/context/core/processes/research-workflow.md`

**Verification**:
- `ls .opencode/context/core/meta/` shows 3 files
- `ls .opencode/context/core/processes/` shows 3 files

---

### Phase 4: Copy reference/, repo/, and troubleshooting/ Files [COMPLETED]

**Goal**: Copy 10 remaining files from reference/, repo/, and troubleshooting/

**Tasks**:
- [ ] Copy 6 files from `.claude/extensions/core/context/reference/` to `.opencode/context/core/reference/`
  - `artifact-templates.md`
  - `README.md`
  - `skill-agent-mapping.md`
  - `state-management-schema.md`
  - `team-wave-helpers.md`
  - `workflow-diagrams.md`
- [ ] Copy 3 files from `.claude/extensions/core/context/repo/` to `.opencode/context/core/repo/`
  - `project-overview.md`
  - `self-healing-implementation-details.md`
  - `update-project.md`
- [ ] Copy 1 file from `.claude/extensions/core/context/troubleshooting/` to `.opencode/context/core/troubleshooting/`
  - `workflow-interruptions.md`
- [ ] Review and adapt any path references in all 10 files

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `.opencode/context/core/reference/artifact-templates.md`
- `.opencode/context/core/reference/README.md`
- `.opencode/context/core/reference/skill-agent-mapping.md`
- `.opencode/context/core/reference/state-management-schema.md`
- `.opencode/context/core/reference/team-wave-helpers.md`
- `.opencode/context/core/reference/workflow-diagrams.md`
- `.opencode/context/core/repo/project-overview.md`
- `.opencode/context/core/repo/self-healing-implementation-details.md`
- `.opencode/context/core/repo/update-project.md`
- `.opencode/context/core/troubleshooting/workflow-interruptions.md`

**Verification**:
- `ls .opencode/context/core/reference/` shows 6 files
- `ls .opencode/context/core/repo/` shows 3 files
- `ls .opencode/context/core/troubleshooting/` shows 1 file

## Testing & Validation

- [ ] Verify all 6 directories exist in `.opencode/context/core/`
- [ ] Verify 18 files copied (2 + 3 + 3 + 6 + 3 + 1)
- [ ] Count total files in `.opencode/context/core/` matches `.claude/extensions/core/context/`
- [ ] Verify no `.claude/` path references remain in copied files (use grep)
- [ ] Verify files are readable and well-formed markdown
- [ ] Compare directory structure between source and target

## Artifacts & Outputs

- `.opencode/context/core/guides/` (2 files)
- `.opencode/context/core/meta/` (3 files)
- `.opencode/context/core/processes/` (3 files)
- `.opencode/context/core/reference/` (6 files)
- `.opencode/context/core/repo/` (3 files)
- `.opencode/context/core/troubleshooting/` (1 file)

## Rollback/Contingency

If implementation fails or files are corrupted:
1. Remove the 6 newly created directories: `rm -rf .opencode/context/core/{guides,meta,processes,reference,repo,troubleshooting}/`
2. The existing 12 directories remain untouched
3. Re-run implementation from Phase 1
4. If specific files have issues, they can be re-copied individually from source

## File Inventory

### Source Files by Directory

**guides/** (2 files):
- extension-development.md
- loader-reference.md

**meta/** (3 files):
- context-revision-guide.md
- domain-patterns.md
- meta-guide.md

**processes/** (3 files):
- implementation-workflow.md
- planning-workflow.md
- research-workflow.md

**reference/** (6 files):
- artifact-templates.md
- README.md
- skill-agent-mapping.md
- state-management-schema.md
- team-wave-helpers.md
- workflow-diagrams.md

**repo/** (3 files):
- project-overview.md
- self-healing-implementation-details.md
- update-project.md

**troubleshooting/** (1 file):
- workflow-interruptions.md

**Total: 18 files**
