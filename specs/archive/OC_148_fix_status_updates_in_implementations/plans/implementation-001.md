# Implementation Plan: Fix Status Updates During Implementation Phases

- **Task**: OC_148 - fix_status_updates_in_implementations
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/OC_148_fix_status_updates_in_implementations/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/standards/documentation-standards.md
  - .opencode/context/core/standards/task-management.md
  - .opencode/context/core/patterns/jq-escaping-workarounds.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses critical gaps in the implementation workflow where task and phase status updates are not being properly synchronized. The research identified 6 specific gaps across skill-implementer, general-implementation-agent, and implement.md command that cause status inconsistencies during the implementation phase.

The implementation follows a layered approach: first fixing the skill-level preflight and postflight stages with explicit jq commands, then removing duplicate logic from the command level, and finally adding verification mechanisms to catch status mismatches.

### Research Integration

This plan integrates findings from research-001.md which identified:
- **Finding 1**: skill-implementer preflight lacks explicit jq commands for status updates (lines 68-77)
- **Finding 2**: skill-implementer postflight lacks detailed stage breakdown (lines 80-88)
- **Finding 3**: general-implementation-agent has phase logic but no task status updates
- **Finding 4**: implement.md has duplicate status update description (lines 65-68)
- **Finding 5**: Missing TODO.md status updates in skill-implementer
- **Finding 6**: Phase verification doesn't catch [NOT STARTED] during active work

## Goals & Non-Goals

**Goals**:
- Add explicit jq/bash commands to skill-implementer preflight for updating state.json and TODO.md to [IMPLEMENTING]
- Expand skill-implementer postflight with detailed stages 5-10 matching skill-researcher pattern
- Remove duplicate status update logic from implement.md command
- Add phase status pre-check to skill-implementer preflight
- Enhance phase verification to catch [NOT STARTED] phases during active work
- Ensure consistent status synchronization across all workflow layers

**Non-Goals**:
- Do not modify general-implementation-agent phase marking logic (it correctly handles [IN PROGRESS] at Stage 4A)
- Do not change the overall workflow architecture (command -> skill -> agent)
- Do not add new status markers or transition rules (use existing status-markers.md)
- Do not modify skill-researcher or skill-planner (they already have correct patterns)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Double status updates if both command and skill update | Medium | Medium | Remove status update from implement.md (Priority 3) - single source of truth in skill |
| jq command syntax errors corrupt state.json | High | Low | Use temp file pattern from jq-escaping-workarounds.md; test commands before applying |
| Phase status and task status get out of sync | Medium | Medium | Add preflight verification (Priority 4) and enhanced postflight verification |
| Breaking existing implementation workflows | High | Low | Make additive changes first; verify each phase before proceeding; maintain backward compatibility |
| Agent doesn't mark phases [IN PROGRESS] | Medium | Medium | Add preflight verification that can auto-correct or warn (Priority 4) |

## Implementation Phases

### Phase 1: Update skill-implementer Preflight with Explicit Status Commands [COMPLETED]

**Goal**: Add detailed jq and Edit commands to skill-implementer preflight for updating task status to [IMPLEMENTING]

**Tasks**:
- [ ] Read current skill-implementer/SKILL.md lines 68-77 (Preflight section)
- [ ] Add explicit jq command for updating state.json status to "implementing" with timestamp
- [ ] Add Edit tool command for updating TODO.md status marker to [IMPLEMENTING]
- [ ] Add postflight marker file creation command
- [ ] Verify the pattern matches skill-researcher preflight structure (lines 66-77)

**Implementation Details**:

Add to skill-implementer/SKILL.md after line 77:

```markdown
   - **Update state.json to implementing**:
     ```bash
     jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg status "implementing" \
       '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
         status: $status,
         last_updated: $ts,
         implementing: $ts
       }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
     ```
   
   - **Update TODO.md to [IMPLEMENTING]**:
     ```
     Edit file: specs/${padded_num}_${project_name}/TODO.md
     oldString: "- **Status**: [PLANNED]"
     newString: "- **Status**: [IMPLEMENTING]"
     ```
   
   - **Create postflight marker file**:
     ```bash
     touch "specs/${padded_num}_${project_name}/.postflight-pending"
     ```

**Timing**: 45 minutes

### Phase 2: Expand skill-implementer Postflight with Detailed Stages [COMPLETED]

**Goal**: Add stages 5-10 to skill-implementer postflight matching skill-researcher pattern for status transitions and artifact linking

**Tasks**:
- [ ] Read current skill-implementer/SKILL.md lines 80-88 (Postflight section)
- [ ] Add Stage 5: Parse Subagent Return (read metadata file)
- [ ] Add Stage 6: Update Task Status in state.json (implementing -> completed/partial)
- [ ] Add Stage 6a: Update TODO.md Status (change marker to [COMPLETED] or [PARTIAL])
- [ ] Add Stage 7: Link Artifacts in state.json (two-step jq pattern)
- [ ] Add Stage 7a: Update TODO.md Artifacts
- [ ] Add Stage 8: Git Commit
- [ ] Add Stage 9: Cleanup
- [ ] Add Stage 10: Return Brief Summary
- [ ] Add Error Handling subsection for postflight stages

**Implementation Details**:

Replace lines 80-88 in skill-implementer/SKILL.md with:

```markdown
4. **Postflight**: Read metadata file and update state + TODO using {file_metadata} and {jq_workarounds}.

   **Stage 5: Parse Subagent Return**
   - Read metadata file and validate JSON:
     ```bash
     metadata_file="specs/${padded_num}_${project_name}/.return-meta.json"
     if [ -f "$metadata_file" ] && jq empty "$metadata_file" 2>/dev/null; then
         status=$(jq -r '.status' "$metadata_file")
         phases_completed=$(jq -r '.metadata.phases_completed // 0' "$metadata_file")
         phases_total=$(jq -r '.metadata.phases_total // 0' "$metadata_file")
         artifact_path=$(jq -r '.artifacts[0].path // ""' "$metadata_file")
         artifact_type=$(jq -r '.artifacts[0].type // ""' "$metadata_file")
         artifact_summary=$(jq -r '.artifacts[0].summary // ""' "$metadata_file")
     fi
     ```

   **Stage 6: Update Task Status in state.json**
   - Determine final status based on metadata:
     - If `status` == "implemented" and `phases_completed` == `phases_total`: use "completed"
     - If `status` == "partial": use "partial"
     - Otherwise: keep "implementing"
   - Update state.json with timestamp:
     ```bash
     final_status="completed"  # or "partial" based on logic above
     jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg status "$final_status" \
       '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
         status: $status,
         last_updated: $ts,
         ${final_status}: $ts
       }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
     ```

   **Stage 6a: Update TODO.md Status**
   - Edit TODO.md to change status marker:
     ```
     Edit file: specs/${padded_num}_${project_name}/TODO.md
     oldString: "- **Status**: [IMPLEMENTING]"
     newString: "- **Status**: [COMPLETED]"  # or [PARTIAL] based on final_status
     ```

   **Stage 7: Link Artifacts in state.json**
   - Use two-step jq pattern to avoid Issue #1132:
     ```bash
     # Step 1: Filter out existing summary artifacts
     jq '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
         [(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type == "summary" | not)]' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
     
     # Step 2: Add new summary artifact
     jq --arg path "$artifact_path" \
        --arg type "$artifact_type" \
        --arg summary "$artifact_summary" \
       '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
     ```

   **Stage 7a: Update TODO.md Artifacts**
   - Add artifact link to TODO.md:
     ```
     Edit file: specs/${padded_num}_${project_name}/TODO.md
     Add to Artifacts section:
     "- [${artifact_path}](${artifact_path}) - ${artifact_summary}"
     ```

   **Stage 8: Git Commit**
   - Stage all changes and commit:
     ```bash
     git add -A
     git commit -m "task ${task_number}: complete implementation

     Session: ${session_id}

     Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
     ```

   **Stage 9: Cleanup**
   - Remove marker and metadata files:
     ```bash
     rm -f "specs/${padded_num}_${project_name}/.postflight-pending"
     rm -f "specs/${padded_num}_${project_name}/.postflight-loop-guard"
     rm -f "specs/${padded_num}_${project_name}/.return-meta.json"
     ```

   **Stage 10: Return Brief Summary**
   - Return concise text summary (3-6 bullet points):
     ```
     Implementation completed for task {N}:
     - Status updated to [COMPLETED] (or [PARTIAL])
     - Phases completed: {phases_completed}/{phases_total}
     - Summary created at: {artifact_path}
     - Artifacts linked in state.json and TODO.md
     - Git commit: task {N}: complete implementation
     ```

   **Error Handling**:
   - If metadata file missing or invalid JSON: Log error, skip artifact linking
   - If jq command fails: Log error, preserve original state.json
   - If git commit fails: Log warning, continue (do not block on git)
   - If TODO.md edit fails: Log error, state.json still updated

**Timing**: 90 minutes

### Phase 3: Remove Duplicate Status Logic from implement.md [COMPLETED]

**Goal**: Remove or clarify the duplicate status update description in implement.md command to avoid confusion with skill-implementer preflight

**Tasks**:
- [ ] Read current implement.md lines 64-68 (Step 5: Update status to IMPLEMENTING)
- [ ] Replace with reference to skill-implementer handling the update
- [ ] Ensure command focuses on validation and delegation only
- [ ] Verify no other duplicate status logic exists in the file

**Implementation Details**:

Change implement.md lines 64-68 from:
```markdown
### 5. Update status to IMPLEMENTING

Edit `specs/state.json`: set `status` to `"implementing"`, update `last_updated`.

Edit `specs/TODO.md`: change current status marker to `[IMPLEMENTING]` on the `### OC_N.` entry.
```

To:
```markdown
### 5. Invoke skill-implementer

**Call skill tool** to execute the implementation workflow:

```
→ Tool: skill
→ Name: skill-implementer
→ Prompt: Execute implementation plan for task {N} with language {language}
```

The skill-implementer will:
1. Load context files (plan-format.md, status-markers.md)
2. Execute preflight (validate, display header, update status to [IMPLEMENTING])
3. **Call Task tool with `subagent_type="general-implementation-agent"`** to execute phases
4. Execute postflight (update state.json to COMPLETED/PARTIAL, create summary, update TODO.md, commit)
5. Return results

**Note**: Status updates are handled by skill-implementer, not this command. The skill updates:
- state.json status to "implementing" in preflight
- state.json status to "completed" or "partial" in postflight
- TODO.md status markers at both stages
```

**Timing**: 30 minutes

### Phase 4: Add Phase Status Pre-check to skill-implementer Preflight [COMPLETED]

**Goal**: Add verification that current phase is marked [IN PROGRESS] before delegation, with auto-correction capability

**Tasks**:
- [ ] Add new subsection "2a. Verify Phase Status" after preflight status update
- [ ] Implement logic to read plan file and find first non-[COMPLETED] phase
- [ ] Add check that phase shows [IN PROGRESS]
- [ ] Add auto-correction logic: if [NOT STARTED], update to [IN PROGRESS]
- [ ] Add warning log for any corrections made

**Implementation Details**:

Add to skill-implementer/SKILL.md after the preflight status update section (after line 77, before Delegate section):

```markdown
### 2a. Verify Phase Status

**Purpose**: Ensure the current implementation phase is marked [IN PROGRESS] before delegation.

**Process**:
1. Read the plan file from `specs/${padded_num}_${project_name}/plans/implementation-*.md` (highest version)
2. Extract all phase headings using regex: `### Phase \d+: .*? \[(NOT STARTED|IN PROGRESS|COMPLETED|PARTIAL)\]`
3. Find the first phase that is not [COMPLETED]
4. Verify it shows [IN PROGRESS]
5. If it shows [NOT STARTED]:
   - Update the phase status to [IN PROGRESS] using Edit tool
   - Log warning: "Phase {N} was [NOT STARTED], updated to [IN PROGRESS]"
6. If it shows [PARTIAL]:
   - Keep as [PARTIAL] (resuming from partial state)
   - Log info: "Resuming Phase {N} from [PARTIAL]"

**Auto-Correction Logic**:
```
Edit file: specs/${padded_num}_${project_name}/plans/implementation-{NNN}.md
oldString: "### Phase {N}: {Name} [NOT STARTED]"
newString: "### Phase {N}: {Name} [IN PROGRESS]"
```

**Why This Matters**:
- Catches cases where agent fails to update phase status
- Provides early warning for status synchronization issues
- Ensures plan file is accurate resume point source of truth
```

**Timing**: 45 minutes

### Phase 5: Enhance Phase Verification in Postflight [COMPLETED]

**Goal**: Expand the existing Phase Verification section to catch [NOT STARTED] phases during active work and handle partial completion scenarios

**Tasks**:
- [ ] Read current Phase Verification section (lines 89-103)
- [ ] Add logic to detect phases that should be [IN PROGRESS] but show [NOT STARTED]
- [ ] Add logic to handle [PARTIAL] phases correctly
- [ ] Add audit trail logging for all corrections
- [ ] Update Recovery Logic subsection with additional rules

**Implementation Details**:

Replace the Phase Verification section (lines 89-103) in skill-implementer/SKILL.md with:

```markdown
## Phase Verification Details

**Purpose**: Ensure plan.md phase status markers stay synchronized with actual implementation progress reported in metadata.

**Process**:
1. Read the plan file from the path specified in metadata
2. Extract all phase status markers using regex: `### Phase \d+: .*? \[(NOT STARTED|IN PROGRESS|COMPLETED|PARTIAL)\]`
3. Count phases by status:
   - completed_count = number of [COMPLETED] phases
   - in_progress_count = number of [IN PROGRESS] phases
   - partial_count = number of [PARTIAL] phases
   - not_started_count = number of [NOT STARTED] phases
4. Compare with metadata.phases_completed
5. Apply recovery logic to correct mismatches
6. Log all corrections for audit trail

**Recovery Logic**:

1. **Completed Phase Recovery**:
   - If metadata.phases_completed > plan [COMPLETED] phases: 
     - Update plan to mark additional phases as [COMPLETED]
     - Log: "Corrected {N} phases to [COMPLETED] based on metadata"
   - If metadata.phases_completed < plan [COMPLETED] phases: 
     - Log warning but do not downgrade (completed is final)
     - Log: "Warning: Plan shows more completed phases than metadata"

2. **In Progress Phase Recovery**:
   - If metadata.phases_completed indicates active work but no [IN PROGRESS] phase found:
     - Find first [NOT STARTED] phase after completed phases
     - Update to [IN PROGRESS]
     - Log: "Corrected Phase {N} to [IN PROGRESS] based on active work"

3. **Partial Phase Recovery**:
   - If metadata.status == "partial" and no [PARTIAL] phase found:
     - Find the phase at metadata.phases_completed + 1
     - If it shows [NOT STARTED] or [IN PROGRESS], update to [PARTIAL]
     - Log: "Marked Phase {N} as [PARTIAL] based on partial completion"

4. **Not Started During Active Work**:
   - If metadata.phases_completed > 0 but current phase shows [NOT STARTED]:
     - Update to [IN PROGRESS] (work has begun on this phase)
     - Log: "Corrected Phase {N} from [NOT STARTED] to [IN PROGRESS]"

**Audit Trail**:
- All corrections are logged with:
  - Phase number and name
  - Old status -> New status
  - Reason for correction
  - Timestamp

**Why This Matters**:
- Ensures plan file accurately reflects implementation progress
- Provides reliable resume point for interrupted implementations
- Maintains consistency between metadata and plan file
```

**Timing**: 45 minutes

### Phase 6: Testing and Validation [COMPLETED]

**Goal**: Verify all status update changes work correctly and don't break existing workflows

**Tasks**:
- [ ] Create test task in state.json for validation
- [ ] Test skill-implementer preflight: verify state.json updates to "implementing"
- [ ] Test skill-implementer preflight: verify TODO.md updates to [IMPLEMENTING]
- [ ] Test skill-implementer postflight: verify state.json updates to "completed" or "partial"
- [ ] Test skill-implementer postflight: verify TODO.md updates to [COMPLETED] or [PARTIAL]
- [ ] Test phase verification: verify [NOT STARTED] -> [IN PROGRESS] correction
- [ ] Test phase verification: verify completed phase counting
- [ ] Verify implement.md no longer has duplicate status logic
- [ ] Run jq command tests with sample data to ensure no syntax errors
- [ ] Document any issues found and fixes applied

**Test Scenarios**:

1. **Normal Implementation Flow**:
   - Task status: planned -> implementing -> completed
   - Phase statuses: not started -> in progress -> completed
   - Verify all transitions work

2. **Partial Implementation Flow**:
   - Task status: planned -> implementing -> partial
   - Phase statuses: not started -> in progress -> partial
   - Verify resume capability

3. **Phase Status Correction**:
   - Create plan with phase marked [NOT STARTED]
   - Run implementation
   - Verify phase gets corrected to [IN PROGRESS]

4. **jq Command Validation**:
   - Test each jq command with sample state.json
   - Verify no INVALID_CHARACTER errors
   - Verify output is valid JSON

**Timing**: 45 minutes

## Testing & Validation

- [ ] All jq commands execute without syntax errors
- [ ] state.json updates correctly in preflight (implementing) and postflight (completed/partial)
- [ ] TODO.md status markers update correctly at both stages
- [ ] Phase status [NOT STARTED] gets corrected to [IN PROGRESS] when work begins
- [ ] Phase status [COMPLETED] count matches metadata.phases_completed
- [ ] implement.md no longer contains duplicate status update logic
- [ ] Git commits are created with proper messages
- [ ] Metadata files are cleaned up after postflight
- [ ] Error handling works for missing metadata files
- [ ] Error handling works for failed jq commands

## Artifacts & Outputs

- Modified: `.opencode/skills/skill-implementer/SKILL.md` - Updated preflight and postflight with explicit status commands
- Modified: `.opencode/commands/implement.md` - Removed duplicate status update logic
- Created: Test validation results documenting successful status transitions
- Updated: `specs/OC_148_fix_status_updates_in_implementations/.return-meta.json` - Planning complete
- Updated: `specs/OC_148_fix_status_updates_in_implementations/TODO.md` - Status updated to [PLANNED]
- Updated: `specs/state.json` - Task status updated to "planned"

## Rollback/Contingency

If implementation causes issues:

1. **Immediate Rollback**:
   - Restore original skill-implementer/SKILL.md from git history
   - Restore original implement.md from git history
   - Command: `git checkout HEAD -- .opencode/skills/skill-implementer/SKILL.md .opencode/commands/implement.md`

2. **Partial Rollback**:
   - If only specific phases cause issues, revert those sections individually
   - Use Edit tool to remove problematic additions

3. **Forward Fix**:
   - If issues are minor, create follow-up task to address them
   - Document workarounds in task notes

4. **Emergency Stop**:
   - If workflows break completely, disable skill-implementer temporarily
   - Use direct agent invocation as fallback

## References

- Research Report: `specs/OC_148_fix_status_updates_in_implementations/reports/research-001.md`
- Status Markers: `.opencode/context/core/standards/status-markers.md`
- jq Workarounds: `.opencode/context/core/patterns/jq-escaping-workarounds.md`
- skill-researcher Pattern: `.opencode/skills/skill-researcher/SKILL.md` lines 94-176
- skill-planner Pattern: `.opencode/skills/skill-planner/SKILL.md` lines 94-179
- Current skill-implementer: `.opencode/skills/skill-implementer/SKILL.md` lines 68-88
- Current implement.md: `.opencode/commands/implement.md` lines 65-68
- general-implementation-agent: `.opencode/agent/subagents/general-implementation-agent.md` lines 145-146
