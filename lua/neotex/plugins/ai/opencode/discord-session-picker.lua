-----------------------------------------------------------
-- Discord Session Picker (Telescope)
--
-- Telescope picker for viewing and managing Discord-linked
-- OpenCode sessions via the bot's HTTP API. Shows session
-- name, status, and linked timestamp in a searchable list
-- with metadata preview.
--
-- Actions:
--   <CR>  - Kill selected session and refresh picker
--   <C-o> - Copy thread URL to clipboard
--
-- Environment variables:
--   DISCORD_BOT_URL        - Bot API base URL (default: http://localhost:8080)
--   DISCORD_BOT_LINK_TOKEN - Bearer token for API auth
--
-- Usage:
--   require("neotex.plugins.ai.opencode.discord-session-picker").show()
--
-- This is a utility module, NOT a lazy.nvim plugin spec.
-----------------------------------------------------------

local M = {}

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------

local BOT_URL = vim.env.DISCORD_BOT_URL or "http://localhost:8080"
local TOKEN = vim.env.DISCORD_BOT_LINK_TOKEN

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

--- Build the Authorization header value.
---@return string|nil header The Bearer token header, or nil if not configured
local function _auth_header()
  if not TOKEN or TOKEN == "" then
    return nil
  end
  return "Bearer " .. TOKEN
end

--- Truncate a string to max_len, appending ellipsis if needed.
---@param str string
---@param max_len number
---@return string
local function _truncate(str, max_len)
  if #str <= max_len then
    return str
  end
  return str:sub(1, max_len - 1) .. "~"
end

--- Format a timestamp as relative time (e.g., "5m ago", "2h ago").
---@param timestamp string|number ISO 8601 timestamp or unix epoch
---@return string Formatted relative time
local function _format_relative_time(timestamp)
  if not timestamp then
    return "-"
  end

  local epoch
  if type(timestamp) == "number" then
    epoch = timestamp
  elseif type(timestamp) == "string" then
    -- Try parsing ISO 8601 (basic: YYYY-MM-DDTHH:MM:SSZ)
    local y, mo, d, h, mi, s = timestamp:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    if y then
      epoch = os.time({ year = tonumber(y), month = tonumber(mo), day = tonumber(d),
        hour = tonumber(h), min = tonumber(mi), sec = tonumber(s) })
    else
      return timestamp
    end
  else
    return "-"
  end

  local elapsed = os.difftime(os.time(), epoch)
  if elapsed < 0 then elapsed = 0 end

  local hours = math.floor(elapsed / 3600)
  local mins = math.floor((elapsed % 3600) / 60)

  if hours > 24 then
    return math.floor(hours / 24) .. "d ago"
  elseif hours > 0 then
    return hours .. "h ago"
  elseif mins > 0 then
    return mins .. "m ago"
  else
    return "just now"
  end
end

--- Make an HTTP request via curl and return parsed JSON.
---@param method string HTTP method (GET, POST)
---@param path string API path
---@param body table|nil Request body
---@param callback function Called with (err, data)
local function _http_request(method, path, body, callback)
  local url = BOT_URL .. path
  local auth = _auth_header()

  if not auth then
    vim.schedule(function()
      callback("DISCORD_BOT_LINK_TOKEN not set -- check env", nil)
    end)
    return
  end

  local cmd = {
    "curl", "-s", "-S",
    "-X", method,
    "-H", "Content-Type: application/json",
    "-H", "Authorization: " .. auth,
    "-w", "\n%{http_code}",
    "--connect-timeout", "5",
    "--max-time", "10",
    url,
  }

  if body then
    local ok, encoded = pcall(vim.fn.json_encode, body)
    if not ok then
      vim.schedule(function()
        callback("Failed to encode request body", nil)
      end)
      return
    end
    table.insert(cmd, "-d")
    table.insert(cmd, encoded)
  end

  local stdout_chunks = {}
  local stderr_chunks = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stdout_chunks, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stderr_chunks, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code ~= 0 then
          local stderr_msg = table.concat(stderr_chunks, "\n")
          if stderr_msg:match("Connection refused") or stderr_msg:match("Could not resolve") then
            callback("Discord bot unreachable -- check systemctl status discord-bot", nil)
          else
            callback("curl failed (exit " .. exit_code .. "): " .. stderr_msg, nil)
          end
          return
        end

        local http_code = stdout_chunks[#stdout_chunks]
        table.remove(stdout_chunks, #stdout_chunks)
        local response_body = table.concat(stdout_chunks, "\n")
        local status = tonumber(http_code) or 0

        if status == 401 then
          callback("DISCORD_BOT_LINK_TOKEN mismatch -- check env", nil)
          return
        end

        if status < 200 or status >= 300 then
          callback("API error (" .. status .. "): " .. response_body, nil)
          return
        end

        local ok_json, parsed = pcall(vim.fn.json_decode, response_body)
        if not ok_json then
          callback("Failed to parse API response", nil)
          return
        end

        callback(nil, parsed)
      end)
    end,
  })
end

-- ---------------------------------------------------------------------------
-- Entry maker
-- ---------------------------------------------------------------------------

--- Create a telescope entry maker for session entries.
---@return function entry_maker
local function _create_entry_maker()
  return function(session)
    local name = _truncate(session.title or session.session_name or session.name or "unnamed", 25)
    local status = session.status or "unknown"
    local linked = _format_relative_time(session.linked_at)

    local display = string.format("%-25s %-10s %s", name, status, linked)

    return {
      value = session,
      display = display,
      ordinal = (session.title or session.session_name or session.name or "")
        .. " " .. (session.id or session.session_id or ""),
    }
  end
end

-- ---------------------------------------------------------------------------
-- Previewer
-- ---------------------------------------------------------------------------

--- Create a buffer previewer that shows session metadata.
---@return table previewer
local function _create_previewer()
  local previewers = require("telescope.previewers")

  return previewers.new_buffer_previewer({
    title = "Session Details",
    define_preview = function(self, entry, _status)
      local session = entry.value
      if not session then
        return
      end

      local lines = {
        "Session Details",
        string.rep("=", 40),
        "",
        "Name:       " .. (session.title or session.session_name or session.name or "-"),
        "Session ID: " .. (session.id or session.session_id or "-"),
        "Status:     " .. (session.status or "-"),
        "Thread URL: " .. (session.thread_url or "-"),
        "Linked At:  " .. (session.linked_at or "-"),
        "",
        string.rep("-", 40),
        "",
      }

      -- Include any additional fields from the API response
      if session.thread_channel then
        table.insert(lines, "Channel:    " .. session.thread_channel)
      end
      if session.directory or session.working_directory or session.cwd then
        table.insert(lines, "CWD:        " .. (session.directory or session.working_directory or session.cwd))
      end

      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
    end,
  })
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

--- Show the telescope session picker.
---
--- Fetches all Discord-linked sessions from the bot API and displays
--- them in a telescope picker with name, status, and linked time columns.
--- Preview pane shows full session metadata.
---
---@param opts table|nil Telescope picker options (passed through)
---@return nil
function M.show(opts)
  opts = opts or {}

  _http_request("GET", "/sessions", nil, function(err, data)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    local sessions = data
    if type(data) == "table" and data.sessions then
      sessions = data.sessions
    end

    if type(sessions) ~= "table" or #sessions == 0 then
      vim.notify("No linked Discord sessions", vim.log.levels.INFO)
      return
    end

    -- Telescope requires
    local ok_pickers, pickers = pcall(require, "telescope.pickers")
    local ok_finders, finders = pcall(require, "telescope.finders")
    local ok_actions, actions = pcall(require, "telescope.actions")
    local ok_state, action_state = pcall(require, "telescope.actions.state")
    local ok_conf, conf_mod = pcall(require, "telescope.config")

    if not (ok_pickers and ok_finders and ok_actions and ok_state and ok_conf) then
      vim.notify("Telescope not available", vim.log.levels.ERROR)
      return
    end

    local conf = conf_mod.values

    pickers.new(opts, {
      prompt_title = "Discord Sessions",
      finder = finders.new_table({
        results = sessions,
        entry_maker = _create_entry_maker(),
      }),
      sorter = conf.generic_sorter(opts),
      previewer = _create_previewer(),
      attach_mappings = function(prompt_bufnr, map)
        -- <CR>: Kill selected session and refresh
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          if not selection then
            return
          end

          local session = selection.value
          local session_id = session.id or session.session_id
          if not session_id then
            vim.notify("No session ID found", vim.log.levels.WARN)
            return
          end

          actions.close(prompt_bufnr)

          _http_request("POST", "/kill", { session_id = session_id }, function(kill_err, _)
            if kill_err then
              vim.notify("Kill failed: " .. kill_err, vim.log.levels.ERROR)
              return
            end

            vim.notify("Session killed: " .. (session.title or session.session_name or session_id), vim.log.levels.INFO)

            -- Re-open picker to show updated list
            vim.defer_fn(function()
              M.show(opts)
            end, 200)
          end)
        end)

        -- <C-o>: Copy thread URL to clipboard
        local function copy_thread_url()
          local selection = action_state.get_selected_entry()
          if not selection then
            return
          end

          local session = selection.value
          local thread_url = session.thread_url
          if not thread_url or thread_url == "" then
            vim.notify("No thread URL for this session", vim.log.levels.WARN)
            return
          end

          vim.fn.setreg("+", thread_url)
          vim.notify("Thread URL copied: " .. thread_url, vim.log.levels.INFO)
        end

        map("i", "<C-o>", copy_thread_url)
        map("n", "<C-o>", copy_thread_url)

        return true
      end,
    }):find()
  end)
end

return M
