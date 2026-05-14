# Extension Manifest Schema Reference

- **Type**: Reference
- **Scope**: OpenCode extension system
- **Last Updated**: 2026-05-07
- **Related**: `specs/541_design_opencode_json_agent_registration/designs/01_agent-registration-design-spec.md`

## Overview

The extension manifest (`manifest.json`) declares what an extension provides and how it integrates with the OpenCode system. This document focuses on the `merge_targets` field, specifically the `opencode_json` target used for agent registration.

## Full Manifest Structure

```json
{
  "name": "string",
  "version": "string",
  "description": "string",
  "language": "string",
  "dependencies": ["string"],
  "routing_exempt": boolean,
  "provides": {
    "agents": ["filename-agent.md"],
    "commands": ["filename.md"],
    "rules": ["filename.md"],
    "skills": ["skill-name"],
    "scripts": ["filename.sh"],
    "hooks": ["filename.sh"],
    "context": ["path/"],
    "docs": ["path/"],
    "templates": ["filename"],
    "systemd": ["filename"]
  },
  "routing": {
    "research": { "key": "skill-name" },
    "plan": { "key": "skill-name" },
    "implement": { "key": "skill-name" }
  },
  "merge_targets": {
    "opencode_md": { "source": "", "target": "", "section_id": "" },
    "index": { "source": "", "target": "" },
    "opencode_json": { "source": "", "target": "" }
  },
  "mcp_servers": {
    "server-name": { "command": "", "args": [""], "env": {} }
  }
}
```

## merge_targets.opencode_json

The `opencode_json` merge target registers extension agents in the project's `opencode.json` file.

### Field Structure

```json
"merge_targets": {
  "opencode_json": {
    "source": "opencode-agents.json",
    "target": "opencode.json"
  }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `source` | string | Yes | Path to the agent fragment file, relative to the extension root |
| `target` | string | Yes | Path to the target `opencode.json`, relative to the project root |

### Real Examples

**Core extension** (`~/.config/nvim/.opencode/extensions/core/manifest.json`):

```json
{
  "name": "core",
  "version": "1.0.0",
  "description": "Core agent system extension providing base commands, agents, rules, skills, scripts, hooks, and context for the OpenCode agent infrastructure.",
  "dependencies": [],
  "routing_exempt": true,
  "provides": {
    "agents": [
      "code-reviewer-agent.md",
      "general-implementation-agent.md",
      "general-research-agent.md",
      "meta-builder-agent.md",
      "planner-agent.md",
      "reviser-agent.md",
      "spawn-agent.md"
    ]
  },
  "merge_targets": {
    "opencode_json": {
      "source": "opencode-agents.json",
      "target": "opencode.json"
    }
  }
}
```

**Present extension** (`~/.config/nvim/.opencode/extensions/present/manifest.json`):

```json
{
  "name": "present",
  "version": "1.0.0",
  "description": "Research presentation support: grant writing, budget planning, timeline management, funding analysis, and academic talks",
  "language": "present",
  "dependencies": ["core", "slidev"],
  "provides": {
    "agents": [
      "grant-agent.md",
      "budget-agent.md",
      "timeline-agent.md",
      "funds-agent.md",
      "slides-research-agent.md",
      "pptx-assembly-agent.md",
      "slidev-assembly-agent.md",
      "slide-planner-agent.md",
      "slide-critic-agent.md"
    ]
  },
  "merge_targets": {
    "opencode_json": {
      "source": "opencode-agents.json",
      "target": "opencode.json"
    }
  }
}
```

## Relationship Between manifest.provides.agents and opencode-agents.json

The `manifest.provides.agents` array and the `opencode-agents.json` fragment are two views of the same data:

- **`manifest.provides.agents`**: Lists the agent filenames that the extension provides (used by the loader to copy files)
- **`opencode-agents.json`**: Maps agent names to their full definitions (used by the merger to inject into `opencode.json`)

### Consistency Requirement

Every agent filename in `manifest.provides.agents` must have a matching entry in `opencode-agents.json`, and vice versa. The naming convention is:

```
Agent name = filename without "-agent.md" suffix
```

Example:

```json
// manifest.json
"provides": {
  "agents": ["grant-agent.md", "budget-agent.md"]
}

// opencode-agents.json
{
  "agent": {
    "grant": { ... },
    "budget": { ... }
  }
}
```

## Validation

The manifest is validated by `manifest.lua` (lines 91-113) with these rules:

1. `merge_targets` must be a table
2. Each merge target must have `source` and `target` fields
3. `opencode_json` is not treated specially; it passes generic validation

Post-load verification (`verify.lua`) checks:
1. Every agent file in `provides.agents` exists on disk
2. (Future) Every agent in `provides.agents` has a matching `opencode-agents.json` entry
3. (Future) Agent names follow the naming convention

## opencode-agents.json Fragment Format

```json
{
  "agent": {
    "agent-name": {
      "description": "Human-readable description",
      "mode": "subagent",
      "prompt": "{file:.opencode/agent/subagents/name-agent.md}",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "glob": true,
        "grep": true,
        "bash": true,
        "webfetch": true,
        "websearch": true
      }
    }
  }
}
```

See `~/.config/nvim/.opencode/extensions/core/opencode-agents.json` for a real example.

## References

- Design spec: `specs/541_design_opencode_json_agent_registration/designs/01_agent-registration-design-spec.md`
- Manifest parser: `lua/neotex/plugins/ai/shared/extensions/manifest.lua`
- Merge implementation: `lua/neotex/plugins/ai/shared/extensions/merge.lua`
- Verify implementation: `lua/neotex/plugins/ai/shared/extensions/verify.lua`
- Core manifest: `~/.config/nvim/.opencode/extensions/core/manifest.json`
- Present manifest: `~/.config/nvim/.opencode/extensions/present/manifest.json`
