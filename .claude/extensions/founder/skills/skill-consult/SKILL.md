---
name: skill-consult
description: Route design consultations to domain-specific design partner agents
allowed-tools: Task, Bash, Edit, Read, Write
---

# Consult Skill

Thin wrapper that routes design consultation requests to domain-specific design partner agents.

**IMPORTANT**: This skill implements the skill-internal postflight pattern. After the subagent returns,
this skill handles all postflight operations (artifact linking, git commit) before returning.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/formats/subagent-return.md`
- Purpose: Return validation
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:

### Direct Invocation
- User runs `/consult --legal` command

### Routing
- `domain=legal` routes to `legal-analysis-agent`
- Future: `domain=investor`, `domain=technical`, `domain=competitor`

### When NOT to trigger

Do not invoke for:
- Contract review (use skill-legal / legal-council-agent)
- Market research (use skill-market)
- Competitive analysis (use skill-analyze)

---

## Execution Flow

### Stage 1: Input Validation

Validate required inputs:
- `domain` - Required, currently only "legal" supported
- `input_type` - Required, one of: file_path, inline_text, design_question, task_number
- `session_id` - Required

```bash
# Validate domain
case "$domain" in
  legal) agent="legal-analysis-agent" ;;
  *) return error "Unsupported domain: $domain. Currently supported: legal" ;;
esac

# Validate input type
case "$input_type" in
  file_path|inline_text|design_question|task_number) ;;
  *) return error "Invalid input_type: $input_type" ;;
esac
```

---

### Stage 2: Resolve Task Context (if task-attached)

If `task_number` is provided, resolve task directory for artifact storage:

```bash
if [ -n "$task_number" ]; then
  task_data=$(jq -r --argjson num "$task_number" \
    '.active_projects[] | select(.project_number == $num)' \
    specs/state.json)

  if [ -z "$task_data" ]; then
    return error "Task $task_number not found"
  fi

  project_name=$(echo "$task_data" | jq -r '.project_name')
  padded_num=$(printf "%03d" "$task_number")
  task_dir="specs/${padded_num}_${project_name}"
  metadata_file="${task_dir}/.return-meta.json"

  mkdir -p "$task_dir"
else
  # Standalone mode: no task directory, agent writes report to a temp location
  metadata_file="/tmp/consult-meta-${session_id}.json"
fi
```

---

### Stage 3: Prepare Delegation Context

```json
{
  "task_context": {
    "description": "{description or input summary}",
    "task_type": "founder"
  },
  "domain": "legal",
  "input_type": "{file_path | inline_text | design_question | task_number}",
  "file_path": "{file path if applicable}",
  "inline_text": "{inline text if applicable}",
  "design_question": "{design question if applicable}",
  "task_number": "{task number if task-attached, null otherwise}",
  "metadata_file_path": "{metadata_file}",
  "metadata": {
    "session_id": "{session_id}",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "consult", "skill-consult"]
  }
}
```

---

### Stage 4: Invoke Agent

**CRITICAL**: You MUST use the **Task** tool to spawn the agent.

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "{agent}" (e.g., "legal-analysis-agent")
  - prompt: [Include all delegation context fields]
  - description: "Legal design consultation"
```

The agent will:
- Understand user intent via Socratic dialogue
- Translate document language to attorney perspective
- Identify translation gaps
- Suggest reframings with rationale
- Write consultation report
- Write metadata file
- Return brief text summary

---

### Stage 4b: Self-Execution Fallback

**CRITICAL**: If you performed the work above WITHOUT using the Task tool (i.e., you read files,
wrote artifacts, or updated metadata directly instead of spawning a subagent), you MUST write a
`.return-meta.json` file now before proceeding to postflight. Use the schema from
`return-metadata-file.md` with the appropriate status value for this operation.

If you DID use the Task tool, skip this stage -- the subagent already wrote the metadata.

---

## Postflight (ALWAYS EXECUTE)

The following stages MUST execute after work is complete, whether the work was done by a
subagent or inline (Stage 4b). Do NOT skip these stages for any reason.

### Stage 5: Read Metadata File

```bash
if [ -f "$metadata_file" ] && jq empty "$metadata_file" 2>/dev/null; then
    status=$(jq -r '.status' "$metadata_file")
    artifact_path=$(jq -r '.artifacts[0].path // ""' "$metadata_file")
    artifact_type=$(jq -r '.artifacts[0].type // ""' "$metadata_file")
    artifact_summary=$(jq -r '.artifacts[0].summary // ""' "$metadata_file")
else
    status="failed"
fi
```

---

### Stage 6: Link Artifacts (if task-attached)

If a task number was provided, link the consultation artifact to the task:

```bash
if [ -n "$task_number" ] && [ -n "$artifact_path" ]; then
    # Add consultation artifact to state.json
    jq --arg path "$artifact_path" \
       --arg type "$artifact_type" \
       --arg summary "$artifact_summary" \
      '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
      specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json
fi
```

---

### Stage 7: Git Commit (if task-attached)

```bash
if [ -n "$task_number" ]; then
  git add -A
  git commit -m "task ${task_number}: legal design consultation

Session: ${session_id}
"
fi
```

---

### Stage 8: Cleanup

```bash
rm -f "$metadata_file"
```

---

### Stage 9: Return Brief Summary

```
Design consultation complete ({domain}):
- Input: {input type and description}
- Translation gaps: {N} identified
- Consultation report: {artifact_path}
- Task attached: {task_number or "standalone"}
- Advisory: recommend attorney review for high-stakes materials
```

---

## Return Format

Brief text summary (NOT JSON).

---

## Error Handling

### Unsupported Domain
Return immediately with supported domain list.

### Task Not Found (if task-attached)
Return error, do not proceed.

### Metadata File Missing
Return partial status with progress from agent output.

### Git Commit Failure
Non-blocking: Log failure but continue.
