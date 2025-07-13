return {
  -- Treesitter for C#
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "c_sharp" })
      end
    end,
  },

  -- Mason installation for core tools
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "omnisharp", "netcoredbg", "csharpier" },
    },
  },

  -- LSP configuration including omnisharp with extended handlers & Telescope mapping
  {
    "neovim/nvim-lspconfig",
    dependencies = { "Hoffs/omnisharp-extended-lsp.nvim", "nvim-telescope/telescope.nvim" },
    opts = {
      servers = {
        omnisharp = {
          cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
          handlers = {
            -- Fixes definition issues
            ["textDocument/definition"] = function(...) return require("omnisharp_extended").handler(...) end,
            ["textDocument/typeDefinition"] = function(...) return require("omnisharp_extended").handler(...) end,
            ["textDocument/implementation"] = function(...) return require("omnisharp_extended").handler() end,
            ["textDocument/references"] = function(...) return require("omnisharp_extended").handler(...) end,
          },
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
          enable_import_completion = true,
          sdk_include_prereleases = true,
          enable_import_completion = true,
          enable_debugging = true,
          enable_decompilation_support = true,
          -- Telescope keymaps for .cs files
          keys = {
            { "gd", function() require("telescope.builtin").lsp_definitions() end, desc = "Telescope: Go to Definition" },
            { "gR", function() require("telescope.builtin").lsp_references() end, desc = "Telescope: Find References" },
            { "gi", function() require("telescope.builtin").lsp_implementations() end, desc = "Telescope: Go to Implementation" },
            { "gt", function() require("telescope.builtin").lsp_type_definitions() end, desc = "Telescope: Type Definition" },
          },
        },
      },
    },
  },

  -- Optional: formatting and debug setup
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.csharpier)
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = { cs = { "csharpier" } },
      formatters = {
        csharpier = { command = "dotnet-csharpier", args = { "--write-stdout" } },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = { "jay-babu/mason-nvim-dap.nvim" },
    config = function()
      require("mason-nvim-dap").setup({ ensure_installed = { "netcoredbg" } })
      local dap = require("dap")
      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.exepath("netcoredbg"),
        args = { "--interpreter=vscode" },
      }
      dap.configurations.cs = {
        {
          type = "coreclr", name = "Launch .NET", request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/net7.0/", "file")
          end,
        },
      }
    end,
  },
}

