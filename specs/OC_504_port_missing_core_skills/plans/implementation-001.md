# Implementation Plan: Task #504

- **Task**: 504 - port_missing_core_skills
- **Status**: [COMPLETED]
- **Effort**: 4.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/OC_504_port_missing_core_skills/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md; status-markers.md; documentation-standards.md; task-management.md
- **Type**: meta

## Overview

Port 4 missing core skills from `.claude/skills/` to `.opencode/skills/` with appropriate path adaptations. The skills require coordinated updates to paths (`.claude/` → `.opencode/`, `specs/{NNN}_` → `specs/OC_{NNN}_`, `CLAUDE.md` → `AGENTS.md`), context references, and team orchestration context files.

### Research Integration

Research findings identify 4 skills already exist in `.opencode/skills/` (skill-memory, skill-project-overview, skill-spawn, skill-tag), leaving 4 to port. Team skills require `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` environment variable and dependent context files (team-orchestration, formats, patterns) that must be copied from `.claude/context/` to `.opencode/context/`.

## Goals & Non-Goals

**Goals**:
- Port skill-reviser (489 lines) - Plan revision thin wrapper
- Port skill-team-research (633 lines) - Multi-agent research orchestration
- Port skill-team-plan (616 lines) - Multi-agent planning orchestration
- Port skill-team-implement (696 lines) - Multi-agent implementation orchestration
- Copy required context files from `.claude/context/` to `.opencode/context/`
- Update all path references to use OC_ prefix and AGENTS.md
- Ensure team skills reference correct environment variable

**Non-Goals**:
- Do not modify existing skills in `.opencode/skills/`
- Do not port skills already present (skill-memory, skill-project-overview, skill-spawn, skill-tag)
- Do not modify source skills in `.claude/skills/`
- Do not implement team functionality (just port the skills)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path reference missed | Medium | Medium | Systematic search/replace with verification grep |
| Team context files missing | High | Low | Explicit dependency phase to copy context first |
| Cross-skill dependency broken | High | Low | Port in dependency order (context → reviser → team skills) |
| File encoding issues | Low | Low | Use Write tool with explicit UTF-8 |

## Implementation Phases

### Phase 1: Copy Team Orchestration Context Files [COMPLETED]

**Goal**: Copy required context files from `.claude/context/` to `.opencode/context/` before porting team skills

**Tasks**:
- [ ] Copy `.claude/context/patterns/team-orchestration.md` to `.opencode/context/core/patterns/`
- [ ] Copy `.claude/context/formats/team-metadata-extension.md` to `.opencode/context/core/formats/` (if exists)
- [ ] Copy `.claude/context/reference/team-wave-helpers.md` to `.opencode/context/core/reference/` (if exists)
- [ ] Copy `.claude/context/formats/return-metadata-file.md` to `.opencode/context/core/formats/` (verify exists)
- [ ] Copy `.claude/context/patterns/postflight-control.md` to `.opencode/context/core/patterns/` (verify exists)
- [ ] Copy `.claude/context/patterns/file-metadata-exchange.md` to `.opencode/context/core/patterns/` (verify exists)
- [ ] Copy `.claude/context/patterns/jq-escaping-workarounds.md` to `.opencode/context/core/patterns/` (verify exists)

**Timing**: 30 minutes

**Files to modify**:
- `.opencode/context/core/patterns/team-orchestration.md` - New file (copy)
- `.opencode/context/core/formats/team-metadata-extension.md` - New file (copy, if exists)
- `.opencode/context/core/reference/team-wave-helpers.md` - New file (copy, if exists)
- Verify other context files already exist in `.opencode/`

**Verification**:
- All referenced context files exist in `.opencode/context/`
- File contents match source (use diff or checksum)

---

### Phase 2: Port skill-reviser [COMPLETED]

**Goal**: Port the plan revision thin wrapper skill with path adaptations

**Tasks**:
- [ ] Read `.claude/skills/skill-reviser/SKILL.md`
- [ ] Write to `.opencode/skills/skill-reviser/SKILL.md` with path adaptations:
  - Replace `.claude/` with `.opencode/`
  - Replace `specs/{NNN}_` with `specs/OC_{NNN}_`
  - Replace `.claude/CLAUDE.md` with `.opencode/AGENTS.md`
  - Update context references to use new paths
- [ ] Verify the skill references correct context files

**Timing**: 45 minutes

**Files to modify**:
- `.opencode/skills/skill-reviser/SKILL.md` - New file (adapted copy, 489 lines)

**Verification**:
- Skill references `.opencode/` paths
- Skill references `specs/OC_{NNN}_{SLUG}/` format
- Skill references `AGENTS.md` not `CLAUDE.md`
- All context file paths updated

---

### Phase 3: Port skill-team-research [COMPLETED]

**Goal**: Port the multi-agent research orchestration skill with path adaptations

**Tasks**:
- [ ] Read `.claude/skills/skill-team-research/SKILL.md`
- [ ] Write to `.opencode/skills/skill-team-research/SKILL.md` with path adaptations:
  - Replace `.claude/` with `.opencode/`
  - Replace `specs/{NNN}_` with `specs/OC_{NNN}_`
  - Replace `CLAUDE.md` with `AGENTS.md`
  - Verify `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` env var reference
- [ ] Update context references in skill
- [ ] Verify team orchestration context references

**Timing**: 60 minutes

**Files to modify**:
- `.opencode/skills/skill-team-research/SKILL.md` - New file (adapted copy, 633 lines)

**Verification**:
- Skill references `.opencode/` paths
- Skill references `specs/OC_{NNN}_{SLUG}/reports/` format
- Skill references `AGENTS.md` not `CLAUDE.md`
- Environment variable name correct
- Team orchestration context paths correct

---

### Phase 4: Port skill-team-plan [COMPLETED]

**Goal**: Port the multi-agent planning orchestration skill with path adaptations

**Tasks**:
- [ ] Read `.claude/skills/skill-team-plan/SKILL.md`
- [ ] Write to `.opencode/skills/skill-team-plan/SKILL.md` with path adaptations:
  - Replace `.claude/` with `.opencode/`
  - Replace `specs/{NNN}_` with `specs/OC_{NNN}_`
  - Replace `CLAUDE.md` with `AGENTS.md`
  - Verify `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` env var reference
- [ ] Update context references in skill
- [ ] Verify team orchestration context references

**Timing**: 60 minutes

**Files to modify**:
- `.opencode/skills/skill-team-plan/SKILL.md` - New file (adapted copy, 616 lines)

**Verification**:
- Skill references `.opencode/` paths
- Skill references `specs/OC_{NNN}_{SLUG}/plans/` format
- Skill references `AGENTS.md` not `CLAUDE.md`
- Environment variable name correct
- Team orchestration context paths correct

---

### Phase 5: Port skill-team-implement [COMPLETED]

**Goal**: Port the multi-agent implementation orchestration skill with path adaptations

**Tasks**:
- [ ] Read `.claude/skills/skill-team-implement/SKILL.md`
- [ ] Write to `.opencode/skills/skill-team-implement/SKILL.md` with path adaptations:
  - Replace `.claude/` with `.opencode/`
  - Replace `specs/{NNN}_` with `specs/OC_{NNN}_`
  - Replace `CLAUDE.md` with `AGENTS.md`
  - Verify `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` env var reference
- [ ] Update context references in skill
- [ ] Verify team orchestration context references

**Timing**: 75 minutes

**Files to modify**:
- `.opencode/skills/skill-team-implement/SKILL.md` - New file (adapted copy, 696 lines)

**Verification**:
- Skill references `.opencode/` paths
- Skill references `specs/OC_{NNN}_{SLUG}/` format for summaries/phases/debug
- Skill references `AGENTS.md` not `CLAUDE.md`
- Environment variable name correct
- Team orchestration context paths correct

---

### Phase 6: Verification and Documentation [COMPLETED]

**Goal**: Verify all ported skills and document the changes

**Tasks**:
- [ ] Verify all 4 skills exist in `.opencode/skills/`
- [ ] Run grep to verify no `.claude/` paths remain in ported skills
- [ ] Run grep to verify no `CLAUDE.md` references remain
- [ ] Run grep to verify `specs/OC_{NNN}_` pattern is used
- [ ] Verify team orchestration context files exist
- [ ] Update task status to completed

**Timing**: 30 minutes

**Files to modify**:
- `specs/TODO.md` - Update task status
- `specs/state.json` - Update task status and artifacts

**Verification**:
```bash
# Verify no .claude/ paths remain
grep -r "\.claude/" .opencode/skills/skill-{reviser,team-research,team-plan,team-implement}/ || echo "Clean: no .claude/ references"

# Verify OC_ prefix is used
grep -r "specs/OC_" .opencode/skills/skill-{reviser,team-research,team-plan,team-implement}/ | head -5

# Verify AGENTS.md is referenced
grep -r "AGENTS\.md" .opencode/skills/skill-{reviser,team-research,team-plan,team-implement}/ | head -5
```

## Testing & Validation

- [ ] All 4 skills files exist in `.opencode/skills/`
- [ ] All 4 skills have correct file sizes (~matching original line counts)
- [ ] No `.claude/` paths remain in ported skills
- [ ] No `CLAUDE.md` references remain in ported skills
- [ ] `specs/OC_{NNN}_` pattern used throughout
- [ ] Team orchestration context files exist in `.opencode/context/`
- [ ] Environment variable reference correct in team skills
- [ ] Git commit successful with all changes

## Artifacts & Outputs

- `.opencode/skills/skill-reviser/SKILL.md` (489 lines)
- `.opencode/skills/skill-team-research/SKILL.md` (633 lines)
- `.opencode/skills/skill-team-plan/SKILL.md` (616 lines)
- `.opencode/skills/skill-team-implement/SKILL.md` (696 lines)
- `.opencode/context/core/patterns/team-orchestration.md` (146 lines)
- `.opencode/context/core/formats/team-metadata-extension.md` (if exists)
- `.opencode/context/core/reference/team-wave-helpers.md` (if exists)
- `specs/OC_504_port_missing_core_skills/plans/implementation-001.md` (this file)

## Rollback/Contingency

If implementation fails:
1. Remove partially created skill directories: `rm -rf .opencode/skills/skill-{reviser,team-research,team-plan,team-implement}/`
2. Remove partially copied context files from `.opencode/context/`
3. Reset task status to `planning` in state.json
4. User can re-run `/implement 504` to resume from failed phase
