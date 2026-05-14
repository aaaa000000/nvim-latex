# Implementation Plan: Task #159

- **Task**: 159 - Require planner agent for /plan command (and similar workflow commands)
- **Status**: [COMPLETED]
- **Effort**: 1.5-2.5 hours
- **Dependencies**: None
- **Research Inputs**: [research-001.md](../reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: meta
- **Date**: 2026-03-06
- **Feature**: Fix workflow command routing to ensure specialized agent delegation via Task tool
- **Estimated Hours**: 1.5-2.5 hours
- **Standards File**: /home/benjamin/.config/nvim/CLAUDE.md
- **Research Reports**: [research-001.md](../reports/research-001.md)
- **Lean Intent**: false

## Overview

The /plan, /research, and /implement commands delegate to skills via the Skill tool. Each skill's SKILL.md contains instructions to invoke the Task tool with the correct `subagent_type` (e.g., `planner-agent`). However, the Skill tool loads the SKILL.md as context for the primary agent, which may process the request itself rather than spawning a specialized subagent. The fix requires updating command files to explicitly mandate Task tool invocation after skill context loading, and adding enforcement language to skill files to make the delegation non-optional.

### Research Integration

Research report (research-001.md) confirmed:
- The `agent:` field in skill frontmatter is informational only
- Skills are thin wrappers that inject context but do not automatically spawn subagents
- Commands must ensure the Skill tool caller faithfully executes the Task tool invocation documented in Stage 5 of each SKILL.md
- All three workflow commands have the same structural issue

## Goals & Non-Goals

**Goals**:
- Ensure /plan always delegates to `planner-agent` via Task tool
- Ensure /research delegates to the correct research agent (`general-research-agent` or `neovim-research-agent`) via Task tool
- Ensure /implement delegates to the correct implementation agent via Task tool
- Add explicit enforcement language to prevent primary agent from processing requests directly

**Non-Goals**:
- Changing the Skill tool's internal mechanics (out of scope)
- Modifying agent definitions (agents are correct as-is)
- Adding new skills or agents
- Changing the neovim-specific skill variants (they follow the same pattern and will benefit from the same fix approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Commands become too verbose with enforcement language | Low | Medium | Keep additions concise and targeted at the delegation stage |
| Skill tool behavior changes in future Claude Code updates | Medium | Low | Document the constraint clearly so it can be adapted |
| Existing working workflows break during edit | Medium | Low | Minimal changes, focused on adding enforcement, not restructuring |
| Enforcement language ignored by model | High | Low | Use CRITICAL/MUST/EXECUTE NOW imperative patterns already proven in codebase |

## Implementation Phases

### Phase 1: Update /plan Command [COMPLETED]

**Goal**: Add explicit enforcement in plan.md's DELEGATE stage to ensure Task tool invocation with `subagent_type="planner-agent"` is non-optional.

**Tasks**:
- [ ] Read current plan.md DELEGATE stage (lines 47-59)
- [ ] Add explicit enforcement block after skill invocation requiring verification that Task tool was called with correct subagent_type
- [ ] Add a "DELEGATION REQUIREMENT" section that states: after skill context is loaded, the skill MUST invoke `Task` with `subagent_type="planner-agent"` -- if this does not happen, the command has FAILED
- [ ] Verify the updated command still references correct skill name and args format

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/plan.md` - Add enforcement language to STAGE 2: DELEGATE section

**Verification**:
- plan.md contains explicit requirement for Task tool invocation with subagent_type
- DELEGATE section includes failure condition for missing delegation
- No structural changes to other stages

---

### Phase 2: Update /research Command [COMPLETED]

**Goal**: Add explicit enforcement in research.md's DELEGATE stage for correct agent routing.

**Tasks**:
- [ ] Read current research.md DELEGATE stage (lines 44-63)
- [ ] Add enforcement block requiring Task tool invocation with language-appropriate subagent_type
- [ ] Add delegation verification language matching the pattern from Phase 1
- [ ] Ensure language routing table is preserved (neovim -> neovim-research-agent, general/meta -> general-research-agent)

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/research.md` - Add enforcement language to STAGE 2: DELEGATE section

**Verification**:
- research.md contains explicit requirement for Task tool invocation
- Language routing table preserved
- Both neovim and general paths have enforcement

---

### Phase 3: Update /implement Command [COMPLETED]

**Goal**: Add explicit enforcement in implement.md's DELEGATE stage for correct agent routing.

**Tasks**:
- [ ] Read current implement.md DELEGATE stage (lines 59-80)
- [ ] Add enforcement block requiring Task tool invocation with language-appropriate subagent_type
- [ ] Add delegation verification language matching the pattern from Phases 1-2
- [ ] Ensure language routing table is preserved (neovim -> neovim-implementation-agent, general/meta -> general-implementation-agent)

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/implement.md` - Add enforcement language to STAGE 2: DELEGATE section

**Verification**:
- implement.md contains explicit requirement for Task tool invocation
- Language routing table preserved
- Both neovim and general paths have enforcement

---

### Phase 4: Strengthen Skill SKILL.md Delegation Instructions [COMPLETED]

**Goal**: Add stronger enforcement language to each SKILL.md's Stage 5 (Invoke Subagent) to make it impossible for the model to skip delegation.

**Tasks**:
- [ ] Update `skill-planner/SKILL.md` Stage 5 with stronger "EXECUTE NOW" and "FAILURE CONDITION" language
- [ ] Update `skill-researcher/SKILL.md` Stage 5 with same enforcement pattern
- [ ] Update `skill-implementer/SKILL.md` Stage 5 with same enforcement pattern
- [ ] Update `skill-neovim-research/SKILL.md` Stage 5 with same enforcement pattern (if it has the same structure)
- [ ] Update `skill-neovim-implementation/SKILL.md` Stage 5 with same enforcement pattern (if it has the same structure)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-planner/SKILL.md` - Strengthen Stage 5 enforcement
- `.claude/skills/skill-researcher/SKILL.md` - Strengthen Stage 5 enforcement
- `.claude/skills/skill-implementer/SKILL.md` - Strengthen Stage 5 enforcement
- `.claude/skills/skill-neovim-research/SKILL.md` - Strengthen Stage 5 enforcement (if applicable)
- `.claude/skills/skill-neovim-implementation/SKILL.md` - Strengthen Stage 5 enforcement (if applicable)

**Verification**:
- Each SKILL.md Stage 5 contains "EXECUTE NOW" imperative directive
- Each SKILL.md Stage 5 contains explicit failure condition for skipped delegation
- Existing subagent_type values and delegation context are unchanged

---

### Phase 5: Add GATE OUT Delegation Verification [COMPLETED]

**Goal**: Add a check in each command's GATE OUT (CHECKPOINT 2) to verify that a subagent was actually spawned, not just skill context loaded.

**Tasks**:
- [ ] In plan.md CHECKPOINT 2, add verification that `.return-meta.json` contains `agent_type: "planner-agent"` in metadata
- [ ] In research.md CHECKPOINT 2, add verification that `.return-meta.json` contains correct agent_type
- [ ] In implement.md CHECKPOINT 2, add verification that `.return-meta.json` contains correct agent_type
- [ ] Document the expected agent_type values for each command

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/plan.md` - Add agent_type check to CHECKPOINT 2
- `.claude/commands/research.md` - Add agent_type check to CHECKPOINT 2
- `.claude/commands/implement.md` - Add agent_type check to CHECKPOINT 2

**Verification**:
- Each command's GATE OUT checks for correct agent_type in metadata
- Verification failure triggers RETRY with explicit delegation instruction

---

### Phase 6: Verification and Testing [COMPLETED]

**Goal**: Verify all changes are internally consistent and follow project standards.

**Tasks**:
- [ ] Re-read all modified command files to verify no syntax/formatting errors
- [ ] Re-read all modified SKILL.md files to verify consistency
- [ ] Verify no references to old patterns remain
- [ ] Run `grep -r "subagent_type" .claude/commands/ .claude/skills/` to confirm correct agent names
- [ ] Verify all modified files follow the established markdown formatting conventions
- [ ] Create implementation summary

**Timing**: 20 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- All grep results show correct subagent_type values
- No formatting or structural regressions
- All modified files are internally consistent
- Implementation summary created

## Testing & Validation

- [ ] All three command files (plan.md, research.md, implement.md) contain explicit Task tool delegation requirements
- [ ] All five skill files contain strengthened Stage 5 enforcement language
- [ ] GATE OUT in each command verifies agent_type from metadata
- [ ] No existing functionality removed or broken
- [ ] Grep confirms correct subagent_type strings throughout

## Artifacts & Outputs

- Modified `.claude/commands/plan.md`
- Modified `.claude/commands/research.md`
- Modified `.claude/commands/implement.md`
- Modified `.claude/skills/skill-planner/SKILL.md`
- Modified `.claude/skills/skill-researcher/SKILL.md`
- Modified `.claude/skills/skill-implementer/SKILL.md`
- Modified `.claude/skills/skill-neovim-research/SKILL.md` (if applicable)
- Modified `.claude/skills/skill-neovim-implementation/SKILL.md` (if applicable)
- Implementation summary at `specs/OC_159_require_planner_agent_for_plan_command/summaries/`

## Rollback/Contingency

All changes are additive (adding enforcement language, not restructuring). Rollback is straightforward:
- `git revert` the implementation commit
- Original command and skill files are fully functional without the enforcement additions
