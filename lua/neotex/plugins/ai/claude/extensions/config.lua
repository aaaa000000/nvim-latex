-- neotex.plugins.ai.claude.extensions.config
-- Claude-specific extension system configuration

local shared_config = require("neotex.plugins.ai.shared.extensions.config")

--- Get Claude extension configuration
--- @param global_dir string|nil Global directory (defaults to ~/.config/nvim)
--- @return table config Claude extension configuration
local function get_config(global_dir)
  return shared_config.claude(global_dir)
end

return {
  get = get_config,
}
