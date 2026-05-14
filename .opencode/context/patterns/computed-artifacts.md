# Computed-Artifact Pattern

- **Type**: Pattern
- **Scope**: OpenCode/Claude extension system
- **Last Updated**: 2026-05-07
- **Related**: `.opencode/context/patterns/json-merge-tracking.md`, `.opencode/context/reference/opencode-json-lifecycle.md`

## Overview

A **computed artifact** is a file that is rebuilt from scratch on every load/unload cycle by aggregating fragments from all loaded extensions over a base template. Unlike the merge-target pattern (which incrementally injects and tracks per-extension contributions), the computed-artifact approach has no per-extension tracking and produces deterministic output given the same set of loaded extensions.

### When to Use Computed-Artifact vs Merge-Target

| Criterion | Computed-Artifact | Merge-Target |
|---|---|---|
| File can be fully regenerated from fragments | Yes | No |
| User customizations must survive | Only in unmanaged mode | Yes (with tracking) |
| Multiple extensions contribute to same namespace | Yes (first-wins) | Yes (tracked keys) |
| Need to preserve order/structure exactly | Yes (template-controlled) | No (incremental) |
| Examples | `CLAUDE.md`, `opencode.json` | `settings.json`, `index.json` |

## Invariants

1. **Determinism**: The output is fully determined by the base template plus the set of loaded extensions. Given the same inputs, the output is always identical.
2. **No per-extension tracking**: There is no `merged_sections` state for computed artifacts. Unloading an extension implicitly removes its content by excluding its fragment from the next regeneration.
3. **Managed sidecar gating**: Regeneration only runs when the target file has a `.managed` sidecar marker (e.g., `.opencode.json.managed`). Unmanaged files are never modified.
4. **Implicit removal**: When an extension is unloaded, its content disappears from the next regeneration without explicit unmerge logic.

## Pattern Template

```lua
function M.generate_artifact(project_dir, config)
  local state_mod = require("...state")
  local manifest_mod = require("...manifest")

  local target_path = project_dir .. "/ARTIFACT"
  local managed_marker = target_path .. ".managed"

  -- 1. Gating: skip if unmanaged
  if vim.fn.filereadable(managed_marker) ~= 1 then
    return true, nil
  end

  -- 2. Read base template
  local base = read_base_template(project_dir)

  -- 3. Order extensions: core first, then stable sort
  local state = state_mod.read(project_dir, config)
  local loaded_names = state_mod.list_loaded(state)
  local ordered = order_extensions(loaded_names)

  -- 4. Collect fragments
  for _, ext_name in ipairs(ordered) do
    local extension = manifest_mod.get_extension(ext_name, config)
    local fragment = read_fragment(extension.path .. "/fragment.json")
    if fragment then
      -- 5. Validate fragment
      local valid, err = validate_fragment(fragment, project_dir)
      if valid then
        -- 6. Merge/assemble (first-wins for objects)
        merge_into_base(base, fragment)
      else
        warn("Skipping invalid fragment: " .. err)
      end
    end
  end

  -- 7. Validate final output
  local ok = pcall(vim.json.encode, base)  -- or equivalent
  if not ok then
    return false, "Validation failed"
  end

  -- 8. Atomic write if managed
  local temp_path = target_path .. ".tmp." .. os.time()
  write_file(temp_path, base)
  os.rename(temp_path, target_path)

  return true, nil
end
```

## Checklist for Applying to New Files

- [ ] File can be fully reconstructed from a base template + extension fragments
- [ ] Define a convention-based fragment path (e.g., `{extension}/artifact-fragment.json`)
- [ ] Implement `generate_ARTIFACT()` in `merge.lua`
- [ ] Add managed/unmanaged gating via sidecar marker
- [ ] Validate output before writing (e.g., `pcall(vim.json.encode)`)
- [ ] Use atomic write (temp file + rename)
- [ ] Call `generate_ARTIFACT()` after `generate_claudemd()` in `manager.load()` and `manager.unload()`
- [ ] Update sync `reinject_loaded_extensions()` to call `generate_ARTIFACT()` instead of per-extension merge
- [ ] Update the installer to trigger generation after base template installation
- [ ] Remove old per-extension merge/unmerge code from `process_merge_targets()` and `reverse_merge_targets()`
- [ ] Remove old merge/unmerge functions from `merge.lua`
- [ ] Remove `merge_targets.ARTIFACT` from all extension manifests
- [ ] Document the new lifecycle

## Examples

### CLAUDE.md (via `generate_claudemd`)

`CLAUDE.md` is rebuilt from a header template plus each loaded extension's `EXTENSION.md` content. The ordering is core first, then remaining extensions in stable sorted order. No section markers are used; the file is a pure concatenation.

### opencode.json (via `generate_opencode_json`)

`opencode.json` is rebuilt from `.opencode/templates/opencode.json` plus each loaded extension's `opencode-agents.json` fragment. The `agent` tables are merged with first-wins semantics: base template agents are preserved, and extension agents are added only if the key does not already exist.

## Centralized Permission Configuration

The computed-artifact pattern enables centralized permission configuration in the base template because the template is the single source of truth for shared structure. Extension fragments merge only into the `agent` table, never into `permission`.

### Permission Block Example

```json
{
  "permission": {
    "edit": "allow",
    "external_directory": {
      "*": "ask"
    },
    "bash": {
      "*": "allow",
      "deny": [
        "rm -rf *",
        "sudo *",
        "chmod 777 *",
        "chmod -R *"
      ]
    }
  }
}
```

- `permission.edit: "allow"`: Auto-approve in-root writes (reduces prompt fatigue for workspace-internal operations).
- `permission.external_directory: { "*": "ask" }`: Ask for approval before accessing any external directory.
- `permission.bash.deny`: Explicit deny rules for destructive commands.

### Agent Instructions Example

The base template can also include guidance in agent prompts that applies uniformly:

```json
{
  "agent": {
    "build": {
      "prompt": "When performing temporary work, use the project's specs/tmp/ directory instead of /tmp/."
    }
  }
}
```

Because the base template is the first-wins source, extension fragments cannot override or remove the `permission` block or the default agent instructions.

## References

- `lua/neotex/plugins/ai/shared/extensions/merge.lua` (`generate_claudemd`, `generate_opencode_json`)
- `lua/neotex/plugins/ai/shared/extensions/init.lua` (load/unload pipeline)
- `.opencode/context/reference/opencode-json-lifecycle.md`
- `.opencode/context/patterns/json-merge-tracking.md`
