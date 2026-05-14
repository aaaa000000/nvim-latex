# Research Report: Task #136

**Task**: OC_136 - Design and implement `/remember` command for intelligent memory management
**Started**: 2026-03-05T22:00:00Z
**Completed**: 2026-03-05T23:30:00Z
**Effort**: 3 hours
**Priority**: High
**Dependencies**: None
**Sources/Inputs**: 
- `.opencode/skills/*/SKILL.md` files (skill patterns)
- `.opencode/commands/*.md` files (command patterns)
- `.opencode/context/core/formats/` (format standards)
- `.opencode/context/core/templates/` (agent templates)
- Web research: A-MEM paper, Knox Memory System, Memory Manager Agents research
**Artifacts**: 
- `specs/OC_136_design_and_implement_remember_command_for_intelligent_memory_management/reports/research-001.md`
**Standards**: status-markers.md, report-format.md, skill-structure.md, command-structure.md, agent-template.md

---

## Executive Summary

- **No existing memory system**: The `.opencode/context/memory/` directory does not exist, confirming this is a greenfield feature requiring full design from scratch
- **Established patterns to leverage**: Existing skills (skill-learn, skill-researcher, skill-planner) provide proven templates for content analysis, interactive workflows, and multi-stage execution flows
- **Interactive checkbox workflow precedent**: The `/learn` command demonstrates multi-select user interaction patterns using `AskUserQuestion` with multiSelect capability for presenting and selecting proposed items
- **Three-layer architecture compliance**: The system should follow Command → Skill → Agent pattern with proper delegation, never executing work directly in command files
- **Content analysis approach**: Should combine regex-based extraction with LLM-powered semantic analysis to identify key concepts, following patterns from tag-scanning in skill-learn
- **Memory organization recommendation**: Hierarchical structure with categorized memory files, cross-references, and timestamps following Zettelkasten-inspired linking principles from A-MEM research

---

## Context & Scope

### What is Being Built

The `/remember` command is an intelligent memory management system that transforms ephemeral user inputs (prompts or file paths) into persistent, structured knowledge stored in `.opencode/context/memory/`. Unlike simple note-taking, this system:

1. **Analyzes** input to extract key concepts, patterns, and relationships
2. **Compares** against existing memory to avoid duplication and identify gaps
3. **Researches** external knowledge when beneficial
4. **Proposes** structured additions via interactive checkboxes
5. **Integrates** approved additions naturally into the existing memory structure

### System Context

The opencode system follows a strict three-layer architecture:
- **Layer 1**: Orchestrator (routes to commands)
- **Layer 2**: Commands (parse arguments, delegate to skills)
- **Layer 3**: Skills and Agents (execute work via subagent delegation)

All work must be delegated; direct execution in command or skill files violates system principles.

### Scope Boundaries

**In Scope**:
- Input parsing (text prompts and file paths)
- Content analysis and extraction
- Memory comparison and deduplication
- Research augmentation when needed
- Interactive approval workflow
- Natural memory file integration
- Proper status tracking

**Out of Scope**:
- Direct memory file writes without user approval
- Automatic memory updates without interactive confirmation
- Memory retrieval/search functionality (separate feature)
- Memory expiration/eviction policies (future enhancement)

---

## Findings

### 1. Existing Memory Infrastructure

**Current State**: No memory system exists in `.opencode/context/`.

The context directory contains:
- `/core/` - System-wide standards, formats, and templates
- `/project/` - Project-specific knowledge (neovim, meta, etc.)
- `/index.md` and `/index.json` - Context indexing

**Gap**: There is no `/memory/` subdirectory or equivalent for user-managed knowledge persistence.

**Implication**: This feature requires:
- New directory structure creation: `.opencode/context/memory/`
- File organization strategy (by category, by date, hybrid)
- Cross-reference and linking patterns
- Metadata standards for memory entries

### 2. Skill and Command Pattern Analysis

#### Skill Structure (from skill-structure.md)

All skills follow a standard YAML frontmatter + XML body structure:

```yaml
---
name: skill-{name}
description: "Brief description"
allowed-tools: Task, Bash, Edit, Read
context: fork
agent: {subagent-name}
---
```

Key observations:
- **Thin wrapper pattern**: Skills validate inputs, load context via `<context_injection>`, and delegate to subagents
- **Context injection**: Critical context files are eagerly loaded and injected into subagent prompts
- **Execution stages**: Standardized stages (LoadContext, Preflight, Delegate, Postflight)
- **Validation**: Return validation against `subagent-return.md` schema

#### Command Structure (from command-structure.md)

Commands are "agents with workflows" not just routers:
- Parse and validate arguments
- Orchestrate execution via subagent delegation
- Aggregate results
- Handle errors
- **NEVER** execute work directly

#### Precedent: skill-learn

The `/learn` command provides the best template for `/remember`:

**Workflow**:
1. Parse paths (or use entire project)
2. Delegate to tag-scan-agent (Task tool with fork context)
3. Read metadata from `.return-meta.json`
4. **Interactive selection**: Present findings via `AskUserQuestion` with multiSelect
5. Create tasks for selected items
6. Update state files
7. Commit changes

**Key insight**: The interactive checkbox pattern already exists - skill-learn presents tag findings and lets users select which to convert to tasks. This maps perfectly to presenting proposed memory additions.

### 3. Content Analysis Patterns

From skill-learn's tag scanning approach:

**Extraction Method**:
- Regex-based pattern matching: `FIX:`, `NOTE:`, `TODO:`
- File-based grouping and duplicate removal
- Context extraction (lines around the tag)

**For `/remember`, content analysis should**:
- Accept both text prompts and file paths
- For text: Direct semantic analysis via LLM
- For files: Multi-layer analysis:
  - Structure analysis (headings, sections)
  - Key concept extraction (entities, relationships)
  - Pattern identification (repeated structures)
  - Importance scoring (frequency, centrality)

### 4. Interactive Workflow Patterns

From interview-patterns.md and skill-learn:

**Progressive Disclosure**:
- Start with summary (what was analyzed)
- Present categorized findings
- Allow drill-down selection
- Confirm before action

**Validation Checkpoints**:
- Present proposed additions clearly
- Require explicit user approval
- Show impact (what files would change)
- Allow selective approval (checkboxes, not all-or-nothing)

**Error Recovery**:
- Handle unclear user input gracefully
- Offer multiple interpretations
- Allow cancellation at any stage

### 5. Memory Organization Structure

From research on agent memory systems (A-MEM paper, Knox Memory System):

**Zettelkasten Principles**:
- **Atomic notes**: Each memory entry is a single concept
- **Unique identifiers**: Timestamp-based IDs
- **Cross-referencing**: Bidirectional links between related memories
- **Contextual descriptions**: Rich metadata (when, why, source)
- **Dynamic indexing**: Tags and categories for retrieval

**Recommended Structure**:

```
.opencode/context/memory/
├── categories/           # By topic/category
│   ├── architecture.md
│   ├── decisions.md
│   ├── patterns.md
│   └── people.md
├── timeline/            # By date (for chronological access)
│   └── 2026/
│       └── 03/
│           └── 05-*.md
├── index.md            # Master index with links
└── templates/
    └── entry-template.md
```

**Entry Format** (from report-format.md patterns):

```markdown
# MEM-20260305-001: Entry Title

**ID**: MEM-20260305-001
**Date**: 2026-03-05
**Source**: /path/to/file.md or "user prompt"
**Category**: architecture
**Tags**: [tag1, tag2]

## Content

Main content here...

## Connections

- [[MEM-20260304-012]] - Related entry
- [[architecture.md]] - Category file

## Context

How this relates to other knowledge...
```

### 6. Comparison and Deduplication Strategy

**Challenge**: Avoid duplicate memory entries while allowing updates/revisions.

**Approach**:
1. **Fingerprinting**: Generate semantic fingerprints for each proposed entry
2. **Similarity scoring**: Compare against existing entries (threshold: 0.85+ = duplicate)
3. **Conflict detection**: Identify if new info contradicts existing entries
4. **Merge opportunities**: Suggest combining with similar existing entries

**Algorithm**:
- Extract key phrases and entities from proposed content
- Query existing memory index for similar terms
- Use LLM to compare semantic similarity
- Present findings: "Similar to existing entry MEM-xxx (85% match)"

### 7. Research Augmentation Triggers

**When to trigger web research**:
- User input contains technical terms not found in existing memory
- Identified gaps in knowledge that would strengthen entry
- User explicitly requests "research this topic"
- Confidence score below threshold for key concepts

**How to integrate**:
- Web search results appended as "Research Context" section
- Clearly labeled as external information
- User approval required before adding research findings

### 8. Orchestrated Workflow Design

Based on command-structure.md patterns, the workflow should be:

```
User Input (prompt or file)
    |
    v
Command: remember.md
    - Parse input type (text vs file)
    - Validate existence (if file path)
    - Generate session_id
    - Delegate to skill-remember
    |
    v
Skill: skill-remember/SKILL.md
    - Load context (report-format, status-markers)
    - Create postflight marker
    - Delegate to remember-agent (Task tool, fork context)
    |
    v
Agent: remember-agent.md
    - Stage 1: Input validation
    - Stage 2: Content analysis (extract key info)
    - Stage 3: Load existing memory index
    - Stage 4: Comparison (check for duplicates/gaps)
    - Stage 5: Research decision (trigger if needed)
    - Stage 6: Generate proposed additions
    - Stage 7: Interactive approval (AskUserQuestion multiSelect)
    - Stage 8: Update memory files (for approved items)
    - Stage 9: Return metadata
    |
    v
Skill: Postflight
    - Update state (if tracking remember operations)
    - Commit changes
    - Return summary
```

---

## Decisions

### Decision 1: Memory Storage Location
**Decision**: Store memory in `.opencode/context/memory/` with dual organization (by category + by date).

**Rationale**:
- Follows existing context directory conventions
- Dual organization supports both topical and chronological access
- Date-based directories prevent single-file bloat
- Category files allow natural grouping and cross-referencing

### Decision 2: Interactive Approval Mechanism
**Decision**: Use `AskUserQuestion` with `multiSelect: true` for presenting proposed additions, following skill-learn pattern.

**Rationale**:
- Existing proven pattern in skill-learn
- Users can select individual items (not all-or-nothing)
- Clear presentation of what would be added
- Natural fit for opencode's interactive model

### Decision 3: Content Analysis Strategy
**Decision**: Two-tier approach: regex/structural analysis for files, LLM semantic analysis for both text and files.

**Rationale**:
- Structural analysis (headings, sections) provides organization hints
- LLM extraction handles semantic nuance (key concepts, relationships)
- Combination provides comprehensive coverage
- Extensible for future analysis types

### Decision 4: Deduplication Approach
**Decision**: Semantic similarity comparison using LLM, with 0.85 threshold for duplicate detection and conflict flagging for contradictions.

**Rationale**:
- Exact string matching insufficient (rewording, paraphrasing)
- LLM similarity captures semantic equivalence
- Conflict detection identifies outdated information
- Threshold balances false positives vs missed duplicates

### Decision 5: Research Trigger Conditions
**Decision**: Trigger research when: (1) technical terms not in existing memory, (2) confidence below 0.7, (3) user explicitly requests, (4) identified knowledge gap.

**Rationale**:
- Automated triggers prevent manual decision fatigue
- Confidence threshold ensures quality
- Explicit override always available
- Gap identification from comparison stage

---

## Recommendations

### 1. Component Implementation Order (Priority: High)

**Phase 1: Foundation**
1. Create `.opencode/context/memory/` directory structure
2. Create initial category files (architecture.md, decisions.md, patterns.md)
3. Create `index.md` with linking conventions
4. Create entry template

**Phase 2: Command Infrastructure**
1. Create `.opencode/commands/remember.md` with argument parsing
2. Create `.opencode/skills/skill-remember/SKILL.md` with delegation logic
3. Define context injection files (memory format, comparison standards)

**Phase 3: Core Agent**
1. Create `.opencode/agents/remember-agent.md` with 9-stage workflow
2. Implement content analysis (Stage 2)
3. Implement memory comparison (Stage 4)
4. Implement interactive approval (Stage 7)
5. Implement memory file updates (Stage 8)

**Phase 4: Enhancement**
1. Add research augmentation (Stage 5)
2. Add conflict resolution workflows
3. Add memory search/retrieval integration (future)

### 2. Memory Entry Format Standard (Priority: High)

Create `.opencode/context/core/formats/memory-entry-format.md`:

```markdown
# Memory Entry Format Standard

## Required Metadata
- **ID**: MEM-YYYYMMDD-NNN (unique identifier)
- **Date**: ISO 8601 timestamp
- **Source**: File path or "prompt"
- **Category**: Primary category file
- **Tags**: Array of searchable tags

## Required Sections
1. **Content**: Main knowledge (markdown)
2. **Connections**: Bidirectional links to related entries
3. **Context**: Relationship to broader knowledge

## Optional Sections
- **Research**: External research findings
- **Confidence**: 0.0-1.0 score
- **Review Date**: When to revisit
```

### 3. Interactive UI Design (Priority: Medium)

**Proposed Checkbox Format** (for AskUserQuestion):

```
Proposed Memory Additions (3 items found):

[ ] MEM-001: "Neovim LSP Configuration Pattern"
    From: lua/neotex/plugins/lsp.lua
    Summary: LSP setup should use lspconfig with on_attach pattern
    Similar to: None

[ ] MEM-002: "Plugin Loading Strategy"
    From: lua/neotex/plugins/
    Summary: Use lazy.nvim with event-based loading for performance
    Similar to: architecture.md#plugin-loading

[ ] MEM-003: "Research: Treesitter Best Practices"
    From: Web search
    Summary: Highlighting requires parser installation
    Research confidence: 0.92

Select items to add to memory files:
```

### 4. Testing Strategy (Priority: Medium)

**Unit Tests** (in `tests/agents/test-remember-agent.lua`):
- Content analysis accuracy
- Similarity scoring correctness
- Entry format validation

**Integration Tests**:
- End-to-end workflow with sample inputs
- Interactive flow simulation
- Memory file structure validation

**Test Data**:
- Sample prompts (technical, vague, detailed)
- Sample files (code, documentation, configuration)
- Existing memory entries (for comparison testing)

### 5. Documentation Requirements (Priority: Medium)

Create comprehensive documentation:
- `.opencode/docs/commands/remember.md` - User guide
- `.opencode/docs/guides/memory-management.md` - Best practices
- Memory entry format specification
- Comparison algorithm documentation

---

## Risks & Mitigations

### Risk 1: Memory Proliferation
**Risk**: Unbounded memory growth leading to information overload and slow comparison operations.

**Mitigation**:
- Implement similarity threshold (0.85) to prevent near-duplicates
- Category files with maximum size limits (split when >1000 entries)
- Quarterly review prompts for outdated entries (future feature)
- Entry confidence scores to filter low-value additions

### Risk 2: User Approval Fatigue
**Risk**: Users overwhelmed by too many proposed additions, leading to blanket approvals or abandonment.

**Mitigation**:
- Group related items into single memory entries
- Importance scoring (only propose high-confidence items by default)
- "Add all similar" option for batch approval
- Summary statistics before detailed list ("Found 12 concepts, showing 5 high-confidence")

### Risk 3: Context Window Overflow
**Risk**: Large memory index exceeds context window when loading for comparison.

**Mitigation**:
- Index-based comparison (not full content load)
- Category-specific indexing
- Fingerprint/summary-based pre-filtering
- Hierarchical memory structure (recent + archived)

### Risk 4: Research Augmentation Cost
**Risk**: Uncontrolled web search costs from automatic research triggers.

**Mitigation**:
- Explicit user opt-in for research mode
- Rate limiting (max 3 searches per remember operation)
- Confidence threshold must be met before research triggered
- Local knowledge base checked first

### Risk 5: Format Drift
**Risk**: Memory entries accumulate in inconsistent formats over time.

**Mitigation**:
- Strict format validation in agent
- Template enforcement for new entries
- Periodic format audits (via /review command)
- Version field in entry metadata for format evolution

---

## Appendix

### A. Related Files and Patterns

**Skills for Reference**:
- `.opencode/skills/skill-learn/SKILL.md` - Interactive selection pattern
- `.opencode/skills/skill-researcher/SKILL.md` - Research delegation pattern
- `.opencode/skills/skill-planner/SKILL.md` - Multi-stage execution

**Commands for Reference**:
- `.opencode/commands/learn.md` - Interactive workflow command
- `.opencode/commands/research.md` - Command routing specification
- `.opencode/commands/task.md` - State management patterns

**Templates**:
- `.opencode/context/core/templates/agent-template.md` - Agent structure
- `.opencode/context/core/templates/thin-wrapper-skill.md` - Skill structure

**Standards**:
- `.opencode/context/core/formats/skill-structure.md`
- `.opencode/context/core/formats/command-structure.md`
- `.opencode/context/core/formats/report-format.md`
- `.opencode/context/core/standards/status-markers.md`

### B. External Research Sources

1. **A-MEM: Agentic Memory for LLM Agents** (arXiv:2502.12110)
   - Zettelkasten-inspired dynamic linking
   - Contextual descriptions and metadata
   - Memory evolution through integration

2. **Knox Memory System** (docs.knox.chat)
   - Brain-like memory architecture
   - Context cache + vector embeddings approach
   - Unlimited context window through intelligent management

3. **Memory Management in AI Agents** (Orbital AI, 2025)
   - Context window constraints and solutions
   - Persistence patterns for stateless models
   - Cost optimization strategies

### C. Proposed File Structure

```
.opencode/
├── commands/
│   └── remember.md                    # User entry point
├── skills/
│   └── skill-remember/
│       └── SKILL.md                   # Delegation logic
├── agents/
│   └── remember-agent.md              # Core execution agent
├── context/
│   ├── memory/                        # NEW: Memory storage
│   │   ├── categories/
│   │   │   ├── architecture.md
│   │   │   ├── decisions.md
│   │   │   ├── patterns.md
│   │   │   └── people.md
│   │   ├── timeline/
│   │   │   └── 2026/
│   │   │       └── 03/
│   │   ├── index.md                   # Master index
│   │   └── templates/
│   │       └── entry-template.md
│   └── core/
│       └── formats/
│           └── memory-entry-format.md # NEW: Format standard
└── docs/
    └── guides/
        └── memory-management.md       # NEW: User guide
```

### D. Workflow State Diagram

```
[NOT STARTED]
    |
    | User runs /remember <input>
    v
[PARSING] ---> [INVALID] ---> [ERROR]
    |
    v
[ANALYZING]
    |
    v
[COMPARING] ---> [DUPLICATES FOUND] ---> [FILTER]
    |                                        |
    v                                        |
[RESEARCHING] ---> [NO RESEARCH NEEDED]     |
    |                                        |
    v                                        |
[GENERATING PROPOSALS] <---------------------+
    |
    v
[AWAITING APPROVAL] ---> [USER CANCELS] ---> [CANCELLED]
    |
    | User selects items
    v
[APPLYING UPDATES]
    |
    v
[COMMITTING]
    |
    v
[COMPLETED]
```

---

## Next Steps

Run `/plan OC_136` to create a detailed implementation plan based on this research.

The plan should include:
1. Phase-by-phase breakdown of component creation
2. File specifications with exact paths and content
3. Testing strategy and test cases
4. Timeline estimates for each phase
5. Risk mitigation procedures
