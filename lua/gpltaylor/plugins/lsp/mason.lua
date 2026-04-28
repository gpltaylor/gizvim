return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      -- Custom registry needed for the roslyn C# language server package
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "terraformls",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
        "gopls",
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier",      -- prettier formatter
        "stylua",        -- lua formatter
        "eslint_d",
        "delve",         -- Go debugger
        "gofumpt",       -- Go formatter
        "goimports",     -- Go imports organizer
        "golangci-lint", -- Go linter
        "gomodifytags",  -- Go struct tag modifier
        "gotests",       -- Go test generator
        "impl",          -- Go interface implementation generator
        "netcoredbg",    -- .NET debugger
        "csharpier",     -- C# formatter
        "roslyn",        -- C# language server (requires Crashdummyy/mason-registry above)
      },
    })
  end,
}
