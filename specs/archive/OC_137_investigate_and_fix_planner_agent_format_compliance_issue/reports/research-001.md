# Research Report: Planner Agent Format Non-Compliance

**Task**: OC_137 - Investigate and fix planner-agent format compliance issue  
**Report**: research-001.md  
**Date**: 2026-03-06  
**Status**: [COMPLETED]

---

## Executive Summary

Implementation plans created by the OpenCode planning system do not follow the specification defined in `.opencode/context/core/formats/plan-format.md`. This issue persists despite task OC_133 being marked as "completed" on 2026-03-04 with the stated goal of fixing this exact problem.

## Evidence of Non-Compliance

### Compliant Example: OC_135 implementation-002.md

This plan (created 2026-03-05) **CORRECTLY** follows plan-format.md:

```markdown
# Implementation Plan: Enforce Workflow Command Delegation to Prevent Direct Implementation [REVISED]

- **Task**: OC_135 - enforce_workflow_command_delegation_to_prevent_direct_implementation
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None
- **Research Inputs**: 
  - specs/OC_135_.../reports/research-001.md
  - specs/OC_135_.../reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: .opencode/context/core/formats/plan-format.md, ...
- **Type**: markdown

## Implementation Phases

### Phase 1: Command Specification Redesign (Priority 1) [COMPLETED]
**Goal**: Redesign all 9 workflow commands as pure routing specifications
**Tasks**:
- [ ] Task 1
- [ ] Task 2
**Timing**: 3 hours
```

**Key Compliance Points**:
- ✓ Metadata fields present (Task, Status, Effort, Dependencies, Research Inputs, Artifacts, Standards, Type)
- ✓ Section named "## Implementation Phases" (not "## Phases")
- ✓ Phase format: "### Phase N: Name [STATUS]" (status IN heading)
- ✓ Phase fields: **Goal**, **Tasks**, **Timing**
- ✓ Has Goals & Non-Goals, Risks & Mitigations, Testing & Validation sections

### Non-Compliant Example: OC_136 implementation-002.md

This plan (created 2026-03-06) **INCORRECTLY** deviates from plan-format.md:

```markdown
# Implementation Plan: Task #136 (Revision 2)

**Task**: OC_136 - Design and implement `/remember` command...
**Version**: 002 (Revised)  
**Created**: 2026-03-06
**Revision Note**: Changed interactive confirmation...
---

## Phases

### Phase 1: Vault Structure and Configuration
**Status**: [NOT STARTED]  
**Estimated effort**: 1-2 hours  
**Last Updated**: 2026-03-06
**Objectives**:
1. Create `.opencode/memory/` vault...
```

**Format Violations**:
- ✗ Missing metadata fields: Effort, Dependencies, Research Inputs, Standards, Type, Lean Intent
- ✗ Section named "## Phases" (should be "## Implementation Phases")
- ✗ Phase format wrong: "### Phase 1: Name" followed by separate "**Status**: [NOT STARTED]" line
  - Should be: "### Phase 1: Name [NOT STARTED]" (status IN heading)
- ✗ Wrong phase fields: **Objectives**, **Estimated effort** (should be **Goal**, **Timing**)
- ✗ Has `---` separators (not allowed per plan-format.md line 93)
- ✗ Missing required sections: Goals & Non-Goals, Risks & Mitigations, Testing & Validation, Artifacts & Outputs, Rollback/Contingency

## Root Cause Analysis

### Hypothesis 1: OC_133 Fix Was Incomplete

Task OC_133 (completed 2026-03-04) claimed to fix planner-agent.md:

> "Fixed planner-agent.md templates and verification to align with plan-format.md. Updated Stage 5 template to use correct phase format (status in heading, Goal/Timing fields, no separators). Enhanced Stage 6a verification with explicit correct/incorrect examples."

**However**, the OC_136 plan created today shows the OLD (wrong) format:
- Separate status lines
- Objectives/Estimated effort fields
- Section named "Phases"

**Conclusion**: Either the fix was reverted, didn't actually change the template, or the agent is not using the updated template.

### Hypothesis 2: Context Injection Failure

The `skill-planner/SKILL.md` has context injection configured:

```yaml
<context_injection>
  <file path=".opencode/context/core/formats/plan-format.md" variable="plan_format" />
</context_injection>
```

And the planner-agent is supposed to load this context. However, if context injection isn't working, the agent falls back to its embedded template - which may still have the wrong format.

### Hypothesis 3: Template in Planner-Agent.md Still Wrong

The planner-agent.md specification contains a Stage 5 template (lines 237-246). If this template wasn't actually updated in OC_133, or was reverted, it would still produce non-compliant plans.

Current planner-agent.md template excerpt:
```markdown
### Phase 1: {Name} [NOT STARTED]

**Goal**: {What this phase accomplishes}

**Tasks**:
- [ ] {Task 1}
- [ ] {Task 2}

**Timing**: {X hours}
```

This LOOKS correct, but the actual plans being produced don't match it.

### Hypothesis 4: Different Invocation Paths

OC_135 plans may have been created via proper `/plan` command flow:
```
User -> /plan command -> skill-planner -> planner-agent (with context)
```

OC_136 plan was created via `/revise` command which may use a different path:
```
User -> /revise command -> revise skill -> ??? -> plan creation
```

If the revise flow doesn't go through skill-planner or doesn't inject context, the planner-agent won't have the format specification.

### Hypothesis 5: Verification Steps Not Enforced

Planner-agent.md Stage 6a has verification instructions:

```markdown
#### 6a. Verify Required Metadata Fields
Re-read the plan file and verify ALL these fields exist...
**If any phase format is incorrect**:
1. Edit the plan file to fix the phase format
2. Re-read the plan file to confirm corrections
3. Only proceed to write success metadata after ALL phase formats are correct
```

But these may not be executing or may not be strict enough.

## Investigation Plan

### Phase 1: Audit planner-agent.md
- Read current planner-agent.md content
- Compare with what OC_133 claimed to fix
- Check if template matches plan-format.md requirements
- Verify Stage 6a verification steps are present and correct

### Phase 2: Verify Context Injection
- Test if skill-planner properly injects plan-format.md
- Check if planner-agent receives and uses the context
- Compare context availability in /plan vs /revise flows

### Phase 3: Test Plan Creation
- Create a test task
- Run /plan on it via proper flow
- Check if generated plan follows format
- If not, identify which part of the system is failing

### Phase 4: Fix and Validate
- Fix root cause (template, context, or verification)
- Test that new plans follow format
- Add safeguards to prevent regression
- Document proper invocation path

## Required Changes

1. **Fix planner-agent.md template** (if still wrong)
2. **Ensure context injection works** in all invocation paths
3. **Strengthen verification** - make it reject non-compliant plans
4. **Add format validation** that runs before plan is saved
5. **Document** which commands/skills produce plans and how they inject context

## Success Criteria

- [ ] All new plans follow plan-format.md exactly
- [ ] No plans with "## Phases" (must be "## Implementation Phases")
- [ ] No plans with separate "**Status**: [STATUS]" lines in phases
- [ ] All plans have required metadata fields
- [ ] All plans have required sections (Goals, Risks, Testing, etc.)
- [ ] Automated verification rejects non-compliant plans before they're saved

## References

- **plan-format.md**: `.opencode/context/core/formats/plan-format.md` (the standard)
- **planner-agent.md**: `.opencode/agent/subagents/planner-agent.md` (the agent spec)
- **skill-planner**: `.opencode/skills/skill-planner/SKILL.md` (the skill wrapper)
- **OC_133**: Task that supposedly fixed this issue
- **OC_135 implementation-002.md**: Compliant example
- **OC_136 implementation-002.md**: Non-compliant example

## Notes

The discrepancy between OC_135 (compliant) and OC_136 (non-compliant) is the smoking gun. Both were created after OC_133 "fixed" the issue, yet only OC_135 follows the format. This suggests:

1. OC_135 used the correct invocation path that properly injects context
2. OC_136 used a different path that doesn't inject context properly
3. The agent has the wrong format as its "default" when context isn't available

**Critical Finding**: The system has a "fallback" behavior where the agent uses an incorrect template when plan-format.md context isn't injected. This must be fixed.
