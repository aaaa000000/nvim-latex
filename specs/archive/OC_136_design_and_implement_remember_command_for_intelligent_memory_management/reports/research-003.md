# Research Report: Task #136 - Obsidian Integration Focus

**Task**: OC_136 - Design and implement `/remember` command for intelligent memory management  
**Started**: 2026-03-06T00:00:00Z  
**Completed**: 2026-03-06T00:15:00Z  
**Effort**: 1.5 hours  
**Priority**: High  
**Focus**: Obsidian integration as memory system - advantages, disadvantages, indexing best practices  
**Dependencies**: None  
**Sources/Inputs**: 
- Web research: Obsidian + AI best practices 2026, Obsidian AI Second Brain guide
- Web research: Obsidian indexing, search performance, large vault optimization
- Web research: Obsidian API integration, REST API, MCP servers
- Web research: Knowledge base indexing best practices, metadata filtering
- Web research: Obsidian vault organization (folders vs flat vs links)
**Artifacts**: 
- `specs/OC_136_design_and_implement_remember_command_for_intelligent_memory_management/reports/research-003.md`
**Standards**: report-format.md

---

## Executive Summary

- **Obsidian as memory vault is highly viable**: Plain Markdown files in `.opencode/context/memory/` can be opened as an Obsidian vault with full feature support
- **Major advantages**: Bidirectional linking, graph view, fast local search, mobile sync, offline-first, AI integration via MCP, no vendor lock-in
- **Key disadvantages**: Requires Obsidian app for full features, larger vaults need optimization, sync setup complexity, mobile editing limitations
- **Indexing strategy recommendation**: Hybrid approach with SQLite index combining BM25 keyword search + vector embeddings + metadata filtering for 23ms retrieval from 16k+ files
- **Best organization**: Flat file structure with naming conventions over deep folders, bidirectional links for connections, MOC (Maps of Content) for navigation
- **Critical success factors**: Maintain separate metadata index, use consistent naming, implement incremental updates, provide both semantic and keyword search

---

## Context & Scope

### User's Specific Requirements

The user wants to explore using Obsidian as the memory system for `/remember` command with these specific concerns:

1. **Obsidian as vault**: `.opencode/context/memory/` files should open as an Obsidian vault
2. **User exploration**: User wants to open and explore the memory files with Obsidian
3. **Indexing concern**: Must carefully maintain an index for all memories for fast lookup
4. **Best practices**: Wants thorough research on indexing and organization approaches

### Research Scope

**In Scope**:
- Advantages of Obsidian integration for AI memory systems
- Disadvantages and limitations to be aware of
- Indexing strategies for fast memory lookup
- Vault organization best practices
- API/integration options for programmatic access

**Out of Scope**:
- General memory management (covered in research-001.md)
- System architecture (covered in research-002.md)
- Implementation details (belongs in planning phase)

---

## Findings

### 1. Obsidian Integration Advantages

#### 1.1 Plain Markdown = Universal Compatibility

**Finding**: Obsidian stores everything as plain Markdown files (.md) in a folder.

**Advantages for AI Memory System**:
- **No vendor lock-in**: Files readable by any tool, editor, or AI system
- **Version control friendly**: Git can track changes, diffs are meaningful
- **Future-proof**: Markdown will be readable in 20 years
- **AI-native**: LLMs can read/write Markdown natively without special parsers
- **Human-readable**: Users can open files in any text editor

**Evidence**:
> "Your notes are plain text files on your computer. When you write in Obsidian, you're creating Markdown files (.md) that live in a folder on your hard drive — not in a cloud database someone else controls, not in a proprietary format. Plain text, readable by any app, on any computer, in any decade."
> — Frank Anaya, "How to Use Obsidian: The Complete Guide" (2026)

#### 1.2 Bidirectional Linking = Knowledge Graph

**Finding**: Obsidian's `[[note name]]` syntax creates automatic backlinks.

**Advantages for AI Memory System**:
- **Discover connections**: See which memories reference each other
- **Emergent structure**: Knowledge organization emerges from connections, not imposed hierarchy
- **Graph view**: Visualize memory relationships and clusters
- **Serendipity**: Find related memories you forgot about

**Evidence**:
> "The linked note then shows you which notes point back to it. This bidirectional awareness — knowing not just where you're going but where you've been referenced — changes how you relate to information. You stop filing and start connecting."
> — Frank Anaya, "Folders vs Links in Obsidian" (2026)

#### 1.3 AI Integration Ecosystem (2026)

**Finding**: Rich ecosystem of AI integration options available in 2026.

**Integration Methods**:

1. **MCP (Model Context Protocol) Servers**:
   - `obsidian-mcp` - Community MCP server for programmatic access
   - `obsidian-notes` - File system access with security-first design
   - `obsidian-cli-rest` - REST API + MCP server (launched Feb 2026)

2. **Local REST API** (Most Popular):
   - `obsidian-local-rest-api` plugin (1,793 stars, 237k+ downloads)
   - Secure HTTPS interface with API key auth
   - CRUD operations on notes, execute commands
   - Localhost-only by default

3. **Copilot Plugin**:
   - Local LLM integration (Ollama, LM Studio)
   - Semantic search, summarization, chat
   - Embedding-based retrieval

**Evidence**:
> "Control your Obsidian vault programmatically. This plugin turns all Obsidian CLI commands into a local HTTP API and MCP server, letting you automate your workflow from scripts, tools, and AI assistants."
> — dsebastien/obsidian-cli-rest repository (Feb 2026)

#### 1.4 Search Performance & Indexing

**Finding**: Obsidian builds search index automatically, with optimization options for large vaults.

**Performance Characteristics**:
- **Startup**: Checks modification times against `.obsidian/cache` index
- **Re-indexing**: Triggered on widespread changes
- **Search**: Instantaneous for most vaults
- **Optimization**: Available for 10,000+ file vaults

**Third-Party Enhancements**:
- **Omnisearch plugin**: Typo-resistant search, previews, relevance ranking
- **Hybrid retrievers**: Combine BM25 + vector search (23ms for 16k+ files)

**Evidence**:
> "A grep through 16,894 markdown files takes 11-66 seconds... A hybrid retriever that fuses both methods returns the right answer in 23 milliseconds (end-to-end, including query embedding) from a single 83 MB SQLite file with zero API calls."
> — Blake Crosley, "Building a Hybrid Retriever for 16,894 Obsidian Files" (Mar 2026)

#### 1.5 Mobile & Sync Options

**Finding**: Multiple sync strategies available for mobile access.

**Sync Methods**:
- **Obsidian Sync**: Official paid service, works seamlessly
- **Git**: Free, version history, works with GitHub/GitLab
- **iCloud**: Built-in for Apple ecosystem
- **Self-hosted**: Nextcloud, WebDAV, etc.

**Mobile Experience**:
- Full vault access offline
- Clean mobile interface with Minimal theme
- Quick capture via mobile-specific shortcuts

**Evidence**:
> "Obsidian works well on a phone for one simple reason: your notes are just local Markdown files in a folder you control. That makes it realistic to keep a personal knowledge system fully usable on a train, on a flight, or in a country where roaming is painful."
> — Alex Rooter, "Obsidian vault setup 2026" (Jan 2026)

---

### 2. Obsidian Integration Disadvantages

#### 2.1 Requires Obsidian App for Full Features

**Limitation**: While Markdown files are universal, advanced features require Obsidian.

**Disadvantages**:
- **Graph view**: Only available in Obsidian app
- **Backlinks panel**: Requires Obsidian UI
- **Plugins**: Most plugins are Obsidian-specific
- **Canvas**: Visual note-taking requires Obsidian

**Mitigation**:
- Core functionality (reading, editing, searching) works in any Markdown editor
- Can use alternative graph visualization tools if needed

#### 2.2 Large Vault Performance Issues

**Limitation**: Vaults beyond 10,000 files experience degradation.

**Issues**:
- **Startup lag**: Index initialization takes time
- **Search slowdown**: Full-text search becomes slower
- **Sync churn**: Large bulk changes trigger lengthy re-indexing
- **Memory usage**: Cache file grows with vault size

**Evidence**:
> "As a vault grows beyond 10,000 files, Obsidian's startup time and search responsiveness can degrade. This is not due to the files themselves, but the index Obsidian builds to navigate them."
> — Obsidian Mastery for Professional Genealogy (2026)

**Mitigation**:
- **Batch operations**: Run large changes, then restart once for single re-index
- **Archive strategy**: Move old files to separate vault
- **Hybrid indexing**: Use external SQLite index for large vaults
- **Attachment management**: Store large files outside vault

#### 2.3 Sync Complexity

**Limitation**: Free sync requires technical setup.

**Issues**:
- **Git learning curve**: Users must understand Git basics
- **Conflict resolution**: File conflicts can occur with multiple devices
- **Mobile limitations**: iOS has more restrictions than Android
- **Initial setup**: More complex than cloud-based solutions

**Evidence**:
> "On iPhone, keeping the vault in local app storage is the most predictable for offline work; using iCloud can be workable, but it has known issues with Obsidian."
> — Alex Rooter, "Obsidian vault setup 2026"

#### 2.4 Mobile Editing Limitations

**Limitation**: Mobile experience is good but not perfect.

**Issues**:
- **Screen size**: Complex layouts difficult on small screens
- **Plugin limitations**: Not all plugins work well on mobile
- **Input methods**: Typing long content on mobile is slower
- **File management**: Renaming/moving files can cause sync issues

**Mitigation**:
- Use mobile primarily for consumption, desktop for creation
- Implement quick capture workflow (inbox → process later)
- Use voice input or quick notes apps that sync to vault

#### 2.5 No Native Collaborative Features

**Limitation**: Obsidian is designed for personal use.

**Issues**:
- **No real-time collaboration**: Unlike Notion or Google Docs
- **Sharing friction**: Requires export or sync setup
- **Permission management**: No built-in access controls

**Mitigation**:
- Use Git for version control with collaborators
- Publish specific notes via Obsidian Publish plugin
- Accept that AI memory system is primarily personal

---

### 3. Indexing Best Practices for Fast Lookup

#### 3.1 Hybrid Search Architecture (Recommended)

**Finding**: Best performance comes from combining multiple search methods.

**Architecture** (from Blake Crosley's 16k+ file vault):

```
┌─────────────────────────────────────────────────────────────┐
│                  Hybrid Retriever                             │
├─────────────────┬─────────────────┬─────────────────────────┤
│   BM25 (FTS5)   │  Vector Search  │    Metadata Filter      │
│   Keywords      │  Embeddings     │    Properties           │
├─────────────────┴─────────────────┴─────────────────────────┤
│              Reciprocal Rank Fusion (RRF)                     │
│              Combine scores from all indexes                  │
└─────────────────────────────────────────────────────────────┘
                           │
                           v
                    Ranked Results
```

**Performance**:
- **16,894 files** → **49,746 chunks** → **83 MB SQLite**
- **Query time**: 23ms end-to-end
- **Re-index**: 4 minutes full, <10 seconds incremental

**Components**:
1. **BM25 (FTS5)**: Exact keyword matching, identifier search
2. **Vector embeddings**: Semantic similarity (Model2Vec)
3. **Reciprocal Rank Fusion (RRF)**: Combine scores mathematically

**Evidence**:
> "The retriever combines FTS5 BM25 keyword search with Model2Vec vector similarity search, fused via Reciprocal Rank Fusion (RRF) into a single ranked list."
> — Blake Crosley (Mar 2026)

#### 3.2 Metadata Schema for AI Memory

**Finding**: Rich metadata enables better filtering and ranking.

**Recommended Metadata Schema**:

```json
{
  "id": "MEM-20260305-001",
  "title": "Neovim LSP Configuration",
  "created": "2026-03-05T10:00:00Z",
  "modified": "2026-03-05T10:00:00Z",
  "source": "lua/neotex/plugins/lsp.lua",
  "source_type": "file",
  "categories": ["neovim", "lsp", "configuration"],
  "tags": ["neovim", "lspconfig", "plugins"],
  "confidence": 0.95,
  "importance": "high",
  "status": "active",
  "related": ["MEM-20260304-012", "MEM-20260303-008"],
  "review_date": "2026-06-05"
}
```

**Metadata Types**:
- **Temporal**: created, modified, review_date
- **Categorical**: categories, tags, status
- **Quality**: confidence, importance, reliability
- **Relational**: related, source, backlinks

**Evidence**:
> "Use metadata and weighting signals (e.g., freshness, reliability, document type, versioning, deprecation flags) to optimise relevance."
> — Microsoft Q&A: "Best practices for indexing and ranking knowledge base content" (Jan 2026)

#### 3.3 Index Maintenance Strategy

**Finding**: Indexes require ongoing maintenance for optimal performance.

**Index Lifecycle**:

```
┌─────────────────────────────────────────────────────────────┐
│                  Index Lifecycle                              │
├──────────────┬──────────────┬──────────────┬─────────────────┤
│   Create     │   Populate   │   Monitor    │    Optimize     │
├──────────────┼──────────────┼──────────────┼─────────────────┤
│ Define schema│ Bulk index   │ Query times  │ Rebuild if      │
│ Set weights  │ existing     │ Index size   │ degraded        │
│ Aliases for  │ content      │ Hit rates    │ Version control │
│ zero-downtime│              │              │ schema updates  │
└──────────────┴──────────────┴──────────────┴─────────────────┘
```

**Best Practices**:
1. **Incremental updates**: Add new memories without full rebuild
2. **Versioned schemas**: Support schema evolution
3. **Index aliasing**: Enable zero-downtime updates
4. **Regular profiling**: Monitor query performance
5. **Cleanup jobs**: Remove or archive stale entries

**Evidence**:
> "Proper management of these indexes is essential for optimal performance, scalability, and resource utilization. This guide outlines best practices for managing indexes throughout their lifecycle."
> — Redis Query Engine documentation (Jan 2026)

#### 3.4 Chunking Strategy

**Finding**: Large memories should be chunked for better retrieval.

**Chunking Approaches**:

| Strategy | When to Use | Example |
|----------|-------------|---------|
| **By section** | Well-structured content | Headers as chunk boundaries |
| **By paragraph** | Narrative content | Natural paragraph breaks |
| **Fixed size** | Uniform content | 512 tokens per chunk |
| **Semantic** | Mixed content | Complete thoughts/ideas |

**Obsidian-Specific**:
- Use natural Markdown boundaries (headers, horizontal rules)
- Preserve YAML frontmatter in first chunk only
- Maintain bidirectional links across chunks
- Store chunk metadata (parent file, chunk number, total chunks)

**Evidence**:
> "49,746 chunks from 16,894 files in 83 MB. Full reindex takes four minutes. Incremental updates run in under ten seconds."
> — Blake Crosley (Mar 2026)

---

### 4. Vault Organization Best Practices

#### 4.1 Flat vs Folder Structure

**Finding**: Flat structure with naming conventions outperforms deep folders.

**Comparison**:

| Aspect | Deep Folders | Flat + Naming |
|--------|--------------|---------------|
| **Discovery** | Must know folder path | Search by name/tag |
| **Flexibility** | Rigid hierarchy | Fluid organization |
| **Moving files** | Breaks bookmarks | Just rename |
| **Linking** | Cross-folder links complex | Links work naturally |
| **Scaling** | Deep nesting confusing | Scales to thousands |
| **Cognitive load** | High (remember structure) | Low (search everything) |

**Evidence**:
> "Everything lives flat with naming conventions instead of folders. I don't use the file explorer at all. The quick switcher (Cmd+O) is how I navigate."
> — Ronald Suwandi, "The Obsidian setup behind the system" (Mar 2026)

**Recommended Naming Convention**:
```
YYYY-MM-DD-Topic-Descriptor.md
2026-03-05-Neovim-LSP-Setup.md
2026-03-04-Project-Architecture-Decision.md
MEM-20260305-001-Neovim-LSP.md
```

#### 4.2 Maps of Content (MOC) Pattern

**Finding**: MOC files provide curated entry points to knowledge domains.

**MOC Structure**:

```markdown
# MOC: Neovim Configuration

## Overview
Entry point for all Neovim-related knowledge.

## Core Topics
- [[2026-03-05-Neovim-LSP-Setup]]
- [[2026-03-04-Plugin-Loading-Strategy]]
- [[2026-03-03-Keymap-Patterns]]

## Tools
- [[2026-03-02-lazy-nvim-Guide]]
- [[2026-03-01-Treesitter-Configuration]]

## Recent Updates
- Added: [[2026-03-05-Neovim-LSP-Setup]]
- Modified: [[2026-03-04-Plugin-Loading-Strategy]]

## Backlinks
<< query for all files linking here >>
```

**Benefits**:
- **Curated navigation**: Human-organized overviews
- **Entry points**: Multiple ways into same knowledge
- **Living documents**: MOCs updated as knowledge grows
- **Context preservation**: Shows relationships and structure

#### 4.3 PARA Method Integration

**Finding**: PARA (Projects, Areas, Resources, Archives) method works well with Obsidian.

**PARA Structure**:

```
00-Inbox/           # Quick capture (process daily)
10-Projects/        # Active projects with deadlines
20-Areas/          # Ongoing responsibilities
30-Resources/      # Reference material
40-Archives/       # Completed/inactive items
```

**Benefits for AI Memory**:
- **Clear status**: Easy to identify active vs archived memories
- **Process workflow**: Inbox → organized structure
- **Archive strategy**: Move old memories without deletion
- **Priority indication**: Projects = high priority

**Evidence**:
> "A practical mobile structure is: 00-Inbox (quick capture), 10-Projects, 20-Areas (ongoing responsibilities), 30-Reference, 40-Archive, and an Attachments folder."
> — Alex Rooter, "Obsidian vault setup 2026"

#### 4.4 Tag vs Link Usage

**Finding**: Tags and links serve different purposes; use both strategically.

**Usage Guidelines**:

| Use | Tags | Links |
|-----|------|-------|
| **Status** | #active #archived | N/A |
| **Topic** | #neovim #lsp | [[Neovim MOC]] |
| **Priority** | #high #low | N/A |
| **Relationships** | N/A | [[Related Note]] |
| **Contexts** | #work #personal | [[Project Context]] |
| **Queries** | Easy to search | Requires graph traversal |

**Best Practice**:
- Use **links** for relationships between specific notes
- Use **tags** for broad categorization and filtering
- Use **both** for maximum flexibility

**Evidence**:
> "Tags are entry points. Links are connections. Folders are buckets. Use tags to find starting points, links to explore, folders only when necessary."
> — Obsidian Forum consensus

---

### 5. API Integration Options

#### 5.1 Local REST API (Recommended)

**Plugin**: `obsidian-local-rest-api` by Adam Coddington

**Features**:
- **Secure HTTPS**: Localhost-only, API key authentication
- **CRUD operations**: Create, read, update, delete notes
- **PATCH support**: Insert content into specific sections
- **Command execution**: Trigger Obsidian commands
- **Periodic notes**: Create/fetch daily/weekly/monthly notes
- **Active development**: Latest release 3.4.4 (Feb 2026)

**Performance**:
- HTTP interface (fast)
- No external dependencies
- Works with any HTTP client

**Use Case**: Best for local automation, AI assistants, browser extensions

#### 5.2 MCP (Model Context Protocol) Servers

**New in 2026**: Multiple MCP server options for Obsidian.

**Options**:

1. **obsidian-cli-rest** (Feb 2026):
   - REST API + MCP server combo
   - TypeScript implementation
   - 1 star, actively maintained
   - Homepage: developassion.gitbook.io

2. **obsidian-mcp**:
   - Community server by Steven Stavrakis
   - Tools for searching, reading, writing, organizing
   - Direct file system access option
   - Security-first design

3. **obsidian-notes**:
   - Direct file system access (no Obsidian app required)
   - Advanced search including MOC discovery
   - obsidian.nvim support
   - No Obsidian app required

**MCP Benefits**:
- **Standardized protocol**: Works with Claude, ChatGPT, other AI assistants
- **Tool exposure**: AI can use Obsidian as a tool
- **Context management**: Automatic context window management
- **Security**: Local-only, user-controlled

#### 5.3 Direct File System Access

**Simplest Option**: Read/write Markdown files directly.

**Advantages**:
- No plugins required
- Works with any programming language
- Zero setup for AI system
- Full control over file structure

**Considerations**:
- No Obsidian-specific features (graph view, backlinks panel)
- Must respect Obsidian's conventions (frontmatter, links)
- File locking not enforced (coordinate access)

**Best For**: AI systems that primarily create/manage memories programmatically

---

## Decisions

### Decision 1: Adopt Obsidian as Memory Interface

**Decision**: Use `.opencode/context/memory/` as an Obsidian-compatible vault.

**Rationale**:
- Plain Markdown files work universally
- Obsidian provides excellent exploration interface
- Bidirectional linking enables knowledge graph
- 2026 AI integration ecosystem is mature (MCP, REST API)
- No vendor lock-in - files work in any tool

### Decision 2: Hybrid Indexing Strategy

**Decision**: Implement hybrid index (BM25 + Vector + Metadata) in SQLite for fast lookup.

**Rationale**:
- 23ms retrieval demonstrated at 16k+ file scale
- Combines exact matching (BM25) with semantic search (vectors)
- Metadata filtering enables precise queries
- SQLite is fast, portable, requires no server
- Incremental updates support real-time addition

### Decision 3: Flat Structure with MOCs

**Decision**: Use flat file structure with naming conventions, organize via MOC (Maps of Content) files.

**Rationale**:
- Flat structure scales better than folders
- Naming conventions enable fast search
- MOCs provide curated navigation without rigid hierarchy
- Links work naturally across all files
- Easy to implement and maintain

### Decision 4: Dual Access Strategy

**Decision**: Support both direct file system access (for AI) and Obsidian app (for user exploration).

**Rationale**:
- AI system can read/write directly (fast, no dependencies)
- Users can open vault in Obsidian (rich exploration interface)
- Best of both worlds: programmatic + human-friendly
- No single point of failure

---

## Recommendations

### 1. Memory Vault Structure

**Recommended Structure**:

```
.opencode/context/memory/
├── .obsidian/                    # Obsidian config (gitignored)
│   ├── app.json
│   ├── appearance.json
│   └── plugins/
│
├── index.md                      # Master index (MOC)
├── MEM-YYYY-INDEX.md            # Yearly index MOCs
│
├── 00-Inbox/                    # Quick capture (process daily)
│   └── .gitkeep
│
├── 10-Projects/                 # Active AI projects/contexts
│   ├── proj-neovim-config.md
│   └── proj-obsidian-integration.md
│
├── 20-Areas/                   # Ongoing responsibilities
│   ├── area-workflow-commands.md
│   └── area-memory-management.md
│
├── 30-Resources/               # Reference knowledge
│   ├── res-neovim-lua-patterns.md
│   └── res-git-workflows.md
│
├── 40-Archives/              # Completed/inactive
│   └── .gitkeep
│
└── metadata/
    └── index.sqlite           # Hybrid search index
```

**Naming Convention**:
- **MOCs**: `MOC-Topic-Name.md`
- **Memories**: `MEM-YYYYMMDD-NNN-Title.md`
- **Indices**: `MEM-YYYY-INDEX.md` or `index.md`
- **Projects**: `proj-Project-Name.md`
- **Areas**: `area-Area-Name.md`
- **Resources**: `res-Resource-Name.md`

### 2. Metadata Schema

**Required Frontmatter**:

```yaml
---
id: MEM-20260305-001
title: "Neovim LSP Configuration"
created: 2026-03-05T10:00:00Z
modified: 2026-03-05T10:00:00Z
source: "lua/neotex/plugins/lsp.lua"
source_type: "file"
categories: ["neovim", "lsp"]
tags: ["neovim", "lspconfig", "plugins"]
confidence: 0.95
importance: "high"
status: "active"
related: ["MEM-20260304-012"]
review_date: "2026-06-05"
---
```

### 3. Index Implementation

**SQLite Schema**:

```sql
-- Memory entries table
CREATE TABLE memories (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    file_path TEXT NOT NULL,
    created TEXT NOT NULL,
    modified TEXT NOT NULL,
    source TEXT,
    source_type TEXT,
    confidence REAL,
    importance TEXT,
    status TEXT,
    content_hash TEXT,
    chunk_count INTEGER DEFAULT 1
);

-- Full-text search (BM25)
CREATE VIRTUAL TABLE memories_fts USING fts5(
    title, content,
    content='memories',
    content_rowid='rowid'
);

-- Vector embeddings
CREATE TABLE memory_embeddings (
    memory_id TEXT,
    chunk_index INTEGER,
    embedding BLOB,
    FOREIGN KEY (memory_id) REFERENCES memories(id)
);

-- Tags
CREATE TABLE tags (
    memory_id TEXT,
    tag TEXT,
    FOREIGN KEY (memory_id) REFERENCES memories(id)
);

-- Relationships
CREATE TABLE relationships (
    from_id TEXT,
    to_id TEXT,
    relationship_type TEXT,
    FOREIGN KEY (from_id) REFERENCES memories(id),
    FOREIGN KEY (to_id) REFERENCES memories(id)
);
```

### 4. User Workflow

**For User Exploration**:

1. **Open vault**: User opens `.opencode/context/memory/` in Obsidian
2. **Start at index**: `index.md` provides overview and navigation
3. **Explore MOCs**: Click through Maps of Content for topical entry points
4. **Follow links**: Bidirectional links show connections
5. **Search**: Use Obsidian search or Omnisearch for fast lookup
6. **Graph view**: Visualize knowledge relationships

**For AI Integration**:

1. **Direct file access**: AI reads/writes Markdown directly
2. **SQLite index**: AI queries hybrid index for fast retrieval
3. **REST API**: Optional integration via local-rest-api plugin
4. **MCP**: AI uses Model Context Protocol for structured access

---

## Risks & Mitigations

### Risk 1: Vault Performance Degradation

**Risk**: As memory vault grows, Obsidian performance degrades.

**Mitigation**:
- **Archive strategy**: Move old memories to `40-Archives/` after review date
- **Hybrid index**: Use SQLite for searches, not Obsidian's built-in
- **Chunking**: Large memories split into chunks
- **Bulk operations**: Batch changes, restart once

### Risk 2: Index Synchronization Issues

**Risk**: SQLite index gets out of sync with Markdown files.

**Mitigation**:
- **Content hashing**: Detect modifications via hash
- **Incremental updates**: Update only changed files
- **Periodic rebuild**: Full rebuild monthly
- **Consistency checks**: Verify index matches files

### Risk 3: User Overwhelmed by Structure

**Risk**: Complex vault structure intimidates users.

**Mitigation**:
- **Start simple**: Begin with flat structure, add organization gradually
- **Good defaults**: Sensible naming conventions
- **Documentation**: Clear README in vault
- **Templates**: Pre-made templates for new memories

### Risk 4: Sync Conflicts

**Risk**: Multiple devices editing same files cause conflicts.

**Mitigation**:
- **Git-based sync**: Version control for conflict resolution
- **Atomic updates**: AI writes files atomically
- **Lock indicators**: YAML frontmatter shows "being edited"
- **Conflict resolution**: AI can help resolve Git conflicts

---

## Appendix

### A. Comparison: Obsidian vs Alternatives

| Feature | Obsidian | Notion | Evernote | Apple Notes |
|---------|----------|--------|----------|-------------|
| **File format** | Markdown | Proprietary | Proprietary | Proprietary |
| **Local storage** | Yes | No | Partial | Partial |
| **AI integration** | Excellent (MCP) | Good | Poor | Poor |
| **Bidirectional links** | Yes | No | No | No |
| **Graph view** | Yes | No | No | No |
| **Offline** | Full | Partial | Partial | Partial |
| **Vendor lock-in** | None | High | High | Medium |
| **Mobile** | Good | Excellent | Good | Excellent |
| **Search** | Good | Good | Good | Basic |
| **API access** | Yes (REST/MCP) | Yes | Limited | No |

### B. 2026 Obsidian AI Ecosystem

**MCP Servers**:
- `obsidian-mcp` - Steven Stavrakis
- `obsidian-notes` - Direct file system
- `obsidian-cli-rest` - REST + MCP (Feb 2026)

**Plugins**:
- `obsidian-local-rest-api` - 1,793 stars, REST interface
- `copilot` - Local LLM integration
- `omnisearch` - Enhanced search
- `templater` - Automation templates
- `dataview` - Query language

**Integrations**:
- Claude Code (via MCP)
- ChatGPT (via MCP)
- Ollama (local LLM)
- LM Studio (local LLM)

### C. Recommended Reading

1. **"Building a Hybrid Retriever for 16,894 Obsidian Files"** - Blake Crosley (Mar 2026)
   - Technical implementation of hybrid search
   - SQLite schema, chunking strategy, performance benchmarks

2. **"Obsidian AI Second Brain: Complete Guide"** - NxCode (Feb 2026)
   - AI integration patterns, MCP setup, practical workflows

3. **"Folders vs Links in Obsidian"** - Frank Anaya (Feb 2026)
   - Organization philosophy, flat vs folder trade-offs

4. **"The Obsidian setup behind the system"** - Ronald Suwandi (Mar 2026)
   - Real-world vault setup, Minimal theme, naming conventions

---

## Next Steps

Run `/plan OC_136` to create an implementation plan that incorporates:

1. **Obsidian-compatible vault structure** (flat + MOCs)
2. **Hybrid indexing system** (SQLite with BM25 + vectors)
3. **Dual access strategy** (direct files + Obsidian app)
4. **Metadata schema** (rich frontmatter for filtering)
5. **Integration options** (direct files as default, REST API as optional)

**Key plan requirements**:
- Must work without Obsidian installed (direct file access)
- Must be enhanced by Obsidian when available (rich exploration)
- Must maintain fast lookup index (<100ms for any query)
- Must scale to 10,000+ memories without degradation
