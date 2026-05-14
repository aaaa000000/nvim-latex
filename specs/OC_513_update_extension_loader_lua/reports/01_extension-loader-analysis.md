# Research Report: Task #513 - Extension Loader Feature Parity Analysis

**Task**: OC_513 - update_extension_loader_lua  
**Started**: 2026-05-03T01:10:00Z  
**Completed**: 2026-05-03T01:25:00Z  
**Effort**: 1-2 hours  
**Dependencies**: 502 (core extension created)  
**Sources/Inputs**: - Codebase analysis of `lua/neotex/plugins/ai/shared/extensions/` and `lua/neotex/plugins/ai/opencode/`  
**Artifacts**: - This report  
**Standards**: report-format.md, neovim-lua-style

## Executive Summary

- **Primary Finding**: The OpenCode extension loader already has feature parity with the Claude loader through the shared extensions system
- **Key Insight**: The picker displays all artifact sections only when extensions are loaded (lines 999-1005 in entries.lua gate check)
- **Verification Required**: Confirm agents install to `agent/subagents/` per `config.agents_subdir = "agent/subagents"`
- **Manifest Correctness**: OpenCode core extension correctly uses `opencode_md` merge target key
- **Action Required**: Testing to verify end-to-end extension loading works correctly

## Context & Scope

This research analyzes the OpenCode extension loader implementation to ensure feature parity with the Claude extension loader. The investigation covers:

1. Source code comparison between Claude and OpenCode loader implementations
2. Feature gap analysis against specified requirements
3. Picker integration and artifact section display logic
4. Agent installation path verification
5. Manifest merge target configuration

## Findings

### 1. Shared Extension Architecture

Both Claude and OpenCode use the **same shared extension system** located at:
- `lua/neotex/plugins/ai/shared/extensions/` - Core extension management
- `lua/neotex/plugins/ai/shared/extensions/picker.lua` - Shared picker UI

**Configuration Differences** (from `config.lua`):

| Aspect | Claude | OpenCode |
|--------|--------|----------|
| `base_dir` | `.claude` | `.opencode` |
| `config_file` | `CLAUDE.md` | `OPENCODE.md` |
| `section_prefix` | `extension_` | `extension_oc_` |
| `merge_target_key` | `claudemd` | `opencode_md` |
| `agents_subdir` | `agents` | `agent/subagents` |

The OpenCode configuration is correctly defined in:
```lua
-- lua/neotex/plugins/ai/shared/extensions/config.lua lines 64-75
function M.opencode(global_dir)
  return M.create({
    base_dir = ".opencode",
    config_file = "OPENCODE.md",
    section_prefix = "extension_oc_",
    state_file = "extensions.json",
    global_extensions_dir = global_dir .. "/.opencode/extensions",
    merge_target_key = "opencode_md",
    agents_subdir = "agent/subagents",  -- CORRECT: agents go here
  })
end
```

### 2. Agent Installation Path Verification

**Requirement**: Extension loading installs agents to `agent/subagents/`

**Implementation Status**: ✅ **CORRECT**

In `loader.lua` lines 90-121, the `copy_simple_files` function handles agent copying:

```lua
function M.copy_simple_files(manifest, source_dir, target_dir, category, extension, agents_subdir)
  -- ...
  -- Use agents_subdir for agents category if provided, otherwise use category name
  local target_category_name = (category == "agents" and agents_subdir) or category
  local target_category_dir = target_dir .. "/" .. target_category_name
  -- ...
end
```

The `agents_subdir` parameter is passed from `init.lua` line 397:
```lua
local files, dirs = loader_mod.copy_simple_files(ext_manifest, source_dir, target_dir, "agents", ".md", config.agents_subdir)
```

**Verification**: For OpenCode, `config.agents_subdir = "agent/subagents"`, so agents from extensions will be installed to `.opencode/agent/subagents/`.

### 3. Manifest Merge Targets Analysis

**Requirement**: Manifest merge_targets use `opencode_md` key

**Implementation Status**: ✅ **CORRECT**

OpenCode core extension manifest (`extensions/core/manifest.json` lines 143-153):
```json
"merge_targets": {
  "opencode_md": {
    "source": "EXTENSION.md",
    "target": ".opencode/AGENTS.md",
    "section_id": "extension_oc_core"
  },
  "index": {
    "source": "index-entries.json",
    "target": ".opencode/context/index.json"
  }
}
```

This correctly uses `opencode_md` as the merge target key, matching the `merge_target_key = "opencode_md"` in the OpenCode config.

### 4. Picker Artifact Section Display

**Requirement**: `<leader>ao` picker shows core/ agent system section when extensions loaded

**Implementation Analysis**:

The picker gate check is in `entries.lua` lines 999-1005:
```lua
-- Gate: only show artifact sections when extensions are loaded
local extensions_module = config and config.extensions_module
  or "neotex.plugins.ai.claude.extensions"
local ok, extensions = pcall(require, extensions_module)
if not ok or #extensions.list_loaded() == 0 then
  return all_entries
end
```

**Behavior**:
- When NO extensions are loaded: Only shows `[Extensions]` section (for loading) + `[Keyboard Shortcuts]`
- When extensions ARE loaded: Shows ALL artifact sections:
  - `[Commands]` - Slash commands
  - `[Root Files]` - Configuration files
  - `[Agents]` - AI agent definitions
  - `[Skills]` - Model-invoked capabilities
  - `[Hook Events]` - Event-triggered scripts
  - `[Memory]` - Memory vault entries
  - `[Rules]` - Auto-applied rules
  - `[Tests]` - Test suites
  - `[Scripts]` - Standalone CLI tools
  - `[Templates]` - Workflow templates
  - `[Lib]` - Utility libraries
  - `[Context]` - Knowledge base and standards
  - `[Docs]` - Documentation
  - `[Extensions]` - Domain-specific capability packs

**Verification**: The picker config for OpenCode (`shared/picker/config.lua` lines 78-99) correctly specifies:
```lua
function M.opencode(global_dir)
  return M.create({
    base_dir = ".opencode",
    agents_subdir = "agent/subagents",
    extensions_module = "neotex.plugins.ai.opencode.extensions",
    -- ...
  })
end
```

### 5. Extension Loader Module Chain

**OpenCode Extension Loading Flow**:

1. **Entry Point**: `lua/neotex/plugins/ai/opencode/extensions/picker.lua`
   - Thin wrapper around shared picker
   - Uses OpenCode extensions module

2. **Extensions Module**: `lua/neotex/plugins/ai/opencode/extensions/init.lua`
   - Delegates to shared extensions with OpenCode config
   - Line 10: `local manager = shared.create(opencode_config)`

3. **Shared Implementation**: `lua/neotex/plugins/ai/shared/extensions/init.lua`
   - Lines 396-460: Copy operations for all artifact types
   - Handles agents, commands, rules, skills, context, scripts, hooks, docs, templates, systemd, root_files

4. **Loader Module**: `lua/neotex/plugins/ai/shared/extensions/loader.lua`
   - File copy engine (lines 90-520)
   - Uses `config.agents_subdir` for agent paths (line 100)

### 6. Comparison: Claude vs OpenCode Extension Loader

**Similarities** (both use shared code):
- Same load/unload/reload logic
- Same dependency resolution with circular detection
- Same conflict checking and merge semantics
- Same state management in `extensions.json`
- Same picker UI with Telescope

**Differences**:
| Feature | Claude | OpenCode |
|---------|--------|----------|
| Agent subdirectory | `agents/` | `agent/subagents/` |
| Merge target key | `claudemd` | `opencode_md` |
| Config file | `CLAUDE.md` | `OPENCODE.md` |
| Section prefix | `extension_` | `extension_oc_` |
| Hooks support | Full | None (hooks_subdir = nil) |
| on_load_all callback | None | Installs base opencode.json |

## Decisions

1. **No Code Changes Required**: The OpenCode extension loader already has feature parity with Claude through the shared extensions system.

2. **Testing Needed**: Create a test plan to verify:
   - Loading core extension installs files to correct paths
   - Agents appear in `agent/subagents/`
   - Picker shows all artifact sections after loading
   - Unloading removes all files correctly

3. **Documentation Gap**: Consider documenting the extension loading behavior in `.opencode/docs/architecture/extension-system.md`

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Agent path mismatch | High | Verify `agents_subdir` is passed correctly in copy_simple_files call |
| Extension not appearing in picker | Medium | Check that `extensions_module` config points to correct module |
| Merge target key mismatch | Medium | Verify manifest.json uses `opencode_md` not `claudemd` |
| State file corruption | Low | Test load/unload cycle with multiple extensions |

## Context Extension Recommendations

**None** - The current implementation is correct. The shared extension system design means both Claude and OpenCode automatically benefit from updates to the core extension loading logic.

**Recommended Follow-up Actions**:

1. **Integration Testing**: Run through full extension load/unload cycle
   ```bash
   # Test commands in Neovim
   :OpencodeExtensions  # Open picker
   # Load core extension
   # Verify files in .opencode/agent/subagents/
   # Verify picker shows all sections
   ```

2. **Verify Manifest Files**: Check all OpenCode extension manifests use `opencode_md` key
   ```bash
   jq -r '.merge_targets | keys[]' .opencode/extensions/*/manifest.json | sort -u
   # Should show: opencode_md, index
   ```

3. **Documentation**: Add a note to `.opencode/docs/guides/extension-development.md` about the shared loader architecture

## Appendix

### Key Files Analyzed

| File | Purpose | Lines |
|------|---------|-------|
| `lua/neotex/plugins/ai/shared/extensions/init.lua` | Main extension manager | 819 |
| `lua/neotex/plugins/ai/shared/extensions/loader.lua` | File copy operations | 628 |
| `lua/neotex/plugins/ai/shared/extensions/config.lua` | Configuration presets | 77 |
| `lua/neotex/plugins/ai/shared/extensions/picker.lua` | Extension picker UI | 286 |
| `lua/neotex/plugins/ai/opencode/extensions/init.lua` | OpenCode API | 13 |
| `lua/neotex/plugins/ai/opencode/extensions/config.lua` | OpenCode config | 15 |
| `lua/neotex/plugins/ai/opencode/extensions/picker.lua` | OpenCode picker | 12 |
| `lua/neotex/plugins/ai/shared/picker/config.lua` | Picker configuration | 102 |
| `lua/neotex/plugins/ai/claude/commands/picker/display/entries.lua` | Picker entries | 1088 |
| `.opencode/extensions/core/manifest.json` | Core extension manifest | 154 |

### Test Verification Steps

1. **Check Extension Loading**:
   ```lua
   :lua require('neotex.plugins.ai.opencode.extensions').load('core', {confirm=false})
   ```

2. **Verify Agent Installation**:
   ```bash
   ls .opencode/agent/subagents/
   # Should show: code-reviewer-agent.md, general-implementation-agent.md, etc.
   ```

3. **Check Picker Display**:
   - Press `<leader>ao` (or run `:OpencodeCommands`)
   - Verify all sections appear: Commands, Agents, Skills, etc.
   - Check that `[Extensions]` section shows core as "active"

4. **Verify State**:
   ```bash
   cat .opencode/extensions.json
   # Should show core in loaded_extensions
   ```

### References

- `.opencode/extensions/core/manifest.json` - Core extension definition
- `.claude/extensions/core/manifest.json` - Claude reference implementation
- `.opencode/docs/architecture/extension-system.md` - Extension system documentation
- `lua/neotex/plugins/ai/shared/extensions/` - Shared implementation
