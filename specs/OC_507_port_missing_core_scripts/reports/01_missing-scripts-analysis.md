# Research Report: Task #507 - Port Missing Core Scripts

**Task**: 507 - port_missing_core_scripts  
**Started**: 2026-05-02T00:00:00Z  
**Completed**: 2026-05-02T00:30:00Z  
**Effort**: 4 hours  
**Dependencies**: None  
**Sources/Inputs**: 
- 14 source scripts from `.claude/scripts/`
- 16 existing scripts in `.opencode/scripts/`
- Directory structure comparison between `.claude/` and `.opencode/`

**Artifacts**: 
- This research report

**Standards**: report-format.md

---

## Executive Summary

This research analyzed 14 utility scripts from `.claude/scripts/` that need to be ported to `.opencode/scripts/`. The scripts fall into four categories: extension management (3), task management (5), validation (5), and documentation (1). Most scripts require path adaptations from `.claude/` to `.opencode/` structure, with several having interdependencies that must be maintained during porting.

### Key Findings:

1. **14 scripts require porting**: check-extension-docs.sh, export-to-markdown.sh, install-extension.sh, uninstall-extension.sh, link-artifact-todo.sh, memory-retrieve.sh, migrate-directory-padding.sh, update-recommended-order.sh, validate-artifact.sh, validate-context-index.sh, validate-extension-index.sh, validate-index.sh, validate-wiring.sh, lint/lint-postflight-boundary.sh

2. **Major structural differences** between `.claude/` and `.opencode/`:
   - Agents: `.claude/agents/` → `.opencode/agent/subagents/`
   - Context: `.claude/context/` → `.opencode/context/core/` (core files)
   - Skills location remains the same (`.opencode/skills/`)

3. **Five scripts have dependencies** on other scripts being ported:
   - install-extension.sh depends on validate-index.sh
   - update-task-status.sh depends on update-plan-status.sh
   - Several validation scripts work as a suite

4. **Three scripts may be .claude-specific** and require evaluation for OpenCode relevance:
   - export-to-markdown.sh (exports .claude/ directory specifically)
   - validate-wiring.sh (validates both systems, may need adaptation)
   - memory-retrieve.sh (depends on .memory/ which may not exist in .opencode/)

---

## Context & Scope

### Task Description
Port missing utility scripts from `.claude/scripts/` to `.opencode/scripts/`. The target system (OpenCode) is an alternative agent orchestration framework that shares concepts with Claude Code but has different directory structures and conventions.

### Scope Boundaries
- **In Scope**: Analyzing all 14 missing scripts, identifying path adaptations, documenting dependencies
- **Out of Scope**: Actually porting the scripts (that's the implementation phase)

### Research Questions
1. What are the structural differences between `.claude/` and `.opencode/` directories?
2. Which scripts have interdependencies?
3. What path adaptations are required for each script?
4. Are there any scripts that are Claude-specific and shouldn't be ported?

---

## Findings

### 1. Source Script Analysis

#### Category A: Extension Management (3 scripts)

**1. check-extension-docs.sh** (209 lines)
- **Purpose**: Doc-lint script for extension validation
- **Key Functionality**: 
  - Validates manifest.json structure
  - Checks for required files (README.md, EXTENSION.md, manifest.json)
  - Verifies manifest entries match disk files
  - Checks routing block for skills
- **Path References**:
  - `.claude/extensions` → needs adaptation
  - Uses `jq` for JSON processing
- **Porting Complexity**: Medium - needs path changes

**2. install-extension.sh** (297 lines)
- **Purpose**: Install Claude Code extensions
- **Key Functionality**:
  - Creates symlinks for commands, skills, agents
  - Merges index-entries.json into main index.json
  - Validates after installation
- **Path References**:
  - `.claude/` paths throughout
  - Calls `validate-index.sh` (dependency)
- **Porting Complexity**: Medium - path changes + dependency

**3. uninstall-extension.sh** (235 lines)
- **Purpose**: Uninstall Claude Code extensions
- **Key Functionality**:
  - Removes symlinks for commands, skills, agents
  - Removes index entries from index.json
- **Path References**:
  - `.claude/` paths throughout
- **Porting Complexity**: Medium - path changes

#### Category B: Task Management (5 scripts)

**4. link-artifact-todo.sh** (250 lines)
- **Purpose**: Automate TODO.md artifact linking
- **Key Functionality**:
  - Implements 4-case artifact linking logic
  - Handles research, plan, and summary field linking
  - Supports --dry-run mode
- **Path References**:
  - `specs/TODO.md` (shared location)
  - Generic paths, minimal changes needed
- **Porting Complexity**: Low - mostly generic

**5. memory-retrieve.sh** (168 lines)
- **Purpose**: Two-phase auto-retrieval for memory system
- **Key Functionality**:
  - Scores memory-index.json entries by keyword overlap
  - Formats memories as `<memory-context>` block
  - Updates retrieval metadata
- **Path References**:
  - `.memory/memory-index.json` 
  - May be Claude-specific feature
- **Porting Complexity**: High - evaluate if OpenCode has memory system

**6. migrate-directory-padding.sh** (197 lines)
- **Purpose**: Migrate unpadded task directories to 3-digit padded format
- **Key Functionality**:
  - Renames directories like `1_slug` → `001_slug`
  - Supports --dry-run mode
- **Path References**:
  - `specs/` directory (shared)
- **Porting Complexity**: Low - generic utility

**7. update-recommended-order.sh** (706 lines)
- **Purpose**: Manage Recommended Order section in TODO.md
- **Key Functionality**:
  - Topological sorting using Kahn's algorithm
  - add/remove/refresh operations
  - Generates action hints from task status
- **Path References**:
  - `specs/TODO.md`
  - `specs/state.json`
- **Porting Complexity**: Low - generic

**8. update-task-status.sh** (335 lines)
- **Purpose**: Centralized task status update script
- **Key Functionality**:
  - Updates state.json atomically
  - Updates TODO.md task entries
  - Updates TODO.md Task Order section
  - Calls update-plan-status.sh for plan files (dependency)
- **Path References**:
  - `specs/state.json`
  - `specs/TODO.md`
  - Calls `./update-plan-status.sh`
- **Porting Complexity**: Medium - dependency on update-plan-status.sh

**9. update-plan-status.sh** (67 lines)
- **Purpose**: Centralized plan-level status update
- **Key Functionality**:
  - Updates plan file status
  - Finds latest plan file in task directory
- **Path References**:
  - `specs/{NNN}_{project}/plans/`
- **Porting Complexity**: Low - generic

#### Category C: Validation Scripts (5 scripts)

**10. validate-artifact.sh** (164 lines)
- **Purpose**: Validate artifact files against format standards
- **Key Functionality**:
  - Validates report, plan, summary artifacts
  - Checks required metadata fields and sections
  - Auto-fix mode for missing fields
- **Path References**:
  - Generic file operations
- **Porting Complexity**: Low - mostly generic

**11. validate-context-index.sh** (154 lines)
- **Purpose**: Validate `.claude/context/index.json`
- **Key Functionality**:
  - Validates JSON syntax
  - Checks file paths exist
  - Validates line counts (10% tolerance)
  - Checks domain values
- **Path References**:
  - `.claude/context/index.json`
  - `.claude/context/` (for path resolution)
- **Porting Complexity**: Medium - path changes

**12. validate-extension-index.sh** (170 lines)
- **Purpose**: Validate extension index-entries.json files
- **Key Functionality**:
  - Validates both `.claude` and `.opencode` extensions
  - Checks path prefixes (no `.claude/` or `.opencode/`)
  - Detects cross-system references
- **Path References**:
  - Both `.claude/extensions/` and `.opencode/extensions/`
- **Porting Complexity**: Low - already handles both systems

**13. validate-index.sh** (138 lines)
- **Purpose**: Validate context index entries
- **Key Functionality**:
  - Checks orphaned entries
  - Checks missing files
  - Checks duplicate paths
  - Budget estimates per agent/task_type
- **Path References**:
  - `.claude/context/index.json` (default)
  - `.claude/context/` directory
- **Porting Complexity**: Medium - needs path parameterization

**14. validate-wiring.sh** (306 lines)
- **Purpose**: Validate agent systems wiring integrity
- **Key Functionality**:
  - Validates skill → agent wiring
  - Validates agent file existence
  - Validates index.json entries
  - Supports `--claude`, `--opencode`, `--all` flags
- **Path References**:
  - Both `.claude/` and `.opencode/` structures
  - Uses `agents/` for .claude, `agent/subagents/` for .opencode
- **Porting Complexity**: Low - already handles both systems

#### Category D: Lint Scripts (1 script)

**15. lint/lint-postflight-boundary.sh** (170 lines)
- **Purpose**: Detect postflight boundary violations in skills
- **Key Functionality**:
  - Checks for prohibited patterns in postflight sections
  - Detects build commands, MCP tools, grep on source files
- **Path References**:
  - `.claude/skills/`
  - `.claude/extensions/`
- **Porting Complexity**: Medium - needs to check both systems

---

### 2. Target Structure Analysis

The existing `.opencode/scripts/` directory contains 16 scripts:

**Already Ported/Matching Scripts:**
- verify-lean-mcp.sh ✓
- setup-lean-mcp.sh ✓
- merge-extensions.sh (OpenCode-specific)
- postflight-implement.sh ✓
- postflight-plan.sh ✓
- postflight-research.sh ✓
- validate-docs.sh (different from validate-artifact.sh)
- test-command.sh
- test-execution-system.sh
- opencode-project-cleanup.sh (equivalent to claude-project-cleanup.sh)
- test-execution.sh
- execute-command.sh
- opencode-refresh.sh (equivalent to claude-refresh.sh)
- opencode-cleanup.sh (equivalent to claude-cleanup.sh)
- install-aliases.sh ✓
- install-systemd-timer.sh ✓

**Key Differences from .claude/scripts/:**
- No `lint/` subdirectory exists yet
- Some cleanup scripts have been renamed (claude-* → opencode-*)

---

### 3. Path Adaptations Required

#### Directory Structure Mapping

| .claude/ Path | .opencode/ Path | Notes |
|---------------|-----------------|-------|
| `.claude/agents/` | `.opencode/agent/subagents/` | Different nesting |
| `.claude/skills/` | `.opencode/skills/` | Same location |
| `.claude/context/` | `.opencode/context/core/` | Core files under `core/` |
| `.claude/commands/` | `.opencode/commands/` | Same location |
| `.claude/rules/` | `.opencode/rules/` | Same location |
| `.claude/extensions/` | `.opencode/extensions/` | Same location |
| `.claude/scripts/` | `.opencode/scripts/` | Same location |
| `specs/` | `specs/` | Shared location |
| `.memory/` | ??? | Verify if exists |

#### Script-Specific Path Changes

| Script | Path Changes Required |
|--------|----------------------|
| check-extension-docs.sh | `.claude/extensions` → `.opencode/extensions` |
| export-to-markdown.sh | `.claude/` → `.opencode/`, output path review |
| install-extension.sh | Multiple `.claude/` → `.opencode/` references |
| uninstall-extension.sh | Multiple `.claude/` → `.opencode/` references |
| link-artifact-todo.sh | None (uses shared specs/) |
| memory-retrieve.sh | Verify `.memory/` exists in .opencode/ |
| migrate-directory-padding.sh | None (uses shared specs/) |
| update-recommended-order.sh | None (uses shared specs/) |
| update-task-status.sh | Path to update-plan-status.sh |
| update-plan-status.sh | None (uses shared specs/) |
| validate-artifact.sh | None (generic file operations) |
| validate-context-index.sh | `.claude/context/` → `.opencode/context/` |
| validate-extension-index.sh | Already handles both systems |
| validate-index.sh | Parameterize or default to .opencode/ |
| validate-wiring.sh | Already handles both systems |
| lint-postflight-boundary.sh | Add `.opencode/skills/` and `.opencode/extensions/` |

---

### 4. Dependency Chain Analysis

#### Direct Dependencies

```
install-extension.sh
  └── depends on: validate-index.sh

update-task-status.sh
  └── depends on: update-plan-status.sh

validate-wiring.sh
  └── depends on: index.json structure (implicit)

validate-context-index.sh
  └── no script dependencies

validate-extension-index.sh
  └── no script dependencies

validate-index.sh
  └── no script dependencies
```

#### Port Order Recommendation

Based on dependencies, port in this order:

**Phase 1 - Independent Scripts (No Dependencies):**
1. validate-artifact.sh
2. validate-index.sh
3. validate-context-index.sh
4. validate-extension-index.sh
5. validate-wiring.sh (already handles both)
6. migrate-directory-padding.sh
7. update-plan-status.sh
8. link-artifact-todo.sh
9. update-recommended-order.sh
10. export-to-markdown.sh (evaluate first)
11. memory-retrieve.sh (evaluate first)

**Phase 2 - Scripts With Dependencies:**
12. update-task-status.sh (depends on update-plan-status.sh)
13. install-extension.sh (depends on validate-index.sh)
14. uninstall-extension.sh

**Phase 3 - Lint Scripts:**
15. lint/lint-postflight-boundary.sh (requires lint/ directory creation)

**Phase 4 - Extension Management (Requires Full Evaluation):**
16. check-extension-docs.sh (may need extension structure review)

---

### 5. Scripts Requiring Special Evaluation

#### A. export-to-markdown.sh
**Status**: ⚠️ Evaluate before porting

This script exports the entire `.claude/` directory to a consolidated markdown file. For OpenCode:
- Should it export `.opencode/` instead?
- Should it support both systems with a flag?
- Current output: `docs/claude-directory-export.md`

**Recommendation**: Create `.opencode/` version or add system parameter

#### B. memory-retrieve.sh
**Status**: ⚠️ Evaluate before porting

This script retrieves from `.memory/memory-index.json`. Questions:
- Does OpenCode have a memory system?
- Is `.memory/` shared between systems or separate?
- If OpenCode doesn't use memories, this script may not be needed

**Recommendation**: Verify OpenCode memory system architecture first

#### C. validate-wiring.sh
**Status**: ✅ Already supports both systems

This script already validates both `.claude/` and `.opencode/` with flags:
- `--claude`: Validate .claude only
- `--opencode`: Validate .opencode only  
- `--all`: Validate both (default)

**Recommendation**: Port as-is, minimal changes needed

#### D. validate-extension-index.sh
**Status**: ✅ Already supports both systems

This script validates extensions in both directories:
- Checks `.claude/extensions/*/index-entries.json`
- Checks `.opencode/extensions/*/index-entries.json`
- Detects cross-system references

**Recommendation**: Port as-is, minimal changes needed

---

## Decisions

### Decision 1: Path Adaptation Strategy
**Decision**: Replace hardcoded `.claude/` paths with `.opencode/` equivalents, except where scripts already support both systems.

**Rationale**: Most scripts are utility functions that should operate on the system they're installed in. Scripts that need to work across both systems (like validate-wiring.sh) already have this capability.

### Decision 2: Script Ordering for Port
**Decision**: Port in dependency order: independent scripts first, then dependent scripts.

**Rationale**: Ensures dependencies are available when needed. The update-task-status.sh requires update-plan-status.sh to be present.

### Decision 3: Extension Management Scripts
**Decision**: Evaluate extension structure compatibility before porting install-extension.sh and uninstall-extension.sh.

**Rationale**: OpenCode may have different extension installation patterns. The scripts assume a specific symlink-based approach that may differ.

### Decision 4: Memory System
**Decision**: Verify OpenCode memory system before porting memory-retrieve.sh.

**Rationale**: If OpenCode doesn't use the memory vault system, this script would be unnecessary.

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path changes break script functionality | High | Medium | Thorough testing after port; use sed to verify all replacements |
| Missing dependencies in target system | Medium | Medium | Port in dependency order; validate-index.sh first |
| Scripts assume .claude-specific features | Medium | Low | Evaluate each script before port; test with --dry-run where available |
| Extension structure differences | High | Medium | Compare .claude/extensions/ vs .opencode/extensions/ structure first |
| Lint script may flag different patterns | Low | Medium | Update lint rules for OpenCode patterns if needed |
| Shared specs/ state corruption | High | Low | Scripts use atomic operations; test with --dry-run first |

---

## Context Extension Recommendations

No context gaps identified - this is a straightforward porting task.

---

## Appendix A: Complete Script Inventory

### Source Scripts (.claude/scripts/)

| Script | Lines | Category | Dependencies | Porting Priority |
|--------|-------|----------|--------------|------------------|
| check-extension-docs.sh | 209 | Extension Mgmt | None | Medium |
| export-to-markdown.sh | 341 | Documentation | None | Low (evaluate) |
| install-extension.sh | 297 | Extension Mgmt | validate-index.sh | Medium |
| uninstall-extension.sh | 235 | Extension Mgmt | None | Medium |
| link-artifact-todo.sh | 250 | Task Mgmt | None | High |
| memory-retrieve.sh | 168 | Task Mgmt | None | Low (evaluate) |
| migrate-directory-padding.sh | 197 | Task Mgmt | None | High |
| update-recommended-order.sh | 706 | Task Mgmt | None | High |
| update-task-status.sh | 335 | Task Mgmt | update-plan-status.sh | Medium |
| update-plan-status.sh | 67 | Task Mgmt | None | High |
| validate-artifact.sh | 164 | Validation | None | High |
| validate-context-index.sh | 154 | Validation | None | Medium |
| validate-extension-index.sh | 170 | Validation | None | High |
| validate-index.sh | 138 | Validation | None | High |
| validate-wiring.sh | 306 | Validation | None | High |
| lint-postflight-boundary.sh | 170 | Lint | None | Medium |

### Target Scripts Already Present (.opencode/scripts/)

| Script | Notes |
|--------|-------|
| verify-lean-mcp.sh | Lean MCP verification |
| setup-lean-mcp.sh | Lean MCP setup |
| merge-extensions.sh | OpenCode-specific |
| postflight-implement.sh | Ported from .claude/ |
| postflight-plan.sh | Ported from .claude/ |
| postflight-research.sh | Ported from .claude/ |
| validate-docs.sh | Different from validate-artifact.sh |
| test-command.sh | Testing utility |
| test-execution-system.sh | Testing utility |
| opencode-project-cleanup.sh | Renamed from claude-project-cleanup.sh |
| test-execution.sh | Testing utility |
| execute-command.sh | Command execution |
| opencode-refresh.sh | Renamed from claude-refresh.sh |
| opencode-cleanup.sh | Renamed from claude-cleanup.sh |
| install-aliases.sh | Ported from .claude/ |
| install-systemd-timer.sh | Ported from .claude/ |

---

## Appendix B: Path Replacement Patterns

For automated porting, these sed patterns can be used:

```bash
# Primary system directory
s/\.claude\//.opencode\//g

# Agent subdirectory (special case)
s/\.opencode\/agents\//.opencode\/agent\/subagents\//g

# Context core subdirectory (special case)
s/\.opencode\/context\//.opencode\/context\/core\//g

# But fix context/index.json (not in core/)
s/\.opencode\/context\/core\/index\.json/.opencode\/context\/index\.json/g
```

---

## Appendix C: Testing Checklist

For each ported script:

- [ ] Script executes without syntax errors (`bash -n script.sh`)
- [ ] Script shows help/usage when called with `--help` or no args
- [ ] Dry-run mode works correctly (where applicable)
- [ ] Path references resolve correctly
- [ ] Dependencies are satisfied
- [ ] Integration with existing scripts tested

---

## Next Steps

1. **Evaluate special scripts**: Determine if export-to-markdown.sh and memory-retrieve.sh should be ported
2. **Create implementation plan**: Use dependency order from this report
3. **Port Phase 1 scripts**: Start with independent validation scripts
4. **Test thoroughly**: Use dry-run modes and validate outputs
5. **Port Phase 2+ scripts**: Proceed to dependent scripts after Phase 1 complete

**Recommended Command**: Run `/plan 507` to create detailed implementation plan based on this research.
