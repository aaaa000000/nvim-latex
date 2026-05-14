# Implementation Plan: Task #136 (Revision 2)

**Task**: OC_136 - Design and implement `/remember` command for intelligent memory management  
**Version**: 002 (Revised)  
**Created**: 2026-03-06  
**Revision Note**: Changed interactive confirmation from simple yes/no to checkbox-based multi-select pattern (similar to /learn command)

---

## Overview

This implementation plan creates a simple-but-effective memory management system using an Obsidian-compatible vault at `.opencode/memory/`. The approach leverages MCP (Model Context Protocol) servers for lookup and storage, avoiding complex custom indexing.

**Key Revision**: The interactive confirmation flow now uses a checkbox-based multi-select pattern (like `/learn` command) instead of simple yes/no approval, providing more flexibility and better UX.

**Core Philosophy**: Start simple, get it working, then iterate. Phase 1 delivers minimal viable functionality; future phases can add advanced features.

---

## Revision Summary

### Changes from v001 to v002:

1. **Phase 2: Interactive Confirmation** - Changed from simple yes/no to checkbox-based multi-select
   - Uses `AskUserQuestion` with `multiSelect` option (like `/learn` command)
   - Presents multiple options: "Add as new memory", "Update existing similar memory", "Skip - don't save"
   - Shows memory preview with metadata
   - Allows user to select multiple actions simultaneously

2. **Skill Implementation** - Updated to match new interactive pattern
   - Supports multiple selection handling
   - Can add new memory AND update existing in one flow
   - More sophisticated user feedback

3. **Verification Checklist** - Updated to test new interactive behaviors
   - Tests multi-select scenarios
   - Validates checkbox-based confirmation

---

## Phases

### Phase 1: Vault Structure and Configuration

**Status**: [NOT STARTED]  
**Estimated effort**: 1-2 hours  
**Last Updated**: 2026-03-06

**Objectives**:
1. Create `.opencode/memory/` vault directory structure
2. Set up basic Obsidian configuration files
3. Create directory structure (Inbox, Memories, Indices, Templates)
4. Create memory template and index files
5. Document MCP server setup instructions

**Files to Create**:
- `.opencode/memory/.obsidian/app.json` - Obsidian app configuration
- `.opencode/memory/.obsidian/appearance.json` - Theme settings
- `.opencode/memory/.obsidian/core-plugins.json` - Enabled plugins
- `.opencode/memory/00-Inbox/.gitkeep` - Inbox directory
- `.opencode/memory/10-Memories/.gitkeep` - Memories directory
- `.opencode/memory/20-Indices/index.md` - Master index with links
- `.opencode/memory/30-Templates/memory-template.md` - Template for new memories
- `.opencode/memory/README.md` - Vault documentation
- `.opencode/docs/memory-setup.md` - MCP server setup instructions

**Steps**:

1. **Create vault structure**
   ```bash
   mkdir -p .opencode/memory/{.obsidian/plugins,00-Inbox,10-Memories,20-Indices,30-Templates}
   ```

2. **Create Obsidian configuration**
   - Write app.json with default settings
   - Write appearance.json with Minimal theme preference
   - Write core-plugins.json enabling necessary plugins

3. **Create template file**
   ```markdown
   ---
   id: MEM-{{date}}-{{sequence}}
   title: "{{title}}"
   date: {{date}}
   tags: {{tags}}
   source: "{{source}}"
   ---
   
   # {{title}}
   
   {{content}}
   
   ## Connections
   <!-- Add links to related memories -->
   ```

4. **Create index.md**
   ```markdown
   # Memory Vault Index
   
   ## Quick Navigation
   - [Inbox](00-Inbox/) - Quick capture
   - [Memories](10-Memories/) - All memory entries
   - [Templates](30-Templates/) - Memory templates
   
   ## Recent Memories
   <!-- Auto-populated by /remember command -->
   
   ## By Topic
   <!-- Organized links to memory categories -->
   ```

5. **Create README.md**
   - Vault purpose and usage
   - MCP server setup instructions
   - Naming conventions
   - Git workflow (what to commit, what to ignore)

6. **Create setup documentation**
   - Step-by-step MCP server installation
   - Configuration examples
   - Testing instructions

**Verification**:
- [ ] Directory structure exists
- [ ] Obsidian can open `.opencode/memory/` as vault
- [ ] Template file is valid markdown with YAML frontmatter
- [ ] README explains vault organization
- [ ] Setup docs are clear and complete

---

### Phase 2: Basic /remember Command with Checkbox Confirmation

**Status**: [NOT STARTED]  
**Estimated effort**: 2-3 hours  
**Last Updated**: 2026-03-06

**Objectives**:
1. Create `/remember` command specification
2. Implement input parsing (text vs file path)
3. Generate memory entries with auto-incrementing IDs
4. **Checkbox-based interactive confirmation** (similar to /learn command)
5. Write approved memories to vault
6. Update index.md automatically

**Files to Create**:
- `.opencode/commands/remember.md` - Command specification
- `.opencode/skills/skill-remember/SKILL.md` - Direct execution skill

**Files to Modify**:
- `.opencode/memory/20-Indices/index.md` - Append new memory links

**Steps**:

1. **Create command specification** (`.opencode/commands/remember.md`)
   ```markdown
   ---
   description: Add a memory to the vault with interactive checkbox confirmation
   ---
   
   # Command: /remember
   
   ## Usage
   /remember "text to remember"
   /remember /path/to/file.md
   
   ## Steps
   
   ### 1. Parse Input
   - Check if argument is existing file path
   - If yes: read file content
   - If no: use argument as text content
   
   ### 2. Generate Memory ID
   - Format: MEM-YYYY-MM-DD-NNN
   - Date: current date
   - NNN: next available sequence number (scan 10-Memories/)
   
   ### 3. Extract Metadata
   - Title: First line (if text) or filename (if file)
   - Source: "user input" or file path
   - Date: Current date
   - Tags: Empty (Phase 1), auto-extract (Phase 2+)
   
   ### 4. Create Memory Entry
   - Load template from 30-Templates/memory-template.md
   - Fill placeholders: {{date}}, {{sequence}}, {{title}}, {{tags}}, {{source}}, {{content}}
   - Generate full markdown content
   
   ### 5. Search for Similar Memories (NEW)
   Before showing confirmation, search existing memories for potential duplicates:
   - Use MCP tool: `search_notes` with title keywords
   - Limit to top 3 similar memories
   - Extract IDs and titles for display
   
   ### 6. Interactive Checkbox Confirmation (REVISED - Similar to /learn)
   Use AskUserQuestion with multiSelect to present options:
   
   **Preview Display**:
   ```
   Memory Preview:
   ─────────────────────────────────────────
   ID: MEM-2026-03-06-001
   Title: Neovim LSP Configuration Best Practices
   Source: user input
   Date: 2026-03-06
   
   Content Preview (first 300 chars):
   When configuring LSP servers in Neovim, it's important to...
   ─────────────────────────────────────────
   
   Similar Memories Found:
   - MEM-2026-03-05-042: "LSP server setup guide"
   - MEM-2026-03-04-038: "Neovim configuration tips"
   ```
   
   **Checkbox Options** (using AskUserQuestion with multiSelect):
   - [ ] Add as new memory
   - [ ] Update existing similar memory (select from list)
   - [ ] Edit content before saving
   - [ ] Skip - don't save
   
   **User Can Select Multiple**:
   - Select "Add as new" only -> Creates new memory file
   - Select "Update existing" -> Shows list of similar memories to choose from
   - Select both -> Adds new AND updates existing (merge scenario)
   - Select "Edit content" -> Opens content in editor before proceeding
   - Select "Skip" -> Cancels operation gracefully
   
   ### 7. Execute Selected Actions
   Based on user selections:
   
   **If "Add as new memory" selected**:
   - Write file to 10-Memories/MEM-YYYY-MM-DD-NNN-slug.md
   - Append link to 20-Indices/index.md
   - Commit changes with message: "memory: add MEM-XXX"
   
   **If "Update existing" selected**:
   - Present list of similar memories found
   - User selects which to update
   - Append new content to existing memory file
   - Add "## Update History" section with timestamp
   - Commit changes with message: "memory: update MEM-XXX"
   
   **If "Edit content" selected**:
   - Open content in temporary buffer
   - Allow user to modify
   - Use modified content for save/update operations
   
   ### 8. Report Success
   Display results based on actions taken:
   ```
   Memory Operations Completed:
   ✓ Added: MEM-2026-03-06-001 (10-Memories/neovim-lsp-configuration-best-practices.md)
   ✓ Updated: MEM-2026-03-05-042 (appended new content)
   ✓ Index updated with 1 new link
   
   Git commit: memory: add MEM-2026-03-06-001, update MEM-2026-03-05-042
   ```
   
   Or if skipped:
   ```
   Memory operation cancelled. No changes made.
   ```
   ```

2. **Create skill implementation** (`.opencode/skills/skill-remember/SKILL.md`)
   ```yaml
   ---
   name: skill-remember
   description: Add a memory to the vault with checkbox-based multi-select confirmation
   allowed-tools: Task, Bash, Edit, Read, Write, Grep, AskUserQuestion
   ---
   
   # Remember Skill
   
   Direct execution skill for adding memories to the vault using checkbox-based interactive confirmation (similar to /learn command pattern).
   
   <context>
     <system_context>OpenCode memory management with interactive multi-select.</system_context>
     <task_context>Add text or file content as memory entry with user-guided actions.</task_context>
   </context>
   
   <role>Direct execution skill for memory creation with checkbox-based confirmation.</role>
   
   <task>Parse input, generate memory entry, present checkbox options, execute selected actions.</task>
   
   <execution>
     <stage id="1" name="ParseInput">
       <action>Determine if input is file path or text</action>
       <action>Read file if path exists, otherwise use text directly</action>
     </stage>
     <stage id="2" name="GenerateID">
       <action>Scan 10-Memories/ for existing IDs</action>
       <action>Generate next sequence number for today</action>
     </stage>
     <stage id="3" name="CreateEntry">
       <action>Load template from 30-Templates/memory-template.md</action>
       <action>Fill template placeholders with metadata</action>
     </stage>
     <stage id="4" name="FindSimilar">
       <action>Search existing memories for similar content</action>
       <action>Extract top 3 similar memory IDs and titles</action>
     </stage>
     <stage id="5" name="InteractiveConfirm">
       <action>Show preview with metadata</action>
       <action>Present checkbox options using AskUserQuestion with multiSelect</action>
       <action>Allow multiple selections: add-new, update-existing, edit-content, skip</action>
     </stage>
     <stage id="6" name="ExecuteActions">
       <action>If "add-new" selected: Write memory file to 10-Memories/</action>
       <action>If "update-existing" selected: Append to selected existing memory</action>
       <action>If "edit-content" selected: Allow content modification before save</action>
       <action>Update index.md with new link(s)</action>
       <action>Commit changes with descriptive message</action>
     </stage>
     <stage id="7" name="Report">
       <action>Return success message with list of completed actions</action>
       <action>Report memory IDs created/updated</action>
     </stage>
   </execution>
   ```

3. **Implement ID generation logic**
   - Scan `.opencode/memory/10-Memories/` for files matching `MEM-YYYY-MM-DD-*.md`
   - Extract sequence numbers for today's date
   - Generate next number (001, 002, etc.)
   - Format: `MEM-2026-03-06-001`

4. **Implement template processing**
   - Read template file
   - Replace placeholders:
     - `{{date}}` → current date
     - `{{sequence}}` → sequence number
     - `{{title}}` → extracted title
     - `{{tags}}` → empty or extracted tags
     - `{{source}}` → source description
     - `{{content}}` → full content

5. **Implement similar memory search** (NEW in v002)
   - Use MCP tool: `search_notes`
   - Query: Extract keywords from title/content
   - Limit: 3 results
   - Extract: ID, title, similarity score

6. **Implement checkbox-based interactive confirmation** (REVISED in v002)
   - Use AskUserQuestion with `multiSelect: true`
   - Present options:
     ```json
     {
       "question": "What would you like to do with this memory?",
       "options": [
         {"label": "Add as new memory", "value": "add_new"},
         {"label": "Update existing similar memory", "value": "update_existing"},
         {"label": "Edit content before saving", "value": "edit_content"},
         {"label": "Skip - don't save", "value": "skip"}
       ],
       "multiple": true
     }
     ```
   - Handle multiple selections:
     - If only "skip" selected → Cancel operation
     - If "edit_content" + others → Edit first, then execute others
     - If "update_existing" → Show sub-menu to select which memory
     - If "add_new" + "update_existing" → Do both (merge scenario)

7. **Implement file writing with action support** (ENHANCED in v002)
   - **Add new**: Create filename: `MEM-YYYY-MM-DD-NNN-slugified-title.md`
   - **Update existing**: 
     - Read existing file
     - Append new content under "## Update History" section
     - Add timestamp metadata
   - **Edit content**:
     - Present content in editable format
     - Allow modifications
     - Use modified content for subsequent actions

8. **Update index.md dynamically** (ENHANCED in v002)
   - For new memories: Append link to Recent Memories section
   - For updated memories: Update timestamp reference
   - Maintain proper markdown list formatting

**Verification** (Updated for v002):
- [ ] Can add text memory: `/remember "test content"`
- [ ] Can add file memory: `/remember /path/to/file.md`
- [ ] ID auto-increments correctly
- [ ] Checkbox confirmation displays with 4 options
- [ ] Can select single option (add/update/edit/skip)
- [ ] Can select multiple options (add + update)
- [ ] Edit content option opens content for modification
- [ ] Update existing shows list of similar memories
- [ ] Skip option cancels without creating files
- [ ] File written to correct location when confirmed
- [ ] Index.md updated with new link
- [ ] Git commit created with descriptive message
- [ ] Success message shows all completed actions

---

### Phase 3: MCP Server Integration and --remember Flag

**Status**: [NOT STARTED]  
**Estimated effort**: 2-3 hours  
**Last Updated**: 2026-03-06

**Objectives**:
1. Document MCP server setup (obsidian-cli-rest)
2. Implement memory search via MCP
3. Add --remember flag to /research command
4. Integrate memory results into research workflow
5. Test end-to-end flow

**Files to Create**:
- `.opencode/docs/mcp-setup.md` - Detailed MCP configuration

**Files to Modify**:
- `.opencode/commands/research.md` - Add --remember flag handling
- `.opencode/memory/.obsidian/plugins/obsidian-cli-rest/config.json` - MCP config template

**Steps**:

1. **Create MCP setup documentation** (`.opencode/docs/mcp-setup.md`)
   ```markdown
   # MCP Server Setup for Memory Vault
   
   ## Prerequisites
   - Obsidian desktop app installed
   - `.opencode/memory/` vault created
   
   ## Installation
   
   1. Open Obsidian
   2. Open `.opencode/memory/` as vault
   3. Settings > Community Plugins > Browse
   4. Search: "Obsidian CLI REST"
   5. Install and Enable
   6. Note the API key from plugin settings
   
   ## Configuration
   
   Add to your Claude Code MCP settings:
   
   ```json
   {
     "mcpServers": {
       "obsidian-memory": {
         "command": "npx",
         "args": ["-y", "@dsebastien/obsidian-cli-rest-mcp@latest"],
         "env": {
           "OBSIDIAN_API_KEY": "your-api-key-here",
           "OBSIDIAN_PORT": "27124"
         }
       }
     }
   }
   ```
   
   ## Testing
   
   Test the connection:
   ```bash
   curl -H "Authorization: Bearer YOUR_API_KEY" \
     http://127.0.0.1:27124/vault/
   ```
   
   ## Troubleshooting
   - Port conflicts: Change port in plugin settings
   - API key issues: Regenerate key in Obsidian
   - Connection refused: Ensure Obsidian is running
   ```

2. **Create MCP config template** (`.opencode/memory/.obsidian/plugins/obsidian-cli-rest/config.json`)
   ```json
   {
     "port": 27124,
     "host": "127.0.0.1",
     "authentication": {
       "type": "bearer"
     },
     "commands": {
       "enabled": ["*"]
     }
   }
   ```

3. **Modify /research command** (`.opencode/commands/research.md`)
   
   Add to Parse Input section:
   ```markdown
   ### Flag Detection
   
   Detect `--remember` flag in arguments:
   - Check if any argument equals "--remember"
   - Remove flag from arguments before processing
   - Set flag: `use_memory = true`
   ```
   
   Add Memory Search step:
   ```markdown
   ### Step 0: Memory Search (if --remember flag present)
   
   If `use_memory` is true:
   
   1. **Build search query**
      - Extract keywords from task description
      - Add focus prompt keywords if provided
      - Limit to 3-5 most significant terms
   
   2. **Query MCP server**
      ```json
      {
        "tool": "search_notes",
        "params": {
          "query": "extracted keywords",
          "limit": 5
        }
      }
      ```
   
   3. **Process results**
      - If results found: Read full content of top 3 memories
      - If no results: Note "No relevant memories found"
   
   4. **Include in research context**
      - Add "## Prior Knowledge from Memory Vault" section
      - Include memory summaries (truncated to 1000 chars each)
      - List memory IDs for reference
   
   5. **Mark as augmented**
      - Add metadata: "memory_augmented: true"
   ```

4. **Implement MCP search integration**
   - Use MCP tool call: `search_notes`
   - Parameters:
     - `query`: Extracted keywords from task
     - `limit`: 5 (configurable)
     - `folder`: "10-Memories" (optional filter)
   
5. **Implement memory content retrieval**
   - For each relevant result:
     - Use MCP tool: `read_note`
     - Extract frontmatter and content
     - Truncate to 1000 characters
     - Include in research report

6. **Test end-to-end flow**
   - Add test memory: `/remember "neovim lsp configuration best practices"`
     - Use checkbox to confirm adding
   - Run research with flag: `/research OC_136 --remember`
   - Verify:
     - Memory search executed
     - Relevant memory found
     - Memory content included in research context
     - Research report references memory

**Verification**:
- [ ] MCP setup docs are clear and complete
- [ ] Config template is valid JSON
- [ ] --remember flag detected correctly
- [ ] Memory search executes when flag present
- [ ] Relevant memories retrieved via MCP
- [ ] Memory content included in research context
- [ ] Research report shows memory-augmented status
- [ ] Graceful handling if MCP unavailable
- [ ] Graceful handling if no memories found

---

### Phase 4: Integration Testing and Documentation

**Status**: [NOT STARTED]  
**Estimated effort**: 1-2 hours  
**Last Updated**: 2026-03-06

**Objectives**:
1. Test complete workflow end-to-end
2. Verify git integration works correctly
3. Document usage examples
4. Create troubleshooting guide
5. Update main README with memory system info

**Files to Create**:
- `.opencode/docs/remember-usage.md` - Usage examples and tips
- `.opencode/docs/memory-troubleshooting.md` - Common issues and solutions

**Files to Modify**:
- `.opencode/README.md` - Add memory system section

**Steps**:

1. **End-to-end testing**
   - Test 1: Add text memory with checkbox confirmation, verify file created
   - Test 2: Add file memory, verify content preserved
   - Test 3: Update existing memory via checkbox selection, verify merge
   - Test 4: Skip memory via checkbox, verify no file created
   - Test 5: Run research with --remember, verify memory search
   - Test 6: Add multiple memories, verify index updates
   - Test 7: Git workflow - commit, push, verify

2. **Create usage documentation** (`.opencode/docs/remember-usage.md`)
   ```markdown
   # /remember Command Usage Guide
   
   ## Basic Usage
   
   ### Adding Text Memories
   ```
   /remember "Your text content here"
   ```
   
   You will see a checkbox dialog with options:
   - [ ] Add as new memory
   - [ ] Update existing similar memory
   - [ ] Edit content before saving
   - [ ] Skip - don't save
   
   ### Adding File Memories
   ```
   /remember /path/to/file.md
   ```
   
   ### Checkbox Options Explained
   
   **Add as new memory**: Creates a new memory file in 10-Memories/
   
   **Update existing**: If similar memories exist, appends content to selected memory
   
   **Edit content**: Opens content in editor before saving/updating
   
   **Skip**: Cancels the operation without making changes
   
   ### Multiple Selection Examples
   
   You can select multiple options:
   - Select "Add as new" AND "Update existing" to merge content
   - Select "Edit content" AND "Add as new" to modify before creating
   
   ## Memory-Augmented Research
   
   ### Using --remember Flag
   ```
   /research OC_136 --remember
   /research OC_136 "focus prompt" --remember
   ```
   
   ## Best Practices
   - Use descriptive first lines for better titles
   - Review similar memories before adding duplicates
   - Use "Update existing" for related content instead of creating many small memories
   - Review index.md regularly for navigation
   - Commit memories to git for version history
   
   ## Examples
   
   ### Example 1: Simple Add
   ```
   /remember "Use vim.keymap.set with silent=true for silent mappings"
   ```
   Select: [x] Add as new memory
   Result: New memory file created
   
   ### Example 2: Update Existing
   ```
   /remember "Additional keymap tips: use buffer=true for buffer-local"
   ```
   Select: [x] Update existing similar memory
   Choose: "vim-keymap-configuration.md"
   Result: Content appended to existing memory
   
   ### Example 3: Edit Before Save
   ```
   /remember /tmp/draft.md
   ```
   Select: [x] Edit content before saving
   (Edit in buffer, add formatting)
   Then select: [x] Add as new memory
   Result: Edited content saved as new memory
   ```

3. **Create troubleshooting guide** (`.opencode/docs/memory-troubleshooting.md`)
   ```markdown
   # Memory System Troubleshooting
   
   ## MCP Server Not Connecting
   - Check Obsidian is running
   - Verify API key in settings
   - Check port 27124 is available
   
   ## Checkbox Confirmation Not Appearing
   - Ensure skill-remember is properly configured
   - Check AskUserQuestion tool is available
   - Verify no conflicting input
   
   ## Memories Not Found in Research
   - Verify --remember flag used
   - Check memory has relevant keywords
   - Try different search terms
   
   ## Similar Memory Detection Not Working
   - MCP server must be running for search
   - Check if memories have proper titles
   - Try shorter, more specific queries
   
   ## Git Conflicts
   - Pull before adding memories
   - Resolve conflicts in index.md
   
   ## Obsidian Not Recognizing Vault
   - Ensure .obsidian/ directory exists
   - Check folder permissions
   ```

4. **Update main README** (`.opencode/README.md`)
   - Add "Memory System" section
   - Link to /remember command
   - Brief description of vault
   - Link to setup documentation
   - Mention checkbox-based confirmation (like /learn)

5. **Verify git integration**
   - Confirm .gitignore excludes .obsidian/
   - Test: Add memory with checkbox, commit, push
   - Test: Clone repo, verify vault structure preserved
   - Test: Merge conflicts in index.md

**Verification**:
- [ ] All 7 end-to-end tests pass
- [ ] Usage docs explain checkbox pattern clearly
- [ ] Troubleshooting covers common issues
- [ ] README updated with memory section
- [ ] Git workflow works correctly
- [ ] Documentation links work

---

## Dependencies

- **Obsidian Desktop**: Required for MCP server (free, available for all platforms)
- **obsidian-cli-rest plugin**: Community plugin (free)
- **Git**: For version control of memories
- **npx/npm**: For MCP server execution

**Optional**:
- **Obsidian Sync**: For mobile access (paid, optional)
- **Git sync**: Free alternative for mobile

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| MCP server not available | Medium | High | Graceful degradation - skip memory search, proceed with research |
| User doesn't have Obsidian | Low | High | Document that Obsidian is required for full features; direct file access still works |
| Vault grows too large | Low | Medium | Phase 1 doesn't auto-archive; user can manually organize; document best practices |
| Git conflicts in index.md | Medium | Low | Instructions for conflict resolution; index.md is simple list, easy to merge |
| Mobile access issues | Medium | Low | Document sync options; provide Git-based sync instructions |
| Performance degradation | Low | Medium | Monitor vault size; document when to consider Phase 2+ optimization |
| Checkbox UI confusion | Low | Low | Clear documentation of multi-select behavior; examples in usage guide |

---

## Success Criteria

- [ ] Vault structure created and functional
- [ ] `/remember` command adds memories with checkbox-based confirmation (like /learn)
- [ ] Checkbox options work: add-new, update-existing, edit-content, skip
- [ ] Multiple selection supported (can add AND update in one flow)
- [ ] Similar memory detection works via MCP
- [ ] Memories stored as valid Markdown with YAML frontmatter
- [ ] `index.md` automatically updated with new memories
- [ ] `--remember` flag triggers memory search before research
- [ ] MCP server integration works for search and retrieval
- [ ] Documentation complete and clear
- [ ] Git workflow functional
- [ ] End-to-end tests pass

---

## Future Phases (Not in Scope for Phase 1)

These features are identified in research but intentionally excluded from Phase 1 to maintain simplicity:

### Phase 2: Enhanced Features (Future)
- Auto-tag extraction from content
- Content analysis for better metadata
- Duplicate detection with automatic merging
- Advanced checkbox workflows (approval chains)

### Phase 3: Advanced Lookup (Future)
- Hybrid indexing (BM25 + vectors)
- Custom SQLite index for large vaults
- Semantic search
- Automatic relevance ranking

### Phase 4: Organization (Future)
- PARA method integration
- Automatic archiving
- Review date reminders
- Memory freshness scoring

### Phase 5: Integration (Future)
- Automatic research augmentation in /remember
- Memory suggestions based on context
- Cross-reference detection
- Graph visualization support

**Note**: The simplified Phase 1 approach uses MCP's built-in search instead of custom indexing. This is sufficient for vaults under 1,000 memories and avoids complexity. Transition to Phase 3+ approach if vault grows beyond that size or search performance becomes an issue.

---

## Implementation Notes

### Direct Execution Pattern

Following research-002.md findings, this implementation uses direct execution pattern (like skill-learn) rather than thin wrapper + agent delegation (which was reverted in OC_135). This means:

- Skills do NOT use `context: fork`
- Skills do NOT have `agent:` field
- All logic implemented directly in skill files
- No delegation to non-existent agents

### Checkbox Pattern (Similar to /learn)

The interactive confirmation uses the same checkbox multi-select pattern as the `/learn` command:

1. **AskUserQuestion with multiSelect**: Presents multiple options as checkboxes
2. **User can select multiple**: Not limited to single choice
3. **Context-aware options**: Shows similar memories if they exist
4. **Action-based workflow**: Each selection triggers specific actions
5. **Comprehensive reporting**: Shows all actions taken, not just "yes/no"

**Example workflow**:
```
1. User: /remember "new neovim tip"
2. System: Generates memory preview + finds similar memories
3. System: Shows checkbox dialog:
   - [x] Add as new memory
   - [ ] Update existing similar memory
   - [ ] Edit content before saving  
   - [ ] Skip - don't save
4. User selects: Add as new + Update existing
5. System executes both actions
6. System reports: "Added MEM-2026-03-06-001, Updated MEM-2026-03-05-042"
```

### Git Workflow

```bash
# Adding a memory triggers:
1. Write memory file to 10-Memories/
2. Update index.md
3. Git add both files
4. Git commit -m "memory: add MEM-2026-03-06-001"

# User can then:
git push  # to sync with remote
```

**What to ignore**:
- `.opencode/memory/.obsidian/` - Obsidian config (user-specific)
- `.opencode/memory/*.sqlite` - Search indexes (rebuildable)

**What to commit**:
- All `.md` files in memory vault
- Templates and indices
- README and documentation

### MCP Tool Usage

Primary tools used from obsidian-cli-rest MCP server:

1. `search_notes` - Find relevant memories (used for similar memory detection)
2. `read_note` - Retrieve memory content
3. `write_note` - Create new memory (alternative to direct file write)
4. `list_notes` - Enumerate memories (for ID generation)

### Testing Checklist

Before marking Phase complete, verify:

**Phase 1**:
- [ ] Directory structure correct
- [ ] Obsidian opens vault without errors
- [ ] Template has all placeholders

**Phase 2**:
- [ ] Text input works
- [ ] File input works
- [ ] ID generation correct
- [ ] Similar memory search works (requires MCP)
- [ ] Checkbox confirmation displays 4 options
- [ ] Can select multiple options
- [ ] "Add as new" creates file correctly
- [ ] "Update existing" appends to selected file
- [ ] "Edit content" allows modification
- [ ] "Skip" cancels without creating files
- [ ] File written to correct location
- [ ] Index.md updated
- [ ] Git commit created
- [ ] Success message shows all actions

**Phase 3**:
- [ ] MCP docs clear
- [ ] Config template valid
- [ ] --remember flag detected
- [ ] Search executes
- [ ] Results included in research

**Phase 4**:
- [ ] All tests pass
- [ ] Docs explain checkbox pattern
- [ ] Troubleshooting covers UI issues
- [ ] README updated
- [ ] Git workflow verified

---

## References

- **research-001.md**: General memory management patterns and best practices
- **research-002.md**: System state analysis post-OC_135 revert (direct execution pattern)
- **research-003.md**: Obsidian integration advantages, disadvantages, indexing best practices
- **research-004.md**: Simplified design specification (this plan's foundation)
- **/learn command**: Checkbox-based multi-select pattern reference

---

## Next Steps

After plan approval, run `/implement OC_136` to begin Phase 1 implementation.

**Phase 1 can begin immediately** - no blockers or external dependencies required.

**Note on v002 Changes**: The checkbox-based confirmation adds approximately 30 minutes to Phase 2 implementation time compared to v001, but provides significantly better UX and aligns with the established /learn command pattern.
