-- neotex.plugins.ai.shared.picker.ai-tool-picker
-- Unified two-stage AI tool picker with session management
-- Stage 1: vim.ui.select for Claude Code vs OpenCode
-- Stage 2: per-tool session picker (Telescope dropdown for OpenCode, delegate for Claude)

local M = {}

local data_dir = vim.fn.stdpath("data") .. "/neotex-ai"
local tool_prefs_file = data_dir .. "/tool-prefs.json"
local opencode_session_file = data_dir .. "/opencode-last-session.json"

-- Track initialization
M._initialized = false

-- Centralized active tool state
M._active_tool = nil -- "claude" | "opencode" | nil
M._active_tool_bufnr = nil -- buffer number of the active tool terminal

-- In-memory cache of tool preferences
local tool_prefs = {
  last_tool = nil, -- "claude" | "opencode" | nil
  last_updated = nil,
}

-----------------------------------------------------------------------
-- DATA DIRECTORY & ATOMIC WRITE HELPERS
-----------------------------------------------------------------------

local function ensure_data_dir()
  if vim.fn.isdirectory(data_dir) == 0 then
    vim.fn.mkdir(data_dir, "p")
  end
end

local function atomic_write(filepath, data)
  local encoded = vim.fn.json_encode(data)
  local tmp = filepath .. ".tmp"
  local f = io.open(tmp, "w")
  if not f then
    return false
  end
  f:write(encoded)
  f:close()
  local ok = os.rename(tmp, filepath)
  return ok ~= nil
end

local function atomic_read(filepath)
  local f = io.open(filepath, "r")
  if not f then
    return nil
  end
  local content = f:read("*all")
  f:close()
  if content == "" then
    return nil
  end
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok then
    return nil
  end
  return data
end

-----------------------------------------------------------------------
-- TOOL LIFECYCLE CLEANUP
-----------------------------------------------------------------------

local function _register_tool_cleanup(tool_name, bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  M._active_tool = tool_name
  M._active_tool_bufnr = bufnr
  local group = vim.api.nvim_create_augroup("NixAIToolCleanup", { clear = true })
  vim.api.nvim_create_autocmd({ "TermClose", "BufWipeout" }, {
    group = group,
    buffer = bufnr,
    once = true,
    callback = function()
      if M._active_tool_bufnr == bufnr then
        M._active_tool = nil
        M._active_tool_bufnr = nil
      end
    end,
  })
end

-----------------------------------------------------------------------
-- TOOL PREFERENCE PERSISTENCE
-----------------------------------------------------------------------

local function load_tool_prefs()
  local data = atomic_read(tool_prefs_file)
  if data and (data.last_tool == "claude" or data.last_tool == "opencode") then
    tool_prefs.last_tool = data.last_tool
    tool_prefs.last_updated = data.last_updated
  end
end

local function save_tool_prefs(tool)
  tool_prefs.last_tool = tool
  tool_prefs.last_updated = os.time()
  ensure_data_dir()
  atomic_write(tool_prefs_file, tool_prefs)
end

-----------------------------------------------------------------------
-- ACTIVE TERMINAL DETECTION
-----------------------------------------------------------------------

-- Check if a terminal buffer is alive (valid + terminal buftype + running job)
local function _is_live_terminal(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  local buftype_ok, buftype = pcall(vim.api.nvim_get_option_value, "buftype", { buf = bufnr })
  if not buftype_ok or buftype ~= "terminal" then
    return false
  end
  local job_id = vim.b[bufnr].terminal_job_id
  if not job_id then
    return false
  end
  return vim.fn.jobwait({ job_id }, 0)[1] == -1
end

-- Detect active Claude terminal using the plugin's own instance registry.
-- Falls back to heuristic buffer-name scanning if the registry is inaccessible.
local function detect_active_claude()
  local ok, claude_code = pcall(require, "claude-code")
  if ok and claude_code.claude_code and type(claude_code.claude_code.instances) == "table" then
    local active = {}
    for _, bufnr in pairs(claude_code.claude_code.instances) do
      if _is_live_terminal(bufnr) then
        table.insert(active, bufnr)
      end
    end
    return #active > 0, active
  end

  -- Fallback: heuristic buffer-name scanning
  local sm_ok, session_manager = pcall(require, "neotex.plugins.ai.claude.core.session-manager")
  if not sm_ok then
    return false, {}
  end
  local claude_buffers = session_manager.detect_claude_buffers()
  local active = {}
  for _, bufnr in ipairs(claude_buffers) do
    if _is_live_terminal(bufnr) then
      table.insert(active, bufnr)
    end
  end
  return #active > 0, active
end

-- Detect active OpenCode terminal using snacks.terminal.list().
-- This already uses the authoritative snacks terminal identity, so no rewrite needed.
local function detect_active_opencode()
  local ok, snacks_term = pcall(require, "snacks.terminal")
  if not ok or not snacks_term.list then
    return false, {}
  end
  local all_terms = snacks_term.list()
  local active = {}
  for _, term in ipairs(all_terms) do
    local buf = term.buf
    if buf and vim.api.nvim_buf_is_valid(buf) then
      local snacks_data = vim.b[buf].snacks_terminal
      if snacks_data then
        local cmd = snacks_data.cmd or snacks_data.args or {}
        local cmd_str = type(cmd) == "table" and table.concat(cmd, " ") or tostring(cmd)
        if cmd_str:match("opencode%s+%-%-port") then
          table.insert(active, buf)
        end
      end
    end
  end
  return #active > 0, active
end

-----------------------------------------------------------------------
-- STAGE 1: TOOL PICKER (vim.ui.select)
-----------------------------------------------------------------------

function M.show_tool_picker()
  ensure_data_dir()
  load_tool_prefs()

  local items = {
    { label = "ClaudeCode", value = "claude" },
    { label = "OpenCode", value = "opencode" },
  }

  -- Reorder to show last-selected tool first
  if tool_prefs.last_tool == "opencode" then
    items = { items[2], items[1] }
  end

  vim.ui.select(items, {
    prompt = "Select AI tool:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    save_tool_prefs(choice.value)
    if choice.value == "claude" then
      -- Hide OpenCode if it is currently visible before opening Claude
      local has_oc, oc_bufs = detect_active_opencode()
      if has_oc then
        for _, buf in ipairs(oc_bufs) do
          if #vim.fn.win_findbuf(buf) > 0 then
            local ok, opencode_mod = pcall(require, "opencode")
            if ok then opencode_mod.toggle() end
            break
          end
        end
      end
      M.show_claude_session_picker()
    elseif choice.value == "opencode" then
      -- Hide Claude if it is currently visible before opening OpenCode
      local has_cc, cc_bufs = detect_active_claude()
      if has_cc then
        for _, buf in ipairs(cc_bufs) do
          if #vim.fn.win_findbuf(buf) > 0 then
            vim.cmd("ClaudeCode")
            break
          end
        end
      end
      M.show_opencode_session_picker()
    end
  end)
end

-----------------------------------------------------------------------
-- UNIFIED COMMANDS LOADER PICKER (<leader>al)
-----------------------------------------------------------------------

function M.show_commands_picker()
  ensure_data_dir()
  load_tool_prefs()
  local mode = vim.api.nvim_get_mode().mode

  local items = {
    { label = "ClaudeCode", value = "claude" },
    { label = "OpenCode", value = "opencode" },
  }
  if tool_prefs.last_tool == "opencode" then
    items = { items[2], items[1] }
  end

  vim.ui.select(items, {
    prompt = "Select AI commands:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    save_tool_prefs(choice.value)
    if mode == "v" or mode == "V" or mode == "\22" then
      if choice.value == "claude" then
        require("neotex.plugins.ai.claude.core.visual").send_visual_to_claude_with_prompt()
      else
        require("neotex.plugins.ai.opencode.core.visual").send_visual_to_opencode_with_prompt()
      end
    else
      vim.cmd(choice.value == "claude" and "ClaudeCommands" or "OpencodeCommands")
    end
  end)
end

-----------------------------------------------------------------------
-- STAGE 2: CLAUDE PATH (delegate to existing picker)
-----------------------------------------------------------------------

function M.show_claude_session_picker()
  local ok, claude_session = pcall(require, "neotex.plugins.ai.claude.core.session")
  if ok and claude_session.show_session_picker then
    claude_session.show_session_picker()
    -- After the picker completes, detect the launched buffer and register cleanup.
    -- Use vim.defer_fn to allow the terminal to be created first.
    vim.defer_fn(function()
      local has, bufs = detect_active_claude()
      if has and bufs[1] then
        _register_tool_cleanup("claude", bufs[1])
      end
    end, 500)
  else
    vim.notify("Claude session picker not available", vim.log.levels.ERROR)
  end
end

-----------------------------------------------------------------------
-- STAGE 2: OPENCODE PATH (Telescope dropdown with 3 options)
-----------------------------------------------------------------------

function M.show_opencode_session_picker()
  -- Try to load OpenCode last session info for the "restore" option
  local last_session_data = atomic_read(opencode_session_file)
  local age_text = ""
  local last_session_id = nil
  if last_session_data and last_session_data.session_id then
    last_session_id = last_session_data.session_id
    local age = os.time() - (last_session_data.timestamp or 0)
    if age < 60 then
      age_text = "just now"
    elseif age < 3600 then
      age_text = string.format("%d min ago", math.floor(age / 60))
    elseif age < 86400 then
      age_text = string.format("%d hr ago", math.floor(age / 3600))
    else
      age_text = string.format("%d days ago", math.floor(age / 86400))
    end
  end

  local opencode_mod = require("opencode")

  local options = {
    {
      display = "Create new session",
      value = "new",
      ord = "Create new session",
    },
    {
      display = last_session_id
        and string.format("Restore last session (%s)", age_text)
        or "Restore last session (none yet)",
      value = "restore",
      ord = "Restore last session",
    },
    {
      display = "Browse all sessions",
      value = "browse",
      ord = "Browse all sessions",
    },
  }

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  pickers.new(require("telescope.themes").get_dropdown({
    winblend = 10,
    width = 0.5,
    previewer = false,
    layout_config = {
      width = 60,
      height = 10,
    },
  }), {
    prompt_title = "OpenCode Session",
    finder = finders.new_table({
      results = options,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.ord,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if not selection then
          return
        end
        local choice = selection.value.value

        -- Toggle opens the terminal (defaults to new session in TUI)
        opencode_mod.toggle()

        -- Register active tool state after toggle creates the terminal
        vim.defer_fn(function()
          local has, bufs = detect_active_opencode()
          if has and bufs[1] then
            _register_tool_cleanup("opencode", bufs[1])
          end
        end, 500)

        if choice == "restore" then
          if last_session_id then
            local server_mod = require("opencode.server")
            server_mod.get()
              :next(function(server)
                server:select_session(last_session_id)
              end)
              :catch(function(err)
                if err then
                  vim.notify(
                    "Failed to restore session: " .. tostring(err),
                    vim.log.levels.ERROR,
                    { title = "OpenCode" }
                  )
                end
              end)
          else
            vim.notify("No previous OpenCode session to restore", vim.log.levels.WARN)
          end
        elseif choice == "browse" then
          opencode_mod.select_session()
        end
        -- "new" needs no follow-up: toggle() already opens a fresh session in the TUI
      end)
      return true
    end,
  }):find()
end

-----------------------------------------------------------------------
-- SMART TOGGLE (primary entry point)
-----------------------------------------------------------------------

function M.smart_toggle()
  ensure_data_dir()
  load_tool_prefs()

  local has_claude, claude_bufs = detect_active_claude()
  local has_opencode, opencode_bufs = detect_active_opencode()

  -- Neither running → show picker
  if not has_claude and not has_opencode then
    M.show_tool_picker()
    return
  end

  -- Only Claude running → toggle it
  if has_claude and not has_opencode then
    _register_tool_cleanup("claude", claude_bufs[1])
    vim.cmd("ClaudeCode")
    return
  end

  -- Only OpenCode running → toggle it
  if has_opencode and not has_claude then
    _register_tool_cleanup("opencode", opencode_bufs[1])
    local ok, opencode_mod = pcall(require, "opencode")
    if ok then opencode_mod.toggle() end
    return
  end

  -- Both running → cycle: just opencode → just claude → neither → just opencode → ...
  local claude_vis = false
  for _, buf in ipairs(claude_bufs) do
    if #vim.fn.win_findbuf(buf) > 0 then claude_vis = true; break end
  end
  local opencode_vis = false
  for _, buf in ipairs(opencode_bufs) do
    if #vim.fn.win_findbuf(buf) > 0 then opencode_vis = true; break end
  end

  local ok, opencode_mod = pcall(require, "opencode")

  if opencode_vis and not claude_vis then
    -- just opencode → just claude: hide opencode, show claude
    if ok then opencode_mod.toggle() end
    vim.cmd("ClaudeCode")
  elseif claude_vis and not opencode_vis then
    -- just claude → neither: hide claude
    vim.cmd("ClaudeCode")
  else
    -- neither or both visible → just opencode: show opencode, hide claude
    if not opencode_vis and ok then opencode_mod.toggle() end
    if claude_vis then vim.cmd("ClaudeCode") end
  end
end

-----------------------------------------------------------------------
-- SETUP
-----------------------------------------------------------------------

-- Shortcut alias for ensure_data_dir (used in show_tool_picker)
local function ensure_dir()
  ensure_data_dir()
end
M._ensure_dir = ensure_dir

function M.setup()
  if M._initialized then
    return
  end
  M._initialized = true

  ensure_data_dir()
  load_tool_prefs()

  -- Register OpenCodeEvent:session.idle autocmd to track last session
  vim.api.nvim_create_augroup("NixAIOpencodeSession", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = "NixAIOpencodeSession",
    pattern = "OpencodeEvent:session.idle",
    callback = function(event)
      local session_id = nil
      local data = event.data
      if type(data) == "string" then
        session_id = data
      elseif type(data) == "table" then
        session_id = data.session_id or data.id or data.session
      end
      if session_id then
        ensure_data_dir()
        atomic_write(opencode_session_file, {
          session_id = session_id,
          timestamp = os.time(),
        })
      end
    end,
  })
end

return M
