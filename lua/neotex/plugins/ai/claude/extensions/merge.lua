-- neotex.plugins.ai.claude.extensions.merge
-- Claude merge strategies (delegates to shared)

local shared_merge = require("neotex.plugins.ai.shared.extensions.merge")

local M = {}

-- Re-export shared functions with Claude-specific aliases for backward compatibility

--- Inject a section into CLAUDE.md
--- @param target_path string Path to CLAUDE.md
--- @param section_content string Section content (without markers)
--- @param section_id string Section identifier (e.g., "extension_lean")
--- @return boolean success True if injection succeeded
--- @return table|nil tracked Tracking data for unmerge
function M.inject_claudemd_section(target_path, section_content, section_id)
  return shared_merge.inject_section(target_path, section_content, section_id)
end

--- Remove a section from CLAUDE.md
--- @param target_path string Path to CLAUDE.md
--- @param section_id string Section identifier
--- @return boolean success True if removal succeeded
function M.remove_claudemd_section(target_path, section_id)
  return shared_merge.remove_section(target_path, section_id)
end

--- Merge settings fragment into target settings file
--- @param target_path string Path to settings.json or settings.local.json
--- @param fragment table Settings fragment to merge
--- @return boolean success True if merge succeeded
--- @return table|nil tracked Tracking data for unmerge
function M.merge_settings(target_path, fragment)
  return shared_merge.merge_settings(target_path, fragment)
end

--- Remove entries that were added by merge_settings
--- @param target_path string Path to settings file
--- @param tracked_entries table Tracking data from merge_settings
--- @return boolean success True if unmerge succeeded
function M.unmerge_settings(target_path, tracked_entries)
  return shared_merge.unmerge_settings(target_path, tracked_entries)
end

--- Append entries to index.json
--- @param target_path string Path to index.json
--- @param entries table Array of entries to append
--- @return boolean success True if append succeeded
--- @return table|nil tracked Tracking data for removal
function M.append_index_entries(target_path, entries)
  return shared_merge.append_index_entries(target_path, entries)
end

--- Remove index entries by tracked paths
--- @param target_path string Path to index.json
--- @param tracked table Tracking data from append_index_entries
--- @return boolean success True if removal succeeded
function M.remove_index_entries_tracked(target_path, tracked)
  return shared_merge.remove_index_entries_tracked(target_path, tracked)
end

return M
