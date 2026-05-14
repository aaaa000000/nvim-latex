# Implementation Plan: Remove Embedded Templates and Strengthen Context Injection

- **Task**: OC_137 - investigate_and_fix_planner_agent_format_compliance_issue
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: 
  - specs/OC_137_investigate_and_fix_planner_agent_format_compliance_issue/reports/research-001.md
  - specs/OC_137_investigate_and_fix_planner_agent_format_compliance_issue/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: 
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/standards/documentation-standards.md
  - .opencode/context/core/standards/task-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This implementation plan removes the non-compliant embedded plan templates from command specifications and strengthens the planner-agent to rely exclusively on context-injected format files. The approach follows the principle of single source of truth: format specifications should only exist in context files, not embedded in command specs or agent templates.

**Core Strategy**: Remove all embedded plan templates from command specifications and enhance context loading mechanisms to ensure planner-agent always uses the correct format from plan-format.md.

## Goals & Non-Goals

**Goals**:
- Remove non-compliant embedded plan template from plan.md
- Audit and remove embedded templates from other command specifications
- Strengthen context injection in skill-planner
- Add context injection to revise flow
- Enhance planner-agent.md to prioritize context files over embedded templates
- Strengthen verification to reject non-compliant plans
- Test both /plan and /revise commands for format compliance

**Non-Goals**:
- Modifying plan-format.md standard
- Changing the structure of planner-agent.md Stage 5 template (already compliant)
- Creating new commands or skills
- Modifying actual plan files (only affects future plans)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing embedded template breaks plan generation entirely | High | Low | Ensure planner-agent.md has robust fallback and context injection is working |
| Context injection still fails intermittently | High | Medium | Add multiple fallback layers and explicit error logging |
| Other commands have embedded templates not found during audit | Medium | High | Comprehensive audit of all command specs |
| Agents use learned patterns from old templates | Medium | Medium | Clear explicit instructions to ignore old patterns |
| Changes affect non-planning commands | Low | Low | Scope changes to plan-related files only |

## Implementation Phases

### Phase 1: Remove Embedded Template from plan.md [NOT STARTED]

**Goal**: Remove the non-compliant embedded plan template from the /plan command specification

**Tasks**:
- [ ] Read current plan.md lines 71-125 (embedded template section)
- [ ] Remove the embedded plan template example (lines 71-125)
- [ ] Replace with reference to external templates only
- [ ] Update Step 6 to reference planner-agent.md and plan-format.md instead of showing template
- [ ] Verify plan.md still has clear instructions for plan creation without embedded template

**Files to Modify**:
- `.opencode/commands/plan.md` - Remove embedded template (lines 71-125), update Step 6

**Verification**:
- [ ] plan.md no longer contains embedded plan template
- [ ] plan.md still references correct standards and agents
- [ ] No syntax errors in modified file

**Timing**: 1 hour

### Phase 2: Audit All Command Specifications for Embedded Templates [NOT STARTED]

**Goal**: Identify all command specifications that may contain embedded plan templates

**Tasks**:
- [ ] Search all `.opencode/commands/*.md` files for embedded plan templates
- [ ] Look for patterns: "## Phases", "**Status**: [NOT STARTED]", "**Objectives**:", "**Estimated effort**:"
- [ ] Check for any markdown blocks showing plan structures
- [ ] Document findings with file paths and line numbers
- [ ] Create list of files requiring template removal

**Files to Examine**:
- `.opencode/commands/*.md` (all command specs)

**Verification**:
- [ ] Complete audit report showing all embedded templates found
- [ ] List of files and line numbers to modify
- [ ] No embedded templates remain undetected

**Timing**: 1.5 hours

### Phase 3: Remove Embedded Templates from Other Commands [NOT STARTED]

**Goal**: Remove any additional embedded plan templates found during audit

**Tasks**:
- [ ] For each file identified in Phase 2:
  - Read the embedded template section
  - Remove or replace with reference to external specs
  - Ensure command still has clear instructions
- [ ] Update any command that shows plan examples to reference plan-format.md
- [ ] Verify all modified files have no syntax errors

**Files to Modify**:
- (TBD based on Phase 2 audit results)

**Verification**:
- [ ] All identified embedded templates removed
- [ ] Commands still function correctly
- [ ] No syntax errors in any modified files

**Timing**: 1.5 hours

### Phase 4: Strengthen Context Injection in planner-agent.md [NOT STARTED]

**Goal**: Enhance planner-agent.md to prioritize context-injected files and explicitly reject embedded templates

**Tasks**:
- [ ] Update Stage 5 introduction to emphasize using injected context
- [ ] Add explicit instruction: "MUST use plan_format context, NOT embedded templates"
- [ ] Add fallback logic: "If plan_format not injected, load @.opencode/context/core/formats/plan-format.md directly"
- [ ] Update Critical Requirements section with stronger language about context priority
- [ ] Add verification step: "Check which template source was used and log it"

**Files to Modify**:
- `.opencode/agent/subagents/planner-agent.md` - Stage 5, Stage 6a, Critical Requirements

**Verification**:
- [ ] planner-agent.md explicitly prioritizes context injection
- [ ] Clear fallback mechanism documented
- [ ] Verification checks template source

**Timing**: 1 hour

### Phase 5: Add Context Injection to Revise Flow [NOT STARTED]

**Goal**: Ensure /revise command properly injects plan-format.md context when calling planner-agent

**Tasks**:
- [ ] Read current revise.md routing section
- [ ] Add `<context_injection>` block for plan-format.md
- [ ] Update delegation to planner-agent to include context
- [ ] Alternative: Route through skill-planner instead of direct planner-agent call
- [ ] Document the chosen approach in revise.md

**Files to Modify**:
- `.opencode/commands/revise.md` - Add context injection

**Verification**:
- [ ] revise.md has working context injection
- [ ] /revise path injects plan-format.md
- [ ] Planner-agent receives context in both /plan and /revise flows

**Timing**: 1 hour

### Phase 6: Test and Validate [NOT STARTED]

**Goal**: Verify both /plan and /revise produce compliant plans

**Tasks**:
- [ ] Create test task: `/task "Test plan format compliance"`
- [ ] Run `/plan` on test task
- [ ] Verify generated plan follows plan-format.md exactly:
  - Section: "## Implementation Phases"
  - Phase format: "### Phase N: Name [STATUS]"
  - Fields: **Goal**, **Tasks**, **Timing**
  - No separators
  - Full metadata block
- [ ] Run `/revise` on the same task
- [ ] Verify revised plan also follows format
- [ ] Document any remaining issues

**Verification**:
- [ ] /plan generates compliant plans
- [ ] /revise generates compliant plans
- [ ] No non-compliant format patterns present
- [ ] All format requirements met

**Timing**: 1 hour

## Testing & Validation

- [ ] Phase 1 verification: plan.md has no embedded template
- [ ] Phase 2 verification: All embedded templates identified
- [ ] Phase 3 verification: All embedded templates removed
- [ ] Phase 4 verification: planner-agent.md prioritizes context
- [ ] Phase 5 verification: revise.md has context injection
- [ ] Phase 6 verification: Both /plan and /revise produce compliant plans
- [ ] End-to-end test: Create test plan and verify format compliance
- [ ] Regression test: Ensure other commands still work correctly

## Artifacts & Outputs

- Modified command specifications (plan.md, possibly others)
- Enhanced planner-agent.md with stronger context priority
- Updated revise.md with context injection
- Test results documenting format compliance

## Rollback/Contingency

If removing embedded templates causes issues:
1. Restore from git: `git checkout -- .opencode/commands/plan.md`
2. Instead of removal, update embedded template to match plan-format.md
3. Alternative: Keep minimal embedded template as example only (not for production use)

## Success Criteria

- [ ] plan.md no longer contains non-compliant embedded template
- [ ] All command specs audited and cleaned of embedded templates
- [ ] planner-agent.md explicitly prioritizes context injection
- [ ] revise.md has working context injection
- [ ] /plan command generates compliant plans
- [ ] /revise command generates compliant plans
- [ ] No plans produced with non-compliant format
- [ ] Future plans automatically follow plan-format.md

## Notes

**Rationale for Removing vs. Updating Templates**:
The user constraint specifies removing embedded templates rather than updating them. This creates a single source of truth where plan-format.md is the only authoritative template. Benefits:
- No risk of drift between embedded and external templates
- Future format changes only need to update one file
- Agents must use context injection (no fallback to bad templates)

**Alternative Approach** (if removal causes issues):
Instead of complete removal, update embedded templates to match plan-format.md exactly. However, this still creates maintenance burden. Removal is preferred per user direction.

## References

- **research-001.md**: Initial analysis identifying context injection issues
- **research-002.md**: Root cause analysis identifying embedded templates
- **plan-format.md**: The single source of truth for plan format
- **planner-agent.md**: Agent specification (already compliant)
- **plan.md**: Command spec with embedded template to remove
- **revise.md**: Command spec needing context injection

## Next Steps

After plan approval, run `/implement OC_137` to begin Phase 1.

**Phase 1 can begin immediately** - no blockers or external dependencies required.
