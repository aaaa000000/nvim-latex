# Research Report: OC_143

**Task**: OC_143 - Fix skill-researcher TODO.md linking regression  
**Started**: 2026-03-05T15:12:00Z  
**Completed**: 2026-03-05T15:15:00Z  
**Effort**: 1-2 hours  
**Dependencies**: None  
**Sources/Inputs**: - SKILL.md files, agent definitions, context format specifications  
**Artifacts**: - specs/OC_143_fix_skill_researcher_todo_linking/reports/research-001.md  
**Standards**: report-format.md

## Executive Summary

- **Root Cause Identified**: skill-researcher's Stage 3 delegation prompt is missing the `metadata_file_path` parameter that general-research-agent expects
- **Impact**: Agent cannot determine where to write `.return-meta.json`, causing postflight to fail at parsing artifacts and linking them in TODO.md
- **Fix Required**: Add `metadata_file_path` parameter to delegation prompt in skill-researcher/SKILL.md
- **Related Work**: OC_147 previously fixed the postflight commands themselves, but missed this delegation parameter
- **Pattern Available**: Multiple extension skills (skill-nix-research, skill-web-research, etc.) correctly implement this pattern

## Context & Scope

This research investigates why research reports are not being linked in TODO.md despite OC_147's fixes to the postflight workflow. The task description indicated the root cause was a missing `metadata_file_path` parameter in the delegation prompt.

### Files Investigated
1. `.opencode/skills/skill-researcher/SKILL.md` - The skill that delegates research
2. `.opencode/agent/subagents/general-research-agent.md` - The agent that performs research
3. `.opencode/context/core/formats/return-metadata-file.md` - Metadata file schema
4. `.opencode/skills/skill-planner/SKILL.md` - Reference skill with similar structure
5. Extension skills (nix, web, formal) - Reference implementations

## Findings

### 1. Current Delegation Flow (Broken)

**skill-researcher/SKILL.md Stage 3** (lines 78-89):
```markdown
3. **Delegate**:
   - Call `Task` tool with `subagent_type="general-research-agent"`
   - Prompt:
     """
     Conduct research for task {N}.

     <system_context>
     Using the following format standards:
     {report_format}
     {status_markers}
     </system_context>
     """
```

**Problem**: The prompt does NOT include `metadata_file_path`, which the agent expects to receive.

### 2. Agent Expectations (From general-research-agent.md)

**Stage 1: Parse Delegation Context** (lines 124-140):
```json
{
  "task_context": {
    "task_number": 412,
    "task_name": "create_general_research_agent",
    "description": "...",
    "language": "meta"
  },
  "metadata": {
    "session_id": "sess_...",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "general-research-agent"]
  },
  "focus_prompt": "optional specific focus area",
  "metadata_file_path": "specs/412_create_general_research_agent/.return-meta.json"
}
```

**Critical Requirement**: The agent explicitly expects `metadata_file_path` to know where to write the return metadata file.

### 3. Postflight Dependency

**skill-researcher Stage 5** (lines 94-103):
```bash
metadata_file="specs/${padded_num}_${project_name}/.return-meta.json"
if [ -f "$metadata_file" ] && jq empty "$metadata_file" 2>/dev/null; then
    status=$(jq -r '.status' "$metadata_file")
    artifact_path=$(jq -r '.artifacts[0].path // ""' "$metadata_file")
    ...
fi
```

**Issue**: Postflight expects to read from `${padded_num}_${project_name}/.return-meta.json`, but if the agent doesn't know this path, it cannot create the file. Without the file:
- `artifact_path` is empty
- TODO.md cannot be updated with the research report link
- state.json artifacts array remains empty

### 4. Working Pattern (From Extension Skills)

**skill-nix-research/SKILL.md** (lines 112, 126):
```markdown
  "metadata_file_path": "specs/{NNN}_{SLUG}/.return-meta.json"
  ...
  - prompt: [Include task_context, delegation_context, focus_prompt, metadata_file_path]
```

**skill-web-research/SKILL.md** follows same pattern.

### 5. OC_147 Context

Task OC_147 ("Fix artifact metadata linking in TODO.md") previously:
- Added 4 missing context files to skill-researcher
- Added detailed Stage 5-10 postflight commands
- But apparently missed updating the Stage 3 delegation prompt

The postflight commands were fixed, but without the agent receiving `metadata_file_path`, it cannot write the metadata that postflight needs to read.

### 6. File Path Format

From return-metadata-file.md (line 10):
```
specs/{N}_{SLUG}/.return-meta.json
```

Where:
- `{N}` = Task number (unpadded, e.g., 143)
- `{SLUG}` = Task slug in snake_case (e.g., fix_skill_researcher_todo_linking)

## Decisions

1. **Parameter Location**: `metadata_file_path` must be added to the delegation prompt in Stage 3, not as a separate parameter
2. **Path Template**: Use `specs/OC_{N}_{project_name}/.return-meta.json` to match existing conventions
3. **Scope**: Fix only skill-researcher; skill-planner has similar structure and should be audited separately
4. **Validation**: After fix, verify metadata file is created and TODO.md is updated

## Required Changes

### File: .opencode/skills/skill-researcher/SKILL.md

**Location**: Lines 80-89 (Stage 3 delegation prompt)

**Current**:
```markdown
   - Prompt:
     """
     Conduct research for task {N}.

     <system_context>
     Using the following format standards:
     {report_format}
     {status_markers}
     </system_context>
     """
```

**Required**:
```markdown
   - Prompt:
     """
     Conduct research for task {N}.

     Task Context:
     - Task number: {N}
     - Project name: {project_name}
     
     Delegation Context:
     - Session ID: {session_id}
     - Delegation depth: 1
     
     File Paths:
     - metadata_file_path: "specs/OC_{N}_{project_name}/.return-meta.json"

     <system_context>
     Using the following format standards:
     {report_format}
     {status_markers}
     </system_context>
     """
```

## Implementation Guidance

### Phase 1: Update Delegation Prompt
1. Edit `.opencode/skills/skill-researcher/SKILL.md`
2. Modify Stage 3 delegation prompt to include:
   - `metadata_file_path` with correct path format
   - Task context (number, project name)
   - Delegation context (session ID, depth)

### Phase 2: Test the Fix
1. Create a test task
2. Run `/research {test_task_number}`
3. Verify:
   - `.return-meta.json` is created in correct location
   - Report is generated
   - TODO.md is updated with research link
   - state.json artifacts array is populated

### Phase 3: Audit Past Tasks
1. Search for tasks with missing Research links in TODO.md
2. Manually add links if metadata files still exist
3. Document any gaps for historical reference

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Path format mismatch | Low | Medium | Follow existing convention from return-metadata-file.md |
| Session ID not available in context | Low | Medium | Use placeholder or derive from context |
| Other parameters also missing | Medium | Low | Full audit of delegation prompt vs agent expectations |
| Breaking existing functionality | Low | High | Test with new task before merging |

## Appendix: Reference Implementations

The following extension skills correctly implement the `metadata_file_path` pattern:

1. **skill-nix-research** - `.opencode/extensions/nix/skills/skill-nix-research/SKILL.md`
2. **skill-web-research** - `.opencode/extensions/web/skills/skill-web-research/SKILL.md`
3. **skill-formal-research** - `.opencode/extensions/formal/skills/skill-formal-research/SKILL.md`

All follow the pattern:
```markdown
"metadata_file_path": "specs/{NNN}_{SLUG}/.return-meta.json"
```

And document in their delegation prompts:
```markdown
- prompt: [Include task_context, delegation_context, focus_prompt, metadata_file_path]
```
