-- neotex.plugins.ai.opencode.extensions.config
-- OpenCode-specific extension system configuration

local shared_config = require("neotex.plugins.ai.shared.extensions.config")

--- Get OpenCode extension configuration
--- @param global_dir string|nil Global directory (defaults to ~/.config/nvim)
--- @return table config OpenCode extension configuration
local function get_config(global_dir)
  return shared_config.opencode(global_dir)
end

return {
  get = get_config,
}
