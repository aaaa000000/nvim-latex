# Research Report: Task #504 - Port Missing Core Skills

**Task**: 504 - port_missing_core_skills
**Started**: 2026-05-02
**Completed**: 2026-05-02
**Effort**: Medium
**Dependencies**: None
**Sources/Inputs**:
- `.claude/skills/skill-*/SKILL.md` - 8 source skills
- `.opencode/skills/skill-*/SKILL.md` - 4 existing skills for comparison
- Task management state from `specs/TODO.md` and `specs/state.json`

**Artifacts**:
- specs/OC_504_port_missing_core_skills/reports/01_missing-skills-analysis.md (this report)

**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- **4 skills already exist** in `.opencode/skills/` with OpenCode-specific adaptations (OC_ prefix for task directories, `.opencode/` paths)
- **4 skills are completely missing** and need to be ported from `.claude/skills/`:
  1. skill-reviser - Plan revision with reviser-agent subagent
  2. skill-team-implement - Multi-agent implementation with wave-based phases
  3. skill-team-plan - Multi-agent planning with trade-off analysis
  4. skill-team-research - Multi-agent research with synthesis
- **5 key path adaptations** are consistently applied across all ported skills
- **All team skills require** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` environment variable

---

## Findings

### Source Analysis: 8 Skills from .claude/skills/

#### 1. skill-memory/SKILL.md (1,805+ lines)
- **Purpose**: Memory vault management for /learn command
- **Key Features**: Content mapping, MCP search, three operations (UPDATE, EXTEND, CREATE)
- **Special Modes**: distill mode (report, purge, merge, compress, refine, gc, auto)
- **Critical Patterns**: MANDATORY STOP with AskUserQuestion, keyword superset guarantee

#### 2. skill-project-overview/SKILL.md (431 lines)
- **Purpose**: Interactive repo analysis and task creation for project-overview.md
- **Key Features**: 3-stage workflow (auto-scan, interview, task creation)
- **Critical Path**: Does NOT write project-overview.md directly - creates task for /plan + /implement

#### 3. skill-reviser/SKILL.md (489 lines)
- **Purpose**: Thin wrapper delegating plan revision to reviser-agent subagent
- **Key Features**: Internal postflight pattern, plan revision OR description update
- **Critical**: Uses Task tool (NOT Skill) to spawn reviser-agent
- **Status**: ❌ MISSING from .opencode/skills/

#### 4. skill-spawn/SKILL.md (514 lines)
- **Purpose**: Blocker analysis and new task spawning with dependency management
- **Key Features**: Kahn's algorithm for topological sort, parent-child relationships
- **Critical**: Creates `.spawn-return.json` for subagent communication

#### 5. skill-team-implement/SKILL.md (696 lines)
- **Purpose**: Multi-agent implementation with parallel phase execution
- **Key Features**: Wave-based coordination, debugger teammate for error recovery
- **Critical**: Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- **Status**: ❌ MISSING from .opencode/skills/

#### 6. skill-team-plan/SKILL.md (616 lines)
- **Purpose**: Multi-agent planning with parallel plan generation
- **Key Features**: 2-3 teammates for diverse approaches, trade-off analysis
- **Critical**: Synthesizes candidates into final plan
- **Status**: ❌ MISSING from .opencode/skills/

#### 7. skill-team-research/SKILL.md (633 lines)
- **Purpose**: Multi-agent research with wave-based parallel execution
- **Key Features**: 4 teammates (Primary, Alternatives, Critic, Horizons)
- **Critical**: Conflict resolution and synthesis
- **Status**: ❌ MISSING from .opencode/skills/

#### 8. skill-tag/SKILL.md (404 lines)
- **Purpose**: Semantic version tagging for CI/CD deployment
- **Key Features**: --patch/--minor/--major flags, --force, --dry-run
- **Critical**: User-only command (agents cannot invoke)
- **Frontmatter**: `user-only: true`

---

### Target Analysis: Existing .opencode/skills/ Versions

#### Skills Already Ported (4):

| Skill | .claude Lines | .opencode Lines | Status | Key Adaptations |
|-------|---------------|-----------------|--------|-----------------|
| skill-memory | 1,805+ | 1,805+ | ✅ Ported | `specs/OC_{NNN}_*`, `.opencode/context/` |
| skill-project-overview | 431 | 431 | ✅ Ported | `.opencode/context/repo/`, `AGENTS.md` |
| skill-spawn | 514 | 514 | ✅ Ported | `specs/OC_{NNN}_*`, `.opencode/context/` |
| skill-tag | 404 | 569 | ✅ Ported | Added example flows, more examples |

#### Analysis of Adaptations Made:

1. **Task Directory Pattern**:
   - `.claude`: `specs/{NNN}_{SLUG}/`
   - `.opencode`: `specs/OC_{NNN}_{SLUG}/`
   
2. **Context Path Pattern**:
   - `.claude`: `.claude/context/`
   - `.opencode`: `.opencode/context/`
   
3. **Main Documentation**:
   - `.claude`: `.claude/CLAUDE.md`
   - `.opencode`: `.opencode/AGENTS.md`
   
4. **Scripts Path**:
   - `.claude`: `.claude/scripts/`
   - `.opencode`: `.opencode/scripts/`
   
5. **Skills Path**:
   - `.claude`: `.claude/skills/`
   - `.opencode`: `.opencode/skills/`

---

### Skills to Port: Complete Missing List

#### 1. skill-reviser/SKILL.md
**Source**: `.claude/skills/skill-reviser/SKILL.md` (489 lines)
**Target**: `.opencode/skills/skill-reviser/SKILL.md` (NEW)

**Path Adaptations Required**:
- `.claude/context/` → `.opencode/context/`
- `specs/{NNN}_` → `specs/OC_{NNN}_`
- `.claude/scripts/` → `.opencode/scripts/`

**Dependencies Referenced**:
- `reviser-agent` subagent (must exist)
- `.claude/context/formats/return-metadata-file.md`
- `.claude/context/formats/plan-format.md`
- `.claude/context/patterns/postflight-control.md`
- `.claude/context/patterns/file-metadata-exchange.md`
- `.claude/context/patterns/jq-escaping-workarounds.md`

---

#### 2. skill-team-implement/SKILL.md
**Source**: `.claude/skills/skill-team-implement/SKILL.md` (696 lines)
**Target**: `.opencode/skills/skill-team-implement/SKILL.md` (NEW)

**Path Adaptations Required**:
- All `.claude/` paths → `.opencode/`
- Task directory pattern: `specs/OC_{NNN}_`

**Dependencies Referenced**:
- `.claude/context/patterns/team-orchestration.md`
- `.claude/context/formats/team-metadata-extension.md`
- `.claude/context/formats/return-metadata-file.md`
- `.claude/context/reference/team-wave-helpers.md`

**Special Notes**:
- Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- Uses TeammateTool for team coordination
- Fallback to `skill-implementer` if team mode unavailable

---

#### 3. skill-team-plan/SKILL.md
**Source**: `.claude/skills/skill-team-plan/SKILL.md` (616 lines)
**Target**: `.opencode/skills/skill-team-plan/SKILL.md` (NEW)

**Path Adaptations Required**:
- All `.claude/` paths → `.opencode/`
- Task directory pattern: `specs/OC_{NNN}_`

**Dependencies Referenced**:
- `.claude/context/patterns/team-orchestration.md`
- `.claude/context/formats/team-metadata-extension.md`
- `.claude/context/formats/return-metadata-file.md`
- `.claude/context/reference/team-wave-helpers.md`

**Special Notes**:
- Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- Fallback to `skill-planner` if team mode unavailable
- Spawns 2-3 teammates for plan candidates

---

#### 4. skill-team-research/SKILL.md
**Source**: `.claude/skills/skill-team-research/SKILL.md` (633 lines)
**Target**: `.opencode/skills/skill-team-research/SKILL.md` (NEW)

**Path Adaptations Required**:
- All `.claude/` paths → `.opencode/`
- Task directory pattern: `specs/OC_{NNN}_`

**Dependencies Referenced**:
- `.claude/context/patterns/team-orchestration.md`
- `.claude/context/formats/team-metadata-extension.md`
- `.claude/context/formats/return-metadata-file.md`
- `.claude/context/reference/team-wave-helpers.md`

**Special Notes**:
- Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- Always uses 4 teammates (Primary, Alternatives, Critic, Horizons)
- Fallback to `skill-researcher` if team mode unavailable

---

## Dependency Analysis

### Context Files Referenced by Missing Skills

The 4 missing skills reference these context files that must exist in `.opencode/context/`:

#### Formats (3 files):
1. `.opencode/context/formats/return-metadata-file.md` - Base metadata schema
2. `.opencode/context/formats/plan-format.md` - Plan file format (skill-reviser)
3. `.opencode/context/formats/team-metadata-extension.md` - Team result schema

#### Patterns (2 files):
1. `.opencode/context/patterns/team-orchestration.md` - Wave coordination
2. `.opencode/context/patterns/postflight-control.md` - Marker file protocol
3. `.opencode/context/patterns/file-metadata-exchange.md` - File I/O helpers
4. `.opencode/context/patterns/jq-escaping-workarounds.md` - jq Issue #1132

#### Reference (1 file):
1. `.opencode/context/reference/team-wave-helpers.md` - Reusable wave patterns

### Subagents Required

These subagent definitions must exist (typically in `.opencode/agents/`):
1. `reviser-agent` - Used by skill-reviser
2. `spawn-agent` - Used by skill-spawn (already exists)
3. Teammate capability - Used by team skills (requires env var)

---

## Path Mapping: Complete .claude → .opencode Adaptations

### Mandatory Path Replacements

| Pattern | .claude Source | .opencode Target |
|---------|----------------|------------------|
| Root config | `.claude/CLAUDE.md` | `.opencode/AGENTS.md` |
| Skills dir | `.claude/skills/` | `.opencode/skills/` |
| Context dir | `.claude/context/` | `.opencode/context/` |
| Scripts dir | `.claude/scripts/` | `.opencode/scripts/` |
| Task directories | `specs/{NNN}_` | `specs/OC_{NNN}_` |

### Context File References in Skills

Each skill file contains context references like:
```markdown
Reference (do not load eagerly):
- Path: `.claude/context/formats/return-metadata-file.md`
```

These become:
```markdown
Reference (do not load eagerly):
- Path: `.opencode/context/formats/return-metadata-file.md`
```

### File Path Patterns in Code Examples

**Task Directory Pattern** (skill-spawn, skill-reviser):
```bash
# .claude version:
mkdir -p "specs/${padded_num}_${project_name}"

# .opencode version:
mkdir -p "specs/OC_${padded_num}_${project_name}"
```

**Script Path Pattern**:
```bash
# .claude version:
bash .claude/scripts/link-artifact-todo.sh

# .opencode version:
bash .opencode/scripts/link-artifact-todo.sh
```

**Metadata File Path**:
```json
// .claude version:
"metadata_file_path": "specs/{NNN}_{SLUG}/.return-meta.json"

// .opencode version:
"metadata_file_path": "specs/OC_{NNN}_{SLUG}/.return-meta.json"
```

---

## Recommendations

### Port Priority Order

**Phase 1: Foundation Skills** (No dependencies)
1. skill-reviser - Single-agent wrapper, reviser-agent dependency

**Phase 2: Team Skills** (Require team mode)
2. skill-team-research - Team research (4 teammates)
3. skill-team-plan - Team planning (2-3 teammates)
4. skill-team-implement - Team implementation (wave-based)

### Implementation Strategy

For each skill to port:
1. **Copy source** from `.claude/skills/skill-{name}/SKILL.md`
2. **Apply path replacements** using the mapping table above
3. **Verify context references** exist in `.opencode/context/`
4. **Test** with `/research 504 --team` (for team skills)

### Verification Checklist

- [ ] skill-reviser exists at `.opencode/skills/skill-reviser/SKILL.md`
- [ ] skill-team-implement exists at `.opencode/skills/skill-team-implement/SKILL.md`
- [ ] skill-team-plan exists at `.opencode/skills/skill-team-plan/SKILL.md`
- [ ] skill-team-research exists at `.opencode/skills/skill-team-research/SKILL.md`
- [ ] All internal paths use `.opencode/` prefix
- [ ] All task directories use `specs/OC_{NNN}_` pattern
- [ ] Context references point to `.opencode/context/`
- [ ] Scripts references point to `.opencode/scripts/`

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Team mode unavailable | High for team skills | Fallback to single-agent skills implemented |
| Context files missing | High | Verify all referenced files exist in `.opencode/context/` |
| Path inconsistencies | Medium | Use find/replace with exact patterns from mapping table |
| Subagent definitions missing | High | Ensure reviser-agent, spawn-agent exist in `.opencode/agents/` |
| Environment variable not set | Medium | Document `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` requirement |

---

## Appendix A: Skill Summary Table

| # | Skill | Lines | .claude Exists | .opencode Exists | Action |
|---|-------|-------|----------------|------------------|--------|
| 1 | skill-memory | 1,805+ | ✅ | ✅ | Compare versions |
| 2 | skill-project-overview | 431 | ✅ | ✅ | Compare versions |
| 3 | skill-reviser | 489 | ✅ | ❌ | **PORT** |
| 4 | skill-spawn | 514 | ✅ | ✅ | Compare versions |
| 5 | skill-team-implement | 696 | ✅ | ❌ | **PORT** |
| 6 | skill-team-plan | 616 | ✅ | ❌ | **PORT** |
| 7 | skill-team-research | 633 | ✅ | ❌ | **PORT** |
| 8 | skill-tag | 404 | ✅ | ✅ | Compare versions |

**Total to Port**: 4 skills (2,434 lines)
**Already Ported**: 4 skills

---

## Appendix B: Complete Path Replacement Script

For each skill file, execute these replacements:

```bash
# 1. Root documentation
sed -i 's/`.claude\/CLAUDE\.md`\/`.opencode\/AGENTS.md`/g' SKILL.md

# 2. Skills directory
sed -i 's/`.claude\/skills\//`.opencode\/skills\//g' SKILL.md

# 3. Context directory
sed -i 's/`.claude\/context\//`.opencode\/context\//g' SKILL.md

# 4. Scripts directory  
sed -i 's/`.claude\/scripts\//`.opencode\/scripts\//g' SKILL.md

# 5. Task directory pattern (in code examples)
sed -i 's/specs\/\${padded_num}/specs\/OC_\${padded_num}/g' SKILL.md
sed -i 's/specs\/{NNN}_/specs\/OC_{NNN}_/g' SKILL.md
sed -i 's/specs\/OC_OC_/specs\/OC_/g' SKILL.md  # Fix double prefix
```

---

## Context Extension Recommendations

**None required** - This is a porting task, not a discovery task. All referenced context files should already exist in the OpenCode system as they are used by the 4 already-ported skills.

If context files are missing during implementation:
1. Copy from `.claude/context/` to `.opencode/context/`
2. Apply same path replacements as skills
3. Verify no `.claude/` references remain

---

*Report generated by general-research-agent for task OC_504*
*Research completed: 2026-05-02*
*Next step: Run `/plan 504` to create implementation plan*
