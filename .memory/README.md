# Claude Code Memory Vault

This directory contains an Obsidian-compatible vault for the Claude Code memory management system.

## Purpose

The memory vault stores structured knowledge that the Claude Code system can reference and search. Memories are stored as Markdown files with YAML frontmatter for metadata.

## Directory Structure

```
.memory/
├── .obsidian/           # Obsidian configuration
├── 00-Inbox/           # Quick capture for new memories
├── 10-Memories/        # Stored memory entries
├── 20-Indices/         # Navigation and organization
└── 30-Templates/       # Memory entry templates
```

## Adding Memories

Use the `/learn` command:
- `/learn "text to remember"` - Add text content
- `/learn /path/to/file.md` - Add file content

The command will:
1. Parse the input
2. Generate a unique memory ID
3. Present a preview with checkbox options
4. Allow you to add new, update existing, edit, or skip

## Git Workflow

**What to commit**:
- All `.md` files in the vault
- Templates and indices
- This README

**What to ignore** (in `.gitignore`):
- `.obsidian/` directory (user-specific Obsidian settings)
- `*.sqlite` files (search indexes)
- Plugin directories

## MCP Server Setup

For advanced features (search, retrieval), install the Obsidian CLI REST MCP server:

1. Open Obsidian app
2. Open this `.memory/` as a vault
3. Install "Obsidian CLI REST" community plugin
4. Note the API key from plugin settings
5. Configure MCP server with the API key

See `.claude/extensions/memory/context/project/memory/memory-setup.md` for detailed instructions.

## Naming Conventions

Memory files follow the pattern:
```
MEM-{semantic-slug}.md
```

Example: `MEM-telescope-custom-pickers.md`, `MEM-neovim-lsp-best-practices.md`

The MEM- prefix is preserved for grep discoverability (`grep -r "MEM-" .memory/`).

## Template Format

Memory entries use YAML frontmatter:
```yaml
---
title: "Neovim LSP Best Practices"
created: 2026-03-06
tags: neovim, lsp, configuration
topic: "neovim/lsp"
source: "user input"
modified: 2026-03-06
---
```

Note: The `id:` field has been removed. Filenames serve as unique identifiers.

## Role Boundaries

This directory stores **learned facts** -- patterns discovered, decisions made,
and observations recorded during development work. It is independent from
`.context/` (user-defined project conventions) and loaded in parallel with it.

| Content type | Belongs here? |
|---|---|
| Patterns discovered during development | Yes |
| Decisions and their rationale | Yes |
| Project conventions and coding style | No -- use `.context/` |
| Agent system patterns | No -- use `.claude/context/` |
| Language-specific references | No -- use extensions |
| User preferences | No -- handled by Claude auto-memory |

For the full context architecture, see `.claude/context/architecture/context-layers.md`.

## Best Practices

- Use descriptive first lines for better titles
- Review index.md regularly for navigation
- Commit memories to git for version history
- Use tags for better organization
- Link related memories using `[[filename]]` syntax
