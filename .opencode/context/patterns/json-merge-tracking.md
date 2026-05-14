# JSON Merge Tracking Pattern

- **Type**: Pattern
- **Scope**: OpenCode extension system
- **Last Updated**: 2026-05-07
- **Related**: `.opencode/context/patterns/computed-artifacts.md`

## Overview

> **Note**: `opencode.json` is no longer managed via JSON merge tracking. It uses the [computed-artifact pattern](computed-artifacts.md) instead. This document retains the pattern documentation for other merge targets such as `settings.json` and `index.json`.

The JSON merge tracking pattern enables idempotent, reversible merging of JSON fragments into target files. It is used by the OpenCode extension system for `settings.json` and `index.json`, and is reusable for other JSON merge targets.

## Problem

When multiple extensions contribute keys to a shared JSON file, we need to:

1. Add extension-specific keys without overwriting existing keys
2. Remove extension-specific keys when the extension is unloaded
3. Preserve user-added keys or keys from other extensions

## Solution: Key-Based Tracking

The pattern uses tracking data to record which keys were added by a specific merge operation. This tracking data is stored in extension state (`extensions.json`) and used during unmerge.

### Data Structures

**Tracking data** (stored in `extensions.json`):
```lua
{
  keys = {"agent1", "agent2", "agent3"}
}
```

**Extension state entry**:
```json
{
  "name": "core",
  "loaded": true,
  "merged_sections": {
    "settings": { ...tracked data... },
    "index": { ...tracked data... }
  }
}
```

### Pseudocode: Merge

```lua
function merge(target_path, fragment, project_dir)
  -- Validate fragment
  valid, err = validate(fragment, project_dir)
  if not valid then return false, {error = err} end

  -- Read or create target
  target = read_json(target_path) or {}

  -- Track what we add
  tracked = {}

  -- Deep merge
  deep_merge(target, fragment, tracked)

  -- Write updated target
  write_json(target_path, target)

  -- Return tracking data for unmerge
  return true, tracked
end
```

### Pseudocode: Unmerge

```lua
function unmerge(target_path, tracked)
  if not tracked then return true end

  target = read_json(target_path) or {}

  -- Remove tracked entries
  remove_tracked(target, tracked)

  write_json(target_path, target)
  return true
end
```

### Key Properties

| Property | Description |
|----------|-------------|
| **Idempotent merge** | Running merge twice with the same fragment adds keys only once (second run finds keys already exist) |
| **Idempotent unmerge** | Running unmerge twice is safe (tracked keys are already removed) |
| **Non-destructive** | Unmerge only removes keys that were added by the corresponding merge; user keys and other extension keys are preserved |
| **Conflict-safe** | If two extensions define the same key, the first wins; the second's key is not tracked, so unmerge of the first does not affect the second's state |

## Real Implementation

The actual implementation is in `lua/neotex/plugins/ai/shared/extensions/merge.lua`:

- `merge_settings()` (lines 225-257): Merges settings fragments
- `unmerge_settings()` (lines 260-312): Removes tracked settings entries
- `append_index_entries()` (lines 315-360): Appends index entries
- `remove_index_entries_tracked()` (lines 363-401): Removes tracked index entries

State tracking is in `lua/neotex/plugins/ai/shared/extensions/state.lua`.

## Reusability

This pattern can be applied to any JSON file that receives additive, reversible contributions:

- `settings.json` for extension-specific settings
- `package.json` for dependency injection
- Custom configuration files with shared namespaces

### Preferred Approach for Fully Regenerable Files

For files that can be fully regenerated from a base template plus extension fragments, the [computed-artifact pattern](computed-artifacts.md) is preferred. It eliminates tracking complexity, resolves orphaning edge cases, and produces deterministic output.

| Characteristic | Merge-Tracking | Computed-Artifact |
|---|---|---|
| Tracking state | Per-extension in `extensions.json` | None |
| Unload behavior | Explicit unmerge | Implicit (excluded from regeneration) |
| Orphaning risk | Yes (tracked keys removed even if another extension provides them) | No (regeneration includes all loaded extensions) |
| Determinism | Depends on load order | Deterministic given same inputs |
| Example targets | `settings.json`, `index.json` | `opencode.json`, `CLAUDE.md` |

To reuse the merge-tracking pattern for a new target:

1. Define a `merge_target_key` in the extension config (e.g., `"my_json"`)
2. Implement `merge_my_json(target_path, fragment)` following the pseudocode above
3. Implement `unmerge_my_json(target_path, tracked)` following the pseudocode above
4. Register the merge target in `manifest.json`:
   ```json
   "merge_targets": {
     "my_json": {
       "source": "my-fragment.json",
       "target": "my-config.json"
     }
   }
   ```
5. Update `process_merge_targets()` in `init.lua` to handle the new key

## References

- Merge implementation: `lua/neotex/plugins/ai/shared/extensions/merge.lua`
- State tracking: `lua/neotex/plugins/ai/shared/extensions/state.lua`
- Extension manager: `lua/neotex/plugins/ai/shared/extensions/init.lua`
- Computed-artifact pattern: `.opencode/context/patterns/computed-artifacts.md`
