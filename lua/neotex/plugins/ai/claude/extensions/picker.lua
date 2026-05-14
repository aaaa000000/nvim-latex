-- neotex.plugins.ai.claude.extensions.picker
-- Claude extension management picker (via :ClaudeExtensions command)
-- Thin wrapper around shared picker with Claude-specific configuration

local shared_picker = require("neotex.plugins.ai.shared.extensions.picker")
local extensions = require("neotex.plugins.ai.claude.extensions")

-- Create Claude picker instance
return shared_picker.create(extensions, {
  label = "Claude Extensions",
  empty_message = "No extensions found in global directory",
})
