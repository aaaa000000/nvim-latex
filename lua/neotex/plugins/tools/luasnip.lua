return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.3.0",  -- Pin to stable version that works with blink.cmp
    lazy = true,
    event = "InsertEnter",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function() end, -- Empty config to prevent auto-loading
      },
    },
    build = "make install_jsregexp", -- Important for NixOS
    config = function()
      -- Set all disabling flags before requiring luasnip
      vim.g.luasnip_no_community_snippets = true
      vim.g.luasnip_no_jsregexp = true
      vim.g.luasnip_no_vscode_loader = true

      -- Initialize LuaSnip with minimal configuration
      local ls = require("luasnip")
      ls.setup({
        history = true,
        update_events = "TextChanged,TextChangedI",
        enable_autosnippets = true,
        -- Store visual selection for use in snippets
        store_selection_keys = "<Tab>",
        -- Exit snippet on unmatched events
        ext_opts = {
          [require("luasnip.util.types").choiceNode] = {
            active = {
              virt_text = {{"●", "DiagnosticWarn"}},
            },
          },
        },
      })

      -- Load snippets immediately
      local ok, loader = pcall(require, "luasnip.loaders.from_snipmate")
      if ok and loader then
        loader.load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
      end
      
      -- NOTE: Do NOT set region_check_events or delete_check_events.
      -- TextChangedI/CursorMovedI fire when editing placeholders and would
      -- cause LuaSnip to exit the session before the user can jump forward.

      -- SELECT mode: handle Tab/S-Tab for placeholder navigation
      vim.keymap.set("s", "<Tab>",   function() ls.jump(1)  end, { silent = true })
      vim.keymap.set("s", "<S-Tab>", function() ls.jump(-1) end, { silent = true })

      -- NOTE: Do NOT add InsertLeave autocmd to unlink snippets.
      -- INSERT → SELECT mode transition fires InsertLeave, which would
      -- immediately destroy the snippet session before the user can navigate.
      
      -- Debug command to check snippet state
      vim.api.nvim_create_user_command("LuaSnipInfo", function()
        local info = {
          in_snippet = ls.in_snippet(),
          jumpable_forward = ls.jumpable(1),
          jumpable_backward = ls.jumpable(-1),
          active_node = ls.session.current_nodes[vim.api.nvim_get_current_buf()] and "yes" or "no",
          mode = vim.fn.mode()
        }
        print(vim.inspect(info))
      end, {})
    end
  }
}
