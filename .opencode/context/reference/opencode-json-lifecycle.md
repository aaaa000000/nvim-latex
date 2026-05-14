# opencode.json Lifecycle Reference

- **Type**: Reference
- **Scope**: OpenCode extension system
- **Last Updated**: 2026-05-07
- **Related**: `.opencode/context/patterns/computed-artifacts.md`

## Overview

This document describes the full lifecycle of `opencode.json` from template installation through extension registration to cleanup and unload. It explains the managed/unmanaged distinction and how it governs sync behavior.

`opencode.json` is a **computed artifact**: it is rebuilt from scratch on every load/unload cycle by aggregating agent fragments from all loaded extensions over the base template. There is no per-extension merge tracking.

## Lifecycle Stages

### Stage 1: Template Installation

**Trigger**: First time the OpenCode picker is opened in a project without `opencode.json`

**Flow**:
1. `needs_base_install()` checks if `opencode.json` exists
2. If missing, `install_base_opencode_json()` copies the global template to the project root
3. Creates `.opencode.json.managed` sidecar marker
4. Calls `generate_opencode_json()` to include any already-loaded extension agents
5. Returns `"Installed base opencode.json"`

**Code**: `lua/neotex/plugins/ai/opencode/core/init.lua`

### Stage 2: Extension Load (Agent Registration)

**Trigger**: User selects an extension in the `<leader>ao` picker and confirms load

**Flow**:
1. `manager.load()` reads the extension manifest and copies extension files
2. `process_merge_targets()` handles settings and index merges (opencode.json is NOT merged per-extension)
3. `state_mod.mark_loaded()` persists installed files to `extensions.json`
4. `generate_opencode_json()` regenerates `opencode.json` from base template + all loaded extension fragments
5. The newly loaded extension's agents are included automatically

**Code**: `lua/neotex/plugins/ai/shared/extensions/init.lua`

### Stage 3: Regeneration (Load/Unload/Sync)

**Trigger**: After any extension load, unload, or sync-all operation

**Flow**:
1. `generate_opencode_json()` checks for `.opencode.json.managed` sidecar
2. If unmanaged: skips regeneration entirely
3. If managed: reads base template from `.opencode/templates/opencode.json`
4. Iterates all loaded extensions in order (core first, then stable sort)
5. Reads each extension's `opencode-agents.json` fragment
6. Validates `{file:...}` references
7. Merges fragment `agent` tables into base with first-wins semantics
8. Validates final output with `pcall(vim.json.encode)`
9. Atomically writes to `opencode.json` (temp file + rename)

**Code**: `lua/neotex/plugins/ai/shared/extensions/merge.lua`

### Stage 4: Sync Operation

**Trigger**: User runs `<leader>sp` (sync picker) and selects "Sync all"

**Flow**:
1. `load_all_globally()` scans global artifacts
2. For `opencode.json`, determines action based on managed status:
   - **Managed**: action = "replace" (overwrites with base template)
   - **Unmanaged**: action = "skip" (preserves user config)
3. If managed, copies base template to project root
4. `reinject_loaded_extensions()` calls `generate_opencode_json()` to restore all loaded extension agents

**Transient State Window**: Between steps 3 and 4, `opencode.json` temporarily lacks extension agents. This window is bounded to Lua execution time (Neovim is single-threaded).

**Code**: `lua/neotex/plugins/ai/claude/commands/picker/operations/sync.lua`

### Stage 5: Extension Unload (Agent Deregistration)

**Trigger**: User selects an extension in the `<leader>ao` picker and confirms unload

**Flow**:
1. `manager.unload()` removes extension files and updates state
2. `reverse_merge_targets()` handles settings and index unmerges (opencode.json has no per-extension unmerge)
3. `state_mod.mark_unloaded()` removes the extension from `extensions.json`
4. `generate_opencode_json()` regenerates `opencode.json` without the unloaded extension's agents

**Orphaning Fix**: Because the file is regenerated from all remaining loaded extensions, an agent key provided by multiple extensions survives as long as at least one provider remains loaded.

**Code**: `lua/neotex/plugins/ai/shared/extensions/init.lua`

## State Diagram

```
[No opencode.json]
       |
       v
[Template Install] --managed--> [Managed opencode.json]
       |                              |
       |--unmanaged--> [User opencode.json] (skip sync)
       |
[Extension Load] --> [State Updated] --> [Regenerate] --> [Managed opencode.json]
       |
[Sync All] --> [Replace managed] --> [Regenerate] --> [Managed opencode.json]
       |
[Extension Unload] --> [State Updated] --> [Regenerate] --> [Managed opencode.json]
```

## Managed vs Unmanaged

### Managed File

- Has `.opencode.json.managed` sidecar marker
- Created by template installation or sync
- Can be overwritten by sync-all
- Regenerated after every extension load/unload
- Extension agents are included automatically

### Unmanaged File

- No `.opencode.json.managed` sidecar marker
- Created manually by the user or imported from another project
- Never overwritten by sync
- **Never regenerated** — extension agents are NOT added
- User must manually maintain agent definitions

### Converting Between States

| From | To | Method |
|------|-----|--------|
| Unmanaged | Managed | Run sync-all or call `install_base_opencode_json()` (backs up to `.user-backup`) |
| Managed | Unmanaged | Delete `.opencode.json.managed` file manually |

### Sidecar Files

```
opencode.json              # The actual config file
opencode.json.managed      # Marker file: "managed-by: neotex-extensions\n"
opencode.json.user-backup  # Backup of previous unmanaged config
```

## User Customization Boundaries

### Allowed on Managed Files

- Adding new agents manually (they persist until the next regeneration IF the key does not conflict with base template or extension fragments)
- Editing agent descriptions, tools, or prompts (will be overwritten on next regeneration)
- Custom agents that don't conflict with base/extension keys will survive regeneration

### Preserved on Unmanaged Files

- Full file structure (agents, settings, metadata)
- Custom agent definitions
- Non-standard fields
- Permission configuration

### Reset on Managed During Regeneration

- File is replaced with base template + loaded extension fragments
- Any manual edits to base-template agents are overwritten
- Custom agents with non-conflicting keys survive

## Best Practices

1. **For automatic management**: Let the system manage `opencode.json` (managed mode). Use sync-all to keep it updated.
2. **For manual control**: Remove `.managed` sidecar to make the file unmanaged. Sync will skip it.
3. **For custom agents in managed mode**: Add them to a custom extension fragment or modify the base template. Direct edits to `opencode.json` will be overwritten on regeneration.
4. **Before uninstalling extensions**: Unload extensions via the picker. Regeneration will automatically remove their agents.

## References

- Base installer: `lua/neotex/plugins/ai/opencode/core/init.lua`
- Generation implementation: `lua/neotex/plugins/ai/shared/extensions/merge.lua`
- Sync implementation: `lua/neotex/plugins/ai/claude/commands/picker/operations/sync.lua`
- Extension manager: `lua/neotex/plugins/ai/shared/extensions/init.lua`
- Computed-artifact pattern: `.opencode/context/patterns/computed-artifacts.md`
