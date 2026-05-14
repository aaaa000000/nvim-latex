-- neotex.plugins.ai.opencode.commands.picker
-- Facade for OpenCode artifacts picker - delegates to shared picker implementation
-- Uses OpenCode-specific configuration from shared picker config

local M = {}

-- Internal implementation (reuses Claude's picker infrastructure)
local internal = require("neotex.plugins.ai.claude.commands.picker.init")
local shared_config = require("neotex.plugins.ai.shared.picker.config")

--- Show the OpenCode artifacts picker
--- This is the public API that external code calls
--- Delegates to the shared picker implementation with OpenCode config
--- @param opts table Telescope options (optional)
function M.show_commands_picker(opts)
  local config = shared_config.opencode()
  return internal.show_commands_picker(opts, config)
end

return M
