# Implementation Plan: Task #511

- **Task**: 511 - update_agents_documentation
- **Status**: [COMPLETED]
- **Effort**: 4.5 hours
- **Dependencies**: Tasks 503-509 (COMPLETED)
- **Research Inputs**: None required (document comparison complete)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update .opencode/AGENTS.md to achieve documentation parity with .claude/CLAUDE.md. AGENTS.md is currently 176 lines (66% shorter than CLAUDE.md at 512 lines) and missing 9 major sections covering team mode, context architecture, multi-task standards, and extension-specific documentation.

### Research Integration

Research findings identified 9 major gaps:
1. Team Mode Skills Table (with --team flag)
2. Context Architecture (5-layer model)
3. Context Imports Section
4. Multi-Task Creation Standards (8-component pattern)
5. jq Command Safety (full examples)
6. Syncprotect Documentation
7. Memory Extension Section (/distill commands)
8. Nix Extension Section (MCP-NixOS)
9. Neovim Extension Context Imports

## Goals & Non-Goals

**Goals**:
- Add comprehensive team mode documentation with skill-to-agent mappings
- Document the 5-layer context architecture model
- Add multi-task creation standards and compliance table
- Expand jq command safety with full examples
- Add syncprotect documentation
- Port Memory extension commands (/learn, /distill)
- Port Nix extension with MCP-NixOS integration
- Port Neovim extension context imports

**Non-Goals**:
- Modifying actual functionality or behavior
- Adding new commands beyond documentation
- Changing CLAUDE.md (it's the reference, not target)
- Rewriting existing content (only adding missing sections)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Content drift between AGENTS.md and CLAUDE.md | Medium | High | Document at top of AGENTS.md that it's a port with date |
| Extension sections become outdated | Low | Medium | Reference .claude/ extension manifests instead of duplicating |
| Documentation too verbose | Low | Low | Follow CLAUDE.md structure closely, maintain conciseness |
| Broken cross-references | Medium | Medium | Validate all @-references after each phase |

## Implementation Phases

### Phase 1: Team Mode Skills and Agent Mappings [COMPLETED]

**Goal**: Add comprehensive team mode documentation and expand skill-to-agent mapping table

**Tasks**:
- [ ] Add Team Mode Skills subsection under "Skill-to-Agent Mapping"
- [ ] Create table with --team flag documentation
- [ ] Add skill-team-research, skill-team-plan, skill-team-implement entries
- [ ] Document CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 requirement
- [ ] Add cost warning (~5x tokens for team mode)
- [ ] Expand Agents table with code-reviewer-agent, reviser-agent, spawn-agent
- [ ] Add Model Enforcement subsection with --fast/--hard and --haiku/--sonnet/--opus flags

**Timing**: 45 minutes

**Files to modify**:
- `.opencode/AGENTS.md` - Lines 82-100 (skill mapping), add team mode section after line 99

**Verification**:
- All team skills documented with correct agent mappings
- Team flag table present with teammate counts
- Model enforcement flags documented

---

### Phase 2: Context Architecture and Context Imports [COMPLETED]

**Goal**: Add 5-layer context model and context imports documentation

**Tasks**:
- [ ] Add "Context Architecture" section after "Rules and Conventions"
- [ ] Create 5-layer table (Agent context, Extensions, Project context, Project memory, Auto-memory)
- [ ] Add "Where to store new content" decision tree
- [ ] Add reference to .opencode/context/architecture/context-layers.md
- [ ] Add "Context Imports" subsection
- [ ] List core context files (@specs/TODO.md, @specs/state.json, etc.)
- [ ] Document extension context availability via extension picker

**Timing**: 40 minutes

**Files to modify**:
- `.opencode/AGENTS.md` - Add after line 113 (after Rules and Conventions)

**Verification**:
- 5-layer table complete with all layers
- Decision tree covers all 5 storage options
- Core context imports listed

---

### Phase 3: Multi-Task Creation Standards [COMPLETED]

**Goal**: Document 8-component multi-task creation pattern

**Tasks**:
- [ ] Add "Multi-Task Creation Standards" section
- [ ] Document 8-component pattern with descriptions
- [ ] Create Commands Using Multi-Touch Creation compliance table
- [ ] List /meta, /fix-it, /review, /errors, /task --review compliance levels
- [ ] Document Required Components (all creators)
- [ ] Document Optional Components (3+ tasks)
- [ ] Add reference to multi-task-operations.md

**Timing**: 35 minutes

**Files to modify**:
- `.opencode/AGENTS.md` - Add after Context Architecture section

**Verification**:
- All 8 components documented
- Compliance table has all 5 commands
- Required vs Optional components clearly separated

---

### Phase 4: jq Command Safety and Syncprotect [COMPLETED]

**Goal**: Expand jq safety documentation and add syncprotect section

**Tasks**:
- [ ] Expand existing jq section (lines 153-158) with full examples
- [ ] Add SAFE pattern example with `select(.type == "X" | not)`
- [ ] Add UNSAFE pattern warning with `select(.type != "X")`
- [ ] Add note about Issue #1132 causing parse errors
- [ ] Add reference to jq-escaping-workarounds.md
- [ ] Add "Syncprotect" section
- [ ] Document .syncprotect file location at project root
- [ ] Document protection rules (comments, blank lines, relative paths)
- [ ] Mention picker preview shows protected files

**Timing**: 30 minutes

**Files to modify**:
- `.opencode/AGENTS.md` - Lines 153-158 (jq section), add syncprotect after

**Verification**:
- Both SAFE and UNSAFE jq examples present
- Syncprotect location documented correctly
- Protection behavior explained

---

### Phase 5: Memory Extension Section [COMPLETED]

**Goal**: Port Memory extension documentation from CLAUDE.md

**Tasks**:
- [ ] Add "Memory Extension" section
- [ ] Add skill-memory to skill-agent mapping
- [ ] Document all /learn commands (text, file, dir, --task)
- [ ] Document all /distill commands (--purge, --merge, --compress, --refine, --gc, --auto)
- [ ] Add Memory Lifecycle diagram/description
- [ ] Document Memory-Augmented Research (auto-retrieval)
- [ ] Document Validate-on-Read behavior
- [ ] Mention no --reindex command needed

**Timing**: 40 minutes

**Files to modify**:
- `.opencode/AGENTS.md` - Add before "Important Notes" section

**Verification**:
- All 4 /learn variants documented
- All 6 /distill variants documented
- Memory lifecycle explained
- Validate-on-read behavior documented

---

### Phase 6: Nix Extension Section [COMPLETED]

**Goal**: Port Nix extension documentation with MCP-NixOS integration

**Tasks**:
- [ ] Add "Nix Extension" section
- [ ] Add nix language to Language Routing table
- [ ] Add skill-nix-research and skill-nix-implementation mappings
- [ ] Document Key Technologies (NixOS, Home Manager, Flakes, MCP-NixOS)
- [ ] Add Build Verification commands (nix flake check, show, rebuild)
- [ ] Document Context Categories (Domain, Patterns, Standards, Tools)
- [ ] Add MCP-NixOS Integration subsection
- [ ] Document available MCP tools (search, options, versions)
- [ ] Note graceful degradation when MCP unavailable

**Timing**: 45 minutes

**Files to modify**:
- `.opencode/AGENTS.md` - Add after Memory Extension section

**Verification**:
- Nix language routing documented
- All 4 key technologies listed
- All 4 build verification commands present
- MCP tools documented with examples

---

### Phase 7: Neovim Extension and Context Imports [COMPLETED]

**Goal**: Port Neovim extension documentation and context imports

**Tasks**:
- [ ] Add "Neovim Extension" section
- [ ] Add neovim language to Language Routing table
- [ ] Add skill-neovim-research and skill-neovim-implementation mappings
- [ ] Document neovim-lua.md rule
- [ ] Add Neovim Patterns subsection (keymaps, options, autocommands, pcall)
- [ ] Add Common Operations examples
- [ ] Add Context Imports subsection with domain knowledge files
- [ ] List neovim-api.md, plugin-spec.md, lazy-nvim-guide.md

**Timing**: 40 minutes

**Files to modify**:
- `.opencode/AGENTS.md` - Add after Nix Extension section

**Verification**:
- Neovim language routing documented
- All 4 patterns documented
- All 4 common operations have examples
- All 3 context imports listed

---

### Phase 8: Final Review and Cross-Reference Validation [COMPLETED]

**Goal**: Validate all documentation, cross-references, and formatting

**Tasks**:
- [ ] Add header comment noting AGENTS.md is a port of CLAUDE.md with date
- [ ] Verify all cross-references (@-paths) are valid
- [ ] Check line count increased from 176 to ~450-500
- [ ] Verify all tables have proper formatting
- [ ] Ensure consistent heading levels
- [ ] Validate markdown rendering
- [ ] Compare key sections side-by-side with CLAUDE.md
- [ ] Update TOC if needed

**Timing**: 30 minutes

**Files to modify**:
- `.opencode/AGENTS.md` - Header and final validation

**Verification**:
- All @-references valid
- Line count ~450-500 (matching CLAUDE.md scope)
- All 9 missing sections now present
- Document renders correctly

---

## Testing & Validation

- [ ] Phase 1: Verify team skills table renders correctly with all columns
- [ ] Phase 2: Verify 5-layer table has all layers with correct locations
- [ ] Phase 3: Verify compliance table shows all 5 commands
- [ ] Phase 4: Verify jq examples show both SAFE and UNSAFE patterns clearly
- [ ] Phase 5: Verify all /learn and /distill variants documented
- [ ] Phase 6: Verify MCP-NixOS integration section complete
- [ ] Phase 7: Verify neovim context imports list all 3 files
- [ ] Phase 8: Final line count verification (target: 450-500 lines)

## Artifacts & Outputs

- Updated `.opencode/AGENTS.md` with 9 new major sections
- ~275 lines of new documentation added
- Complete skill-agent mapping for team mode and extensions
- Full extension documentation (Memory, Nix, Neovim)

## Rollback/Contingency

If documentation causes confusion or bloat:
1. Keep original AGENTS.md backup before starting
2. Use git to revert specific sections if needed
3. Alternative: Create AGENTS.md as a minimal quick-reference and link to full CLAUDE.md docs
4. Can remove extension sections and reference .claude/ docs instead if too verbose

## Phase Dependencies

```
Phase 1 (Team Mode) ──────────────────────────┐
Phase 2 (Context Architecture) ───────────────┼──► Phase 8 (Final Review)
Phase 3 (Multi-Task) ─────────────────────────┤
Phase 4 (jq + Syncprotect) ───────────────────┤
Phase 5 (Memory) ──► Phase 6 (Nix) ──► Phase 7 (Neovim) ──┘
```

Phases 1-4 are independent and can be completed in any order.
Phases 5-7 are sequential (extension sections build on each other).
Phase 8 depends on all previous phases.
