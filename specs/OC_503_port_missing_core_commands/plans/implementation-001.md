# Implementation Plan: Task #503

- **Task**: 503 - Port Missing Core Commands
- **Status**: [COMPLETED]
- **Effort**: 12 hours
- **Dependencies**: None
- **Research Inputs**: specs/OC_503_port_missing_core_commands/reports/01_missing-commands-analysis.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan ports 6 missing commands from `.claude/` to `.opencode/`: `tag.md`, `merge.md`, `distill.md`, `learn.md`, `project-overview.md`, and `spawn.md`. The porting involves adapting Claude-specific references to OpenCode equivalents (`.claude/` → `.opencode/`, `CLAUDE.md` → `AGENTS.md`, `agents/` → `agent/subagents/`, `specs/{NNN}_*` → `specs/OC_{NNN}_*`).

### Research Integration

The research identified 6 commands and 3 skills that need porting:
- **Independent commands**: tag.md (75 lines), merge.md (434 lines)
- **Commands with existing skills**: distill.md, learn.md (delegate to skill-memory - already exists)
- **Skills to port**: skill-memory, skill-project-overview, skill-spawn
- **Agents to port**: spawn-agent
- **Complex commands**: project-overview.md (delegates to skill-project-overview), spawn.md (delegates to skill-spawn)

The recommended order is: independent commands → commands with existing skills → skills → agents → complex commands.

## Goals & Non-Goals

**Goals**:
- Port all 6 missing commands to `.opencode/commands/`
- Port required skills: skill-memory, skill-project-overview, skill-spawn
- Port required agent: spawn-agent
- Update all Claude-specific path references to OpenCode equivalents
- Ensure all ported files work correctly with the OpenCode system

**Non-Goals**:
- Do not port skills that already exist in `.opencode/` (skill-tag, skill-learn already exist)
- Do not modify existing `.opencode/` files unless required for references
- Do not add new features beyond what exists in `.claude/` versions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path references missed during adaptation | High | Medium | Use systematic search/replace with verification checklist |
| skill-memory conflicts with existing skill-learn | High | Low | skill-learn already exists and handles text mode; skill-memory adds directory/file/task modes |
| Dependency chain failures (spawn requires skill-spawn requires spawn-agent) | Medium | Low | Follow strict phase order; verify each component before moving to next |
| Complex logic in merge.md for GitHub/GitLab platform detection | Medium | Low | Port verbatim first, then test with real git remotes |
| spawn-agent has complex workflow with metadata files | High | Medium | Careful adaptation of return file paths and delegation context |

## Implementation Phases

### Phase 1: Independent Commands [COMPLETED]

**Goal**: Port tag.md and merge.md (no skill dependencies)

**Tasks**:
- [ ] **1.1** Copy `.claude/commands/tag.md` to `.opencode/commands/tag.md`
- [ ] **1.2** Update path references in tag.md:
  - Replace references to `.claude/` with `.opencode/`
  - Update `CLAUDE.md` to `AGENTS.md` if mentioned
- [ ] **1.3** Verify tag.md delegates to `skill-tag` (already exists in .opencode/)
- [ ] **1.4** Copy `.claude/commands/merge.md` to `.opencode/commands/merge.md`
- [ ] **1.5** Update path references in merge.md:
  - Replace `.claude/` → `.opencode/`
  - Update any context references from `.claude/context/` to `.opencode/context/`
- [ ] **1.6** Verify merge.md Git workflow commands work correctly

**Timing**: 1.5 hours

**Files to modify**:
- `.opencode/commands/tag.md` - new file
- `.opencode/commands/merge.md` - new file

**Verification**:
- [ ] tag.md file exists and has correct frontmatter
- [ ] merge.md file exists and has correct frontmatter
- [ ] No remaining `.claude/` references in ported files
- [ ] Git commands in merge.md reference correct tools

---

### Phase 2: Commands with Existing Skills [COMPLETED]

**Goal**: Port distill.md and learn.md (skills already exist in .opencode/)

**Context**: skill-memory exists in .claude/ but skill-learn exists in .opencode/. Research shows skill-learn may be a simplified version. Need to check if skill-memory should be ported to add file/directory/task modes.

**Tasks**:
- [ ] **2.1** Analyze existing `.opencode/skills/skill-learn/SKILL.md` vs `.claude/skills/skill-memory/SKILL.md`
- [ ] **2.2** Copy `.claude/commands/distill.md` to `.opencode/commands/distill.md`
- [ ] **2.3** Update distill.md path references:
  - Replace `.claude/` → `.opencode/`
  - Replace `CLAUDE.md` → `AGENTS.md`
  - Replace `.memory/` paths (these should remain as-is, memory vault is shared)
- [ ] **2.4** Copy `.claude/commands/learn.md` to `.opencode/commands/learn.md`
- [ ] **2.5** Update learn.md path references:
  - Replace `.claude/` → `.opencode/`
  - Replace `specs/{NNN}_*` → `specs/OC_{NNN}_*` where applicable
- [ ] **2.6** Verify learn.md delegation - if skill-memory doesn't exist in .opencode, document this dependency

**Timing**: 1.5 hours

**Files to modify**:
- `.opencode/commands/distill.md` - new file
- `.opencode/commands/learn.md` - new file

**Verification**:
- [ ] Both files ported with updated paths
- [ ] No remaining `.claude/` or `CLAUDE.md` references
- [ ] skill-memory dependency documented (to be addressed in Phase 3)

---

### Phase 3: Port skill-memory Skill [COMPLETED]

**Goal**: Port skill-memory which provides file, directory, and task modes for /learn and all modes for /distill

**Tasks**:
- [ ] **3.1** Create directory `.opencode/skills/skill-memory/`
- [ ] **3.2** Copy `.claude/skills/skill-memory/SKILL.md` to `.opencode/skills/skill-memory/SKILL.md`
- [ ] **3.3** Update skill-memory path references:
  - Replace `.claude/` → `.opencode/`
  - Replace `CLAUDE.md` → `AGENTS.md`
  - Replace `specs/{NNN}_*` → `specs/OC_{NNN}_*` in task mode section
  - Keep `.memory/` paths unchanged (shared memory vault)
- [ ] **3.4** Verify skill-memory modes:
  - text mode (may overlap with skill-learn)
  - file mode
  - directory mode
  - task mode
  - distill mode (report, purge, merge, compress, refine, gc, auto)
- [ ] **3.5** Check for any agent references in skill-memory (should be direct execution)

**Timing**: 2 hours

**Files to modify**:
- `.opencode/skills/skill-memory/SKILL.md` - new file

**Verification**:
- [ ] skill-memory directory and file created
- [ ] All path references updated to OpenCode equivalents
- [ ] Task mode uses `specs/OC_{NNN}_*` pattern
- [ ] Memory vault paths remain `.memory/`

---

### Phase 4: Port skill-project-overview Skill [COMPLETED]

**Goal**: Port skill-project-overview which handles interactive repository scanning

**Tasks**:
- [ ] **4.1** Create directory `.opencode/skills/skill-project-overview/`
- [ ] **4.2** Copy `.claude/skills/skill-project-overview/SKILL.md` to `.opencode/skills/skill-project-overview/SKILL.md`
- [ ] **4.3** Update skill-project-overview path references:
  - Replace `.claude/` → `.opencode/`
  - Replace `CLAUDE.md` → `AGENTS.md`
  - Replace `.claude/context/repo/` → `.opencode/context/repo/`
  - Replace `specs/{NNN}_*` → `specs/OC_{NNN}_*`
- [ ] **4.4** Verify task creation logic uses correct task directory format
- [ ] **4.5** Check project-overview.md generation path references

**Timing**: 1.5 hours

**Files to modify**:
- `.opencode/skills/skill-project-overview/SKILL.md` - new file

**Verification**:
- [ ] skill-project-overview created with updated paths
- [ ] Repository scan paths updated
- [ ] Task creation uses `specs/OC_{NNN}_*` format

---

### Phase 5: Port skill-spawn Skill and spawn-agent [COMPLETED]

**Goal**: Port skill-spawn wrapper and spawn-agent subagent (complex dependency chain)

**Tasks**:
- [ ] **5.1** Create directory `.opencode/skills/skill-spawn/`
- [ ] **5.2** Copy `.claude/skills/skill-spawn/SKILL.md` to `.opencode/skills/skill-spawn/SKILL.md`
- [ ] **5.3** Update skill-spawn path references:
  - Replace `.claude/` → `.opencode/`
  - Replace `agents/` → `agent/subagents/`
  - Replace `CLAUDE.md` → `AGENTS.md`
  - Replace `specs/{NNN}_*` → `specs/OC_{NNN}_*`
- [ ] **5.4** Verify spawn-agent invocation path: `agent/subagents/spawn-agent.md`
- [ ] **5.5** Create directory if needed: `.opencode/agent/subagents/`
- [ ] **5.6** Copy `.claude/agents/spawn-agent.md` to `.opencode/agent/subagents/spawn-agent.md`
- [ ] **5.7** Update spawn-agent path references:
  - Replace `.claude/` → `.opencode/`
  - Replace `CLAUDE.md` → `AGENTS.md`
  - Replace `specs/{NNN}_*` → `specs/OC_{NNN}_*`
- [ ] **5.8** Verify spawn-agent context references:
  - `.claude/context/formats/` → `.opencode/context/formats/`
  - `.claude/context/standards/` → `.opencode/context/standards/`

**Timing**: 3 hours

**Files to modify**:
- `.opencode/skills/skill-spawn/SKILL.md` - new file
- `.opencode/agent/subagents/spawn-agent.md` - new file

**Verification**:
- [ ] skill-spawn created with correct subagent path
- [ ] spawn-agent created in correct location
- [ ] All delegation context paths updated
- [ ] Return file paths updated

---

### Phase 6: Port Complex Commands [COMPLETED]

**Goal**: Port project-overview.md and spawn.md (depend on skills from Phases 4-5)

**Tasks**:
- [ ] **6.1** Copy `.claude/commands/project-overview.md` to `.opencode/commands/project-overview.md`
- [ ] **6.2** Update project-overview.md path references:
  - Replace `.claude/` → `.opencode/`
  - Replace `CLAUDE.md` → `AGENTS.md`
  - Replace `specs/{NNN}_*` → `specs/OC_{NNN}_*`
  - Update skill-project-overview references
- [ ] **6.3** Copy `.claude/commands/spawn.md` to `.opencode/commands/spawn.md`
- [ ] **6.4** Update spawn.md path references:
  - Replace `.claude/` → `.opencode/`
  - Replace `CLAUDE.md` → `AGENTS.md`
  - Replace `agents/` → `agent/subagents/`
  - Replace `specs/{NNN}_*` → `specs/OC_{NNN}_*`
- [ ] **6.5** Verify spawn.md delegates to skill-spawn correctly

**Timing**: 1.5 hours

**Files to modify**:
- `.opencode/commands/project-overview.md` - new file
- `.opencode/commands/spawn.md` - new file

**Verification**:
- [ ] Both complex commands ported
- [ ] All skill/agent references updated
- [ ] Task directory patterns use `OC_{NNN}` prefix

---

### Phase 7: Final Verification and Documentation [COMPLETED]

**Goal**: Verify all ports are complete and create summary

**Tasks**:
- [ ] **7.1** Run comprehensive path check across all ported files
- [ ] **7.2** Verify no remaining `.claude/` references in ported commands
- [ ] **7.3** Verify no remaining `CLAUDE.md` references (should be `AGENTS.md`)
- [ ] **7.4** Verify no remaining `agents/` references (should be `agent/subagents/`)
- [ ] **7.5** Verify `specs/{NNN}_*` references use `specs/OC_{NNN}_*` or `specs/{NNN}_*` as appropriate
- [ ] **7.6** Create verification checklist summary
- [ ] **7.7** Update task status to [COMPLETED]

**Timing**: 1 hour

**Verification Commands**:
```bash
# Check for any remaining .claude/ references in ported files
grep -r "\.claude/" .opencode/commands/ .opencode/skills/skill-{memory,project-overview,spawn}/ .opencode/agent/subagents/spawn-agent.md 2>/dev/null || echo "No .claude/ references found"

# Check for CLAUDE.md references (excluding legitimate references)
grep -r "CLAUDE.md" .opencode/commands/ .opencode/skills/ 2>/dev/null | grep -v "AGENTS.md" || echo "No unconverted CLAUDE.md references"

# Check for correct agent path references
grep -r "agent/subagents" .opencode/skills/skill-spawn/SKILL.md
```

---

## Testing & Validation

- [ ] All 6 commands exist in `.opencode/commands/`
- [ ] skill-memory exists in `.opencode/skills/`
- [ ] skill-project-overview exists in `.opencode/skills/`
- [ ] skill-spawn exists in `.opencode/skills/`
- [ ] spawn-agent exists in `.opencode/agent/subagents/`
- [ ] No `.claude/` references in ported files
- [ ] No `CLAUDE.md` references (should be `AGENTS.md`)
- [ ] Task directory patterns use `OC_{NNN}_*` where appropriate
- [ ] Memory vault paths remain `.memory/` (shared)

## Artifacts & Outputs

| File | Type | Description |
|------|------|-------------|
| `.opencode/commands/tag.md` | Command | Semantic version tagging |
| `.opencode/commands/merge.md` | Command | Create pull/merge requests |
| `.opencode/commands/distill.md` | Command | Memory vault maintenance |
| `.opencode/commands/learn.md` | Command | Add memories |
| `.opencode/commands/project-overview.md` | Command | Generate project overview |
| `.opencode/commands/spawn.md` | Command | Spawn tasks to unblock |
| `.opencode/skills/skill-memory/SKILL.md` | Skill | Memory vault management |
| `.opencode/skills/skill-project-overview/SKILL.md` | Skill | Project overview generation |
| `.opencode/skills/skill-spawn/SKILL.md` | Skill | Spawn task wrapper |
| `.opencode/agent/subagents/spawn-agent.md` | Agent | Blocker analysis agent |

## Rollback/Contingency

If any phase fails:
1. **Document the failure** in the phase's verification checklist
2. **Do not proceed** to dependent phases
3. **Revert ported files** from the failed phase:
   ```bash
   rm -rf .opencode/commands/{tag,merge,distill,learn,project-overview,spawn}.md
   rm -rf .opencode/skills/skill-{memory,project-overview,spawn}/
   rm -f .opencode/agent/subagents/spawn-agent.md
   ```
4. **Create a new task** for the specific failing component with detailed failure analysis

## Summary

This plan ports 6 commands, 3 skills, and 1 agent from `.claude/` to `.opencode/` following a dependency-aware order:
1. Independent commands (tag, merge) - Phase 1
2. Commands with existing skills (distill, learn) - Phase 2
3. Required skills (skill-memory, skill-project-overview, skill-spawn) - Phases 3-5
4. Complex commands (project-overview, spawn) - Phase 6
5. Final verification - Phase 7

Total estimated effort: 12 hours across 7 phases.
