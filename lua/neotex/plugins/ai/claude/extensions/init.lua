-- neotex.plugins.ai.claude.extensions
-- Public API for Claude extension management
-- Delegates to shared extension base with Claude-specific configuration

local shared = require("neotex.plugins.ai.shared.extensions")
local config = require("neotex.plugins.ai.claude.extensions.config")

-- Create manager instance with Claude configuration
local claude_config = config.get()
local manager = shared.create(claude_config)

-- Export the manager API
return manager
