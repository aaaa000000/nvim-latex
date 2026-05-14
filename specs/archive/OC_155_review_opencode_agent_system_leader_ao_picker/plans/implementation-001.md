# Implementation Plan: Review .opencode/ Agent System for <leader>ao Picker

- **Task**: OC_155 - Review .opencode/ agent system for <leader>ao picker improvements
- **Status**: [COMPLETED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: Research report identifying gaps in context/, memory/, and rules/ picker integration
- **Artifacts**: plans/implementation-001.md
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/standards/documentation-standards.md
  - .opencode/context/core/standards/task-management.md
  - .opencode/context/project/neovim/standards/lua-style-guide.md
- **Type**: markdown

## Overview

The <leader>ao picker provides hierarchical navigation of the .opencode/ agent system but currently has three critical gaps: context files (90+ files) are not accessible, the memory system lacks picker integration, and the rules directory (6 files) is not exposed. This plan implements complete picker coverage for all three areas by adding scanning functions, entry creators, and metadata parsers following the established picker architecture patterns.

The picker uses a thin facade pattern where lua/neotex/plugins/ai/opencode/commands/picker.lua delegates to the shared lua/neotex/plugins/ai/claude/commands/picker/ infrastructure. Entries are created in display/entries.lua with support for local/global merging and hierarchical display.

## Goals & Non-Goals

**Goals**:
- Add `scan_context_directory()` function to scan.lua for recursive .opencode/context/ scanning
- Add `create_context_entries()` in entries.lua for context files with category grouping
- Add `create_memory_entries()` in entries.lua for memory system (10-Memories/, 20-Indices/)
- Add `create_rules_entries()` in entries.lua for rules directory files
- Add metadata parsing functions for context, memory, and rules entries
- Update picker entry creation order to include new sections
- Maintain consistency with existing patterns (local/global merge, tree display, ordinal sorting)

**Non-Goals**:
- No changes to specs/ directory integration (explicitly excluded per user requirements)
- No modifications to existing Commands, Skills, Agents, Extensions sections
- No changes to the picker UI or telescope configuration
- No new keymaps or commands beyond picker entries

## Risks & Mitigations

- **Risk**: Context directory has 90+ files which may impact picker performance. **Mitigation**: Implement hierarchical grouping by subdirectory (core/, project/, docs/) to limit initial display; use lazy loading for descriptions.
- **Risk**: Memory files use MEM-YYYY-MM-DD-NNN.md naming which may not sort intuitively. **Mitigation**: Parse dates from filenames and sort reverse-chronologically with recent memories first.
- **Risk**: Rules files may conflict with existing naming conventions. **Mitigation**: Use consistent "rules" entry_type and verify no naming collisions with existing sections.
- **Risk**: Ordinal sorting may cause new sections to appear in unexpected positions. **Mitigation**: Follow existing "zzzz_" prefix pattern and place new sections between existing logical groups.

## Implementation Phases

### Phase 1: Context Directory Scanner [COMPLETED]

- **Goal:** Implement `scan_context_directory()` function in scan.lua
- **Tasks:**
  - [ ] Add function to recursively scan .opencode/context/ directory
  - [ ] Support glob pattern "**/*.md" for nested context files
  - [ ] Group files by subdirectory (core/, project/, docs/, etc.)
  - [ ] Return structured data with {name, filepath, category, is_local}
  - [ ] Handle both local and global context directories
- **Timing:** 1.5 hours
- **Files Modified:** lua/neotex/plugins/ai/claude/commands/picker/utils/scan.lua
- **Verification:** Function returns all 90+ context files grouped by category

### Phase 2: Context Entry Creator [COMPLETED]

- **Goal:** Implement `create_context_entries()` in entries.lua
- **Tasks:**
  - [ ] Create function following pattern of create_docs_entries()
  - [ ] Group entries by category (core, project, docs) with subheadings
  - [ ] Add tree-style indentation for hierarchical display
  - [ ] Set ordinals using "zzzz_context_{category}_{name}" pattern
  - [ ] Add entry_type = "context" for previewer support
  - [ ] Integrate with create_picker_entries() in reverse order
- **Timing:** 1.5 hours
- **Files Modified:** lua/neotex/plugins/ai/claude/commands/picker/display/entries.lua
- **Verification:** Context section appears in picker with 90+ files organized by category

### Phase 3: Memory System Integration [COMPLETED]

- **Goal:** Implement `create_memory_entries()` for 10-Memories/ and 20-Indices/
- **Tasks:**
  - [ ] Scan 10-Memories/ for MEM-*.md files
  - [ ] Parse dates from MEM-YYYY-MM-DD-NNN.md filenames
  - [ ] Sort memories reverse-chronologically (newest first)
  - [ ] Include 20-Indices/index.md as entry point
  - [ ] Add memory entry_type with filepath navigation
  - [ ] Format display with date prefix (YYYY-MM-DD: Title)
- **Timing:** 1.5 hours
- **Files Modified:** lua/neotex/plugins/ai/claude/commands/picker/display/entries.lua
- **Verification:** Memory section shows indexed memories sorted by date

### Phase 4: Rules Directory Integration [COMPLETED]

- **Goal:** Implement `create_rules_entries()` for .opencode/rules/ directory
- **Tasks:**
  - [ ] Scan rules/ directory for *.md files (excluding README.md)
  - [ ] Parse rule descriptions from file headers
  - [ ] Create entries for: git-workflow.md, state-management.md, error-handling.md, neovim-lua.md, workflows.md, artifact-formats.md
  - [ ] Add rules entry_type for previewer support
  - [ ] Integrate into picker entry order
- **Timing:** 1 hour
- **Files Modified:** lua/neotex/plugins/ai/claude/commands/picker/display/entries.lua
- **Verification:** Rules section appears with all 6 rule files

### Phase 5: Metadata Parsers and Integration [COMPLETED]

- **Goal:** Add metadata parsing and finalize picker integration
- **Tasks:**
  - [ ] Add `parse_context_description()` in metadata.lua
  - [ ] Add `parse_memory_title()` in metadata.lua
  - [ ] Add `parse_rule_description()` in metadata.lua
  - [ ] Update create_picker_entries() to call new section creators
  - [ ] Verify ordinal ordering places sections correctly
  - [ ] Test local/global merging works for all new sections
- **Timing:** 1 hour
- **Files Modified:**
  - lua/neotex/plugins/ai/claude/commands/picker/artifacts/metadata.lua
  - lua/neotex/plugins/ai/claude/commands/picker/display/entries.lua
- **Verification:** All picker sections display with proper descriptions and navigation

### Phase 6: Testing and Validation [COMPLETED]

- **Goal:** Verify complete picker functionality
- **Tasks:**
  - [ ] Run picker and verify context section displays 90+ files
  - [ ] Verify memory section shows correct date ordering
  - [ ] Verify rules section shows all 6 files
  - [ ] Test file navigation opens correct files
  - [ ] Verify local/global indicators work correctly
  - [ ] Run existing tests to ensure no regressions
- **Timing:** 1 hour
- **Verification:** All picker sections functional and tests pass

## Testing & Validation

- [ ] Context section displays with hierarchical categories (core, project, docs)
- [ ] Memory section shows memories sorted reverse-chronologically
- [ ] Rules section displays all 6 rule files with descriptions
- [ ] File navigation opens correct context/memory/rules files
- [ ] Local file indicator (*) appears for local overrides
- [ ] Ordinal sorting maintains logical section order
- [ ] Previewer displays file contents for all new entry types
- [ ] No performance degradation with 90+ context files
- [ ] Existing Commands, Skills, Agents sections remain functional

## Artifacts & Outputs

- lua/neotex/plugins/ai/claude/commands/picker/utils/scan.lua (modified)
- lua/neotex/plugins/ai/claude/commands/picker/display/entries.lua (modified)
- lua/neotex/plugins/ai/claude/commands/picker/artifacts/metadata.lua (modified)
- plans/implementation-001.md (this file)

## Rollback/Contingency

- All changes are additive (new functions only) - no modifications to existing entry creators
- If issues arise, new sections can be disabled by commenting out calls in create_picker_entries()
- Original scan.lua functions remain unchanged as foundation
- Git history preserves pre-change state for full rollback if needed
- Each phase is independent and can be reverted separately
