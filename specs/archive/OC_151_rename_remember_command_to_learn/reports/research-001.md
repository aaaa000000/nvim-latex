# Research Report: OC_151 Rename /remember to /learn

**Task**: OC_151 - rename_remember_command_to_learn  
**Started**: 2026-03-05T00:00:00Z  
**Completed**: 2026-03-05T00:30:00Z  
**Effort**: 2 hours  
**Dependencies**: None  
**Sources/Inputs**: Codebase search (78+ references to "skill-remember", 264+ references to "/remember")  
**Artifacts**: specs/OC_151_rename_remember_command_to_learn/reports/research-001.md  
**Standards**: report-format.md

---

## Executive Summary

Renaming the `/remember` command to `/learn` involves updating **47+ distinct references** across the OpenCode system. The primary files requiring changes are:

1. **Skill Definition**: `.opencode/skills/skill-remember/` directory must be renamed to `skill-learn/`
2. **Command Definition**: `.opencode/commands/remember.md` must be renamed to `learn.md` with updated content
3. **Skill Metadata**: `SKILL.md` header must change from `name: skill-remember` to `name: skill-learn`
4. **Documentation**: Multiple usage guides, READMEs, and troubleshooting docs
5. **Skill Index**: `.opencode/skills/README.md` listing
6. **Main System README**: `.opencode/README.md` memory system section

**Key Finding**: This is a **clean-break rename** scenario similar to the previous `/learn` → `/fix` rename (OC_142). Based on that precedent, **backward compatibility is NOT recommended** - the rename should be atomic with no aliases.

---

## Context & Scope

This research task analyzed all references to "skill-remember" and "/remember" in the codebase to identify every file that needs updating for a successful rename to "skill-learn" and "/learn".

**Scope Includes**:
- Skill directory and SKILL.md file
- Command definition file
- All documentation references
- Index files and navigation links
- Memory system documentation

**Scope Excludes**:
- Archive files (specs/archive/*) - historical records should NOT be modified
- Git history (.git/logs/*) - immutable history
- CHANGE_LOG.md entries - historical record of changes

---

## Findings

### Category 1: Core Skill and Command Files (CRITICAL - Must Update)

These files **must** be renamed or updated for the system to function:

| File | Current Path | New Path | Changes Required |
|------|-------------|----------|------------------|
| **Skill Directory** | `.opencode/skills/skill-remember/` | `.opencode/skills/skill-learn/` | Full directory rename |
| **SKILL.md** | `.opencode/skills/skill-remember/SKILL.md` | `.opencode/skills/skill-learn/SKILL.md` | Update name field, all references |
| **README.md** | `.opencode/skills/skill-remember/README.md` | `.opencode/skills/skill-learn/README.md` | Update links and content |
| **Command File** | `.opencode/commands/remember.md` | `.opencode/commands/learn.md` | Rename, update all /remember refs |

**Specific Changes in SKILL.md**:
- Line 2: `name: skill-remember` → `name: skill-learn`
- Line 266, 284: Example usage flows showing `/remember` → `/learn`
- All internal documentation references

**Specific Changes in Command File**:
- Line 5: `# Command: /remember` → `# Command: /learn`
- Line 9: `Delegates To: skill-remember` → `Delegates To: skill-learn`
- Lines 44, 47: skill references in workflow
- Lines 85, 112-113, 123-124, 133: All /remember command examples

### Category 2: Index and Navigation Files (HIGH PRIORITY)

These files list and link to the skill/command:

| File | Line(s) | Current Content | Required Change |
|------|---------|-----------------|-----------------|
| `.opencode/skills/README.md` | 18 | `- [skill-remember/](skill-remember/README.md)` | `- [skill-learn/](skill-learn/README.md)` |
| `.opencode/commands/README.md` | MISSING | No /remember listed | **ADD** `/learn` entry |
| `.opencode/docs/README.md` | 23 | `remember-usage.md` | `learn-usage.md` |
| `.opencode/docs/guides/README.md` | 23 | `remember-usage.md` | `learn-usage.md` |

### Category 3: Documentation Files (MEDIUM PRIORITY)

These files contain user-facing documentation:

| File | Path | Changes Required |
|------|------|------------------|
| **Usage Guide** | `.opencode/docs/guides/remember-usage.md` | Rename to `learn-usage.md`, update all /remember refs |
| **Main README** | `.opencode/README.md` | Lines 82-102: Memory system section |
| **Memory README** | `.opencode/memory/README.md` | Lines 22-24: Usage examples |

**Specific Changes in Main README.md**:
- Line 82: `/remember` examples → `/learn` examples
- Line 102: Link `[Usage Guide](docs/guides/remember-usage.md)` → `[Usage Guide](docs/guides/learn-usage.md)`

**Specific Changes in Memory README.md**:
- Lines 22-24: `/remember "text"` → `/learn "text"`

**Specific Changes in Usage Guide**:
- File rename: `remember-usage.md` → `learn-usage.md`
- Line 1: `# /remember Command Usage Guide` → `# /learn Command Usage Guide`
- Lines 8, 13, 19, 24, 29, 136, 146, 160, 183-185: All command examples

### Category 4: Other Documentation References (LOW PRIORITY)

These files reference the command but are less critical:

| File | References |
|------|------------|
| `.opencode/docs/examples/knowledge-capture-usage.md` | Lines 53-55, 60, 92, 114, 202, 250: All /remember --task examples |
| `.opencode/docs/guides/memory-troubleshooting.md` | Lines 43, 70, 87, 138, 236, 250: Troubleshooting references |
| `.opencode/memory/10-Memories/*.md` | Historical memory entries (preserve as-is) |

### Category 5: Archive and Historical Files (DO NOT MODIFY)

These files are historical records and should **NOT** be modified:

- `specs/archive/OC_*/**/*` - All historical task archives
- `specs/CHANGE_LOG.md` - Change history (append-only)
- `.git/logs/*` - Git history (immutable)

---

## Breaking Changes Analysis

### What Will Break If Not Updated

1. **Command Invocation**: Users typing `/remember` will fail
2. **Skill Loading**: References to `skill-remember` will fail to resolve
3. **Documentation Links**: Broken links in README files
4. **Skill Index**: Missing entry in skills/README.md

### Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| User muscle memory | Medium | Clean break, no aliases - users adapt quickly |
| Documentation confusion | Medium | Update all docs atomically |
| Skill delegation failures | **HIGH** | Must update all skill references |
| Broken navigation links | Low | Update all README links |

---

## Recommendations

### 1. Clean-Break Rename (RECOMMENDED)

Based on the successful precedent of renaming `/learn` to `/fix` in OC_142, implement a **clean-break rename** with **NO backward compatibility aliases**.

**Rationale**:
- The `/learn` → `/fix` rename was completed successfully without aliases
- Aliases create long-term technical debt
- Users adapt quickly to command renames
- The system is still in early development

### 2. Atomic Update Pattern

Follow the same pattern used in OC_142:

1. **Phase 1**: Rename skill directory and update SKILL.md
2. **Phase 2**: Rename command file and update content
3. **Phase 3**: Update all documentation files
4. **Phase 4**: Update all index/README files
5. **Phase 5**: Integration test

### 3. Files Requiring Updates (Summary)

**Critical Path (Rename + Content)**:
```
.opencode/skills/skill-remember/ → skill-learn/
.opencode/commands/remember.md → learn.md
.opencode/docs/guides/remember-usage.md → learn-usage.md
```

**Content Updates Only**:
```
.opencode/skills/skill-learn/SKILL.md (name field, examples)
.opencode/skills/skill-learn/README.md (title, links)
.opencode/commands/learn.md (all /remember refs)
.opencode/docs/guides/learn-usage.md (all /remember refs)
.opencode/skills/README.md (skill-remember → skill-learn)
.opencode/commands/README.md (ADD /learn entry)
.opencode/docs/README.md (remember-usage → learn-usage)
.opencode/docs/guides/README.md (remember-usage → learn-usage)
.opencode/README.md (memory system section)
.opencode/memory/README.md (usage examples)
```

**Optional Updates (Non-critical)**:
```
.opencode/docs/examples/knowledge-capture-usage.md
.opencode/docs/guides/memory-troubleshooting.md
```

### 4. Testing Strategy

After the rename:
1. Verify `/learn "test memory"` works
2. Verify `/learn --task 151` works (task mode)
3. Verify skill loads correctly
4. Check all documentation links
5. Verify memory vault operations work

---

## Decisions

1. **No Backward Compatibility**: Do NOT maintain `/remember` alias. Clean break only.
2. **Atomic Rename**: All files updated in single commit/implementation phase.
3. **Preserve History**: Do NOT modify archive files or CHANGE_LOG.md.
4. **Documentation Priority**: Update all user-facing docs before implementation.

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missed reference | Medium | Medium | Comprehensive grep search before commit |
| Broken skill loading | **HIGH** | Low | Test skill loading after rename |
| User confusion | Low | Medium | Update documentation first |
| Broken navigation | Low | Low | Update all README links atomically |

---

## Next Steps

1. **Run `/plan 151`** to create implementation plan
2. **Implementation order**:
   - Rename skill directory
   - Update SKILL.md metadata
   - Rename command file
   - Update all documentation
   - Update all index files
3. **Testing**: Verify `/learn` command works end-to-end
4. **Documentation**: Ensure all user guides are updated

---

## Appendix: Full Reference List

### All Files Containing "skill-remember" (Non-archive)

| File | Line(s) | Context |
|------|---------|---------|
| `.opencode/skills/skill-remember/SKILL.md` | 2 | name field |
| `.opencode/skills/skill-remember/README.md` | all | entire file |
| `.opencode/commands/remember.md` | 9, 44, 47 | delegation references |
| `.opencode/skills/README.md` | 18 | index listing |
| `specs/TODO.md` | 15 | task description |
| `specs/state.json` | 12 | task state |
| `specs/CHANGE_LOG.md` | 59 | historical record (preserve) |

### All Files Containing "/remember" (Non-archive, Non-git)

| File | Count | Priority |
|------|-------|----------|
| `.opencode/commands/remember.md` | 15 | **CRITICAL** |
| `.opencode/skills/skill-remember/SKILL.md` | 6 | **CRITICAL** |
| `.opencode/docs/guides/remember-usage.md` | 14 | **HIGH** |
| `.opencode/README.md` | 8 | **HIGH** |
| `.opencode/memory/README.md` | 3 | **MEDIUM** |
| `.opencode/docs/examples/knowledge-capture-usage.md` | 8 | **MEDIUM** |
| `.opencode/docs/guides/memory-troubleshooting.md` | 7 | **LOW** |
| `specs/TODO.md` | 2 | task description (preserve context) |
| `specs/state.json` | 1 | task state (preserve) |
| `specs/CHANGE_LOG.md` | 4 | historical (preserve) |

### Memory Entries (Preserve As-Is)

- `.opencode/memory/10-Memories/MEM-2026-03-05-003-memory-classification-taxonomy.md` - Historical memory, do not modify

---

## Appendix: Context Knowledge Candidates

### Candidate 1: Clean-Break Rename Pattern
**Type**: Pattern  
**Domain**: system-design  
**Target Context**: `.opencode/context/core/patterns/`  
**Content**: When renaming commands or components in OpenCode, use a clean-break approach with NO backward compatibility aliases. This was successfully applied in OC_142 (/learn → /fix) and should be the standard for all renames. Rationale: prevents technical debt, users adapt quickly, system is in early development.  
**Source**: OC_142 implementation and OC_151 research  
**Rationale**: This is a domain-general pattern applicable to any command/skill rename operation.

### Candidate 2: Skill Rename Checklist
**Type**: Pattern  
**Domain**: system-design  
**Target Context**: `.opencode/context/project/opencode/`  
**Content**: When renaming a skill from X to Y, update: 1) Directory name, 2) SKILL.md name field, 3) Command file name and content, 4) All documentation references, 5) All index/README listings. Do NOT modify: archive files, CHANGE_LOG.md, git history, existing memory entries.  
**Source**: OC_151 research findings  
**Rationale**: Reusable checklist for any skill rename operation.

---

*End of Research Report*
