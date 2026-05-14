# Implementation Plan: Task #512

- **Task**: 512 - port_missing_domain_extensions
- **Status**: [COMPLETED]
- **Effort**: 6-8 hours
- **Dependencies**: None
- **Research Inputs**: specs/OC_512_port_missing_domain_extensions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Port 3 missing domain extensions from `.claude/extensions/` to `.opencode/extensions/`. The extensions form a dependency chain: slidev (base) → present (depends on slidev) → founder (depends on slidev).

**Porting Strategy**: Copy all files with path adaptations and manifest transformations, maintaining directory structure and content integrity.

### Research Integration

Research findings establish the scope:
- **slidev/**: 19 files, ~1,000 lines - Resource-only extension (no agents/commands/skills)
- **present/**: 95 files, ~12,000 lines - 9 agents, 7 skills, 5 commands
- **founder/**: 121 files, ~24,000 lines - 16 agents, 15 skills, 9 commands

**Critical transformations**:
1. Path: `.claude/` → `.opencode/`
2. Path: `CLAUDE.md` → `AGENTS.md`
3. Manifest: `task_type` → `language`
4. Manifest: `claudemd` merge target → `opencode_md`

## Goals & Non-Goals

**Goals**:
- Port slidev extension completely (19 files)
- Port present extension completely (95 files, 9 agents, 7 skills, 5 commands)
- Port founder extension completely (121 files, 16 agents, 15 skills, 9 commands)
- Update all manifest.json files with OpenCode schema
- Preserve all file content, directory structure, and functionality
- Update internal references from .claude to .opencode paths

**Non-Goals**:
- No functional changes to extension logic
- No new features or improvements
- No removal of deprecated features
- No verification testing (beyond basic file existence)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| File path errors during copy | High | Medium | Use explicit file lists, verify with find/locate |
| Manifest schema errors | High | Low | Compare against working examples in .opencode/extensions/ |
| Missing internal references | Medium | Medium | Grep for `.claude/` patterns in ported files |
| Dependency chain issues | High | Low | Port in dependency order: slidev → present → founder |
| Binary file corruption | Low | Low | Use cp -r for binary files, verify with file command |

## Implementation Phases

### Phase 1: Port slidev Extension [COMPLETED]

**Goal**: Port resource-only slidev extension (19 files, ~1,000 lines)

**Tasks**:
- [ ] Create `.opencode/extensions/slidev/` directory structure
- [ ] Copy all animation files (6 files in context/project/slidev/animation/)
- [ ] Copy all style files (9 files in context/project/slidev/style/)
- [ ] Copy manifest.json, EXTENSION.md, README.md, index-entries.json
- [ ] Transform manifest.json:
  - Keep `name`, `version`, `description`
  - Change merge target from `claudemd` to `opencode_md`
  - Update target path: `.claude/CLAUDE.md` → `.opencode/AGENTS.md`
  - Update section_id: `extension_present` → `extension_oc_slidev`
  - Update index target: `.claude/context/index.json` → `.opencode/context/index.json`

**Timing**: 30-45 minutes

**Files to modify**:
- `.opencode/extensions/slidev/manifest.json` - Transform to OpenCode schema

**Verification**:
- [ ] All 19 files copied to correct locations
- [ ] `find .opencode/extensions/slidev -type f | wc -l` returns 19
- [ ] manifest.json has `opencode_md` merge target with correct path
- [ ] No references to `.claude/` in any ported files

---

### Phase 2: Port present Extension [COMPLETED]

**Goal**: Port present extension (95 files, ~12,000 lines, 9 agents, 7 skills, 5 commands)

**Tasks**:
- [ ] Create `.opencode/extensions/present/` directory structure
- [ ] Copy all command files (5 files in commands/)
- [ ] Copy all skill files (7 SKILL.md files in skills/)
- [ ] Copy all agent files (9 files in agents/)
- [ ] Copy all context files (project/present/domain/, patterns/, talk/)
- [ ] Copy manifest.json, EXTENSION.md, README.md, index-entries.json, opencode-agents.json
- [ ] Transform manifest.json:
  - Change `task_type` to `language`
  - Change merge target from `claudemd` to `opencode_md`
  - Update target path: `.claude/CLAUDE.md` → `.opencode/AGENTS.md`
  - Update section_id: `extension_present` → `extension_oc_present`
  - Update index target: `.claude/context/index.json` → `.opencode/context/index.json`
  - Update dependencies: verify slidev dependency still valid
- [ ] Update internal references in README.md:
  - Change `../slidev/README.md` to correct relative path
  - Change any `.claude/` references to `.opencode/`

**Timing**: 2-2.5 hours

**Files to modify**:
- `.opencode/extensions/present/manifest.json` - Transform to OpenCode schema
- `.opencode/extensions/present/README.md` - Update cross-references

**Verification**:
- [ ] All 95 files copied to correct locations
- [ ] `find .opencode/extensions/present -type f | wc -l` returns 95
- [ ] manifest.json has `language` field (not `task_type`)
- [ ] manifest.json has `opencode_md` merge target
- [ ] No references to `.claude/` in any ported files

---

### Phase 3: Port founder Extension [COMPLETED]

**Goal**: Port founder extension (121 files, ~24,000 lines, 16 agents, 15 skills, 9 commands)

**Tasks**:
- [ ] Create `.opencode/extensions/founder/` directory structure
- [ ] Copy all command files (9 files in commands/)
- [ ] Copy all skill files (15 SKILL.md files in skills/)
- [ ] Copy all agent files (16 files in agents/)
- [ ] Copy all context files (project/founder/domain/, patterns/, templates/, deck/)
- [ ] Copy manifest.json, EXTENSION.md, README.md, index-entries.json
- [ ] Transform manifest.json:
  - Change `task_type` to `language`
  - Change merge target from `claudemd` to `opencode_md`
  - Update target path: `.claude/CLAUDE.md` → `.opencode/AGENTS.md`
  - Update section_id: `extension_founder` → `extension_oc_founder`
  - Update index target: `.claude/context/index.json` → `.opencode/context/index.json`
  - Keep MCP server configurations (sec-edgar, firecrawl)
- [ ] Update internal references in README.md:
  - Change `../slidev/README.md` to correct relative path
  - Change any `.claude/` references to `.opencode/`

**Timing**: 2.5-3 hours

**Files to modify**:
- `.opencode/extensions/founder/manifest.json` - Transform to OpenCode schema
- `.opencode/extensions/founder/README.md` - Update cross-references

**Verification**:
- [ ] All 121 files copied to correct locations
- [ ] `find .opencode/extensions/founder -type f | wc -l` returns 121
- [ ] manifest.json has `language` field (not `task_type`)
- [ ] manifest.json has `opencode_md` merge target
- [ ] No references to `.claude/` in any ported files

---

### Phase 4: Verification and Cross-Reference Update [COMPLETED]

**Goal**: Verify complete port and fix any remaining references

**Tasks**:
- [ ] Run file count verification for all three extensions
- [ ] Grep for any remaining `.claude/` references in ported files
- [ ] Verify manifest.json schemas match OpenCode format
- [ ] Check that all binary files (PPTX, images) copied correctly
- [ ] Verify directory structure matches source

**Timing**: 30-45 minutes

**Files to verify**:
- `.opencode/extensions/slidev/manifest.json`
- `.opencode/extensions/present/manifest.json`
- `.opencode/extensions/founder/manifest.json`

**Verification commands**:
```bash
# File counts
echo "slidev: $(find .opencode/extensions/slidev -type f | wc -l) files"
echo "present: $(find .opencode/extensions/present -type f | wc -l) files"
echo "founder: $(find .opencode/extensions/founder -type f | wc -l) files"

# Check for stray .claude references
grep -r "\.claude/" .opencode/extensions/slidev/ || echo "slidev: clean"
grep -r "\.claude/" .opencode/extensions/present/ || echo "present: clean"
grep -r "\.claude/" .opencode/extensions/founder/ || echo "founder: clean"

# Verify manifest structure
jq '.language // .task_type' .opencode/extensions/*/manifest.json
```

---

### Phase 5: Documentation Update [COMPLETED]

**Goal**: Update task status and create completion summary

**Tasks**:
- [ ] Update TODO.md with completion status
- [ ] Update state.json with task status "completed"
- [ ] Create completion summary in specs/OC_512_port_missing_domain_extensions/summaries/
- [ ] Commit all changes with appropriate message

**Timing**: 15-20 minutes

**Files to modify**:
- `specs/TODO.md` - Mark task 512 as completed
- `specs/state.json` - Update task status
- `specs/OC_512_port_missing_domain_extensions/summaries/completion-summary.md` - Create summary

**Verification**:
- [ ] Git status shows all new files in .opencode/extensions/
- [ ] No uncommitted changes
- [ ] Commit message follows convention: "task 512: port slidev, present, founder extensions"

## Testing & Validation

- [ ] All 235 files (19 + 95 + 121) successfully copied to .opencode/extensions/
- [ ] File counts match source extensions
- [ ] No `.claude/` references remain in ported files
- [ ] All manifest.json files have correct OpenCode schema:
  - `language` field (not `task_type`)
  - `opencode_md` merge target (not `claudemd`)
  - Correct target paths (`.opencode/` not `.claude/`)
- [ ] Binary files (PPTX, images) preserved correctly
- [ ] Directory structure maintained

## Artifacts & Outputs

- `.opencode/extensions/slidev/` - Complete slidev extension (19 files)
- `.opencode/extensions/present/` - Complete present extension (95 files)
- `.opencode/extensions/founder/` - Complete founder extension (121 files)
- `specs/OC_512_port_missing_domain_extensions/summaries/completion-summary.md` - Completion documentation

## Rollback/Contingency

**If porting fails mid-process:**
1. Remove partially ported extension directory: `rm -rf .opencode/extensions/{extname}/`
2. Fix identified issues
3. Re-run from beginning of failed phase

**If manifest schema errors discovered:**
1. Compare against working examples in `.opencode/extensions/lean/manifest.json`
2. Fix schema issues
3. Re-verify with jq validation

**If file count mismatch:**
1. Compare source and destination with `find` and `diff`
2. Identify missing files
3. Copy individually with `cp --parents`

## Summary Statistics

| Extension | Files | Lines | Agents | Skills | Commands | Est. Time |
|-----------|-------|-------|--------|--------|----------|-----------|
| slidev | 19 | ~1,000 | 0 | 0 | 0 | 30-45 min |
| present | 95 | ~12,000 | 9 | 7 | 5 | 2-2.5 hrs |
| founder | 121 | ~24,000 | 16 | 15 | 9 | 2.5-3 hrs |
| **Total** | **235** | **~37,000** | **25** | **22** | **14** | **6-8 hrs** |
