# Research Report: Systematic OpenCode Cleanup

**Task**: OC_514 - systematic_opencode_cleanup
**Started**: 2026-05-02T00:00:00Z
**Completed**: 2026-05-02T01:00:00Z
**Effort**: 2-3 hours
**Dependencies**: None
**Sources/Inputs**: Codebase analysis of .opencode/ directory
**Artifacts**: specs/OC_514_systematic_opencode_cleanup/reports/01_cleanup-audit.md
**Standards**: report-format.md, agent-frontmatter-standard.md

## Executive Summary

This research identified **2,142 .claude/ path references** and **247 CLAUDE.md references** in the .opencode/ directory that require systematic cleanup. The primary objective is to migrate all legacy `.claude/` paths to `.opencode/` and update CLAUDE.md references to AGENTS.md where appropriate.

Key findings:
- **2142 .claude/ references** across approximately 140 unique files
- **247 CLAUDE.md references** across approximately 70 unique files  
- **1 agent frontmatter inconsistency**: `.opencode/agent/orchestrator.md` uses non-standard `tools:` format
- **All 16 extension manifests have valid dependencies** (no fixes required)
- **Duplicate files exist** between `.opencode/agent/subagents/` and `.opencode/extensions/core/agents/`

## Context & Scope

The .opencode/ agent system was ported from .claude/ directory structure. While the file migration is complete, internal path references within documentation, skills, and agent files still reference the old `.claude/` paths. This creates confusion and potential broken functionality when the system tries to reference non-existent paths.

### Scope Boundaries
- **In scope**: All .claude/ and CLAUDE.md references within .opencode/ directory
- **Out of scope**: References in .claude/ directory itself (to be handled separately)
- **Special cases**: References to external .claude/ (like `~/.claude/` for user settings)

## Findings

### 1. .claude/ Path Reference Analysis

#### Total Count
```
2,142 total .claude/ references across .opencode/ markdown files
```

#### Breakdown by Category

| Category | Count | Primary Files |
|----------|-------|---------------|
| **Extensions (core)** | 1,102 | `.opencode/extensions/core/` duplicates |
| **Context files** | 468 | Templates, standards, troubleshooting |
| **Documentation** | 302 | Guides, architecture docs |
| **Skills** | 138 | SKILL.md files in skills/ |
| **Agent definitions** | 66 | Subagent files |
| **Commands** | 44 | Command definitions |
| **Rules** | 15 | Rule files |
| **Templates** | 2 | Header and README templates |
| **AGENTS.md** | 3 | Main documentation file |

#### Top Files by Reference Count

| File | Count | Type |
|------|-------|------|
| `.opencode/extensions/core/docs/guides/context-loading-best-practices.md` | 38 | Guide (duplicate) |
| `.opencode/docs/guides/context-loading-bestactices.md` | 38 | Guide |
| `.opencode/extensions/core/docs/guides/creating-extensions.md` | 36 | Guide (duplicate) |
| `.opencode/docs/guides/creating-extensions.md` | 36 | Guide |
| `.opencode/extensions/core/docs/architecture/extension-system.md` | 29 | Architecture (duplicate) |
| `.opencode/docs/architecture/extension-system.md` | 29 | Architecture |
| `.opencode/extensions/core/agents/meta-builder-agent.md` | 28 | Agent (duplicate) |
| `.opencode/agent/subagents/meta-builder-agent.md` | 28 | Agent |

#### Path Subdirectory Distribution

```
.claude/context/     - 1,100+ references (formats, standards, patterns, guides)
.claude/agents/      - 150+ references
.claude/skills/      - 138 references
.claude/scripts/     - 80+ references
.claude/extensions/  - 48 references
.claude/commands/    - 44 references
.claude/docs/        - 40+ references
```

### 2. CLAUDE.md Reference Analysis

#### Total Count
```
247 CLAUDE.md references across .opencode/ markdown files
```

#### Context Categories

**Type 1: Context References (should become AGENTS.md)**
- Examples: `@.claude/CLAUDE.md` → `@.opencode/AGENTS.md`
- Count: ~180 references
- Files: Skills, agents, context files

**Type 2: Documentation References (may need context-aware updates)**
- Examples: "See CLAUDE.md for..."
- Count: ~50 references
- Files: Guides, architecture docs

**Type 3: Code/Path References (need careful review)**
- Examples: `.claude/CLAUDE.md`
- Count: ~17 references
- Files: Scripts, skills

#### Top Files with CLAUDE.md References

| File | Count |
|------|-------|
| `.opencode/commands/todo.md` | 24 |
| `.opencode/docs/architecture/extension-system.md` | 19 |
| `.opencode/docs/guides/creating-extensions.md` | 10 |
| `.opencode/context/guides/extension-development.md` | 8 |
| `.opencode/docs/guides/adding-domains.md` | 7 |

### 3. Agent Frontmatter Validation

#### Standard Frontmatter (Correct)
All core agents in `.opencode/agent/subagents/` use the correct format:

```yaml
---
name: spawn-agent
description: Analyzes blocked tasks, researches blockers...
model: opus
---
```

#### Non-Standard Frontmatter (Issue Found)
**File**: `.opencode/agent/orchestrator.md`

**Current (incorrect)**:
```yaml
---
name: orchestrator
description: "Read-only repository assistant..."
mode: primary
temperature: 0.3
tools:
  read: true
  write: false
  edit: false
  glob: true
  grep: true
  bash: false
  task: false
---
```

**Problem**: The `tools:` block uses inline YAML object format which is inconsistent with the agent frontmatter standard defined in `.opencode/docs/reference/standards/agent-frontmatter-standard.md`.

**Standard requires**:
- `name`: string (required)
- `description`: string (required)
- `model`: string (optional)

**Tools specification** in this file appears to be a legacy format that should be removed or converted to match the standard.

### 4. Extension Manifest Validation

All 16 extension manifests were reviewed:

| Extension | Dependencies | Status |
|-----------|--------------|--------|
| core | [] | Valid |
| epidemiology | ["core"] | Valid |
| filetypes | ["core"] | Valid |
| formal | ["core"] | Valid |
| founder | ["core", "slidev"] | Valid |
| latex | ["core"] | Valid |
| lean | ["core"] | Valid |
| memory | ["core"] | Valid |
| nix | ["core"] | Valid |
| nvim | ["core"] | Valid |
| present | ["core", "slidev"] | Valid |
| python | ["core"] | Valid |
| slidev | ["core"] | Valid |
| typst | ["core"] | Valid |
| web | ["core"] | Valid |
| z3 | ["core"] | Valid |

**Result**: All manifests have proper dependencies. No fixes required.

### 5. Duplicate File Issue

Identified duplicate files between:
- `.opencode/agent/subagents/*` (primary location)
- `.opencode/extensions/core/agents/*` (extension location)

**Files affected** (7 agents):
- `code-reviewer-agent.md`
- `general-implementation-agent.md`
- `general-research-agent.md`
- `meta-builder-agent.md`
- `planner-agent.md`
- `reviser-agent.md`
- `spawn-agent.md`

These files appear to be identical (diff shows no differences). Both locations reference `.claude/` paths and need updating.

### 6. Path Mapping Documentation

#### Primary Mappings

| From | To | Context |
|------|-----|---------|
| `.claude/` | `.opencode/` | All internal system references |
| `.claude/CLAUDE.md` | `.opencode/AGENTS.md` | Main documentation reference |
| `.claude/agents/` | `.opencode/agent/subagents/` | Agent definitions |
| `.claude/skills/` | `.opencode/skills/` | Skill definitions |
| `.claude/context/` | `.opencode/context/` | Context files |
| `.claude/commands/` | `.opencode/commands/` | Command definitions |
| `.claude/scripts/` | `.opencode/scripts/` | Utility scripts |
| `.claude/extensions/` | `.opencode/extensions/` | Extensions |
| `.claude/rules/` | `.opencode/rules/` | Rule files |

#### Special Cases (Do NOT Change)

| Pattern | Reason |
|---------|--------|
| `~/.claude/` | User home directory settings |
| `.claude/` when referring to legacy system documentation | Historical context |
| References in migration guides | Should document the transition |

## Recommendations

### Phase 1: Critical Path Updates (Priority 1)

1. **Update agent/subagents/ files** (8 files)
   - These are the core agents that are actively invoked
   - Update all `.claude/` references to `.opencode/`
   - Update CLAUDE.md references to AGENTS.md

2. **Fix orchestrator.md frontmatter**
   - Remove non-standard `tools:` block
   - Keep only standard fields: name, description, model

3. **Update skill files in skills/** (17 skills)
   - SKILL.md files contain execution paths
   - Critical for workflow functionality

### Phase 2: Context and Standards Updates (Priority 2)

4. **Update context/ files** (formats, standards, patterns, templates)
   - High reference count (468+)
   - Used as templates for new files

5. **Update commands/** (17 commands)
   - User-facing command definitions
   - Important for user experience

### Phase 3: Documentation Updates (Priority 3)

6. **Update docs/** guides and architecture
   - Lower priority as these are reference materials
   - Large file count (300+ references)

7. **Update AGENTS.md main file**
   - Self-references and intro text

### Phase 4: Extension Cleanup (Priority 4)

8. **Update extensions/core/ duplicates**
   - These are copies of main files
   - May be auto-generated (verify first)

### Special Considerations

#### AGENTS.md Line 5
The AGENTS.md file contains:
```markdown
> **Port of CLAUDE.md**: This documentation was ported from `.claude/CLAUDE.md` on 2026-05-02...
```

This is **historical context** and should be preserved as-is, explaining the origin of the file.

#### Skill SCRIPT References
Skills reference scripts like:
- `.claude/scripts/update-task-status.sh`
- `.claude/scripts/link-artifact-todo.sh`
- `.claude/scripts/validate-artifact.sh`

These should become:
- `.opencode/scripts/update-task-status.sh`
- `.opencode/scripts/link-artifact-todo.sh`
- `.opencode/scripts/validate-artifact.sh`

Verify these scripts exist in `.opencode/scripts/` before updating references.

#### Context @-references
References like `@.claude/context/formats/return-metadata-file.md` should become `@.opencode/context/formats/return-metadata-file.md`.

## Decisions

### Decision 1: CLAUDE.md Reference Handling
- **Decision**: Update CLAUDE.md references to AGENTS.md for system/context references
- **Rationale**: AGENTS.md is the current canonical documentation
- **Exception**: Keep historical context references that explain the port

### Decision 2: Duplicate Files Strategy
- **Decision**: Update both locations for now, investigate if one can be removed
- **Rationale**: Avoid breaking the extension system
- **Follow-up**: Create task to consolidate duplicate agent files

### Decision 3: orchestrator.md Tools Format
- **Decision**: Remove the non-standard `tools:` block entirely
- **Rationale**: Doesn't match agent frontmatter standard
- **Alternative**: Convert to comments if tool specification is needed

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Broken script paths | High | Verify all `.opencode/scripts/` files exist before updating references |
| Context loading failures | High | Test @-references after updating paths |
| Extension system breakage | Medium | Update both duplicate locations simultaneously |
| Documentation confusion | Low | Add clear comments about historical references |
| Partial updates leaving inconsistent state | Medium | Complete by phase, verify with grep after each phase |

## Context Extension Recommendations

Based on this research, the following context documentation gaps were identified:

1. **Path Migration Guide**: Create `.opencode/context/guides/path-migration.md` documenting the mapping from `.claude/` to `.opencode/`
   - Include the complete path mapping table from this report
   - Document special cases and exceptions
   - Provide grep commands for verification

2. **Agent Frontmatter Validation Tool**: Consider adding a script to `.opencode/scripts/` that validates agent frontmatter against the standard
   - Could catch issues like the orchestrator.md `tools:` block
   - Similar to existing `validate-artifact.sh` and `validate-wiring.sh`

3. **Duplicate File Policy**: Document in `.opencode/context/architecture/extension-system.md` the relationship between:
   - `.opencode/agent/subagents/`
   - `.opencode/extensions/core/agents/`
   - Clarify which is authoritative and if/when duplicates should exist

## Appendix A: Complete Path Mapping Reference

### Directory Structure Mapping

```
Legacy (.claude/)              Current (.opencode/)
-------------------            --------------------
.claude/CLAUDE.md       →      .opencode/AGENTS.md
.claude/agents/         →      .opencode/agent/subagents/
.claude/skills/         →      .opencode/skills/
.claude/context/        →      .opencode/context/
.claude/commands/       →      .opencode/commands/
.claude/scripts/        →      .opencode/scripts/
.claude/rules/          →      .opencode/rules/
.claude/extensions/     →      .opencode/extensions/
.claude/hooks/          →      .opencode/hooks/
.claude/docs/           →      .opencode/docs/
.claude/memory/         →      .opencode/memory/
.claude/templates/      →      .opencode/templates/
```

### Context File Path Patterns

| Legacy Pattern | New Pattern |
|----------------|-------------|
| `@.claude/context/formats/*.md` | `@.opencode/context/formats/*.md` |
| `@.claude/context/standards/*.md` | `@.opencode/context/standards/*.md` |
| `@.claude/context/patterns/*.md` | `@.opencode/context/patterns/*.md` |
| `@.claude/context/orchestration/*.md` | `@.opencode/context/orchestration/*.md` |
| `@.claude/context/workflows/*.md` | `@.opencode/context/workflows/*.md` |
| `@.claude/CLAUDE.md` | `@.opencode/AGENTS.md` |

### Script References

| Legacy Script | New Script | Verified Exists |
|---------------|------------|-----------------|
| `.claude/scripts/update-task-status.sh` | `.opencode/scripts/update-task-status.sh` | Yes |
| `.claude/scripts/link-artifact-todo.sh` | `.opencode/scripts/link-artifact-todo.sh` | Yes |
| `.claude/scripts/validate-artifact.sh` | `.opencode/scripts/validate-artifact.sh` | Yes |
| `.claude/scripts/memory-retrieve.sh` | `.opencode/scripts/memory-retrieve.sh` | Yes |
| `.claude/scripts/update-recommended-order.sh` | `.opencode/scripts/update-recommended-order.sh` | Yes |
| `.claude/scripts/update-plan-status.sh` | `.opencode/scripts/update-plan-status.sh` | Yes |

## Appendix B: Verification Commands

### Count remaining .claude/ references
```bash
rg -n "\.claude/" --type md .opencode/ | wc -l
```

### Count remaining CLAUDE.md references
```bash
rg -n "CLAUDE\.md" .opencode/ --type md | wc -l
```

### Find files with .claude/ references by directory
```bash
rg -n "\.claude/" --type md .opencode/ | awk -F: '{print $1}' | sort | uniq -c | sort -rn
```

### Verify agent frontmatter consistency
```bash
rg -A5 "^---$" .opencode/agent/subagents/*.md | grep -E "^(name|description|model):"
```

## Appendix C: File Inventory

### Files requiring updates (by priority)

**Priority 1 - Core Agents (8 files)**
- `.opencode/agent/subagents/spawn-agent.md`
- `.opencode/agent/subagents/general-research-agent.md`
- `.opencode/agent/subagents/general-implementation-agent.md`
- `.opencode/agent/subagents/planner-agent.md`
- `.opencode/agent/subagents/meta-builder-agent.md`
- `.opencode/agent/subagents/code-reviewer-agent.md`
- `.opencode/agent/subagents/reviser-agent.md`
- `.opencode/agent/orchestrator.md` (frontmatter fix)

**Priority 2 - Skills (17 files)**
- `.opencode/skills/skill-researcher/SKILL.md`
- `.opencode/skills/skill-planner/SKILL.md`
- `.opencode/skills/skill-implementer/SKILL.md`
- `.opencode/skills/skill-meta/SKILL.md`
- `.opencode/skills/skill-spawn/SKILL.md`
- `.opencode/skills/skill-reviser/SKILL.md`
- `.opencode/skills/skill-orchestrator/SKILL.md`
- `.opencode/skills/skill-todo/SKILL.md`
- `.opencode/skills/skill-fix-it/SKILL.md`
- `.opencode/skills/skill-refresh/SKILL.md`
- `.opencode/skills/skill-git-workflow/SKILL.md`
- `.opencode/skills/skill-status-sync/SKILL.md`
- `.opencode/skills/skill-tag/SKILL.md`
- `.opencode/skills/skill-project-overview/SKILL.md`
- `.opencode/skills/skill-learn/SKILL.md`
- And 2 more...

**Priority 3 - Context Files (30+ files)**
- `.opencode/context/formats/*.md`
- `.opencode/context/standards/*.md`
- `.opencode/context/patterns/*.md`
- `.opencode/context/templates/*.md`
- `.opencode/context/workflows/*.md`

**Priority 4 - Commands (17 files)**
- `.opencode/commands/todo.md`
- `.opencode/commands/task.md`
- `.opencode/commands/meta.md`
- `.opencode/commands/plan.md`
- `.opencode/commands/implement.md`
- `.opencode/commands/research.md`
- `.opencode/commands/revise.md`
- `.opencode/commands/spawn.md`
- `.opencode/commands/refresh.md`
- `.opencode/commands/tag.md`
- `.opencode/commands/merge.md`
- `.opencode/commands/review.md`
- `.opencode/commands/errors.md`
- `.opencode/commands/fix-it.md`
- `.opencode/commands/project-overview.md`

**Priority 5 - Documentation (15+ files)**
- `.opencode/docs/guides/*.md`
- `.opencode/docs/architecture/*.md`
- `.opencode/docs/README.md`
- `.opencode/docs/docs-README.md`

**Priority 6 - Extension Core Duplicates**
- All files in `.opencode/extensions/core/` that mirror main files

---

**Report generated by**: general-research-agent
**Analysis date**: 2026-05-02
**Task**: OC_514
