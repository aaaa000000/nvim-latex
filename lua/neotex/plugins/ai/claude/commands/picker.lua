-- neotex.plugins.ai.claude.commands.picker
-- Facade for Claude artifacts picker - delegates to modular implementation
-- Uses Claude-specific configuration from shared picker config

local M = {}

-- Internal implementation
local internal = require("neotex.plugins.ai.claude.commands.picker.init")
local shared_config = require("neotex.plugins.ai.shared.picker.config")

--- Show the Claude artifacts picker
--- This is the public API that external code calls
--- Delegates to the modular implementation in picker/init.lua with Claude config
--- @param opts table Telescope options (optional)
function M.show_commands_picker(opts)
  local config = shared_config.claude()
  return internal.show_commands_picker(opts, config)
end

return M
