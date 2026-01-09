return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
--    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    local opts = { noremap = true, silent = true }
    local on_attach = function(client, bufnr)
      opts.buffer = bufnr

      -- set keybinds
      -- nvim 0.11+ has a default keymap grr which does the same as our gR

      -- replace the default gd keymap with an LSP-driven one which is
      -- smarter about finding definitions
      opts.desc = "Go to definition (LSP)"
      keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- go to definition

      -- nvim 0.11+ has a default keymap gri which shows the same info as our gi
      -- it seems never to have been used so isn't Telescope-ized here

      -- nvim 0.11+ has a default keymap grt which shows the same info,
      -- but Telescope's builtin picker shows it better
      opts.desc = "Show LSP type definitions"
      keymap.set("n", "grt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      -- nvim 0.11+ has a default keymap gra which does the same as our <leader>ca
      -- nvim 0.11+ has a default keymap grn which does the same as our <leader>rn

      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      -- nvim 0.11+ has a default keymap <C-w>d which does the same as our <leader>d
      -- nvim 0.11+ defines the same [d keymap we had here
      -- nvim 0.11+ defines the same ]d keymap we had here
      -- nvim 0.11+ defines the same K keymap we had here

      opts.desc = "Restart LSP"
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()


    -- use the nvim 0.11 way of configuring diagnostic signs
    vim.diagnostic.config({
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "\u{F05E}",   -- fontawesome "ban"
                [vim.diagnostic.severity.WARN] = "\u{F071}",    -- fontawesome "triangle-exclamation"
                [vim.diagnostic.severity.HINT] = "\u{F0EB}",    -- fontawesome "lightbulb"
                [vim.diagnostic.severity.INFO] = "\u{F05A}",    -- fontawesome "circle-info"
            }
        }
    })

    -- configure python server
    vim.lsp.config("pyright", {
      capabilities = capabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable("pyright")

    -- configure jdtls server
    vim.lsp.config("jdtls", {
      cmd = { "/opt/homebrew/bin/jdtls" },
      capabilities = capabilities,
      on_attach = on_attach,
      root_markers = { '.git', 'pom.xml' }
    })
    vim.lsp.enable("jdtls")

  end
}
