# Implementation Plan: Fix /todo orphan detection for completed tasks not in state.json

- **Task**: OC_150 - Fix /todo orphan detection for completed tasks not in state.json
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/OC_150_fix_todo_orphan_detection/reports/research-001.md - Analysis of orphan detection gap
  - specs/OC_150_fix_todo_orphan_detection/reports/research-002.md - Comparison of .claude/ vs .opencode/ implementations
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/standards/documentation-standards.md
  - .opencode/context/core/standards/task-management.md
- **Type**: markdown

## Overview

Fix the /todo command's orphan detection logic to identify and archive completed tasks that exist in TODO.md but have been manually removed from state.json. Currently, tasks like OC_138, OC_139, and OC_140 are marked [COMPLETED] in TODO.md with existing directories in specs/, but are not being archived because the /todo command only scans state.json's active_projects array. This implementation adds TODO.md scanning to Stage 3, cross-references entries with state.json, and integrates TODO.md orphans into the archival workflow through Stages 9-11.

**Research Integration**:
- research-001.md identified the gap: /todo only scans state.json, missing TODO.md orphans
- research-002.md provides patterns from .claude/ implementation: filesystem-first detection and TODO.md cross-referencing

## Goals & Non-Goals

**Goals**:
- Add TODO.md scanning to extract completed/abandoned task entries
- Cross-reference TODO.md entries with state.json active_projects
- Identify "TODO.md orphans" (completed/abandoned in TODO.md but not in state.json)
- Integrate TODO.md orphans into Stage 9 interactive prompts
- Archive TODO.md orphans through Stage 10 like regular tasks
- Remove TODO.md orphan entries via Stage 11
- Update CHANGE_LOG.md with orphan archival entries
- Successfully detect and archive OC_138, OC_139, OC_140 as test cases

**Non-Goals**:
- No changes to .claude/ implementation
- No modifications to existing state.json archive structure
- No new memory harvesting logic
- No changes to roadmap scanning or CLAUDE.md suggestions
- No filesystem-level orphan detection (directories without TODO.md entries)

## Risks & Mitigations

- **Risk**: TODO.md parsing fails on edge case formats
  **Mitigation**: Use robust regex patterns with fallbacks; test against actual OC_138, OC_139, OC_140 entries
  
- **Risk**: State corruption if TODO.md orphan archival fails mid-operation
  **Mitigation**: Implement dry-run support first; validate all state changes before applying
  
- **Risk**: Duplicate archival if task exists in both state.json and TODO.md orphans list
  **Mitigation**: Deduplicate by project_number before archival; prefer state.json source when available
  
- **Risk**: Breaking existing orphan detection for filesystem-level orphans
  **Mitigation**: Preserve existing Stage 3 filesystem scanning logic; add TODO.md scanning as parallel operation

## Implementation Phases

### Phase 1: Analyze TODO.md format and extraction patterns [NOT STARTED]
- **Goal**: Understand TODO.md structure and define extraction logic
- **Tasks**:
  - [ ] Read specs/TODO.md and analyze task entry patterns
  - [ ] Identify header format: `### OC_{N}. {title}` or `### {N}. {title}`
  - [ ] Identify status format: `- **Status**: [COMPLETED]` or `[ABANDONED]`
  - [ ] Document extraction regex patterns for headers and status
  - [ ] Extract OC_138, OC_139, OC_140 as test cases
  - [ ] Verify directory existence for each TODO.md orphan candidate
- **Timing**: 30 minutes

### Phase 2: Design TODO.md orphan detection logic [NOT STARTED]
- **Goal**: Design the cross-referencing algorithm
- **Tasks**:
  - [ ] Define `todo_md_orphans` array structure
  - [ ] Design extraction function: parse TODO.md headers + status
  - [ ] Design cross-reference logic: check if project_number in state.json active_projects
  - [ ] Define orphan criteria: status in [COMPLETED, ABANDONED] AND not in state.json
  - [ ] Document edge cases (legacy numeric IDs vs OC_ prefixed)
  - [ ] Create test plan for detection logic
- **Timing**: 30 minutes

### Phase 3: Update Stage 3 - Add TODO.md scanning to ScanTasks [NOT STARTED]
- **Goal**: Integrate TODO.md scanning into existing orphan detection
- **Tasks**:
  - [ ] Read current skill-todo/SKILL.md Stage 2 and Stage 3
  - [ ] Add Step 2.5: Read and parse TODO.md content
  - [ ] Add Step 3.3: Cross-reference TODO.md entries with state.json
  - [ ] Add Step 3.4: Populate `todo_md_orphans` array
  - [ ] Update Stage 3 process description to include TODO.md scanning
  - [ ] Preserve existing filesystem orphan detection (Steps 3.1-3.2)
  - [ ] Add validation: verify directory exists for each TODO.md orphan
- **Timing**: 45 minutes

### Phase 4: Update Stage 9 - Add TODO.md orphan prompts [NOT STARTED]
- **Goal**: Present TODO.md orphans for user confirmation
- **Tasks**:
  - [ ] Add Step 9.1: Check if `todo_md_orphans` array is non-empty
  - [ ] Display header: "Found {N} completed/abandoned tasks in TODO.md not tracked in state.json:"
  - [ ] List each orphan with: task number, status, directory location
  - [ ] Add AskUserQuestion: "Archive these TODO.md orphans?" with options
  - [ ] Options: "Archive all", "Review individually", "Skip orphans"
  - [ ] Store user decision for Stage 10 processing
- **Timing**: 30 minutes

### Phase 5: Update Stage 10 - Archive TODO.md orphans [NOT STARTED]
- **Goal**: Archive TODO.md orphans like regular tasks
- **Tasks**:
  - [ ] Add Step 10.3: Process TODO.md orphans (if user approved)
  - [ ] For each TODO.md orphan:
    - [ ] Create archive entry in specs/archive/state.json
    - [ ] Include: project_number, project_name, status, archived timestamp
    - [ ] Move directory from specs/ to specs/archive/
    - [ ] Track for CHANGE_LOG.md entry
  - [ ] Handle case where orphan has no directory (state-only archival)
  - [ ] Ensure deduplication with state.json orphans
- **Timing**: 45 minutes

### Phase 6: Update Stage 11 - Remove TODO.md orphan entries [NOT STARTED]
- **Goal**: Ensure TODO.md entries are removed for archived orphans
- **Tasks**:
  - [ ] Update Step 11.1 to include TODO.md orphans in removal list
  - [ ] Remove entire task section (from `###` header to next `###` or `---`)
  - [ ] Update next_project_number in TODO.md frontmatter if needed
  - [ ] Ensure CHANGE_LOG.md entries created for orphans
  - [ ] Verify entries are actually removed from TODO.md
- **Timing**: 30 minutes

### Phase 7: Test with real orphans (OC_138, OC_139, OC_140) [NOT STARTED]
- **Goal**: Validate fix with known orphan tasks
- **Tasks**:
  - [ ] Run /todo --dry-run and verify orphans are detected
  - [ ] Confirm OC_138, OC_139, OC_140 appear in orphan list
  - [ ] Verify directory locations are correctly identified
  - [ ] Test interactive prompts for TODO.md orphans
  - [ ] Execute archival and verify:
    - [ ] Directories moved to specs/archive/
    - [ ] Entries removed from TODO.md
    - [ ] Entries added to specs/archive/state.json
    - [ ] CHANGE_LOG.md updated
  - [ ] Document any issues found
- **Timing**: 30 minutes

## Testing & Validation

- [ ] Unit test: TODO.md parsing extracts correct task numbers and status
- [ ] Unit test: Cross-reference logic identifies OC_138, OC_139, OC_140 as orphans
- [ ] Integration test: /todo --dry-run displays TODO.md orphans in preview
- [ ] Integration test: Interactive prompt shows TODO.md orphans with correct status
- [ ] Integration test: Archival moves directories to specs/archive/
- [ ] Integration test: Archival removes entries from TODO.md
- [ ] Integration test: Archival adds entries to specs/archive/state.json
- [ ] Integration test: CHANGE_LOG.md includes orphan archival entries
- [ ] Regression test: Existing state.json orphan detection still works
- [ ] Regression test: Normal task archival flow unchanged
- [ ] Edge case test: Handle legacy numeric task IDs (e.g., "87", "78")
- [ ] Edge case test: Handle tasks without directories

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- Modified: .opencode/skills/skill-todo/SKILL.md
  - Stage 2: Added TODO.md reading step
  - Stage 3: Added TODO.md scanning and cross-reference logic
  - Stage 9: Added TODO.md orphan prompts
  - Stage 10: Added TODO.md orphan archival
  - Stage 11: Updated to include TODO.md orphans in removal
- Test results: OC_138, OC_139, OC_140 successfully archived
- summaries/implementation-summary-2026-03-06.md (post-implementation)

## Rollback/Contingency

If implementation fails or introduces bugs:

1. **Pre-implementation backup**:
   - Copy .opencode/skills/skill-todo/SKILL.md to SKILL.md.backup.$(date +%s)
   - Copy specs/state.json to state.json.backup.$(date +%s)
   - Copy specs/TODO.md to TODO.md.backup.$(date +%s)

2. **Rollback procedure**:
   ```bash
   # Restore original files
   cp SKILL.md.backup.* .opencode/skills/skill-todo/SKILL.md
   cp state.json.backup.* specs/state.json
   cp TODO.md.backup.* specs/TODO.md
   
   # Verify restoration
   git diff --stat
   ```

3. **Partial failure handling**:
   - If TODO.md scanning breaks: Disable Step 2.5, revert to state.json-only scanning
   - If archival fails: Manual cleanup using .claude/ /todo command
   - If state corruption occurs: Restore from backup, file-by-file verification

4. **Emergency contacts** (metaphorical):
   - Reference .claude/ implementation as working alternative
   - Use filesystem-first detection from .claude/ as fallback pattern

---

## plan_metadata

```json
{
  "phases": 7,
  "total_effort_hours": 3.5,
  "complexity": "medium",
  "research_integrated": true,
  "plan_version": 1,
  "reports_integrated": [
    {
      "path": "reports/research-001.md",
      "integrated_in_plan_version": 1,
      "integrated_date": "2026-03-06"
    },
    {
      "path": "reports/research-002.md",
      "integrated_in_plan_version": 1,
      "integrated_date": "2026-03-06"
    }
  ]
}
```
