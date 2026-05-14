-- neotex.plugins.ai.claude.extensions.manifest
-- Claude extension manifest parsing (delegates to shared)

local shared_manifest = require("neotex.plugins.ai.shared.extensions.manifest")
local config = require("neotex.plugins.ai.claude.extensions.config")

local M = {}

local claude_config = config.get()

--- Read and validate manifest from an extension directory
--- @param extension_dir string Path to extension directory
--- @return table|nil manifest Validated manifest or nil on error
--- @return string|nil error Error message if reading/validation failed
function M.read(extension_dir)
  return shared_manifest.read(extension_dir)
end

--- Validate a manifest object
--- @param manifest table Manifest data
--- @return boolean valid True if manifest is valid
--- @return string|nil error Error message if validation failed
function M.validate(manifest)
  return shared_manifest.validate(manifest)
end

--- List all valid extensions from the global extensions directory
--- @param global_dir string|nil Global source directory (defaults to config value)
--- @return table extensions Array of {name, path, manifest} for valid extensions
function M.list_extensions(global_dir)
  local cfg = global_dir and config.get(global_dir) or claude_config
  return shared_manifest.list_extensions(cfg)
end

--- Get extension by name
--- @param name string Extension name
--- @param global_dir string|nil Global source directory
--- @return table|nil extension Extension info or nil if not found
function M.get_extension(name, global_dir)
  local cfg = global_dir and config.get(global_dir) or claude_config
  return shared_manifest.get_extension(name, cfg)
end

return M
