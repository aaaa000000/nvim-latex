# Research Report: /todo Orphan Detection Bug (OC_150)

**Date:** 2026-03-06  
**Task:** OC_150 - Fix /todo orphan detection for completed tasks not in state.json

---

## Executive Summary

The /todo command has a critical gap in its orphan detection logic. Tasks that are marked [COMPLETED] in TODO.md but have been manually removed from state.json are not being archived. This leaves orphaned completed tasks in the active specs/ directory and TODO.md file.

---

## Problem Description

### Current Behavior

The /todo command's Stage 3 (ScanTasks) performs the following:
1. Reads specs/state.json
2. Identifies tasks with `status = "completed"` in active_projects array
3. Identifies tasks with `status = "abandoned"` in active_projects array

**Gap:** It does NOT scan TODO.md for completed/abandoned entries that may have been removed from state.json.

### Real-World Example

The following tasks were discovered as orphans during OC_142/OC_143 archival:

| Task | TODO.md Status | Directory Exists | In state.json? | Archived? |
|------|---------------|------------------|----------------|-----------|
| OC_138 | [COMPLETED] | Yes (specs/) | No | No |
| OC_139 | [COMPLETED] | Yes (specs/) | No | No |
| OC_140 | [COMPLETED] | Yes (specs/) | No | No |
| 87 | [COMPLETED] | Unknown | Unknown | Unknown |
| 78 | [COMPLETED] | Unknown | Unknown | Unknown |

**Impact:** These completed tasks remain in the active workflow even though they should have been archived.

---

## Root Cause Analysis

### Detection Logic Gap

The skill-todo SKILL.md Stage 3 only considers:
```
active_projects[].status == "completed" OR "abandoned"
```

It ignores TODO.md entries with status markers like:
```markdown
- **Status**: [COMPLETED]
- **Status**: [ABANDONED]
```

### Why This Happens

1. **Manual state.json edits**: Tasks may be manually removed from state.json during cleanup
2. **Legacy tasks**: Older tasks may predate the archival system
3. **State corruption**: Interrupted operations may leave inconsistent state
4. **Testing scenarios**: Test tasks may be created and completed without proper archival

---

## Required Fixes

### Stage 3: ScanTasks Enhancement

Add TODO.md scanning:

```markdown
**Step 3.2 - Scan TODO.md for Orphans:**
1. Read specs/TODO.md
2. Extract all task entries with patterns:
   - `### OC_{N}. ` or `### {N}. ` for task headers
   - `- **Status**: \[COMPLETED\]` for completed status
   - `- **Status**: \[ABANDONED\]` for abandoned status
3. For each TODO.md task found:
   - Extract project_number from header
   - Check if in state.json active_projects
   - If NOT in state.json AND status is completed/abandoned:
     - Add to `todo_md_orphans` array
     - Flag for archival
```

### Stage 9: InteractivePrompts Enhancement

Add prompt for TODO.md orphans:

```markdown
**Step 9.1 - Present TODO.md Orphans:**
If todo_md_orphans found:
- Display: "Found {N} completed/abandoned tasks in TODO.md not tracked in state.json:"
- List each orphan with status
- AskUserQuestion: "Archive these TODO.md orphans?"
- Store user decision
```

### Stage 10: ArchiveTasks Enhancement

Handle both types of orphans:

```markdown
**Step 10.1 - Archive State.json Orphans:**
(Move existing logic here)

**Step 10.2 - Archive TODO.md Orphans:**
For each task in todo_md_orphans:
- Create archive entry (similar to state.json tasks)
- Move directory to specs/archive/
- Update specs/archive/state.json
- Track for CHANGE_LOG.md
```

### Stage 11: UpdateTODO Enhancement

Ensure TODO.md orphans are removed:

```markdown
**Step 11.1 - Remove Archived Entries:**
For all archived tasks (both types):
- Remove corresponding TODO.md entry
- Update next_project_number if needed
```

---

## Implementation Complexity

| Phase | Complexity | Effort |
|-------|-----------|--------|
| Parse TODO.md format | Medium | 30 min |
| Cross-reference logic | Medium | 45 min |
| Add orphan detection | Low | 30 min |
| Update prompts | Low | 20 min |
| Test scenarios | Medium | 30 min |
| **Total** | | **~2.5 hours** |

---

## Test Scenarios

### Scenario 1: TODO.md Orphan Only
- Task marked [COMPLETED] in TODO.md
- Directory exists in specs/
- NOT in state.json
- **Expected:** Detected and offered for archival

### Scenario 2: State.json Orphan Only
- Task marked "completed" in state.json
- Directory exists in specs/
- NOT in TODO.md (unusual but possible)
- **Expected:** Detected and offered for archival

### Scenario 3: Both Orphan Types
- Mix of TODO.md orphans and state.json orphans
- **Expected:** Both detected and archived together

### Scenario 4: No Orphans
- All completed tasks properly archived
- **Expected:** No orphans detected, normal flow

---

## Files to Modify

1. **.opencode/skills/skill-todo/SKILL.md**
   - Stage 3: Add TODO.md scanning (Step 3.2)
   - Stage 9: Add TODO.md orphan prompts (Step 9.1)
   - Stage 10: Add TODO.md orphan archival (Step 10.2)
   - Stage 11: Ensure removal from TODO.md

---

## Success Criteria

- [ ] OC_138, OC_139, OC_140 properly detected as orphans
- [ ] User prompted to archive these TODO.md orphans
- [ ] Directories moved to specs/archive/
- [ ] Entries removed from TODO.md
- [ ] CHANGE_LOG.md updated with orphan archival entries
- [ ] Git commit includes all changes

---

## Notes

### Related Issues
- This fix complements the existing orphan detection (Stage 3, Step 3.x)
- Should be tested alongside normal archival workflow
- May reveal other orphaned tasks in the system

### Backwards Compatibility
- Changes are additive - existing functionality preserved
- No breaking changes to command interface
- Existing archived tasks remain unaffected

---

**Report created:** 2026-03-06  
**Recommended next step:** Create implementation plan for skill-todo updates
