# Implementation Plan: OC_514 - systematic_opencode_cleanup

- **Task**: 514 - systematic_opencode_cleanup
- **Status**: [COMPLETED]
- **Effort**: 8-10 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_cleanup-audit.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/standards/documentation-standards.md
  - .opencode/context/core/workflows/task-breakdown.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Systematically migrate all remaining `.claude/` path references and `CLAUDE.md` references in the `.opencode/` directory to use the new `.opencode/` paths and `AGENTS.md` naming. This task addresses 2,142 `.claude/` references and 247 `CLAUDE.md` references across approximately 140 unique files. The work is organized into prioritized phases following the critical path identified in the research report.

### Research Integration

This plan integrates findings from `reports/01_cleanup-audit.md` which identified:
- **Priority 1**: Core agents (8 files) and orchestrator frontmatter fix
- **Priority 2**: Skills (17 files) and commands (17 files)
- **Priority 3**: Context files (30+ files) and standards
- **Priority 4**: Documentation (15+ files) and extension duplicates
- **Key risk**: Duplicate files exist between `agent/subagents/` and `extensions/core/agents/`

## Goals & Non-Goals

**Goals**:
- Replace all `.claude/` path references with `.opencode/` equivalents
- Replace context references `@.claude/CLAUDE.md` with `@.opencode/AGENTS.md`
- Fix non-standard frontmatter in `agent/orchestrator.md`
- Update all 17 skill files with correct script and context paths
- Update all command definitions with correct references
- Ensure extension core duplicates are consistent

**Non-Goals**:
- Do not modify references within `.claude/` directory itself
- Do not change historical context references (e.g., port notes in AGENTS.md line 5)
- Do not modify external references like `~/.claude/` (user home directory)
- Do not consolidate duplicate files (separate task recommended)
- Do not modify files outside `.opencode/` directory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken script paths after update | High | Medium | Verify all scripts exist in `.opencode/scripts/` before updating references |
| Context loading failures | High | Low | Test @-references after each phase; use grep verification |
| Extension system breakage | Medium | Medium | Update both duplicate locations simultaneously |
| Partial updates leaving inconsistent state | Medium | Medium | Complete by phase, verify with ripgrep after each phase |
| Missing files referenced in documentation | Low | Low | Pre-flight file existence check before editing |
| Accidental modification of historical context | Low | Low | Review each CLAUDE.md reference for context before changing |

## Implementation Phases

### Phase 1: Fix orchestrator.md Frontmatter [COMPLETED]

**Goal**: Correct the non-standard frontmatter in the orchestrator agent definition

**Tasks**:
- [ ] Read `.opencode/agent/orchestrator.md` to verify current state
- [ ] Remove non-standard `tools:` block from frontmatter
- [ ] Keep standard fields: `name`, `description`, `model`
- [ ] Verify frontmatter matches agent-frontmatter-standard.md

**Timing**: 15-30 minutes

**Files to modify**:
- `.opencode/agent/orchestrator.md` - Remove tools block, keep standard fields

**Verification**:
- Frontmatter contains only: `name`, `description`, `model` (no `tools:` block)
- File passes frontmatter validation

---

### Phase 2: Update Core Agent Files [COMPLETED]

**Goal**: Fix `.claude/` and `CLAUDE.md` references in all core agent definitions

**Tasks**:
- [ ] Update `.opencode/agent/subagents/spawn-agent.md`
- [ ] Update `.opencode/agent/subagents/general-research-agent.md`
- [ ] Update `.opencode/agent/subagents/general-implementation-agent.md`
- [ ] Update `.opencode/agent/subagents/planner-agent.md`
- [ ] Update `.opencode/agent/subagents/meta-builder-agent.md`
- [ ] Update `.opencode/agent/subagents/code-reviewer-agent.md`
- [ ] Update `.opencode/agent/subagents/reviser-agent.md`

**Timing**: 1.5-2 hours

**Files to modify**:
- `.opencode/agent/subagents/*.md` (7 files) - Update all `.claude/` paths to `.opencode/`
- Update context references like `@.claude/context/...` to `@.opencode/context/...`
- Update CLAUDE.md references to AGENTS.md where appropriate

**Verification**:
```bash
# Verify no .claude/ references remain in agent files
rg "\.claude/" .opencode/agent/subagents/ --type md | wc -l
# Expected: 0
```

---

### Phase 3: Update Skill Files [COMPLETED]

**Goal**: Fix script paths and context references in all skill definitions

**Tasks**:
- [ ] Update `.opencode/skills/skill-researcher/SKILL.md`
- [ ] Update `.opencode/skills/skill-planner/SKILL.md`
- [ ] Update `.opencode/skills/skill-implementer/SKILL.md`
- [ ] Update `.opencode/skills/skill-meta/SKILL.md`
- [ ] Update `.opencode/skills/skill-spawn/SKILL.md`
- [ ] Update `.opencode/skills/skill-reviser/SKILL.md`
- [ ] Update `.opencode/skills/skill-orchestrator/SKILL.md`
- [ ] Update `.opencode/skills/skill-todo/SKILL.md`
- [ ] Update `.opencode/skills/skill-fix-it/SKILL.md`
- [ ] Update `.opencode/skills/skill-refresh/SKILL.md`
- [ ] Update `.opencode/skills/skill-git-workflow/SKILL.md`
- [ ] Update `.opencode/skills/skill-status-sync/SKILL.md`
- [ ] Update `.opencode/skills/skill-tag/SKILL.md`
- [ ] Update `.opencode/skills/skill-project-overview/SKILL.md`
- [ ] Update `.opencode/skills/skill-learn/SKILL.md`
- [ ] Update remaining 2 skill files

**Timing**: 2-2.5 hours

**Files to modify**:
- `.opencode/skills/*/SKILL.md` (17 files) - Update script references
- Change `.claude/scripts/` to `.opencode/scripts/`
- Update context file references to use `.opencode/context/`

**Verification**:
```bash
# Verify no .claude/ references remain in skills
rg "\.claude/" .opencode/skills/ --type md | wc -l
# Expected: 0
```

---

### Phase 4: Update Commands [COMPLETED]

**Goal**: Fix references in all command definitions

**Tasks**:
- [ ] Update `.opencode/commands/todo.md` (24 CLAUDE.md references - highest count)
- [ ] Update `.opencode/commands/task.md`
- [ ] Update `.opencode/commands/meta.md`
- [ ] Update `.opencode/commands/plan.md`
- [ ] Update `.opencode/commands/implement.md`
- [ ] Update `.opencode/commands/research.md`
- [ ] Update `.opencode/commands/revise.md`
- [ ] Update `.opencode/commands/spawn.md`
- [ ] Update `.opencode/commands/refresh.md`
- [ ] Update `.opencode/commands/tag.md`
- [ ] Update `.opencode/commands/merge.md`
- [ ] Update `.opencode/commands/review.md`
- [ ] Update `.opencode/commands/errors.md`
- [ ] Update `.opencode/commands/fix-it.md`
- [ ] Update `.opencode/commands/project-overview.md`

**Timing**: 1.5-2 hours

**Files to modify**:
- `.opencode/commands/*.md` (15 files) - Update context references
- Focus on `@.claude/context/` patterns

**Verification**:
```bash
# Verify command files
rg "\.claude/" .opencode/commands/ --type md | wc -l
# Expected: 0
```

---

### Phase 5: Update Context Files [COMPLETED]

**Goal**: Fix references in context formats, standards, patterns, and templates

**Tasks**:
- [ ] Update `.opencode/context/formats/*.md` files
- [ ] Update `.opencode/context/standards/*.md` files
- [ ] Update `.opencode/context/patterns/*.md` files
- [ ] Update `.opencode/context/templates/*.md` files
- [ ] Update `.opencode/context/workflows/*.md` files
- [ ] Update `.opencode/context/orchestration/*.md` files
- [ ] Update `.opencode/context/guides/*.md` files

**Timing**: 1.5-2 hours

**Files to modify**:
- All files under `.opencode/context/` directory
- These are high-reuse templates (468+ references total)

**Verification**:
```bash
# Verify context files
rg "\.claude/" .opencode/context/ --type md | wc -l
# Expected: 0
```

---

### Phase 6: Update Documentation [COMPLETED]

**Goal**: Fix references in guides, architecture docs, and main AGENTS.md

**Tasks**:
- [ ] Update `.opencode/docs/guides/creating-extensions.md` (36 references)
- [ ] Update `.opencode/docs/guides/context-loading-best-practices.md` (38 references)
- [ ] Update `.opencode/docs/guides/adding-domains.md`
- [ ] Update `.opencode/docs/architecture/extension-system.md` (29 references)
- [ ] Update `.opencode/docs/README.md`
- [ ] Update `.opencode/docs/docs-README.md`
- [ ] Update `.opencode/AGENTS.md` (preserve historical context on line 5)

**Timing**: 1-1.5 hours

**Files to modify**:
- `.opencode/docs/guides/*.md`
- `.opencode/docs/architecture/*.md`
- `.opencode/AGENTS.md` (careful with line 5 historical note)

**Special Consideration**:
- AGENTS.md line 5 contains historical context: `> **Port of CLAUDE.md**: This documentation was ported from `.claude/CLAUDE.md` on 2026-05-02...`
- This line should be preserved as historical documentation

**Verification**:
```bash
# Verify docs files (excluding historical references)
rg "\.claude/" .opencode/docs/ --type md | wc -l
# Expected: 0
```

---

### Phase 7: Handle Extension Core Duplicates [COMPLETED]

**Goal**: Update duplicate files in extensions/core/ to match main files

**Tasks**:
- [ ] Verify duplicates match main files (diff check)
- [ ] Update `.opencode/extensions/core/agents/*.md` (7 files)
- [ ] Update `.opencode/extensions/core/docs/guides/*.md`
- [ ] Update `.opencode/extensions/core/docs/architecture/*.md`
- [ ] Update any other files with `.claude/` references in extensions/core/

**Timing**: 1-1.5 hours

**Files to modify**:
- `.opencode/extensions/core/agents/*.md` (7 files)
- `.opencode/extensions/core/docs/guides/*.md`
- `.opencode/extensions/core/docs/architecture/*.md`

**Note**: These are duplicates of main files. Both locations must be updated to maintain consistency until a separate consolidation task is completed.

**Verification**:
```bash
# Verify extension core files
rg "\.claude/" .opencode/extensions/core/ --type md | wc -l
# Expected: 0
```

---

### Phase 8: Final Verification and Validation [COMPLETED]

**Goal**: Comprehensive verification that all references are updated

**Tasks**:
- [ ] Run final count of remaining `.claude/` references
- [ ] Run final count of remaining `CLAUDE.md` references
- [ ] Verify no references remain except historical context
- [ ] Check for any missed files
- [ ] Verify file integrity (no corruption from edits)
- [ ] Create summary report of changes

**Timing**: 30-45 minutes

**Verification Commands**:
```bash
# Count remaining .claude/ references
echo ".claude/ references remaining:"
rg -n "\.claude/" --type md .opencode/ | wc -l

# Count remaining CLAUDE.md references
echo "CLAUDE.md references remaining:"
rg -n "CLAUDE\.md" .opencode/ --type md | wc -l

# Find any files still with references
echo "Files with remaining .claude/ references:"
rg -l "\.claude/" --type md .opencode/
```

**Expected Results**:
- `.claude/` references: 0 (or only historical context if explicitly preserved)
- `CLAUDE.md` references: 0 (or only historical context)
- All files should be clean except documented exceptions

---

## Testing & Validation

- [ ] Each phase includes ripgrep verification command
- [ ] Final verification runs comprehensive count across entire .opencode/ directory
- [ ] Historical context references (AGENTS.md line 5) are preserved and documented
- [ ] No files are corrupted during editing (line counts preserved, valid markdown)
- [ ] Extension system loads without errors (test via `<leader>ao` if applicable)

## Artifacts & Outputs

- Updated files across 8 categories:
  - 8 agent files (orchestrator + 7 subagents)
  - 17 skill files
  - 15 command files
  - 30+ context files
  - 15+ documentation files
  - Extension core duplicates (7+ agents, guides, architecture)
- `specs/OC_514_systematic_opencode_cleanup/summaries/implementation-summary-{YYYYMMDD}.md` (created at completion)

## Rollback/Contingency

**If issues discovered during implementation**:
1. Stop at current phase, do not proceed to next
2. Document issue in task notes
3. Use git to revert specific phase commits if needed
4. Re-run verification to confirm clean state

**If verification shows missed references**:
1. Identify pattern of missed references
2. Create targeted fix for that pattern
3. Re-run full verification

**If duplicate files cause confusion**:
1. Document which location is authoritative (recommend: `agent/subagents/`)
2. Create follow-up task for duplicate consolidation
3. Ensure both locations stay synchronized during this cleanup

## Path Mapping Reference

| Legacy Pattern | New Pattern | Notes |
|----------------|-------------|-------|
| `.claude/CLAUDE.md` | `.opencode/AGENTS.md` | Main documentation |
| `.claude/agents/` | `.opencode/agent/subagents/` | Agent definitions |
| `.claude/skills/` | `.opencode/skills/` | Skill definitions |
| `.claude/context/` | `.opencode/context/` | Context files |
| `.claude/commands/` | `.opencode/commands/` | Command definitions |
| `.claude/scripts/` | `.opencode/scripts/` | Utility scripts |
| `.claude/rules/` | `.opencode/rules/` | Rule files |
| `.claude/extensions/` | `.opencode/extensions/` | Extensions |
| `.claude/docs/` | `.opencode/docs/` | Documentation |

## Special Cases (Do Not Modify)

| Pattern | Location | Reason |
|---------|----------|--------|
| `~/.claude/` | Any | User home directory settings |
| `Port of CLAUDE.md` | AGENTS.md line 5 | Historical context |
| Migration guide references | docs/ | Document the transition |
