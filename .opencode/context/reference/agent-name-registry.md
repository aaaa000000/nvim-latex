# Agent Name Registry

- **Type**: Reference
- **Scope**: OpenCode extension system
- **Last Updated**: 2026-05-07
- **Related**: `specs/541_design_opencode_json_agent_registration/designs/01_agent-registration-design-spec.md`

## Reserved Core Agent Names

The following agent names are defined in the base template (`~/.config/nvim/.opencode/templates/opencode.json`) and are considered reserved. Extensions should not define agents with these names.

| Agent Name | Mode | Purpose |
|-----------|------|---------|
| `build` | primary | Primary build agent |
| `plan` | primary | Planning mode agent |
| `task-planner` | subagent | Create implementation plans from research findings |
| `general-research` | subagent | Research general tasks using web search and codebase exploration |
| `general-implementation` | subagent | Implement general, meta, and markdown tasks from plans |
| `meta-builder` | subagent | Interactive system builder for .opencode/ architecture changes |
| `code-reviewer` | subagent | Review code for security, performance, and maintainability |

Core agents are always present in `opencode.json` (via the base template) and cannot be overridden by extensions.

## Extension Agent Naming Conventions

Extensions define agents in their `opencode-agents.json` fragment. Follow these conventions to avoid collisions:

### 1. Descriptive Names

Use descriptive, task-oriented names that reflect the agent's purpose:

- Good: `grant`, `budget`, `timeline`, `nix-research`, `neovim-implementation`
- Bad: `agent1`, `myagent`, `foo`

### 2. Domain Prefixing

For domain-specific agents, consider prefixing with the domain name:

- `nix-research` (Nix extension research agent)
- `neovim-implementation` (Neovim extension implementation agent)
- `slide-planner` (Presentation extension slide planner)

This reduces collision probability across extensions.

### 3. Suffix by Role

Use consistent suffixes to indicate agent role:

| Suffix | Role | Typical Tools |
|--------|------|--------------|
| `-research` | Research and exploration | read, write, edit, glob, grep, bash, webfetch, websearch |
| `-implementation` | File implementation | write, edit, bash, read, glob, grep |
| `-planner` | Plan creation | read, write, edit, glob, grep, bash, webfetch, websearch |
| `-reviewer` | Code review | read, grep, glob (limited write) |
| `-critic` | Critique and evaluation | read, write, edit, glob, grep, bash, webfetch, websearch |
| `-assembly` | Assembly and generation | read, write, edit, glob, grep, bash, webfetch, websearch |

### 4. Filename-to-Agent Mapping

Agent name = filename without `-agent.md` suffix:

| Filename | Agent Name |
|----------|-----------|
| `grant-agent.md` | `grant` |
| `budget-agent.md` | `budget` |
| `slide-planner-agent.md` | `slide-planner` |
| `nix-research-agent.md` | `nix-research` |

This convention is enforced by the fragment-to-manifest consistency validator (see Decision 2 in the design spec).

## Conflict Resolution

When two extensions define the same agent name, the **first-loaded wins** with a warning:

```
Extension 'present' agent 'grant' conflicts with already-loaded extension 'founder'.
Agent 'grant' was not registered. Unload 'founder' first, or rename the agent.
```

To avoid conflicts:
1. Check this registry before choosing an agent name
2. Use domain-specific prefixes for niche agents
3. Propose new names if your preferred name is taken

## Proposing New Agent Names

If you are developing a new extension and need an agent name:

1. Check the existing extensions in `~/.config/nvim/.opencode/extensions/`
2. Review their `opencode-agents.json` fragments for name collisions
3. Choose a unique, descriptive name following the conventions above
4. Document the name in your extension's `manifest.json` `provides.agents` array

There is no formal approval process; the first extension to load with a given name claims it. However, extension authors are encouraged to coordinate via the project issue tracker to avoid unnecessary collisions.

## Current Extension Agent Names

As of 2026-05-07, the following extension agents are registered:

| Extension | Agents |
|-----------|--------|
| `core` | `code-reviewer`, `general-implementation`, `general-research`, `meta-builder`, `planner`, `reviser`, `spawn` |
| `present` | `budget`, `funds`, `grant`, `pptx-assembly`, `slide-critic`, `slide-planner`, `slides-research`, `slidev-assembly`, `timeline` |

This list is not exhaustive; other extensions may define additional agents.

## References

- Design spec: `specs/541_design_opencode_json_agent_registration/designs/01_agent-registration-design-spec.md`
- Merge implementation: `lua/neotex/plugins/ai/shared/extensions/merge.lua`
- Base template: `~/.config/nvim/.opencode/templates/opencode.json`
