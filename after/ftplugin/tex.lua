-- We're now using nvim-surround instead of mini.surround
-- LaTeX-specific surround configurations are in lua/neotex/plugins/coding/surround.lua

-- This file includes buffer-specific surround configuration
require("nvim-surround").buffer_setup({
  surrounds = {
    -- LaTeX environments
    ["e"] = {
      add = function()
        local env = vim.fn.input("Environment: ")
        return { { "\\begin{" .. env .. "}" }, { "\\end{" .. env .. "}" } }
      end,
    },
    -- LaTeX quotes
    ["Q"] = {
      add = { "``", "''" },
      find = "%b``.-''",
      delete = "^(``)().-('')()$",
    },
    -- LaTeX single quotes
    ["q"] = {
      add = { "`", "'" },
      find = "`.-'",
      delete = "^(`)().-(')()$",
    },
    -- LaTeX text formatting
    ["b"] = {
      add = { "\\textbf{", "}" },
      find = "\\%a-bf%b{}",
      delete = "^(\\%a-bf{)().-(})()$",
    },
    ["i"] = {
      add = { "\\textit{", "}" },
      find = "\\%a-it%b{}",
      delete = "^(\\%a-it{)().-(})()$",
    },
    ["t"] = {
      add = { "\\texttt{", "}" },
      find = "\\%a-tt%b{}",
      delete = "^(\\%a-tt{)().-(})()$",
    },
    ["$"] = {
      add = { "$", "$" },
    },
  },
})

-- PdfAnnots
function PdfAnnots()
  local ok, pdf = pcall(vim.api.nvim_eval,
    "vimtex#context#get().handler.get_actions().entry.file")
  if not ok then
    vim.notify "No file found"
    return
  end

  local cwd = vim.fn.getcwd()
  vim.fn.chdir(vim.b.vimtex.root)

  if vim.fn.isdirectory('Annotations') == 0 then
    vim.fn.mkdir('Annotations')
  end

  local md = vim.fn.printf("Annotations/%s.md", vim.fn.fnamemodify(pdf, ":t:r"))
  -- vim.fn.system(vim.fn.printf('pdfannots -o "%s" "%s"', md, pdf))
  vim.fn.system(string.format('pdfannots -o "%s" "%s"', md, pdf))
  vim.cmd.edit(vim.fn.fnameescape(md))

  vim.fn.chdir(cwd)
end

-- Inline math: Ctrl+Shift+M → $math$
vim.keymap.set("i", "<C-S-m>", function()
  local ls = require("luasnip")
  ls.snip_expand(ls.snippet("", {
    ls.text_node("$"),
    ls.insert_node(1, "math"),
    ls.text_node("$"),
    ls.insert_node(0),
  }))
end, { buffer = true, noremap = true, silent = true, desc = "Inline math $...$" })

-- Display math: Ctrl+Shift+D → \[\n\t math \n\]
vim.keymap.set("i", "<C-S-d>", function()
  local ls = require("luasnip")
  ls.snip_expand(ls.snippet("", {
    ls.text_node({ "\\[", "\t" }),
    ls.insert_node(1, "math"),
    ls.text_node({ "", "\\]" }),
    ls.insert_node(0),
  }))
end, { buffer = true, noremap = true, silent = true, desc = "Display math \\[...\\]" })


-- Enable full-line syntax highlighting for LaTeX files
-- Override the global synmaxcol=200 setting for better LaTeX support
vim.opt_local.synmaxcol = 0  -- 0 means no limit

-- Helper function for bibexport
local function run_bibexport()
  local filedir = vim.fn.expand('%:p:h')
  local filename = vim.fn.expand('%:t:r')
  local output_bib = filename .. '.bib'
  local aux_file = 'build/' .. filename .. '.aux'

  -- Build the command to run in terminal
  local cmd = string.format('cd "%s" && bibexport -o "%s" "%s"', filedir, output_bib, aux_file)
  vim.cmd('terminal ' .. cmd)
end

-- Returns the Zathura PID and D-Bus address, or nil if not running.
local uid = vim.fn.system('id -u'):gsub('%s+', '')
local dbus_addr = 'unix:path=/run/user/' .. uid .. '/bus'

-- Get the D-Bus name of a running Zathura by querying the session bus directly.
-- More reliable than pgrep because Zathura may fork, making the registered PID
-- differ from the process PID.
local function zathura_dbus_name()
  local out = vim.fn.system(
    'DBUS_SESSION_BUS_ADDRESS=' .. dbus_addr
      .. ' dbus-send --session --print-reply --dest=org.freedesktop.DBus'
      .. ' /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null'
  )
  return out:match('org%.pwmt%.zathura%.PID%-%d+')
end

local function synctex_tex_path()
  return vim.fn.expand('%:p')
end

-- Send forward search to a running Zathura via D-Bus. Returns true on success.
local function zathura_dbus_forward(dbus_name, tex, line, col)
  local out = vim.fn.system(string.format(
    'DBUS_SESSION_BUS_ADDRESS=%s dbus-send --session --print-reply'
      .. ' --dest=%s /org/pwmt/zathura'
      .. ' org.pwmt.zathura.SynctexView string:"%s" uint32:%d uint32:%d 2>&1',
    dbus_addr, dbus_name, tex, line, col
  ))
  return out:match('boolean true') ~= nil
end

-- Debug: :ZathuraTest shows D-Bus name and whether SynctexView succeeds
vim.api.nvim_buf_create_user_command(0, 'ZathuraTest', function()
  local name = zathura_dbus_name()
  local tex  = synctex_tex_path()
  local line = vim.fn.line('.')
  vim.notify(string.format('dbus: %s\ntex: %s\nline: %d', name or 'NOT FOUND', tex, line))
  if name then
    vim.notify('SynctexView returned: ' .. tostring(zathura_dbus_forward(name, tex, line, 1)))
  end
end, {})

-- Open Zathura if not running, or forward-search if it is.
local function zathura_view()
  local name = zathura_dbus_name()
  if name then
    zathura_dbus_forward(name, synctex_tex_path(), vim.fn.line('.'), vim.fn.col('.'))
  else
    vim.cmd('VimtexView')
  end
end

-- Only forward-search; never opens Zathura (for cursor sync).
local function zathura_sync_if_open()
  local name = zathura_dbus_name()
  if name then
    zathura_dbus_forward(name, synctex_tex_path(), vim.fn.line('.'), vim.fn.col('.'))
  end
end


-- Auto forward search after each successful compile + real-time cursor sync
local group = vim.api.nvim_create_augroup("ZathuraAutoSync", { clear = true })

-- Auto-start continuous compilation when opening a tex buffer
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "VimtexEventInitPost",
  callback = function()
    if vim.b.vimtex and vim.b.vimtex.compiler then
      vim.cmd('VimtexCompile')
    end
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "VimtexEventCompileSuccess",
  callback = zathura_sync_if_open,
})

-- Debounced cursor sync: highlights cursor position in Zathura 300ms after cursor stops
local sync_timer = nil
local function schedule_zathura_sync()
  if sync_timer then
    sync_timer:stop()
    sync_timer:close()
    sync_timer = nil
  end
  sync_timer = vim.uv.new_timer()
  sync_timer:start(300, 0, vim.schedule_wrap(function()
    if sync_timer then sync_timer:close(); sync_timer = nil end
    zathura_sync_if_open()  -- never opens Zathura, only syncs if already running
  end))
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  group = group,
  buffer = 0,
  callback = schedule_zathura_sync,
})

-- Register LaTeX-specific which-key mappings for this buffer
local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
  -- LaTeX commands
  wk.add({
    { "<leader>b", "<cmd>VimtexCompileSS<CR>", desc = "build and view pdf", icon = "󰖷", buffer = 0 },
    { "<leader>l", group = "latex", icon = "󰙩", buffer = 0 },
    { "<leader>la", "<cmd>lua PdfAnnots()<CR>", desc = "annotate", icon = "󰏪", buffer = 0 },
    { "<leader>lb", function() run_bibexport() end, desc = "bib export", icon = "󰈝", buffer = 0 },
    { "<leader>lc", "<cmd>VimtexCompile<CR>", desc = "compile", icon = "󰖷", buffer = 0 },
    { "<leader>ld", "<cmd>terminal LATEXMK_DRAFT_MODE=1 latexmk -pdf -e '$draft_mode=1' %:p<CR>", desc = "draft mode", icon = "󰌶", buffer = 0 },
    { "<leader>le", "<cmd>VimtexErrors<CR>", desc = "errors", icon = "󰅚", buffer = 0 },
    { "<leader>lf", "<cmd>terminal latexmk -pdf %:p<CR>", desc = "final build", icon = "󰸞", buffer = 0 },
    { "<leader>lg", "<cmd>e ~/.config/nvim/templates/Glossary.tex<CR>", desc = "glossary", icon = "󰈚", buffer = 0 },
    { "<leader>lh", "<cmd>terminal latexindent -w %:p:r.tex<CR>", desc = "format", icon = "󰉣", buffer = 0 },
    { "<leader>li", "<cmd>VimtexTocOpen<CR>", desc = "index", icon = "󰋽", buffer = 0 },
    { "<leader>lk", "<cmd>VimtexClean<CR>", desc = "kill aux", icon = "󰩺", buffer = 0 },
    { "<leader>lm", "<plug>(vimtex-context-menu)", desc = "menu", icon = "󰍉", buffer = 0 },
    { "<leader>lv", zathura_view, desc = "view", icon = "󰛓", buffer = 0 },
    { "<leader>lw", "<cmd>VimtexCountWords!<CR>", desc = "word count", icon = "󰆿", buffer = 0 },
    { "<leader>lx", "<cmd>:VimtexClearCache All<CR>", desc = "clear cache", icon = "󰃢", buffer = 0 },
    { "<leader>ls", function()
      local vimtex = vim.b.vimtex
      if vimtex and vim.fn.expand('%:p') == vimtex.tex then
        vim.notify("Already on main file", vim.log.levels.INFO)
      else
        vim.cmd('VimtexToggleMain')
      end
    end, desc = "subfile toggle", icon = "󰔏", buffer = 0 },
  })

  -- Template mappings
  wk.add({
    { "<leader>T", group = "templates", icon = "󰈭", buffer = 0 },
    { "<leader>Ta", "<cmd>read ~/.config/nvim/templates/article.tex<CR>", desc = "article.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Tb", "<cmd>read ~/.config/nvim/templates/beamer_slides.tex<CR>", desc = "beamer_slides.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Tg", "<cmd>read ~/.config/nvim/templates/glossary.tex<CR>", desc = "glossary.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Th", "<cmd>read ~/.config/nvim/templates/handout.tex<CR>", desc = "handout.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Tl", "<cmd>read ~/.config/nvim/templates/letter.tex<CR>", desc = "letter.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Tm", "<cmd>read ~/.config/nvim/templates/MultipleAnswer.tex<CR>", desc = "MultipleAnswer.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Tr", function()
      local template_dir = vim.fn.expand("~/.config/nvim/templates/report")
      local current_dir = vim.fn.getcwd()
      vim.fn.system("cp -r " .. vim.fn.shellescape(template_dir) .. " " .. vim.fn.shellescape(current_dir))
      require('neotex.util.notifications').editor('Template copied', require('neotex.util.notifications').categories.USER_ACTION, { template = 'report', directory = current_dir })
    end, desc = "Copy report/ directory", icon = "󰉖", buffer = 0 },
    { "<leader>Ts", function()
      local template_dir = vim.fn.expand("~/.config/nvim/templates/springer")
      local current_dir = vim.fn.getcwd()
      vim.fn.system("cp -r " .. vim.fn.shellescape(template_dir) .. " " .. vim.fn.shellescape(current_dir))
      require('neotex.util.notifications').editor('Template copied', require('neotex.util.notifications').categories.USER_ACTION, { template = 'springer', directory = current_dir })
    end, desc = "Copy springer/ directory", icon = "󰉖", buffer = 0 },
  })
end



-- -- LSP menu to preserve vimtex citation data
-- require('cmp').setup.buffer {
--   formatting = {
--     format = function(entry, vim_item)
--         vim_item.menu = ({
--           omni = (vim.inspect(vim_item.menu):gsub('%"', "")),
--           buffer = "[Buffer]",
--           -- formatting for other sources
--           })[entry.source.name]
--         return vim_item
--       end,
--   },
--   sources = {
--     { name = 'omni' },
--     { name = 'buffer' },
--     -- other sources
--   },
-- }
