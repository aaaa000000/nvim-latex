-- Neovim STT (Speech-to-Text) Plugin
-- Uses Vosk for offline speech recognition with context-aware Claude Code integration
--
-- Requirements:
--   - parecord (pulseaudio-utils or pipewire-pulse)
--   - vosk Python package with vosk-model-small-en-us
--   - ~/.local/bin/vosk-transcribe.py (transcription helper)
--   - Terminal with enhanced keyboard protocol (WezTerm, Kitty) for <C-'> support
--
-- Configuration (optional):
--   vim.g.stt_model_path = "~/.local/share/vosk/vosk-model-small-en-us"
--   vim.g.stt_record_timeout = 30  -- max seconds for recording
--   vim.g.stt_sample_rate = 16000  -- audio sample rate
--
-- Usage:
--   <leader>vr - Start recording (which-key, if enabled)
--   <leader>vs - Stop recording and transcribe (which-key, if enabled)
--   <leader>vv - Toggle recording (which-key, if enabled)
--   <C-'>      - Unified dictation key (normal, insert, terminal modes)
--                In Claude Code buffers: toggles voice mode via /voice
--                  (use Space for hold-to-talk once voice mode is enabled)
--                In all other buffers: toggles Vosk STT recording/transcription
--
-- Global state:
--   vim.g.stt_recording - true when recording, false otherwise (for statusline)

local M = {}

-- State
local recording_job_id = nil
local recording_file = "/tmp/nvim-stt-recording.wav"
local is_recording = false

-- Configuration with defaults
local function get_config()
  return {
    model_path = vim.g.stt_model_path or vim.fn.expand("~/.local/share/vosk/vosk-model-small-en-us"),
    transcribe_script = vim.g.stt_transcribe_script or vim.fn.expand("~/.local/bin/vosk-transcribe.py"),
    record_timeout = vim.g.stt_record_timeout or 30,
    sample_rate = vim.g.stt_sample_rate or 16000,
    recording_file = vim.g.stt_recording_file or recording_file,
  }
end

local function notify(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify("[STT] " .. msg, level)
end

local function command_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Claude Code integration
local _session_manager_ok, _session_manager = pcall(require, "neotex.plugins.ai.claude.core.session-manager")

local function _is_claude_code_buffer(bufnr)
  if not _session_manager_ok then
    return false
  end
  local ok, result = pcall(_session_manager.is_claude_buffer, bufnr)
  if not ok then
    return false
  end
  return result
end

local function _send_claude_voice(bufnr)
  local channel = vim.b[bufnr].terminal_job_id
  if not channel or channel <= 0 then return false end
  vim.fn.chansend(channel, "/voice\r")
  return true
end

function M.start_recording()
  if is_recording then
    notify("Already recording! Press <leader>vs to stop.", vim.log.levels.WARN)
    return
  end

  local config = get_config()

  if not command_exists("parecord") then
    notify("parecord not found. Install pulseaudio-utils or pipewire-pulse.", vim.log.levels.ERROR)
    return
  end

  vim.fn.delete(config.recording_file)

  local cmd = {
    "parecord",
    "--channels=1",
    "--rate=" .. config.sample_rate,
    "--file-format=wav",
    config.recording_file
  }

  recording_job_id = vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code, _)
      is_recording = false
      vim.g.stt_recording = false
      recording_job_id = nil

      if exit_code == 0 or exit_code == 143 then
        M.transcribe_and_insert()
      else
        notify("Recording failed with exit code: " .. exit_code, vim.log.levels.ERROR)
      end
    end,
    on_stderr = function(_, data, _)
      if data and #data > 0 and data[1] ~= "" then
        for _, line in ipairs(data) do
          if line ~= "" then
            notify("Recording stderr: " .. line, vim.log.levels.DEBUG)
          end
        end
      end
    end,
  })

  if recording_job_id > 0 then
    is_recording = true
    vim.g.stt_recording = true
    notify("[STT] Recording started", vim.log.levels.INFO)

    vim.defer_fn(function()
      if is_recording then
        notify("Recording timeout reached, auto-stopping", vim.log.levels.WARN)
        M.stop_recording()
      end
    end, config.record_timeout * 1000)
  else
    notify("Failed to start recording", vim.log.levels.ERROR)
  end
end

function M.stop_recording()
  if not is_recording or not recording_job_id then
    notify("Not currently recording", vim.log.levels.WARN)
    return
  end

  vim.fn.jobstop(recording_job_id)
  vim.g.stt_recording = false
  notify("[STT] Stopped recording", vim.log.levels.INFO)
end

function M.toggle_recording()
  if is_recording then
    M.stop_recording()
  else
    M.start_recording()
  end
end

function M.transcribe_and_insert()
  local config = get_config()

  if vim.fn.filereadable(config.recording_file) ~= 1 then
    notify("Recording file not found: " .. config.recording_file, vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(config.transcribe_script) ~= 1 then
    notify("Transcription script not found: " .. config.transcribe_script, vim.log.levels.ERROR)
    return
  end

  if not command_exists("python3") then
    notify("python3 not found", vim.log.levels.ERROR)
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_buf = vim.api.nvim_get_current_buf()

  local cmd = {
    "python3",
    config.transcribe_script,
    config.recording_file,
    config.model_path,
  }

  local output_lines = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      if data and #data > 0 and data[1] ~= "" then
        for _, line in ipairs(data) do
          if line ~= "" then
            notify("Transcription error: " .. line, vim.log.levels.ERROR)
          end
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      if exit_code ~= 0 then
        notify("Transcription failed with exit code: " .. exit_code, vim.log.levels.ERROR)
        return
      end

      local text = table.concat(output_lines, " ")

      if text == "" then
        notify("No speech detected", vim.log.levels.WARN)
        return
      end

      vim.schedule(function()
        if vim.api.nvim_get_current_buf() == current_buf then
          local buftype = vim.api.nvim_get_option_value('buftype', { buf = current_buf })
          if buftype == 'terminal' then
            local channel = vim.b[current_buf].terminal_job_id
            if channel and channel > 0 then
              vim.fn.chansend(channel, text)
            else
              vim.fn.setreg('"', text)
              notify("Terminal channel unavailable, text saved to register", vim.log.levels.WARN)
            end
          else
            vim.api.nvim_win_set_cursor(0, cursor_pos)
            vim.api.nvim_put({text}, 'c', true, true)
          end
        else
          vim.fn.setreg('"', text)
          notify("Text saved to register: " .. string.sub(text, 1, 50) .. (string.len(text) > 50 and "..." or ""), vim.log.levels.INFO)
        end
      end)

      vim.fn.delete(config.recording_file)
    end,
  })
end

function M.health()
  local config = get_config()
  local issues = {}

  if not command_exists("parecord") then
    table.insert(issues, "parecord not found - install pulseaudio-utils or pipewire-pulse")
  end

  if not command_exists("python3") then
    table.insert(issues, "python3 not found")
  end

  if vim.fn.filereadable(config.transcribe_script) ~= 1 then
    table.insert(issues, "Transcription script not found at " .. config.transcribe_script)
  end

  if vim.fn.isdirectory(config.model_path) ~= 1 then
    table.insert(issues, "Vosk model not found at " .. config.model_path)
  end

  if #issues == 0 then
    notify("All dependencies satisfied!", vim.log.levels.INFO)
    return true
  else
    for _, issue in ipairs(issues) do
      notify("Issue: " .. issue, vim.log.levels.ERROR)
    end
    return false
  end
end

function M.setup(opts)
  opts = opts or {}

  if opts.model_path then
    vim.g.stt_model_path = opts.model_path
  end
  if opts.transcribe_script then
    vim.g.stt_transcribe_script = opts.transcribe_script
  end
  if opts.record_timeout then
    vim.g.stt_record_timeout = opts.record_timeout
  end
  if opts.sample_rate then
    vim.g.stt_sample_rate = opts.sample_rate
  end

  if opts.keymaps ~= false then
    if opts.keymaps == true then
      local keymap_opts = { noremap = true, silent = true }
      vim.keymap.set('n', '<leader>vr', M.start_recording, vim.tbl_extend("force", keymap_opts, { desc = "STT: Start recording" }))
      vim.keymap.set('n', '<leader>vs', M.stop_recording, vim.tbl_extend("force", keymap_opts, { desc = "STT: Stop recording" }))
      vim.keymap.set('n', '<leader>vv', M.toggle_recording, vim.tbl_extend("force", keymap_opts, { desc = "STT: Toggle recording" }))
      vim.keymap.set('n', '<leader>vh', M.health, vim.tbl_extend("force", keymap_opts, { desc = "STT: Health check" }))
    end
  end

  vim.api.nvim_create_user_command('STTStart', M.start_recording, { desc = 'Start STT recording' })
  vim.api.nvim_create_user_command('STTStop', M.stop_recording, { desc = 'Stop STT recording' })
  vim.api.nvim_create_user_command('STTToggle', M.toggle_recording, { desc = 'Toggle STT recording' })
  vim.api.nvim_create_user_command('STTHealth', M.health, { desc = 'Check STT dependencies' })

  vim.api.nvim_create_user_command('STTClaudeVoice', function()
    local bufnr = vim.api.nvim_get_current_buf()
    if not _is_claude_code_buffer(bufnr) then
      notify("Not a Claude Code buffer", vim.log.levels.WARN)
      return
    end
    _send_claude_voice(bufnr)
  end, { desc = 'STT: Toggle Claude Code voice mode' })

  -- <C-'> context-aware dictation
  -- Claude Code buffers: toggle voice mode (use Space for PTT)
  -- All other buffers: Vosk STT toggle

  vim.keymap.set('n', "<C-'>", function()
    local bufnr = vim.api.nvim_get_current_buf()
    if _is_claude_code_buffer(bufnr) then
      _send_claude_voice(bufnr)
    else
      M.toggle_recording()
    end
  end, {
    noremap = true,
    silent = true,
    desc = "STT: Toggle dictation (Ctrl-')"
  })

  vim.keymap.set('i', "<C-'>", function()
    M.toggle_recording()
  end, {
    noremap = true,
    silent = true,
    desc = "STT: Toggle dictation (insert mode, Ctrl-')"
  })

  vim.keymap.set('t', "<C-'>", function()
    local bufnr = vim.api.nvim_get_current_buf()
    if _is_claude_code_buffer(bufnr) then
      _send_claude_voice(bufnr)
    else
      vim.cmd('stopinsert')
      M.toggle_recording()
      vim.schedule(function()
        vim.cmd('startinsert')
      end)
    end
  end, {
    noremap = true,
    silent = true,
    desc = "STT: Toggle dictation (terminal mode, Ctrl-')"
  })

end

return M
