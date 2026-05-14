-- neotex.plugins.ai.opencode.extensions
-- Public API for OpenCode extension management
-- Delegates to shared extension base with OpenCode-specific configuration

local shared = require("neotex.plugins.ai.shared.extensions")
local config = require("neotex.plugins.ai.opencode.extensions.config")

-- Create manager instance with OpenCode configuration
local opencode_config = config.get()
local manager = shared.create(opencode_config)

-- Export the manager API
return manager
