-- Label and Flag Management Module
-- Provides label/flag operations for Himalaya email client
-- Includes cross-account compatibility (Gmail + Protonmail)

local M = {}

-- Dependencies
local state = require('neotex.plugins.tools.himalaya.core.state')
local config = require('neotex.plugins.tools.himalaya.core.config')
local utils = require('neotex.plugins.tools.himalaya.utils')
local logger = require('neotex.plugins.tools.himalaya.core.logger')
local notify = require('neotex.util.notifications')

-- Standard IMAP flags that work universally
-- These are portable across Gmail, Protonmail, and other providers
M.STANDARD_FLAGS = {
  { name = 'seen', display = 'Read/Unread', desc = 'Mark as read or unread' },
  { name = 'flagged', display = 'Starred/Flagged', desc = 'Toggle star/flag' },
  { name = 'answered', display = 'Replied', desc = 'Mark as replied' },
  { name = 'deleted', display = 'Deleted', desc = 'Mark for deletion' },
  { name = 'draft', display = 'Draft', desc = 'Mark as draft' },
}

-- System folders to exclude from label pickers
local SYSTEM_FOLDERS = {
  'INBOX', 'Drafts', 'Sent', 'Trash', 'Spam', 'Junk',
  '[Gmail]', 'All Mail', 'Starred', 'Important',
  'Archive', 'Notes', 'Outbox'
}

-- ============================================================================
-- Utility Functions
-- ============================================================================

--- Check if a folder is a system folder
--- @param folder_name string The folder name to check
--- @return boolean True if system folder
local function is_system_folder(folder_name)
  local lower = folder_name:lower()
  for _, sys in ipairs(SYSTEM_FOLDERS) do
    if lower == sys:lower() or lower:match('^%[' .. sys:lower():gsub('%[', ''):gsub('%]', '') .. '%]') then
      return true
    end
  end
  -- Gmail special folders
  if lower:match('^%[gmail%]') then
    return true
  end
  return false
end

--- Normalize label path for account-specific handling
--- Gmail uses top-level folders, Protonmail uses Labels/ prefix
--- @param label_name string The label name
--- @param account string The account name
--- @return string Normalized label path
local function normalize_label_path(label_name, account)
  -- Protonmail (logos account) requires Labels/ prefix
  if account == 'logos' and not label_name:match('^Labels/') then
    return 'Labels/' .. label_name
  end
  return label_name
end

--- Get the current email ID from cursor position or selection
--- @return string|nil email_id The email ID or nil
local function get_current_email_id()
  local line_num = vim.fn.line('.')
  local line_map = state.get('email_list.line_map', {})
  local metadata = line_map[line_num]

  if metadata then
    return metadata.email_id or metadata.id
  end
  return nil
end

--- Get email IDs to operate on (selection-aware)
--- Returns selected emails if any, otherwise current email under cursor
--- @return table email_ids Array of email IDs
--- @return boolean is_selection True if operating on selection
local function get_email_ids_to_operate()
  local selected = state.get_selected_emails()

  if #selected > 0 then
    local ids = {}
    for _, email in ipairs(selected) do
      table.insert(ids, email.id)
    end
    return ids, true
  end

  -- No selection, use current email
  local current_id = get_current_email_id()
  if current_id then
    return { current_id }, false
  end

  return {}, false
end

-- ============================================================================
-- Flag Operations (Universal across providers)
-- ============================================================================

--- Get current flags for an email
--- @param email_id string The email ID
--- @param account string|nil Account name (uses current if nil)
--- @param folder string|nil Folder name (uses current if nil)
--- @return table|nil flags Array of current flags or nil on error
function M.get_email_flags(email_id, account, folder)
  account = account or state.get_current_account()
  folder = folder or state.get_current_folder()

  if not email_id or not account or not folder then
    logger.error('get_email_flags: missing required parameters')
    return nil
  end

  -- Use himalaya to get envelope which includes flags
  local result = utils.execute_himalaya(
    { 'envelope', 'list', '--ids', email_id },
    { account = account, folder = folder }
  )

  if result and result[1] and result[1].flags then
    return result[1].flags
  end

  return nil
end

--- Check if an email has a specific flag
--- @param flags table Array of flags
--- @param flag_name string The flag to check (e.g., 'seen', 'flagged')
--- @return boolean True if flag is set
local function has_flag(flags, flag_name)
  if not flags then return false end
  for _, f in ipairs(flags) do
    if f:lower() == flag_name:lower() then
      return true
    end
  end
  return false
end

--- Add flag to emails
--- @param email_ids table Array of email IDs
--- @param flag_name string The flag to add
--- @param account string|nil Account name
--- @param folder string|nil Folder name
--- @return boolean success
function M.add_flag(email_ids, flag_name, account, folder)
  account = account or state.get_current_account()
  folder = folder or state.get_current_folder()

  if #email_ids == 0 then
    notify.himalaya('No emails selected', notify.categories.WARNING)
    return false
  end

  local ids_str = table.concat(email_ids, ',')

  local result, err = utils.execute_himalaya(
    { 'flag', 'add', flag_name, '--ids', ids_str },
    { account = account, folder = folder }
  )

  if err then
    notify.himalaya('Failed to add flag: ' .. err, notify.categories.ERROR)
    return false
  end

  logger.info('Added flag', { flag = flag_name, count = #email_ids })
  return true
end

--- Remove flag from emails
--- @param email_ids table Array of email IDs
--- @param flag_name string The flag to remove
--- @param account string|nil Account name
--- @param folder string|nil Folder name
--- @return boolean success
function M.remove_flag(email_ids, flag_name, account, folder)
  account = account or state.get_current_account()
  folder = folder or state.get_current_folder()

  if #email_ids == 0 then
    notify.himalaya('No emails selected', notify.categories.WARNING)
    return false
  end

  local ids_str = table.concat(email_ids, ',')

  local result, err = utils.execute_himalaya(
    { 'flag', 'remove', flag_name, '--ids', ids_str },
    { account = account, folder = folder }
  )

  if err then
    notify.himalaya('Failed to remove flag: ' .. err, notify.categories.ERROR)
    return false
  end

  logger.info('Removed flag', { flag = flag_name, count = #email_ids })
  return true
end

--- Toggle read/unread status (selection-aware)
--- @param email_ids table|nil Optional specific email IDs; uses selection if nil
function M.toggle_read_status(email_ids)
  local is_selection = false
  if not email_ids then
    email_ids, is_selection = get_email_ids_to_operate()
  end

  if #email_ids == 0 then
    notify.himalaya('No email to toggle read status', notify.categories.WARNING)
    return
  end

  local account = state.get_current_account()
  local folder = state.get_current_folder()

  -- For single email, check current state and toggle
  -- For multiple emails, mark all as read (most common use case)
  local flags = M.get_email_flags(email_ids[1], account, folder)
  local is_read = has_flag(flags, 'seen')

  local success
  if is_read then
    success = M.remove_flag(email_ids, 'seen', account, folder)
    if success then
      local msg = #email_ids == 1 and 'Marked as unread' or
                  string.format('Marked %d emails as unread', #email_ids)
      notify.himalaya(msg, notify.categories.STATUS)
    end
  else
    success = M.add_flag(email_ids, 'seen', account, folder)
    if success then
      local msg = #email_ids == 1 and 'Marked as read' or
                  string.format('Marked %d emails as read', #email_ids)
      notify.himalaya(msg, notify.categories.STATUS)
    end
  end

  if success then
    -- Clear selection after bulk operation
    if is_selection then
      state.clear_selection()
    end
    -- Refresh email list to show updated status
    local ok, email_list = pcall(require, 'neotex.plugins.tools.himalaya.ui.email_list')
    if ok and email_list.refresh_email_list then
      email_list.refresh_email_list()
    end
  end
end

--- Toggle star/flagged status (selection-aware)
--- @param email_ids table|nil Optional specific email IDs; uses selection if nil
function M.toggle_star_status(email_ids)
  local is_selection = false
  if not email_ids then
    email_ids, is_selection = get_email_ids_to_operate()
  end

  if #email_ids == 0 then
    notify.himalaya('No email to toggle star', notify.categories.WARNING)
    return
  end

  local account = state.get_current_account()
  local folder = state.get_current_folder()

  -- Check current state and toggle
  local flags = M.get_email_flags(email_ids[1], account, folder)
  local is_starred = has_flag(flags, 'flagged')

  local success
  if is_starred then
    success = M.remove_flag(email_ids, 'flagged', account, folder)
    if success then
      local msg = #email_ids == 1 and 'Removed star' or
                  string.format('Removed star from %d emails', #email_ids)
      notify.himalaya(msg, notify.categories.STATUS)
    end
  else
    success = M.add_flag(email_ids, 'flagged', account, folder)
    if success then
      local msg = #email_ids == 1 and 'Added star' or
                  string.format('Added star to %d emails', #email_ids)
      notify.himalaya(msg, notify.categories.STATUS)
    end
  end

  if success then
    -- Clear selection after bulk operation
    if is_selection then
      state.clear_selection()
    end
    -- Refresh email list to show updated status
    local ok, email_list = pcall(require, 'neotex.plugins.tools.himalaya.ui.email_list')
    if ok and email_list.refresh_email_list then
      email_list.refresh_email_list()
    end
  end
end

--- Toggle read status for current email (wrapper for keybinding)
function M.toggle_read_current()
  M.toggle_read_status()
end

--- Toggle star status for current email (wrapper for keybinding)
function M.toggle_star_current()
  M.toggle_star_status()
end

-- ============================================================================
-- Label/Folder Application (Account-aware)
-- ============================================================================

--- Get available labels/folders for current account
--- Filters out system folders
--- @param account string|nil Account name (uses current if nil)
--- @return table labels Array of label names
function M.get_available_labels(account)
  account = account or state.get_current_account()

  local result = utils.execute_himalaya(
    { 'folder', 'list' },
    { account = account }
  )

  if not result then
    return {}
  end

  local labels = {}
  for _, folder in ipairs(result) do
    local name = folder.name or folder
    if type(name) == 'string' and not is_system_folder(name) then
      table.insert(labels, name)
    end
  end

  return labels
end

--- Apply label to emails by copying them to the label folder
--- Uses `message copy` command for folder-based labels
--- @param email_ids table Array of email IDs
--- @param label_name string The label/folder name
--- @param account string|nil Account name
--- @param folder string|nil Source folder name
--- @return boolean success
function M.apply_label(email_ids, label_name, account, folder)
  account = account or state.get_current_account()
  folder = folder or state.get_current_folder()

  if #email_ids == 0 then
    notify.himalaya('No emails selected', notify.categories.WARNING)
    return false
  end

  -- Normalize label path for account
  local target_folder = normalize_label_path(label_name, account)

  local ids_str = table.concat(email_ids, ',')

  -- Use message copy to apply label (copy to folder)
  local result, err = utils.execute_himalaya(
    { 'message', 'copy', target_folder, '--ids', ids_str },
    { account = account, folder = folder }
  )

  if err then
    notify.himalaya('Failed to apply label: ' .. err, notify.categories.ERROR)
    return false
  end

  local msg = #email_ids == 1 and
              string.format('Applied label "%s"', label_name) or
              string.format('Applied label "%s" to %d emails', label_name, #email_ids)
  notify.himalaya(msg, notify.categories.STATUS)

  logger.info('Applied label', { label = label_name, count = #email_ids })
  return true
end

--- Show picker for standard flags
--- @param email_ids table Array of email IDs
local function show_standard_flag_picker(email_ids)
  local account = state.get_current_account()
  local folder = state.get_current_folder()

  -- Build picker items
  local items = {}
  for _, flag in ipairs(M.STANDARD_FLAGS) do
    table.insert(items, {
      display = flag.display,
      flag_name = flag.name,
      desc = flag.desc,
    })
  end

  vim.ui.select(items, {
    prompt = 'Select flag to apply:',
    format_item = function(item)
      return item.display .. ' - ' .. item.desc
    end,
  }, function(choice)
    if not choice then return end

    -- For seen and flagged, use toggle
    if choice.flag_name == 'seen' then
      M.toggle_read_status(email_ids)
    elseif choice.flag_name == 'flagged' then
      M.toggle_star_status(email_ids)
    else
      -- For other flags, just add
      if M.add_flag(email_ids, choice.flag_name, account, folder) then
        -- Clear selection after operation
        state.clear_selection()
        -- Refresh email list
        local ok, email_list = pcall(require, 'neotex.plugins.tools.himalaya.ui.email_list')
        if ok and email_list.refresh_email_list then
          email_list.refresh_email_list()
        end
      end
    end
  end)
end

--- Show flag/label picker (selection-aware)
--- Presents standard flags plus available folder labels
--- @param email_ids table|nil Optional specific email IDs; uses selection if nil
function M.show_flag_picker(email_ids)
  local is_selection = false
  if not email_ids then
    email_ids, is_selection = get_email_ids_to_operate()
  end

  if #email_ids == 0 then
    notify.himalaya('No email selected', notify.categories.WARNING)
    return
  end

  local account = state.get_current_account()

  -- Build combined picker: flags + labels
  local items = {}

  -- Add section header for flags
  table.insert(items, { display = '--- Standard Flags ---', is_header = true })

  for _, flag in ipairs(M.STANDARD_FLAGS) do
    if flag.name == 'seen' or flag.name == 'flagged' then
      table.insert(items, {
        display = flag.display,
        flag_name = flag.name,
        desc = flag.desc,
        type = 'flag'
      })
    end
  end

  -- Add section header for labels
  local labels = M.get_available_labels(account)
  if #labels > 0 then
    table.insert(items, { display = '--- Labels/Folders ---', is_header = true })
    for _, label in ipairs(labels) do
      table.insert(items, {
        display = label,
        label_name = label,
        type = 'label'
      })
    end
  end

  -- Add create new folder option
  table.insert(items, { display = '--- Actions ---', is_header = true })
  table.insert(items, { display = '+ Create new folder...', type = 'create' })

  vim.ui.select(items, {
    prompt = string.format('Apply to %d email(s):', #email_ids),
    format_item = function(item)
      if item.is_header then
        return item.display
      elseif item.type == 'flag' then
        return '  [Flag] ' .. item.display
      elseif item.type == 'label' then
        return '  [Label] ' .. item.display
      elseif item.type == 'create' then
        return item.display
      end
      return item.display
    end,
  }, function(choice)
    if not choice or choice.is_header then return end

    if choice.type == 'flag' then
      if choice.flag_name == 'seen' then
        M.toggle_read_status(email_ids)
      elseif choice.flag_name == 'flagged' then
        M.toggle_star_status(email_ids)
      end
    elseif choice.type == 'label' then
      if M.apply_label(email_ids, choice.label_name) then
        if is_selection then
          state.clear_selection()
        end
        local ok, email_list = pcall(require, 'neotex.plugins.tools.himalaya.ui.email_list')
        if ok and email_list.refresh_email_list then
          email_list.refresh_email_list()
        end
      end
    elseif choice.type == 'create' then
      M.prompt_create_folder(function(folder_name)
        if folder_name then
          if M.apply_label(email_ids, folder_name) then
            if is_selection then
              state.clear_selection()
            end
            local ok, email_list = pcall(require, 'neotex.plugins.tools.himalaya.ui.email_list')
            if ok and email_list.refresh_email_list then
              email_list.refresh_email_list()
            end
          end
        end
      end)
    end
  end)
end

-- ============================================================================
-- Folder Management
-- ============================================================================

--- Create a new folder
--- @param folder_name string The folder name to create
--- @param account string|nil Account name
--- @return boolean success
function M.create_folder(folder_name, account)
  account = account or state.get_current_account()

  if not folder_name or folder_name == '' then
    notify.himalaya('Folder name cannot be empty', notify.categories.WARNING)
    return false
  end

  -- Normalize path for account
  local full_path = normalize_label_path(folder_name, account)

  local result, err = utils.execute_himalaya(
    { 'folder', 'create', full_path },
    { account = account }
  )

  if err then
    notify.himalaya('Failed to create folder: ' .. err, notify.categories.ERROR)
    return false
  end

  notify.himalaya('Created folder: ' .. folder_name, notify.categories.STATUS)
  logger.info('Created folder', { folder = folder_name, account = account })
  return true
end

--- Delete a folder
--- @param folder_name string The folder name to delete
--- @param account string|nil Account name
--- @return boolean success
function M.delete_folder(folder_name, account)
  account = account or state.get_current_account()

  if not folder_name or folder_name == '' then
    notify.himalaya('Folder name cannot be empty', notify.categories.WARNING)
    return false
  end

  -- Normalize path for account
  local full_path = normalize_label_path(folder_name, account)

  local result, err = utils.execute_himalaya(
    { 'folder', 'delete', full_path },
    { account = account }
  )

  if err then
    notify.himalaya('Failed to delete folder: ' .. err, notify.categories.ERROR)
    return false
  end

  notify.himalaya('Deleted folder: ' .. folder_name, notify.categories.STATUS)
  logger.info('Deleted folder', { folder = folder_name, account = account })
  return true
end

--- Prompt user to create a new folder
--- @param callback function|nil Callback with folder name on success
function M.prompt_create_folder(callback)
  vim.ui.input({ prompt = 'New folder name: ' }, function(name)
    if name and name ~= '' then
      if M.create_folder(name) then
        if callback then
          callback(name)
        end
      end
    end
  end)
end

--- Show folder picker for deletion with confirmation
function M.prompt_delete_folder()
  local account = state.get_current_account()
  local labels = M.get_available_labels(account)

  if #labels == 0 then
    notify.himalaya('No custom folders to delete', notify.categories.WARNING)
    return
  end

  vim.ui.select(labels, {
    prompt = 'Select folder to delete:',
  }, function(choice)
    if not choice then return end

    -- Confirm deletion
    vim.ui.select({ 'Yes, delete', 'Cancel' }, {
      prompt = string.format('Delete folder "%s"? This cannot be undone.', choice),
    }, function(confirm)
      if confirm == 'Yes, delete' then
        M.delete_folder(choice)
      end
    end)
  end)
end

--- Show label management menu (create/delete)
function M.show_label_management_menu()
  local items = {
    { display = 'Create new folder', action = 'create' },
    { display = 'Delete folder', action = 'delete' },
  }

  vim.ui.select(items, {
    prompt = 'Label Management:',
    format_item = function(item) return item.display end,
  }, function(choice)
    if not choice then return end

    if choice.action == 'create' then
      M.prompt_create_folder()
    elseif choice.action == 'delete' then
      M.prompt_delete_folder()
    end
  end)
end

-- ============================================================================
-- Module Export
-- ============================================================================

return M
