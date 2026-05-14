# Research Report: Task #511 - AGENTS.md Gap Analysis

**Task**: OC_511 - update_agents_documentation
**Started**: 2026-05-02
**Completed**: 2026-05-02
**Effort**: ~30 minutes
**Dependencies**: Tasks 503-509 (all completed)
**Sources/Inputs**: .claude/CLAUDE.md (512 lines), .opencode/AGENTS.md (176 lines)
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

Comprehensive gap analysis reveals that .opencode/AGENTS.md is missing **9 major sections** and **numerous minor details** from .claude/CLAUDE.md. The .claude version contains 512 lines vs .opencode's 176 lines - a **336-line deficit** (66% shorter). Key missing sections include team mode skills, context architecture 5-layer model, multi-task creation standards, memory/nix/neovim extensions, syncprotect, and detailed command patterns.

## Context & Scope

### Files Compared
- **Source (Complete)**: `.claude/CLAUDE.md` - 512 lines, comprehensive agent system documentation
- **Target (Incomplete)**: `.opencode/AGENTS.md` - 176 lines, basic agent system documentation

### Comparison Methodology
1. Line-by-line structural comparison
2. Section mapping and identification
3. Content depth analysis
4. Missing element cataloging

## Findings

### 1. Team Mode Skills Table (CRITICAL MISSING)

**Location in CLAUDE.md**: Lines 216-225
**Status in AGENTS.md**: ❌ **COMPLETELY MISSING**

**Missing Content**:
```markdown
| Flag | Team Skill | Teammates | Purpose |
|------|------------|-----------|---------|
| `--team` | skill-team-research | 2-4 | Parallel investigation with synthesis |
| `--team` | skill-team-plan | 2-3 | Parallel plan generation with trade-offs |
| `--team` | skill-team-implement | 2-4 | Parallel phase execution with debugger |

**Note**: Team mode uses ~5x tokens compared to single-agent. Default team_size=2 minimizes cost.
```

**Related Missing**: Environment variable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` mention

### 2. Context Architecture 5-Layer Model (CRITICAL MISSING)

**Location in CLAUDE.md**: Lines 268-299
**Status in AGENTS.md**: ❌ **COMPLETELY MISSING**

**Missing Content**:
```markdown
## Context Architecture

Five layers provide context to agents. Each has a distinct owner and purpose.

| Layer | Location | Owner | Contains |
|-------|----------|-------|----------|
| Agent context | `.claude/context/` | Extension loader | Core agent patterns + extension domain knowledge |
| Extensions | `.claude/extensions/*/context/` | Extension loader | Language-specific standards, tools, patterns |
| Project context | `.context/` | User (via index.json) | Project conventions not covered by extensions |
| Project memory | `.memory/` | Agents over time | Learned facts, discoveries, decisions |
| Auto-memory | `~/.claude/projects/` | Claude Code | User preferences, behavioral corrections |

### Where to store new content

```
Language-specific standard, pattern, or tool reference?
  YES --> extension context (.claude/extensions/*/context/)

Agent system pattern (orchestration, format, workflow)?
  YES --> .claude/context/

Project convention (coding style, naming, domain knowledge)?
  YES --> .context/

Learned fact from development (discovery, decision, pattern)?
  YES --> .memory/

User preference or behavioral correction?
  YES --> auto-memory (automatic, no action needed)
```

Full details: `.claude/context/architecture/context-layers.md`
```

### 3. Context Imports Section (MAJOR MISSING)

**Location in CLAUDE.md**: Lines 301-308
**Status in AGENTS.md**: ❌ **COMPLETELY MISSING**

**Missing Content**:
```markdown
## Context Imports

Core context (always available):
- @.claude/context/repo/project-overview.md
- @README.md

**Extension Context**: Available when extensions are loaded via the extension picker. Query `index.json` for extension-specific context files.
```

### 4. Multi-Task Creation Standards (MAJOR MISSING)

**Location in CLAUDE.md**: Lines 309-333
**Status in AGENTS.md**: ❌ **COMPLETELY MISSING**

**Missing Content**:
```markdown
## Multi-Task Creation Standards

Commands that create multiple tasks follow a standardized 8-component pattern. See `.claude/docs/reference/standards/multi-task-creation-standard.md` for the complete specification.

**Commands Using Multi-Task Creation**:
| Command | Compliance | Notes |
|---------|------------|-------|
| `/meta` | Full (Reference) | All 8 components, Kahn's algorithm, DAG visualization |
| `/fix-it` | Full | Interactive selection, topic grouping, internal dependencies |
| `/review` | Partial | Tier-based selection, grouping; no dependencies |
| `/errors` | Partial | Automatic mode (intentional); no interactive selection |
| `/task --review` | Partial | Numbered selection, parent_task linking |

**Required Components** (all multi-task creators):
- Item Discovery - Identify potential tasks
- Interactive Selection - AskUserQuestion with multiSelect
- User Confirmation - Explicit "Yes, create tasks" before creation
- State Updates - Atomic state.json + TODO.md updates

**Optional Components** (for 3+ tasks):
- Topic Grouping - Cluster related items
- Dependency Declaration - Ask about task relationships
- Topological Sorting - Kahn's algorithm for ordering
- Visualization - Linear chain or layered DAG display
```

### 5. jq Command Safety (PARTIALLY MISSING)

**Location in CLAUDE.md**: Lines 340-354
**Status in AGENTS.md**: ⚠️ **PRESENT BUT INCOMPLETE**

**Current AGENTS.md** (lines 153-158):
```markdown
## jq Command Safety

Claude Code Issue #1132 causes jq parse errors when using `!=` operator.

**Safe pattern**: Use `select(.type == "X" | not)` instead of `select(.type != "X")`
```

**Missing from CLAUDE.md version**:
- Full documentation reference: `@.claude/context/patterns/jq-escaping-workarounds.md`
- Code example showing safe vs unsafe patterns:
  ```bash
  # SAFE - use "| not" pattern
  select(.type == "plan" | not)
  
  # UNSAFE - gets escaped as \!=
  select(.type != "plan")
  ```

### 6. Syncprotect Documentation (CRITICAL MISSING)

**Location in CLAUDE.md**: Lines 356-358
**Status in AGENTS.md**: ❌ **COMPLETELY MISSING**

**Missing Content**:
```markdown
## Syncprotect

The `.syncprotect` file lives at the **project root** (not inside `.claude/`) and lists relative paths (one per line) of artifacts that should never be overwritten during sync operations. Lines starting with `#` are comments, blank lines are ignored. Paths are relative to the base directory (e.g., `rules/my-custom-rule.md`). Protected files are skipped during both full "Load Core" syncs and individual artifact updates via `Ctrl-l`. The picker preview shows a "Protected Files" section listing which files will be skipped.
```

### 7. Memory Extension Section (MAJOR MISSING)

**Location in CLAUDE.md**: Lines 367-408
**Status in AGENTS.md**: ❌ **COMPLETELY MISSING**

**Missing Content**:
```markdown
## Memory Extension

Knowledge capture and retrieval via the memory vault. Supports text, file, directory, and task-based memory creation with MCP-backed search and deduplication. Includes vault distillation for scoring, health reporting, and automated maintenance.

### Skill-Agent Mapping

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-memory | (direct execution) | Memory creation, distillation, and management |

### Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `/learn` | `/learn "text"` | Add text as memory (with content mapping and deduplication) |
| `/learn` | `/learn /path/to/file` | Add file content as memory |
| `/learn` | `/learn /path/to/dir/` | Scan directory for learnable content |
| `/learn` | `/learn --task N` | Review task artifacts and create memories |
| `/distill` | `/distill` | Generate memory vault health report with scoring |
| `/distill` | `/distill --purge` | Tombstone stale memories (interactive purge) |
| `/distill` | `/distill --merge` | Combine duplicate memories by keyword overlap |
| `/distill` | `/distill --compress` | Summarize oversized memories to key points |
| `/distill` | `/distill --refine` | Improve memory metadata quality (keywords, tags, topics) |
| `/distill` | `/distill --gc` | Hard-delete tombstoned memories past 7-day grace period |
| `/distill` | `/distill --auto` | Automated Tier 1 maintenance (non-interactive) |

### Memory-Augmented Research

Memory retrieval is automatic: when the memory extension is loaded, `/research`, `/plan`, and `/implement` preflight stages call `memory-retrieve.sh` to inject relevant memories as `<memory-context>` into the agent context. The `--clean` flag on these commands suppresses auto-retrieval.

### Memory Lifecycle

```
/learn -> create memories -> auto-retrieval in /research, /plan, /implement
                          -> /todo harvests memory candidates from completed tasks
                          -> /distill scores, reports, and maintains the vault
```

### Validate-on-Read

There is no `--reindex` command. The memory system uses validate-on-read: before any scoring or retrieval operation, `memory-index.json` is compared against the filesystem. If stale (missing entries or orphaned entries), the index is automatically regenerated. This provides self-healing index consistency without explicit user intervention.
```

### 8. Nix Extension Section (MAJOR MISSING)

**Location in CLAUDE.md**: Lines 409-471
**Status in AGENTS.md**: ❌ **COMPLETELY MISSING**

**Missing Content**:
```markdown
## Nix Extension

This project includes NixOS and Home Manager configuration support via the nix extension.

### Language Routing

| Language | Research Tools | Implementation Tools |
|----------|----------------|---------------------|
| `nix` | MCP-NixOS, WebSearch, WebFetch, Read | Read, Write, Edit, Bash (nix flake check, nixos-rebuild, home-manager) |

### Skill-Agent Mapping

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-nix-research | nix-research-agent | NixOS/Home Manager/flakes research with MCP-NixOS |
| skill-nix-implementation | nix-implementation-agent | Nix configuration implementation with verification |

### Key Technologies

- **NixOS**: Declarative Linux distribution with reproducible system configurations
- **Home Manager**: User-level declarative configuration management
- **Nix Flakes**: Reproducible, hermetic package management with lockfiles
- **MCP-NixOS**: Model Context Protocol server for package/option search and validation

### Build Verification

```bash
# Check flake syntax and evaluate outputs
nix flake check

# Show flake outputs
nix flake show

# Build NixOS configuration
nixos-rebuild build --flake .#hostname

# Build Home Manager configuration
home-manager build --flake .#user

# Evaluate specific expression
nix eval .#path
```

### Context Categories

- **Domain**: Core Nix concepts (Nix language, flakes, NixOS modules, Home Manager)
- **Patterns**: Implementation patterns (modules, overlays, derivations)
- **Standards**: Coding conventions (style guide)
- **Tools**: Tool-specific guides (nixos-rebuild, home-manager)

### MCP-NixOS Integration

The MCP-NixOS server provides enhanced package and option validation:

```bash
# Available via MCP tools when configured:
mcp__nixos__nix(action="search", query="pkgname", source="nixpkgs")
mcp__nixos__nix(action="options", query="services.X", source="nixos-options")
mcp__nixos__nix_versions(package="nodejs")
```

Agents gracefully degrade to WebSearch and CLI commands when MCP is unavailable.
```

### 9. Neovim Extension Context Imports (MINOR MISSING)

**Location in CLAUDE.md**: Lines 507-512
**Status in AGENTS.md**: ❌ **PARTIALLY MISSING**

**Current AGENTS.md** has the Neovim extension section but is missing the Context Imports subsection.

**Missing Content**:
```markdown
### Context Imports

Domain knowledge (load as needed):
- @.claude/context/project/neovim/domain/neovim-api.md
- @.claude/context/project/neovim/patterns/plugin-spec.md
- @.claude/context/project/neovim/tools/lazy-nvim-guide.md
```

## Additional Minor Gaps

### Skill-to-Agent Mapping Gaps
**AGENTS.md lines 82-99** vs **CLAUDE.md lines 175-196**

**Missing Skills in AGENTS.md**:
| Skill | Agent | Purpose | Status |
|-------|-------|---------|--------|
| skill-todo | (direct execution) | Archive completed tasks with CHANGE_LOG updates | Description incomplete |
| skill-tag | (user-only) | Semantic version tagging for deployment | Description incomplete |
| skill-team-research | (team orchestration) | sonnet | Multi-agent parallel research | ❌ Missing |
| skill-team-plan | (team orchestration) | sonnet | Multi-agent parallel planning | ❌ Missing |
| skill-team-implement | (team orchestration) | sonnet | Multi-agent parallel implementation | ❌ Missing |
| skill-reviser | reviser-agent | opus | Plan revision and description update | ❌ Missing |
| skill-spawn | spawn-agent | opus | Analyze blockers and spawn new tasks | ❌ Missing |
| skill-project-overview | (direct execution) | - | Interactive repo scan and project-overview.md task creation | ❌ Missing |

**Missing Agents Table** (CLAUDE.md lines 198-209):
```markdown
### Agents

| Agent | Purpose |
|-------|---------|
| general-research-agent | General web/codebase research |
| general-implementation-agent | General file implementation |
| planner-agent | Implementation plan creation |
| meta-builder-agent | System building and meta tasks |
| code-reviewer-agent | Code quality assessment and review |
| reviser-agent | Plan revision with research synthesis |
| spawn-agent | Blocker analysis and task decomposition |
```

### Task Management Gaps

**Status Markers**:
- CLAUDE.md: `[BLOCKED]`, `[PARTIAL]` as exception states (non-terminal)
- AGENTS.md: Lists `[BLOCKED]`, `[ABANDONED]`, `[PARTIAL]`, `[EXPANDED]` all together without clarification

**Artifact Paths**:
- CLAUDE.md: Has detailed naming convention explanation (lines 60-71)
- AGENTS.md: Missing naming convention details

**System-Specific Naming** (CLAUDE.md lines 67-71):
```markdown
**System-Specific Naming**: Task directories use different prefixes by system:
- **Claude Code** (.claude/): `specs/{NNN}_{SLUG}/` (no prefix)
- **OpenCode** (.opencode/): `specs/OC_{NNN}_{SLUG}/` (OC_ prefix)

This distinction enables identification of which system created each task.
```

### Command Reference Gaps

**Missing Commands in AGENTS.md**:
| Command | CLAUDE.md | AGENTS.md |
|---------|-----------|-----------|
| `/project-overview` | ✅ Present | ❌ Missing |
| `/tag` | ✅ Present | ❌ Missing (only mentioned in skills) |
| `/spawn` | ✅ Present | ❌ Missing |
| `/merge` | ✅ Present | ❌ Missing |
| `/convert` | ❌ Missing | ✅ Present (AGENTS.md has this, CLAUDE.md doesn't) |

**Missing Flags**:
- `--team` flag for `/research`, `/plan`, `/implement`
- `--fast`, `--hard` effort flags
- `--haiku`, `--sonnet`, `--opus` model flags
- `--force` flag for `/implement`
- `--clean` flag
- Multi-task syntax (commas and ranges)

### State Synchronization Gaps

**Missing in AGENTS.md**:
- `completion_summary` field documentation
- `roadmap_items` field documentation
- Completion workflow explanation
- Vault operation documentation (lines 148-162)

### Context Discovery Section (MAJOR MISSING)

**CLAUDE.md lines 238-266** contains complete context discovery section:
```markdown
## Context Discovery

Context is discovered from three independent layers, loaded in parallel:

| Layer | Source | Notes |
|-------|--------|-------|
| Agent context | `.claude/context/index.json` | Core + extensions (merged by loader) |
| Project context | `.context/index.json` | User conventions (may be empty) |
| Project memory | `.memory/` files | Loaded directly, no index needed |
```

With jq query examples - **completely missing from AGENTS.md**.

### Extension Context Details (MISSING)

**CLAUDE.md has** (lines 83-90, 214-215, 236-237):
- Extension dependencies explanation
- Extension rules auto-loading
- Extension skill-agent mappings
- Extension task types (lean4, latex, typst, python, nix, web, z3, epi, formal, founder, present)

**AGENTS.md has only** (lines 58-61):
- Brief mention that extensions exist

### Model Enforcement Section (MISSING)

**CLAUDE.md lines 210-215**:
```markdown
**Model Enforcement**: Agents declare preferred models via `model:` frontmatter field. All agents default to Opus. Two independent flag dimensions override behavior at invocation time: effort flags (`--fast`, `--hard`) control reasoning depth, and model flags (`--haiku`, `--sonnet`, `--opus`) select the model family. These flags work on `/research`, `/plan`, and `/implement`. See `.claude/docs/reference/standards/agent-frontmatter-standard.md` for details.
```

### Utility Scripts (MISSING)

**CLAUDE.md lines 118-120**:
```markdown
### Utility Scripts

- `.claude/scripts/export-to-markdown.sh` - Export .claude/ directory to consolidated markdown file
- `.claude/scripts/check-extension-docs.sh` - Doc-lint: validate extension READMEs, manifests, and cross-references (exits non-zero on failures)
```

## Decisions

1. **Gap Priority**: Sections are prioritized as CRITICAL (blocking functionality), MAJOR (important features), MINOR (nice-to-have)
2. **Extension Content**: Nix and Neovim extension sections should be included since this repository contains both `.claude/extensions/nix/` and `.claude/extensions/nvim/`
3. **Path Translation**: When porting from CLAUDE.md to AGENTS.md, paths need translation:
   - `.claude/` → `.opencode/`
   - `CLAUDE_CODE_*` → `OPENCODE_*` (env vars)
   - `<leader>ao` for extension picker in OpenCode

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Path references incorrect | High | Systematic review of all paths when copying |
| Environment variables wrong | Medium | Update `CLAUDE_CODE_*` to `OPENCODE_*` |
| Extension picker command wrong | Low | Change from "extension picker" to `<leader>ao` |
| File becomes too large | Medium | Consider splitting into multiple files |
| Duplicate content maintenance | Low | Document that AGENTS.md mirrors CLAUDE.md |

## Implementation Recommendations

### Priority 1: Critical Gaps (Must Have)
1. Team Mode Skills Table (lines 216-225)
2. Context Architecture 5-Layer Model (lines 268-299)
3. Syncprotect Documentation (lines 356-358)

### Priority 2: Major Gaps (Should Have)
4. Context Imports Section (lines 301-308)
5. Multi-Task Creation Standards (lines 309-333)
6. Memory Extension Section (lines 367-408)
7. Nix Extension Section (lines 409-471)
8. Context Discovery Section (lines 238-266)

### Priority 3: Minor Gaps (Nice to Have)
9. Complete jq Command Safety examples (lines 340-354)
10. Neovim Extension Context Imports (lines 507-512)
11. Missing Skills and Agents tables
12. Command flags documentation
13. Utility Scripts section
14. Model Enforcement section
15. State Synchronization completion workflow

### Translation Notes
When implementing, ensure these path/command translations:
- `.claude/` → `.opencode/`
- `Ctrl-l` → appropriate OpenCode refresh command
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` → `OPENCODE_EXPERIMENTAL_AGENT_TEAMS`
- Extension picker references → `<leader>ao`

## Summary Statistics

| Metric | CLAUDE.md | AGENTS.md | Gap |
|--------|-----------|-----------|-----|
| Total Lines | 512 | 176 | -336 (66%) |
| Sections | 15+ | 8 | -7 |
| Tables | 10+ | 4 | -6+ |
| Code Examples | 8+ | 2 | -6+ |

**Estimated new lines to add**: ~250-300 lines

## Context Extension Recommendations

- **Topic**: Agent system documentation synchronization
- **Gap**: No documented process for keeping .claude/CLAUDE.md and .opencode/AGENTS.md in sync
- **Recommendation**: Create `.claude/context/guides/documentation-sync.md` with procedures for:
  - Regular synchronization schedule
  - Change detection process
  - Translation rules (paths, env vars, commands)
  - Review checklist

## Appendix

### Search Queries Used
- N/A (file comparison only)

### References
- `.claude/CLAUDE.md` (512 lines)
- `.opencode/AGENTS.md` (176 lines)
- Tasks 503-509 completion status
