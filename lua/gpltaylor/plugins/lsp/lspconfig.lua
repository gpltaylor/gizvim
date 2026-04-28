return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function(_, opts)
    -- Diagnostics
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
    vim.diagnostic.config({
      -- Show all severities (errors, warnings, info, hints)
      virtual_text = {
        severity = { min = vim.diagnostic.severity.HINT },
        prefix = "●",
        spacing = 4,
      },
      signs = {
        severity = { min = vim.diagnostic.severity.HINT },
      },
      underline = {
        severity = { min = vim.diagnostic.severity.HINT },
      },
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = "always",
        severity_sort = true,
      },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local on_attach = function(client, bufnr)
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc, noremap = true, silent = true })
      end
      map("K",          vim.lsp.buf.hover,       "Hover Documentation")
      map("<leader>rn", vim.lsp.buf.rename,       "Rename Symbol")
      map("<leader>ca", vim.lsp.buf.code_action,  "Code Action")
      map("<leader>ds", function() require("telescope.builtin").lsp_document_symbols() end,          "Document Symbols")
      map("<leader>ws", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, "Workspace Symbols")
    end

    -- mason-lspconfig v2 API: handlers go inside setup(), not setup_handlers().
    -- This call merges with mason.lua's setup (which sets ensure_installed).
    -- The default handler runs for every installed server, merging any per-server
    -- opts from other specs (e.g. opts.servers.gopls from golang.lua).
    require("mason-lspconfig").setup({
      handlers = {
        function(server_name)
          -- roslyn is managed entirely by roslyn.nvim (csharp.lua) — skip it here.
          -- omnisharp is superseded by roslyn — skip it to avoid duplicate C# servers.
          if server_name == "roslyn" or server_name == "omnisharp" then return end
          local server_config = vim.tbl_deep_extend("force", {
            capabilities = capabilities,
            on_attach = on_attach,
          }, (opts.servers or {})[server_name] or {})
          require("lspconfig")[server_name].setup(server_config)
        end,
      },
    })
  end,
}
