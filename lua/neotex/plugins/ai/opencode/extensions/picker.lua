-- neotex.plugins.ai.opencode.extensions.picker
-- OpenCode extension management picker (via :OpencodeExtensions command)
-- Thin wrapper around shared picker with OpenCode-specific configuration

local shared_picker = require("neotex.plugins.ai.shared.extensions.picker")
local extensions = require("neotex.plugins.ai.opencode.extensions")

-- Create OpenCode picker instance
return shared_picker.create(extensions, {
  label = "OpenCode Extensions",
  empty_message = "No OpenCode extensions found",
})
