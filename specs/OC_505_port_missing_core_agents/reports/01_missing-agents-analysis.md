# Research Report: Port Missing Core Agents

**Task**: OC_505 - port_missing_core_agents
**Started**: 2026-05-02
**Completed**: 2026-05-02
**Effort**: 2-3 hours
**Dependencies**: None
**Sources/Inputs**: `.claude/agents/`, `.opencode/agent/subagents/`, extension manifests
**Artifacts**: This research report
**Standards**: Agent frontmatter standard, context path mapping conventions

## Executive Summary

- **spawn-agent.md**: Already ported to `.opencode/agent/subagents/` (task 503 completed this)
- **reviser-agent.md**: MISSING - needs to be ported from `.claude/agents/`
- **Extension agents**: Declared in manifests but NOT installed in `.opencode/agent/subagents/`
- **Path mapping pattern**: Established from spawn-agent.md comparison
- **Recommendation**: Port reviser-agent.md and verify extension agent loading mechanism

## Context & Scope

This research examines the agent porting status from the Claude Code system (`.claude/agents/`) to the OpenCode system (`.opencode/agent/subagents/`). The task scope includes:

1. Identifying missing core agents
2. Documenting path mapping adaptations
3. Verifying extension agent declarations
4. Assessing installation requirements

## Findings

### Source Analysis (.claude/agents/)

The source directory contains 11 agent files:

| Agent | Status in Target |
|-------|-----------------|
| `code-reviewer-agent.md` | ✓ Present |
| `general-implementation-agent.md` | ✓ Present |
| `general-research-agent.md` | ✓ Present |
| `meta-builder-agent.md` | ✓ Present |
| `neovim-implementation-agent.md` | ✗ Missing |
| `neovim-research-agent.md` | ✗ Missing |
| `nix-implementation-agent.md` | ✗ Missing |
| `nix-research-agent.md` | ✗ Missing |
| `planner-agent.md` | ✓ Present |
| `reviser-agent.md` | ✗ **MISSING - needs port** |
| `spawn-agent.md` | ✓ Present (ported in task 503) |

### Target Analysis (.opencode/agent/subagents/)

Current target directory contains 7 agents + README.md:
- `code-reviewer-agent.md`
- `general-implementation-agent.md`
- `general-research-agent.md`
- `meta-builder-agent.md`
- `planner-agent.md`
- `spawn-agent.md` (recently added - May 2)
- `README.md`

**Missing from target**: `reviser-agent.md`, all 4 extension agents (neovim-* and nix-*)

### Path Mapping Documentation

Based on comparison of `spawn-agent.md` source vs target:

| Source Pattern | Target Pattern | Example |
|---------------|----------------|---------|
| `.claude/context/` | `.opencode/context/` | `@.claude/context/formats/` → `@.opencode/context/formats/` |
| `.claude/CLAUDE.md` | `.opencode/AGENTS.md` | Main configuration reference |
| `specs/{NNN}_{SLUG}/` | `specs/OC_{NNN}_{SLUG}/` | Task directory prefix |
| `.claude/context/standards/` | `.opencode/context/standards/` | Standards documentation |
| `rules/error-handling.md` | `rules/error-handling.md` | Relative path unchanged |

### Extension Agent Verification

#### nvim Extension Manifest

**Claude version** (`.claude/extensions/nvim/manifest.json`):
```json
"provides": {
  "agents": [
    "neovim-research-agent.md",
    "neovim-implementation-agent.md"
  ],
  ...
}
```

**OpenCode version** (`.opencode/extensions/nvim/manifest.json`):
```json
"provides": {
  "agents": ["neovim-research-agent.md", "neovim-implementation-agent.md"],
  ...
}
```

✓ **Agents declared**: Both manifests correctly declare the agents.
✗ **Agents not installed**: Files are not present in `.opencode/agent/subagents/`.

#### nix Extension Manifest

**Claude version** (`.claude/extensions/nix/manifest.json`):
```json
"provides": {
  "agents": [
    "nix-research-agent.md",
    "nix-implementation-agent.md"
  ],
  ...
}
```

**OpenCode version** (`.opencode/extensions/nix/manifest.json`):
```json
"provides": {
  "agents": ["nix-research-agent.md", "nix-implementation-agent.md"],
  ...
}
```

✓ **Agents declared**: Both manifests correctly declare the agents.
✗ **Agents not installed**: Files are not present in `.opencode/agent/subagents/`.

### Agent Loading Mechanism Analysis

The extension manifests declare agents but don't specify an installation path. This suggests either:

1. **Extension loader copies agents** during extension activation
2. **Agents should be manually ported** like core agents
3. **Agents are loaded from extension directory** directly

Current evidence suggests option 2 (manual porting) is the pattern being followed for core agents.

### reviser-agent.md Content Overview

The missing `reviser-agent.md` is a 192-line agent definition with:

**Frontmatter**:
```yaml
---
name: reviser-agent
description: Revise implementation plans by synthesizing existing plans with new research findings
model: opus
---
```

**Key Context References** (needing path adaptation):
- `@.claude/context/formats/return-metadata-file.md`
- `@.claude/context/formats/plan-format.md`
- `@.claude/context/workflows/task-breakdown.md`
- `@.claude/CLAUDE.md`
- `@.claude/context/patterns/context-discovery.md`
- `@.claude/context/formats/roadmap-format.md`

**Execution Stages**:
1. Initialize early metadata
2. Parse delegation context
3. Determine revision mode
4. Load existing plan
5. Load new research
6. Synthesize revised plan
7. Update metadata file
8. Return brief text summary

**Output Artifacts**:
- `specs/{NNN}_{SLUG}/.return-meta.json` (metadata)
- Revised plan at `specs/{NNN}_{SLUG}/plans/{NN}_{short-slug}.md`

## Decisions

1. **reviser-agent.md porting required**: The only missing core agent needing porting.

2. **Path adaptation pattern confirmed**: Use established pattern from spawn-agent.md:
   - `.claude/context/` → `.opencode/context/`
   - `.claude/CLAUDE.md` → `.opencode/AGENTS.md`
   - `specs/{NNN}_{SLUG}/` → `specs/OC_{NNN}_{SLUG}/`

3. **Extension agent installation out of scope**: The manifests correctly declare agents; installation mechanism needs separate investigation (may be handled by extension loader).

4. **Task scope clarification**: Original task mentioned 2 missing agents (reviser + spawn), but spawn is already ported. Focus on reviser-agent.md.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Missing context files in target | Medium | Verify `.opencode/context/formats/` and `.opencode/context/standards/` exist |
| Path mapping inconsistencies | Low | Follow established spawn-agent.md pattern exactly |
| Extension agents not loading | Medium | Verify extension loader behavior; may need manual porting |
| Agent skill mapping issues | Low | Update `.opencode/AGENTS.md` skill-to-agent table |

## Implementation Recommendations

### Phase 1: Port reviser-agent.md

1. Copy `.claude/agents/reviser-agent.md` to `.opencode/agent/subagents/reviser-agent.md`
2. Apply path adaptations:
   - `.claude/context/` → `.opencode/context/`
   - `.claude/CLAUDE.md` → `.opencode/AGENTS.md`
   - `specs/{NNN}_{SLUG}/` → `specs/OC_{NNN}_{SLUG}/`
3. Verify context files exist in target locations
4. Update `.opencode/agent/subagents/README.md` to list reviser-agent

### Phase 2: Verify Extension Agent Loading (Optional)

1. Check if extension loader automatically copies agents from extension directories
2. If not, port extension agents following same pattern
3. Update skill-to-agent mappings in `.opencode/AGENTS.md`

### Phase 3: Update Documentation

1. Add reviser-agent to skill-to-agent table in `.opencode/AGENTS.md`
2. Update subagents README.md with reviser-agent entry

## Context Extension Recommendations

**None required** - This is a meta task for porting existing agents. The research reveals that:

- Extension manifests properly declare agents (no documentation gap)
- Path mapping pattern is established (no new patterns needed)
- The only gap is the actual file presence in target directory

## Appendix

### A. Source vs Target Directory Listing

```
.claude/agents/ (11 files):
  ✓ code-reviewer-agent.md
  ✓ general-implementation-agent.md
  ✓ general-research-agent.md
  ✓ meta-builder-agent.md
  ✗ neovim-implementation-agent.md (extension)
  ✗ neovim-research-agent.md (extension)
  ✗ nix-implementation-agent.md (extension)
  ✗ nix-research-agent.md (extension)
  ✓ planner-agent.md
  ✗ reviser-agent.md (NEEDS PORT)
  ✓ spawn-agent.md (already ported)

.opencode/agent/subagents/ (7 files + README):
  ✓ code-reviewer-agent.md
  ✓ general-implementation-agent.md
  ✓ general-research-agent.md
  ✓ meta-builder-agent.md
  ✓ planner-agent.md
  ✓ spawn-agent.md
  ✗ reviser-agent.md (MISSING)
```

### B. Extension Manifest Agent Declarations

**nvim extension**: `neovim-research-agent.md`, `neovim-implementation-agent.md`
**nix extension**: `nix-research-agent.md`, `nix-implementation-agent.md`

Both declared in both Claude and OpenCode manifests.

### C. References

- Source: `.claude/agents/reviser-agent.md`
- Target pattern: `.opencode/agent/subagents/spawn-agent.md`
- Extension manifests: `.claude/extensions/{nvim,nix}/manifest.json`, `.opencode/extensions/{nvim,nix}/manifest.json`
