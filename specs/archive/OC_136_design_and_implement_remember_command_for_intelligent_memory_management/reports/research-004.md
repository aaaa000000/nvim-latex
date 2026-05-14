# Research Report: Task #136 - Simplified Design Focus

**Task**: OC_136 - Design and implement `/remember` command for intelligent memory management  
**Started**: 2026-03-06T00:30:00Z  
**Completed**: 2026-03-06T00:45:00Z  
**Effort**: 1 hour  
**Priority**: High  
**Focus**: Simple-but-effective design using .opencode/memory/ vault with MCP integration and --remember flag  
**Dependencies**: None  
**Sources/Inputs**: 
- Previous research reports (research-001.md, research-002.md, research-003.md)
- Current .opencode/ system structure
- MCP server integration patterns
- Obsidian vault best practices (simplified)
**Artifacts**: 
- `specs/OC_136_design_and_implement_remember_command_for_intelligent_memory_management/reports/research-004.md`
**Standards**: report-format.md

---

## Executive Summary

- **Simplified location**: `.opencode/memory/` (not nested in `context/`) provides cleaner, more accessible vault structure
- **MCP server is the right approach**: obsidian-mcp and obsidian-cli-rest provide clean API for both lookup and storage without complex indexing
- **--remember flag design**: Simple flag that triggers memory scan before web research, using MCP tools to search vault contents
- **Default lookup**: MCP server's built-in search (combining filename, content, and metadata) is superior to manual indexing for simplicity
- **Phase 1 scope**: Create vault structure, simple /remember command, basic MCP integration, --remember flag for /research

---

## Context & Scope

### User's Simplified Requirements

The user wants to start simple with a focused scope:

1. **Location**: `.opencode/memory/` (simpler than `.opencode/context/memory/`)
2. **Obsidian vault**: Standard vault that opens in Obsidian
3. **MCP server**: Use MCP for lookup and storage (not building custom indexing)
4. **--remember flag**: Add to `/research` command to scan memories before web research
5. **Default lookup**: Use Obsidian/MCP compatible system (not building custom search)
6. **Philosophy**: Start simple, get it working, then improve

### What This Research Covers

**In Scope**:
- Simplified vault structure for `.opencode/memory/`
- MCP server selection and integration approach
- --remember flag design for /research
- Simple lookup mechanism using MCP
- Minimal viable implementation recommendations

**Out of Scope**:
- Complex indexing systems (covered in research-003)
- Advanced Obsidian features (graph view, canvas)
- Hybrid search architecture (overkill for simple start)
- Archive strategies (future enhancement)

---

## Findings

### 1. Simplified Vault Location: .opencode/memory/

**Decision**: Move from `.opencode/context/memory/` to `.opencode/memory/`

**Advantages**:
- **Shorter path**: Easier to type, remember, and navigate
- **Top-level visibility**: Memories are first-class citizens alongside skills/, commands/
- **Git-friendly**: Cleaner directory structure in repository root
- **Obsidian-ready**: Can open `.opencode/memory/` directly as vault root
- **MCP-simple**: No nested paths in MCP configuration

**Vault Structure (Simplified)**:

```
.opencode/memory/
├── .obsidian/                    # Obsidian configuration (gitignored)
│   ├── app.json
│   ├── appearance.json
│   ├── core-plugins.json
│   └── plugins/
│       ├── obsidian-local-rest-api/
│       └── templater/
│
├── 00-Inbox/                    # Quick capture (process daily)
│   └── .gitkeep
│
├── 10-Memories/                 # Active memory entries
│   ├── MEM-2026-03-05-001-neovim-lsp.md
│   ├── MEM-2026-03-04-002-git-workflow.md
│   └── ...
│
├── 20-Indices/                  # Navigation and lookup aids
│   ├── index.md                 # Master index with links
│   ├── by-topic.md              # Topic-based MOC
│   └── by-date.md               # Chronological index
│
├── 30-Templates/                # Templates for new memories
│   └── memory-template.md
│
└── README.md                    # Vault documentation
```

**Naming Convention (Simple)**:
- `MEM-YYYY-MM-DD-NNN-descriptive-title.md`
- Example: `MEM-2026-03-05-001-neovim-lsp-configuration.md`

**Frontmatter (Minimal)**:
```yaml
---
id: MEM-2026-03-05-001
title: "Neovim LSP Configuration"
date: 2026-03-05
tags: [neovim, lsp, configuration]
source: "lua/neotex/plugins/lsp.lua"
---
```

### 2. MCP Server Selection

**Best Option: obsidian-cli-rest (Feb 2026)**

**Why this one**:
- **Dual interface**: REST API + MCP server in one
- **Modern**: Launched February 2026, actively maintained
- **Simple**: Localhost HTTP API, standard authentication
- **Complete**: Supports search, read, write, list, commands
- **Claude-ready**: MCP protocol for Claude Code integration

**Alternative: obsidian-local-rest-api**
- **Pros**: Mature (1,793 stars), stable, well-documented
- **Cons**: REST only (no native MCP), requires separate MCP bridge
- **Use if**: You prefer proven stability over newest features

**Installation**:
```bash
# In Obsidian: Settings > Community Plugins > Browse
# Search: "Obsidian CLI REST"
# Install and Enable
# Server starts automatically on http://127.0.0.1:27124
```

**Configuration**:
```json
# .opencode/memory/.obsidian/plugins/obsidian-cli-rest/config.json
{
  "port": 27124,
  "host": "127.0.0.1",
  "authentication": {
    "type": "bearer",
    "token": "your-api-key-here"
  },
  "commands": {
    "enabled": ["*"]
  }
}
```

**MCP Server Configuration**:
```json
# claude_mcp_settings.json or similar
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": ["-y", "@dsebastien/obsidian-cli-rest-mcp@latest"],
      "env": {
        "OBSIDIAN_API_KEY": "your-api-key",
        "OBSIDIAN_PORT": "27124"
      }
    }
  }
}
```

### 3. --remember Flag Design

**Purpose**: Explicitly direct /research to scan memories before conducting web research

**Command Syntax**:
```
/research OC_136 --remember       # Scan memories + web research
/research OC_136 "focus prompt" --remember  # With focus
/research OC_136 --remember "focus prompt"    # Alternative order
```

**Implementation Flow**:

```
User runs: /research OC_136 --remember

1. Parse task number (OC_136)
2. Detect --remember flag
3. If flag present:
   a. Query MCP server for relevant memories
   b. Include memory content in research context
   c. Mark as "memory-augmented research"
4. Proceed with standard research (web + codebase)
5. Synthesize findings including memory insights
```

**MCP Tool Call for Memory Search**:

```json
{
  "tool": "search_notes",
  "params": {
    "query": "neovim lsp configuration",
    "limit": 10,
    "include_content": true
  }
}
```

**Response Processing**:
- Extract relevant memory IDs
- Read full content of top 3-5 memories
- Include in research context as "Prior Knowledge"
- Note: "Based on existing memories MEM-001, MEM-003..."

**Integration in /research Command**:

```markdown
## Parse Input

- First token: task number
- Detect `--remember` flag anywhere in arguments
- Remaining tokens: optional focus prompt

---

## Steps

### 0. Memory Search (if --remember flag)

If `--remember` flag detected:
1. Extract search terms from task description + focus prompt
2. Query MCP server: `search_notes` tool
3. Retrieve top 5 relevant memories
4. Include memory content in research context
5. Mark research as "memory-augmented"

### 1. Look up task
...
```

### 4. Simple Lookup Mechanism

**Approach: Use MCP Server's Built-in Search**

**Why not build custom indexing**:
- **Simplicity**: MCP server handles indexing automatically
- **Speed**: Built-in search is fast enough for moderate vault sizes
- **Maintenance**: No custom code to maintain
- **Compatibility**: Works with Obsidian's native search
- **Future-proof**: MCP server updates improve search

**MCP Search Capabilities**:

1. **Keyword Search**:
   ```json
   {
     "tool": "search_notes",
     "params": {
       "query": "neovim configuration",
       "limit": 10
     }
   }
   ```

2. **Filename Search**:
   ```json
   {
     "tool": "list_notes",
     "params": {
       "pattern": "MEM-*neovim*"
     }
   }
   ```

3. **Tag-based Search**:
   ```json
   {
     "tool": "search_notes",
     "params": {
       "query": "tag:neovim tag:lsp",
       "limit": 10
     }
   }
   ```

**Search Strategy for --remember**:

1. **Extract keywords** from task description
2. **Query MCP** with extracted terms
3. **Rank results** by relevance (MCP returns scored results)
4. **Retrieve top N** (configurable, default 5)
5. **Include in context** for research augmentation

**Fallback Behavior**:
- If MCP server not available: Skip memory search, proceed with warning
- If no memories found: Proceed with standard research, note "No relevant memories"
- If search fails: Log error, proceed without memory augmentation

### 5. /remember Command Design (Simple)

**Core Flow**:

```
User Input (text or file path)
    |
    v
Parse Input
    - Determine type: text vs file path
    - Validate file exists (if path)
    |
    v
Extract Content
    - If text: use directly
    - If file: read content
    |
    v
Generate Memory Entry
    - Create markdown with frontmatter
    - Generate ID: MEM-YYYY-MM-DD-NNN
    - Extract tags from content
    |
    v
Interactive Approval (optional for simple version)
    - Show proposed entry
    - Ask: "Add to memories? (yes/no)"
    |
    v
Write to Vault
    - Save to .opencode/memory/10-Memories/
    - Update index.md
    |
    v
Confirm
    - Report: "Memory MEM-XXX added"
```

**Simple Implementation (Phase 1)**:

```markdown
# Command: /remember

## Usage

```
/remember "text to remember"
/remember /path/to/file.md
```

## Steps

### 1. Parse Input

- If argument is existing file path: read file content
- Otherwise: treat as text content

### 2. Generate Memory Entry

Create markdown file:
- ID: MEM-YYYY-MM-DD-NNN (auto-increment)
- Title: Extracted or provided
- Date: Current date
- Tags: Auto-extracted or empty
- Content: Input content

### 3. Interactive Confirmation

Show user:
- Proposed memory entry (preview)
- Location: .opencode/memory/10-Memories/
- Ask: "Add this memory? (yes/no)"

### 4. Write to Vault

If confirmed:
- Write file to 10-Memories/
- Append link to index.md
- Commit changes

### 5. Report

"Memory MEM-2026-03-05-001 added to vault"
```

### 6. Phase 1 Scope (Minimal Viable)

**Included**:
- [ ] Create `.opencode/memory/` vault structure
- [ ] Create basic templates and index
- [ ] Simple /remember command (text + file input)
- [ ] Basic MCP server setup instructions
- [ ] --remember flag for /research
- [ ] Memory search via MCP (basic keyword)
- [ ] Interactive approval (simple yes/no)

**Excluded (Future Phases)**:
- [ ] Complex indexing (use MCP's built-in)
- [ ] Content analysis / auto-tagging
- [ ] Duplicate detection
- [ ] Research augmentation in /remember
- [ ] Archive management
- [ ] Graph visualization
- [ ] Mobile optimization

---

## Decisions

### Decision 1: Use .opencode/memory/ Location

**Decision**: Use `.opencode/memory/` instead of `.opencode/context/memory/`

**Rationale**:
- Simpler, cleaner path
- Top-level visibility
- Easier MCP configuration
- Direct Obsidian vault opening
- Less cognitive overhead

### Decision 2: MCP Server Over Custom Indexing

**Decision**: Use obsidian-cli-rest MCP server instead of building custom indexing

**Rationale**:
- Simplicity: No custom code to maintain
- Speed to market: Works immediately
- Feature-rich: Search, read, write included
- Compatibility: Works with Obsidian
- Good enough: For moderate vault sizes (<10k files)

### Decision 3: --remember as Explicit Flag

**Decision**: Use explicit `--remember` flag rather than automatic memory scanning

**Rationale**:
- User control: Explicit opt-in
- Performance: Don't scan unless needed
- Clarity: Makes memory usage visible
- Predictability: No hidden behavior
- Simple to implement: Flag detection straightforward

### Decision 4: Simple Interactive Approval

**Decision**: Single yes/no confirmation rather than checkbox selection for Phase 1

**Rationale**:
- Simplicity: Easier to implement
- Speed: Faster workflow
- Phase 1: Get basic flow working
- Future: Can add multi-select later

### Decision 5: No Archive/Organization Strategy (Phase 1)

**Decision**: All memories go to `10-Memories/`, no automatic archiving

**Rationale**:
- Simplicity: Flat structure easiest
- Search handles scale: MCP search works across flat structure
- Manual cleanup: User can organize manually for now
- Future: Add organization features once basic flow works

---

## Recommendations

### 1. Vault Structure (Phase 1)

```
.opencode/
├── memory/                      # NEW: Obsidian vault
│   ├── .obsidian/              # Gitignored Obsidian config
│   │   └── plugins/
│   │       └── obsidian-cli-rest/
│   │
│   ├── 00-Inbox/               # Quick capture
│   ├── 10-Memories/            # Memory entries
│   │   ├── MEM-2026-03-05-001-example.md
│   │   └── ...
│   ├── 20-Indices/             # Navigation
│   │   └── index.md            # Simple list with links
│   ├── 30-Templates/           # Templates
│   │   └── memory-template.md
│   └── README.md               # Vault documentation
│
└── ... (existing .opencode structure)
```

### 2. Memory Template (Simple)

```markdown
---
id: MEM-{{date:YYYY-MM-DD}}-{{sequence}}
title: "{{title}}"
date: {{date:YYYY-MM-DD}}
tags: {{tags}}
source: "{{source}}"
---

# {{title}}

{{content}}

## Connections

<!-- Add links to related memories -->

## Context

<!-- How this relates to other knowledge -->
```

### 3. MCP Setup Instructions

**For User**:

1. Install Obsidian (if not already)
2. Open `.opencode/memory/` as vault
3. Settings > Community Plugins > Browse
4. Search: "Obsidian CLI REST"
5. Install and Enable
6. Copy API key from plugin settings
7. Add MCP config to Claude Code settings

**Configuration File**:

```json
// ~/.config/claude/settings.json or similar
{
  "mcpServers": {
    "obsidian-memory": {
      "command": "npx",
      "args": ["-y", "@dsebastien/obsidian-cli-rest-mcp@latest"],
      "env": {
        "OBSIDIAN_API_KEY": "paste-key-here",
        "OBSIDIAN_PORT": "27124"
      }
    }
  }
}
```

### 4. /remember Command Specification (Simple)

```markdown
---
description: Add a memory to the vault
---

# Command: /remember

## Usage

/remember "text to remember"
/remember /path/to/file.md

## Steps

1. **Parse Input**
   - Check if argument is existing file path
   - If yes: read file content
   - If no: use argument as text content

2. **Generate Memory ID**
   - Format: MEM-YYYY-MM-DD-NNN
   - Date: current date
   - NNN: next available sequence number

3. **Extract Title**
   - First line if text
   - Filename if file
   - Truncate to 50 chars

4. **Create Memory Entry**
   - Apply template
   - Fill frontmatter
   - Include content

5. **Interactive Confirmation**
   - Show preview
   - Ask: "Add to vault? (yes/no)"

6. **Write to Vault**
   - Save to 10-Memories/
   - Update index.md
   - Git commit

7. **Report**
   - "Memory MEM-XXX added"
```

### 5. --remember Flag Specification

```markdown
## Parse Input for /research

1. Extract task number
2. Detect `--remember` flag
3. Extract focus prompt (remaining text)

---

## Memory Search Step (if --remember)

Before web research:

1. **Build search query**
   - Combine: task description + focus prompt
   - Extract keywords (first 3-5 significant terms)

2. **Query MCP**
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
   - If results found: read full content of top 3
   - If no results: note "No relevant memories found"

4. **Include in research**
   - Add "Prior Knowledge from Memory Vault" section
   - Include relevant memory summaries
   - Note memory IDs for reference

5. **Proceed with research**
   - Standard web search + codebase exploration
   - Synthesize with memory content
```

### 6. Testing Strategy (Simple)

**Phase 1 Tests**:

1. **Vault Creation**
   - Create `.opencode/memory/`
   - Verify Obsidian can open it
   - Check MCP server connects

2. **Remember Command**
   - Add text memory
   - Add file memory
   - Verify file created correctly
   - Check index updated

3. **--remember Flag**
   - Run `/research OC_X --remember`
   - Verify memory search executed
   - Check results included in research

4. **MCP Integration**
   - Test search via MCP
   - Test read via MCP
   - Test write via MCP

---

## Risks & Mitigations

### Risk 1: MCP Server Not Available

**Risk**: User doesn't have Obsidian or MCP server running

**Mitigation**:
- **Graceful degradation**: /remember works without MCP (direct file write)
- **--remember skips**: If MCP unavailable, proceed without memory search
- **Clear error messages**: "MCP server not available, proceeding without memory augmentation"
- **Setup documentation**: Clear instructions for enabling MCP

### Risk 2: Vault Growth Without Organization

**Risk**: All memories in flat structure become hard to navigate

**Mitigation**:
- **Search-first**: Rely on MCP search, not manual browsing
- **Index maintenance**: Auto-update index.md with new entries
- **Naming discipline**: Enforce descriptive filenames
- **Future phase**: Add organization features once basics work

### Risk 3: Git Conflicts with Obsidian

**Risk**: Obsidian and git operations conflict

**Mitigation**:
- **Gitignore .obsidian/**: Don't track Obsidian config
- **Atomic commits**: Commit after each memory addition
- **Pull before work**: Instructions to sync before adding memories
- **Conflict resolution**: Document how to handle (keep both, merge)

### Risk 4: Performance at Scale

**Risk**: MCP search slows with many memories

**Mitigation**:
- **Monitor**: Track search performance
- **Threshold**: Document when to optimize (e.g., >1000 memories)
- **Upgrade path**: Document transition to custom indexing if needed
- **Archive strategy**: Manual archiving when vault grows

---

## Appendix

### A. Comparison: MCP Servers

| Server | Type | Pros | Cons | Best For |
|--------|------|------|------|----------|
| **obsidian-cli-rest** | REST + MCP | Modern, dual interface, active | Newer, less proven | **Recommended** |
| **obsidian-local-rest-api** | REST only | Mature, 1.8k stars, stable | No native MCP, needs bridge | Stability preference |
| **obsidian-mcp** | MCP only | Purpose-built, clean | Single purpose | MCP-only setup |

### B. MCP Tool Reference

**Available Tools** (obsidian-cli-rest):

```json
// Search
{
  "tool": "search_notes",
  "params": {
    "query": "search terms",
    "limit": 10
  }
}

// Read
{
  "tool": "read_note",
  "params": {
    "path": "10-Memories/MEM-2026-03-05-001.md"
  }
}

// Write
{
  "tool": "write_note",
  "params": {
    "path": "10-Memories/MEM-2026-03-05-002.md",
    "content": "# Title\n\nContent..."
  }
}

// List
{
  "tool": "list_notes",
  "params": {
    "folder": "10-Memories"
  }
}
```

### C. Simple vs Advanced (Future)

| Feature | Phase 1 (Simple) | Phase 2+ (Advanced) |
|---------|------------------|---------------------|
| **Location** | .opencode/memory/ | Same |
| **Lookup** | MCP built-in search | Custom hybrid index |
| **Approval** | Yes/No | Checkbox multi-select |
| **Analysis** | None | Auto-tag extraction |
| **Deduplication** | None | Similarity detection |
| **Research** | --remember flag | Automatic relevance |
| **Organization** | Flat structure | PARA method |
| **Archive** | Manual | Automatic review dates |

---

## Next Steps

Run `/plan OC_136` to create implementation plan for simplified design:

1. **Phase 1**: Basic vault structure + simple /remember + --remember flag
2. **Phase 2+**: (Future) Advanced features from research-001/003

**Plan should include**:
- Exact file structure for `.opencode/memory/`
- MCP server configuration
- Simple /remember command specification
- --remember flag integration
- Basic templates and index
- Testing strategy

**Focus**: Get basic flow working first, then iterate.
