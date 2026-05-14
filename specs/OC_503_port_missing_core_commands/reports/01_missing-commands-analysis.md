# Research Report: Task #503

**Task**: 503 - Port Missing Core Commands from .claude/ to .opencode/
**Started**: 2026-05-02T00:00:00Z
**Completed**: 2026-05-02T01:00:00Z
**Effort**: 4 hours
**Dependencies**: None
**Sources/Inputs**:
- 6 source command files from .claude/commands/
- 12 existing ported commands from .opencode/commands/
- Associated SKILL.md files from .claude/skills/ and .opencode/skills/
- AGENTS.md from .opencode/ and CLAUDE.md from .claude/
**Artifacts**:
- specs/OC_503_port_missing_core_commands/reports/01_missing-commands-analysis.md
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- **6 commands** need porting from `.claude/` to `.opencode/`: distill.md, learn.md, merge.md, project-overview.md, spawn.md, tag.md
- **4 associated skills** require porting: skill-memory, skill-project-overview, skill-spawn, skill-tag
- **2 agents** may need porting: spawn-agent, reviser-agent (skill-reviser context needed)
- **Path mapping** follows consistent pattern: `.claude/` → `.opencode/`, `CLAUDE.md` → `AGENTS.md`, `agents/` → `agent/subagents/`
- **Recommended order**: Port simpler commands first, then complex skill-dependent ones

---

## Context & Scope

This research analyzes the 6 missing commands that exist in `.claude/commands/` but not in `.opencode/commands/`. The goal is to understand the adaptations needed to port each command, identify dependencies, and recommend an optimal porting order.

### Commands to Port

| Command | Lines | Complexity | Skill Dependencies | Agent Dependencies |
|---------|-------|------------|-------------------|-------------------|
| distill.md | 197 | Medium | skill-memory | None |
| learn.md | 286 | Medium | skill-memory | None |
| merge.md | 434 | Low | None | None |
| project-overview.md | 53 | Low | skill-project-overview | None |
| spawn.md | 242 | High | skill-spawn | spawn-agent |
| tag.md | 75 | Low | skill-tag | None |

---

## Findings

### 1. Source Command Analysis

#### 1.1 distill.md

**Purpose**: Analyze memory vault health and run distillation operations (purge, merge, compress, refine, gc)

**Structure**:
- YAML frontmatter with description, layer, delegates-to
- Argument parsing section with sub-mode dispatch
- Workflow execution with 4 steps
- Error handling section
- State management section

**Key Features**:
- Sub-modes: report (default), purge, merge, compress, refine, gc, auto
- Flags: --dry-run, --verbose
- Delegates to: skill-memory mode=distill
- Reads/writes: .memory/memory-index.json, .memory/distill-log.json, specs/state.json

**Required Adaptations**:
- No path changes needed (references `.memory/` which is shared)
- Check skill-memory exists in .opencode/skills/

**Dependencies**:
- **skill-memory** (already exists in .opencode/skills/)

**Porting Difficulty**: Easy - Straightforward delegation pattern

---

#### 1.2 learn.md

**Purpose**: Add memories from text, files, directories, or task artifacts

**Structure**:
- YAML frontmatter
- Four-mode argument parsing (task, directory, file, text)
- Workflow execution with 2 steps
- Detailed mode-specific sections
- Error handling and state management

**Key Features**:
- Modes: text, file, directory, task (--task N)
- Content mapping with segmentation
- Memory operations: UPDATE, EXTEND, CREATE
- Classification taxonomy: [TECHNIQUE], [PATTERN], [CONFIG], [WORKFLOW], [INSIGHT], [SKIP]

**Required Adaptations**:
- Path references: `.claude/context/repo/project-overview.md` → `.opencode/...`
- Check that task directory pattern matches .opencode/ (specs/OC_NNN_*)

**Dependencies**:
- **skill-memory** (already exists)

**Porting Difficulty**: Easy - Mostly path updates

---

#### 1.3 merge.md

**Purpose**: Create pull/merge request for current branch (GitHub PR or GitLab MR)

**Structure**:
- YAML frontmatter with allowed-tools, argument-hint, model
- Platform flag mapping table
- 6-step execution flow
- Examples and troubleshooting

**Key Features**:
- Auto-detects platform from git remote URL
- Supports GitHub (gh) and GitLab (glab) CLIs
- Flags: --draft, --assignee, --label, --reviewer, --title, --body, --target
- Direct execution (no skill delegation)

**Required Adaptations**:
- No path changes needed
- References to `.claude/` in related commands section
- Remove references to `/task`, `/implement`, `/review` that link to .claude/

**Dependencies**: None

**Porting Difficulty**: Very Easy - Self-contained command

---

#### 1.4 project-overview.md

**Purpose**: Analyze repository and create task to generate project-overview.md

**Structure**:
- YAML frontmatter with allowed-tools, model
- Brief description and overview
- Interactive flow explanation
- Single execution instruction

**Key Features**:
- Creates task in [RESEARCHED] status
- User runs `/plan` then `/implement` separately
- Very short (53 lines) - delegates entirely to skill

**Required Adaptations**:
- Path references: `.claude/context/repo/project-overview.md` → `.opencode/context/...`
- Path references: `.claude/context/repo/update-project.md` → `.opencode/context/...`

**Dependencies**:
- **skill-project-overview** (NEEDS PORTING - exists only in .claude/)

**Porting Difficulty**: Easy - But requires skill porting first

---

#### 1.5 spawn.md

**Purpose**: Spawn new tasks to unblock a blocked task

**Structure**:
- YAML frontmatter with allowed-tools, argument-hint, model
- Complex checkpoint-based workflow (GATE IN → DELEGATE → GATE OUT)
- 3 stages with multiple steps each
- Error handling for each stage

**Key Features**:
- Analyzes task blocker and creates new dependent tasks
- Updates parent task to [BLOCKED] status
- Establishes dependency relationships
- Delegates to skill-spawn

**Required Adaptations**:
- Path references: `.claude/context/` → `.opencode/context/`
- Path references: `agents/` → `agent/subagents/`
- References to `CLAUDE.md` → `AGENTS.md`
- Update parent task directory pattern: `specs/{NNN}_{SLUG}/` → `specs/OC_{NNN}_{SLUG}/`

**Dependencies**:
- **skill-spawn** (NEEDS PORTING - exists only in .claude/)
- **spawn-agent** (NEEDS PORTING - exists only in .claude/agents/)

**Porting Difficulty**: Hard - Requires skill and agent porting

---

#### 1.6 tag.md

**Purpose**: Create and push semantic version tags for CI/CD deployment

**Structure**:
- YAML frontmatter with argument-hint, model
- Warning about user-only restriction
- Usage and flags documentation
- Workflow overview
- Agent restrictions section

**Key Features**:
- User-only command (agents prohibited from invoking)
- Flags: --patch, --minor, --major, --force, --dry-run
- Direct execution via skill-tag
- Updates deployment_versions in state.json

**Required Adaptations**:
- References to `CLAUDE.md` → `AGENTS.md`
- Path references in examples

**Dependencies**:
- **skill-tag** (already exists in .opencode/skills/)

**Porting Difficulty**: Very Easy - Self-contained

---

### 2. Target Structure Analysis

#### 2.1 Existing .opencode/commands/ Structure

**12 existing ported commands**:
- task.md - Task management
- fix-it.md - Tag scanning and task creation
- meta.md - System builder
- research.md - Task research
- plan.md - Plan creation
- implement.md - Plan execution
- revise.md - Plan revision
- review.md - Code review
- errors.md - Error analysis
- todo.md - Task archiving
- refresh.md - Resource cleanup

**Key patterns observed**:
1. **Frontmatter**: Consistent use of `description` field
2. **Input**: `$ARGUMENTS` as standard input
3. **Structure**: Argument parsing → Workflow execution → Error handling → State management
4. **Delegation**: Uses `<workflow_execution>` with `<step_N>` format
5. **Status updates**: Always update state.json first, then TODO.md
6. **Path pattern**: `specs/OC_{NNN}_{SLUG}/` (OC_ prefix)

#### 2.2 Path Mapping Conventions

| Source (.claude/) | Target (.opencode/) | Notes |
|-------------------|---------------------|-------|
| `.claude/` | `.opencode/` | Root directory |
| `.claude/commands/` | `.opencode/commands/` | Commands |
| `.claude/skills/` | `.opencode/skills/` | Skills |
| `.claude/agents/` | `.opencode/agent/subagents/` | Agents moved to subdirectory |
| `.claude/context/` | `.opencode/context/` | Context files |
| `.claude/rules/` | `.opencode/rules/` | Rules |
| `CLAUDE.md` | `AGENTS.md` | Main documentation file |
| `specs/{NNN}_{SLUG}/` | `specs/OC_{NNN}_{SLUG}/` | Task directories with OC_ prefix |

#### 2.3 Skill Mapping

| Skill | .claude/ | .opencode/ | Status |
|-------|----------|------------|--------|
| skill-researcher | ✓ | ✓ | Already ported |
| skill-planner | ✓ | ✓ | Already ported |
| skill-implementer | ✓ | ✓ | Already ported |
| skill-meta | ✓ | ✓ | Already ported |
| skill-fix-it | ✓ | ✓ | Already ported |
| skill-todo | ✓ | ✓ | Already ported |
| skill-refresh | ✓ | ✓ | Already ported |
| skill-status-sync | ✓ | ✓ | Already ported |
| skill-git-workflow | ✓ | ✓ | Already ported |
| skill-orchestrator | ✓ | ✓ | Already ported |
| skill-tag | ✓ | ✓ | Already ported |
| skill-memory | ✓ | ✗ | NEEDS PORTING |
| skill-project-overview | ✓ | ✗ | NEEDS PORTING |
| skill-spawn | ✓ | ✗ | NEEDS PORTING |
| skill-reviser | ✓ | ✗ | Optional - for /revise |

#### 2.4 Agent Mapping

| Agent | .claude/agents/ | .opencode/agent/subagents/ | Status |
|-------|-----------------|----------------------------|--------|
| general-research-agent | ✓ | ✓ | Already ported |
| general-implementation-agent | ✓ | ✓ | Already ported |
| planner-agent | ✓ | ✓ | Already ported |
| meta-builder-agent | ✓ | ✓ | Already ported |
| code-reviewer-agent | ✓ | ✓ | Already ported |
| neovim-research-agent | ✓ | ✗ | Extension - may not need |
| neovim-implementation-agent | ✓ | ✗ | Extension - may not need |
| nix-research-agent | ✓ | ✗ | Extension - may not need |
| nix-implementation-agent | ✓ | ✗ | Extension - may not need |
| spawn-agent | ✓ | ✗ | NEEDS PORTING |
| reviser-agent | ✓ | ✗ | Optional - for /revise |

---

### 3. Required Adaptations Summary

#### 3.1 Path Replacements

**Universal replacements for ALL commands**:
```
.claude/ → .opencode/
CLAUDE.md → AGENTS.md
agents/ → agent/subagents/
specs/{NNN}_ → specs/OC_{NNN}_
```

**Command-specific replacements**:

| Command | Specific Path Changes |
|---------|----------------------|
| distill.md | None (uses shared `.memory/`) |
| learn.md | `.claude/context/repo/` → `.opencode/context/` |
| merge.md | None (no path dependencies) |
| project-overview.md | `.claude/context/repo/` → `.opencode/context/` |
| spawn.md | `.claude/context/`, `agents/` → `agent/subagents/` |
| tag.md | `CLAUDE.md` → `AGENTS.md` |

#### 3.2 Content Adaptations

**Status markers** (consistent across both systems):
- `[NOT STARTED]`, `[RESEARCHING]`, `[RESEARCHED]`, `[PLANNING]`, `[PLANNED]`, `[IMPLEMENTING]`, `[COMPLETED]`, `[BLOCKED]`, `[ABANDONED]`, `[PARTIAL]`

**Task numbering**:
- `.claude/`: Uses plain `N` in state.json, `{NNN}` in paths
- `.opencode/`: Uses `OC_N` format consistently

**Commit messages**:
- Same format: `task {N}: {action}`
- Same session ID format: `sess_{timestamp}_{random}`

---

### 4. Dependency Mapping

```
Commands to Port:
├── distill.md ──────┬──→ skill-memory (exists) ────────────┐
├── learn.md ─────────┤                                      │
│                     └──→ .memory/ (shared, no change)      │
├── merge.md ────────────→ None                              │
├── project-overview.md ─→ skill-project-overview (needs) ──┤
├── spawn.md ────────────→ skill-spawn (needs) ──────────────┤
│                          └──→ spawn-agent (needs)          │
└── tag.md ──────────────→ skill-tag (exists) ───────────────┘

Skills to Port:
├── skill-memory ────┐
├── skill-project-overview
├── skill-spawn ─────┴──→ spawn-agent (needs)
└── skill-reviser (optional for /revise)

Agents to Port:
├── spawn-agent
└── reviser-agent (optional)
```

---

## Recommendations

### 5.1 Porting Order

**Phase 1: Independent Commands (No skill dependencies)**
1. **tag.md** - Simplest, no path changes
2. **merge.md** - Self-contained, direct execution

**Phase 2: Commands with Existing Skills**
3. **distill.md** - Depends on skill-memory (exists in .opencode/)
4. **learn.md** - Depends on skill-memory (exists in .opencode/)

**Phase 3: Skills Required**
5. **skill-memory** - Required for distill and learn
   - Port from .claude/skills/ to .opencode/skills/
6. **skill-project-overview** - Required for project-overview command
7. **skill-spawn** - Required for spawn command
8. **spawn-agent** - Required by skill-spawn

**Phase 4: Complex Commands**
9. **project-overview.md** - After skill-project-overview is ported
10. **spawn.md** - After skill-spawn and spawn-agent are ported

### 5.2 Implementation Strategy

**For each command**:
1. Copy source file from `.claude/commands/{file}` to `.opencode/commands/{file}`
2. Apply universal path replacements
3. Apply command-specific path replacements
4. Verify skill dependencies exist in .opencode/
5. Update any task number references (N → OC_N format)
6. Test the command workflow end-to-end

**For each skill**:
1. Copy source file from `.claude/skills/skill-{name}/SKILL.md`
2. Create directory `.opencode/skills/skill-{name}/`
3. Write SKILL.md with path adaptations
4. Update references to context files

**For each agent**:
1. Copy source file from `.claude/agents/{agent}.md`
2. Create file at `.opencode/agent/subagents/{agent}.md`
3. Update path references in agent definition

### 5.3 Verification Checklist

For each ported command:
- [ ] All `.claude/` paths updated to `.opencode/`
- [ ] All `CLAUDE.md` references updated to `AGENTS.md`
- [ ] All `agents/` paths updated to `agent/subagents/`
- [ ] Task directory format uses `OC_{NNN}_` prefix
- [ ] Skill dependencies verified to exist
- [ ] Agent dependencies verified to exist
- [ ] Frontmatter preserved correctly
- [ ] Argument parsing logic unchanged
- [ ] Workflow execution steps unchanged
- [ ] Error handling sections unchanged
- [ ] State management paths updated

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| skill-memory differences between versions | Medium | Medium | Compare .claude/ and .opencode/ versions carefully |
| spawn-agent has different return format | High | Low | Test spawn workflow with sample blocked task |
| Path references missed during porting | Low | Medium | Use grep to search for remaining `.claude/` references |
| State format differences | Medium | Low | Verify state.json schema matches between systems |
| Task numbering confusion | Low | Medium | Document OC_ prefix requirement clearly |

---

## Context Extension Recommendations

**None** - This is a meta task (porting system components), so no context gaps to document for future non-meta tasks.

---

## Appendix A: Detailed File Analysis

### A.1 Lines of Code Comparison

| File | .claude/ Lines | .opencode/ Lines | Diff |
|------|---------------|------------------|------|
| commands/task.md | - | 267 | N/A |
| commands/fix-it.md | - | 114 | N/A |
| commands/research.md | - | 315 | N/A |
| commands/distill.md | 197 | - | -197 |
| commands/learn.md | 286 | - | -286 |
| commands/merge.md | 434 | - | -434 |
| commands/project-overview.md | 53 | - | -53 |
| commands/spawn.md | 242 | - | -242 |
| commands/tag.md | 75 | - | -75 |

### A.2 Cross-Reference Map

**Commands referencing other files**:

```
distill.md
├── skill-memory (delegates to)
├── .memory/memory-index.json (reads)
├── .memory/distill-log.json (writes)
└── specs/state.json (updates)

learn.md
├── skill-memory (delegates to)
├── .memory/30-Templates/memory-template.md (reference)
├── .memory/20-Indices/index.md (reference)
├── specs/{NNN}_*/ (reads task artifacts)
└── .memory/10-Memories/ (writes)

merge.md
├── git CLI (executes)
├── gh CLI (executes)
└── glab CLI (executes)

project-overview.md
├── skill-project-overview (delegates to)
├── .claude/context/repo/project-overview.md (checks)
├── .claude/context/repo/update-project.md (reference)
├── specs/TODO.md (updates)
└── specs/state.json (updates)

spawn.md
├── skill-spawn (delegates to)
├── spawn-agent (subagent)
├── specs/state.json (updates)
└── specs/TODO.md (updates)

tag.md
├── skill-tag (delegates to)
├── git CLI (executes)
└── specs/state.json (updates)
```

---

## Appendix B: Migration Pattern Examples

### Example 1: Simple Path Replacement

**Before (.claude/commands/distill.md)**:
```markdown
---
description: Analyze memory vault health...
---

Delegates To: skill-memory mode=distill
```

**After (.opencode/commands/distill.md)**:
```markdown
---
description: Analyze memory vault health...
---

Delegates To: skill-memory mode=distill
```
*(No changes needed - no .claude/ specific paths)*

### Example 2: Path Reference Update

**Before (.claude/commands/learn.md)**:
```markdown
Reference (do not load eagerly):
- Path: `@.claude/context/project/memory/learn-usage.md` - Usage guide
```

**After (.opencode/commands/learn.md)**:
```markdown
Reference (do not load eagerly):
- Path: `@.opencode/context/project/memory/learn-usage.md` - Usage guide
```

### Example 3: Task Directory Pattern

**Before (.claude/commands/spawn.md)**:
```bash
padded_num=$(printf "%03d" "$task_number")
plan_path="specs/${padded_num}_${project_name}/plans/"
```

**After (.opencode/commands/spawn.md)**:
```bash
padded_num=$(printf "%03d" "$task_number")
plan_path="specs/OC_${padded_num}_${project_name}/plans/"
```

---

## Appendix C: File Inventory

### Commands to Port
```
.claude/commands/distill.md         -> .opencode/commands/distill.md
.claude/commands/learn.md           -> .opencode/commands/learn.md
.claude/commands/merge.md           -> .opencode/commands/merge.md
.claude/commands/project-overview.md -> .opencode/commands/project-overview.md
.claude/commands/spawn.md           -> .opencode/commands/spawn.md
.claude/commands/tag.md             -> .opencode/commands/tag.md
```

### Skills to Port
```
.claude/skills/skill-memory/SKILL.md          -> .opencode/skills/skill-memory/SKILL.md
.claude/skills/skill-project-overview/SKILL.md -> .opencode/skills/skill-project-overview/SKILL.md
.claude/skills/skill-spawn/SKILL.md           -> .opencode/skills/skill-spawn/SKILL.md
```

### Agents to Port
```
.claude/agents/spawn-agent.md       -> .opencode/agent/subagents/spawn-agent.md
```

---

*End of Research Report*
