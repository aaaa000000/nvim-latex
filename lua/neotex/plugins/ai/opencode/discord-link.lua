-----------------------------------------------------------
-- Discord Link
--
-- Links the current OpenCode session to a Discord thread
-- via the bot's HTTP API. Discovers the active session by
-- running `opencode session list` filtered to the current
-- working directory.
--
-- Environment variables:
--   DISCORD_BOT_URL        - Bot API base URL (default: http://localhost:8080)
--   DISCORD_BOT_LINK_TOKEN - Bearer token for API auth
--
-- Usage:
--   require("neotex.plugins.ai.opencode.discord-link").link_current_session()
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

--- Make an HTTP request via curl and return parsed JSON.
---@param method string HTTP method (GET, POST)
---@param path string API path (e.g., "/link")
---@param body table|nil Request body (JSON-encoded for POST)
---@param callback function Called with (err, data) on completion
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

        -- Last line of stdout is the HTTP status code (from -w)
        local http_code = stdout_chunks[#stdout_chunks]
        table.remove(stdout_chunks, #stdout_chunks)
        local response_body = table.concat(stdout_chunks, "\n")

        local status = tonumber(http_code) or 0

        if status == 401 then
          callback("DISCORD_BOT_LINK_TOKEN mismatch -- check env", nil)
          return
        end

        if status == 409 then
          -- Already linked -- try to extract thread_url from response
          local ok_json, data = pcall(vim.fn.json_decode, response_body)
          if ok_json and data and data.thread_url then
            callback("Session already linked: " .. data.thread_url, nil)
          else
            callback("Session already linked to a Discord thread", nil)
          end
          return
        end

        if status < 200 or status >= 300 then
          callback("API error (" .. status .. "): " .. response_body, nil)
          return
        end

        -- Parse successful response
        local ok_json, data = pcall(vim.fn.json_decode, response_body)
        if not ok_json then
          callback("Failed to parse API response", nil)
          return
        end

        callback(nil, data)
      end)
    end,
  })
end

--- Discover the current OpenCode session for this working directory.
---@param callback function Called with (err, session_id, session_name)
local function _discover_session(callback)
  local cwd = vim.fn.getcwd()
  local cmd = { "opencode", "session", "list", "--format", "json" }

  local stdout_chunks = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stdout_chunks, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code ~= 0 then
          callback("Failed to list OpenCode sessions (exit " .. exit_code .. ")", nil, nil)
          return
        end

        local raw = table.concat(stdout_chunks, "\n")
        if raw == "" then
          callback("No active OpenCode session -- start one first", nil, nil)
          return
        end

        local ok, sessions = pcall(vim.fn.json_decode, raw)
        if not ok or type(sessions) ~= "table" then
          callback("Failed to parse OpenCode session list", nil, nil)
          return
        end

        -- Filter sessions by CWD
        local matching = {}
        for _, sess in ipairs(sessions) do
          if sess.directory == cwd then
            table.insert(matching, sess)
          end
        end

        if #matching == 0 and #sessions > 0 then
          -- Fall back to most recent session (sorted by updated desc)
          table.insert(matching, sessions[1])
        end

        if #matching == 0 then
          callback("No active OpenCode session -- start one first", nil, nil)
          return
        end

        local session = matching[1]
        local session_id = session.id
        local session_name = session.title or vim.fn.fnamemodify(cwd, ":t")

        if not session_id then
          callback("Could not determine session ID", nil, nil)
          return
        end

        callback(nil, session_id, session_name)
      end)
    end,
  })
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

--- Link the current OpenCode session to a Discord thread.
---
--- Discovers the active session for the current working directory, then
--- calls the bot's POST /link endpoint to create a Discord thread.
--- On success, displays the thread URL and copies it to the clipboard.
---
---@return nil
function M.link_current_session()
  vim.notify("Discovering OpenCode session...", vim.log.levels.INFO)

  _discover_session(function(err, session_id, session_name)
    if err then
      vim.notify(err, vim.log.levels.WARN)
      return
    end

    vim.notify("Linking session to Discord...", vim.log.levels.INFO)

    _http_request("POST", "/link", {
      session_id = session_id,
      session_name = session_name,
    }, function(api_err, data)
      if api_err then
        vim.notify(api_err, vim.log.levels.ERROR)
        return
      end

      local thread_url = data and data.thread_url or ""
      if thread_url ~= "" then
        vim.fn.setreg("+", thread_url)
        vim.notify("Discord thread linked: " .. thread_url .. " (copied to clipboard)", vim.log.levels.INFO)
      else
        vim.notify("Session linked to Discord (no thread URL returned)", vim.log.levels.INFO)
      end
    end)
  end)
end

return M
