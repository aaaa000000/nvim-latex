# Research Report: Task #509

**Task**: OC_509 - port_missing_core_rules
**Started**: 2026-05-02T00:00:00Z
**Completed**: 2026-05-02T00:00:00Z
**Effort**: 30 minutes
**Dependencies**: None
**Sources/Inputs**: - .claude/rules/*, .opencode/rules/*, .claude/context/formats/plan-format.md, .claude/context/repo/project-overview.md
**Artifacts**: - specs/OC_509_port_missing_core_rules/reports/01_missing-rules-analysis.md (this report)
**Standards**: report-format.md

## Executive Summary

- Found **9 Claude rules** and **6 OpenCode rules** (excluding README)
- **2 core rules** identified for porting: `plan-format-enforcement.md`, `project-overview-detection.md`
- **5 core rules** already have OpenCode equivalents (verified)
- **2 extension rules** exist in Claude but are domain-specific (neovim-lua, nix)
- Rule format uses YAML frontmatter with `paths:` pattern for auto-application

## Context & Scope

### Research Questions Addressed
1. What rules exist in `.claude/rules/` vs `.opencode/rules/`?
2. Which Claude rules are missing from OpenCode?
3. What is the format and structure of these rules?
4. What are the specific content requirements for the 2 target rules?

### Rule System Overview

Rules are auto-applied Markdown files with YAML frontmatter specifying path patterns. They contain:
- Path patterns (which files trigger the rule)
- Guidelines and constraints
- Code examples and patterns
- Do/Do-not lists

## Findings

### Claude Rules Inventory (9 files)

| Rule | Type | OpenCode Equivalent | Status |
|------|------|---------------------|--------|
| state-management.md | Core | state-management.md | ✅ Exists |
| git-workflow.md | Core | git-workflow.md | ✅ Exists |
| artifact-formats.md | Core | artifact-formats.md | ✅ Exists |
| workflows.md | Core | workflows.md | ✅ Exists |
| error-handling.md | Core | error-handling.md | ✅ Exists |
| plan-format-enforcement.md | Core | **NONE** | ❌ **TO PORT** |
| project-overview-detection.md | Core | **NONE** | ❌ **TO PORT** |
| neovim-lua.md | Extension | None | Extension-specific |
| nix.md | Extension | None | Extension-specific |

### OpenCode Rules Inventory (6 files)

| Rule | Description | Paths |
|------|-------------|-------|
| state-management.md | Task state patterns | `specs/**/*` |
| git-workflow.md | Git commit conventions | Global (no paths) |
| artifact-formats.md | Artifact format conventions | `specs/**/*` |
| workflows.md | Command lifecycle | `.opencode/**/*` |
| error-handling.md | Error recovery patterns | `.opencode/**/*` |
| README.md | Rules index | N/A |

### Gap Analysis

**Core Rules Missing (2):**

1. **plan-format-enforcement.md**
   - Claude path: `specs/**/plans/**`
   - Purpose: Enforces plan artifact format standards
   - References: `.claude/context/formats/plan-format.md`
   - Key requirements:
     - Required metadata fields (Task, Status, Effort, Dependencies, Research Inputs, Artifacts, Standards, Type)
     - Required sections (Overview, Goals & Non-Goals, Risks & Mitigations, Implementation Phases, Testing & Validation, Artifacts & Outputs, Rollback/Contingency)
     - Phase heading format: `### Phase N: {name} [STATUS]`
     - Valid markers: `[NOT STARTED]`, `[IN PROGRESS]`, `[COMPLETED]`, `[PARTIAL]`, `[BLOCKED]`
     - No emojis allowed

2. **project-overview-detection.md**
   - Claude path: `.claude/context/repo/project-overview.md`
   - Purpose: Detects generic template placeholder and prompts user
   - Key requirements:
     - Check if file begins with `<!-- GENERIC TEMPLATE`
     - If found: notify user, suggest `/project-overview` command or task
     - Reference `.claude/context/repo/update-project.md`
     - Do NOT silently proceed with generic content

### Rule Format Comparison

Both systems use similar structure:
```yaml
---
paths: pattern/**/*  # or ["pattern1", "pattern2"]
---

# Rule Title

## Section

Content...
```

**Key differences:**
- Claude: `specs/**/plans/**` for plans
- OpenCode: `specs/OC_{NNN}_{SLUG}/plans/` naming convention
- OpenCode uses `OC_` prefix for task numbers

### Plan Format Requirements

From `.claude/context/formats/plan-format.md`:

**Required Metadata (Markdown block, not YAML):**
- Task: {id} - {title}
- Status: [NOT STARTED]
- Effort: {estimate}
- Dependencies: {list}
- Research Inputs: {list}
- Artifacts: {paths}
- Standards: {referenced rules}
- Type: markdown

**Required Sections:**
1. Overview (2-4 sentences)
2. Goals & Non-Goals (bullets)
3. Risks & Mitigations (bullets)
4. Implementation Phases (with Dependency Analysis table)
5. Testing & Validation (bullets)
6. Artifacts & Outputs (enumerate)
7. Rollback/Contingency (brief plan)

**Phase Format:**
```markdown
### Phase N: {name} [STATUS]
- **Goal:** short statement
- **Tasks:** bullet checklist
- **Timing:** expected duration
- **Depends on:** phase numbers
- **Started/Completed:** ISO8601 timestamps
```

### Project Overview Detection Requirements

The rule detects the generic template marker in project-overview.md:

**Marker to detect:**
```markdown
<!-- GENERIC TEMPLATE
```

**If found:**
1. Notify user that project-overview.md contains placeholder
2. Suggest running `/project-overview` command
3. Fallback: `/task "Generate project-overview.md for this repository"`
4. Reference `.claude/context/repo/update-project.md`

**If not found:**
- No action needed (file is customized)

## Recommendations

### For plan-format-enforcement.md

1. Copy structure from `.claude/rules/plan-format-enforcement.md`
2. Update references from `.claude/` to `.opencode/`
3. Use OpenCode naming conventions:
   - Task IDs: `OC_{N}` (unpadded)
   - Directory names: `OC_{NNN}` (3-digit padded)
   - Artifact names: `MM_{short-slug}.md` format

### For project-overview-detection.md

1. Copy structure from `.claude/rules/project-overview-detection.md`
2. Update paths from `.claude/context/repo/` to `.opencode/context/repo/`
3. Verify the generic template marker hasn't changed

### Verification Checklist

After porting, verify:
- [ ] Both files exist in `.opencode/rules/`
- [ ] YAML frontmatter has correct paths
- [ ] All references point to `.opencode/` not `.claude/`
- [ ] OpenCode naming conventions used (OC_ prefix)
- [ ] Content is otherwise identical to Claude versions

## Decisions

1. **Extension Rules Excluded**: neovim-lua.md and nix.md are extension-specific and not part of the core rule porting task.
2. **5 Core Rules Verified**: state-management, git-workflow, artifact-formats, workflows, error-handling already exist in OpenCode.
3. **Format Consistency**: Rules use consistent YAML frontmatter + Markdown structure across both systems.
4. **Path Differences**: OpenCode uses `OC_` prefix for task numbers; paths should reflect this.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Path pattern mismatch | Medium | Test rules by creating test plans after porting |
| Reference to non-existent files | Low | Update all `.claude/` references to `.opencode/` |
| Missing OpenCode naming conventions | Medium | Use `OC_` prefix in examples and paths |
| Rule not being applied | Low | Verify paths match OpenCode file structure |

## Context Extension Recommendations

- **Topic**: Rule porting documentation
- **Gap**: No documentation exists for how to port rules between Claude and OpenCode
- **Recommendation**: Create `.opencode/context/core/patterns/rule-porting.md` with:
  - Rule format specification
  - Reference mapping between `.claude/` and `.opencode/`
  - Naming convention differences
  - Verification checklist

## Appendix

### Search Queries Used

1. `glob **/.claude/rules/*` - Found 9 Claude rules
2. `glob **/.opencode/rules/*` - Found 6 OpenCode rules
3. `read .claude/rules/plan-format-enforcement.md` - Analyzed content
4. `read .claude/rules/project-overview-detection.md` - Analyzed content
5. `read .opencode/rules/*.md` - Compared existing OpenCode rules
6. `read .claude/context/formats/plan-format.md` - Reviewed plan format standard
7. `read .claude/context/repo/project-overview.md` - Checked generic template

### File References

**Source Files (Claude):**
- `.claude/rules/plan-format-enforcement.md`
- `.claude/rules/project-overview-detection.md`
- `.claude/rules/state-management.md`
- `.claude/rules/git-workflow.md`
- `.claude/rules/artifact-formats.md`
- `.claude/rules/workflows.md`
- `.claude/rules/error-handling.md`
- `.claude/rules/neovim-lua.md` (extension)
- `.claude/rules/nix.md` (extension)

**Existing OpenCode Rules:**
- `.opencode/rules/state-management.md`
- `.opencode/rules/git-workflow.md`
- `.opencode/rules/artifact-formats.md`
- `.opencode/rules/workflows.md`
- `.opencode/rules/error-handling.md`

**Target Files to Create:**
- `.opencode/rules/plan-format-enforcement.md`
- `.opencode/rules/project-overview-detection.md`

### Summary Statistics

| Metric | Count |
|--------|-------|
| Claude rules total | 9 |
| OpenCode rules total | 6 |
| Core rules verified | 5 |
| Core rules to port | 2 |
| Extension rules (skip) | 2 |
