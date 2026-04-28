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

  -- Mason: only csharpier formatter and netcoredbg debugger (roslyn.nvim self-installs)
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "netcoredbg", "csharpier" },
    },
  },

  -- roslyn.nvim: official Roslyn C# language server (replaces omnisharp)
  -- Install the server: :MasonInstall roslyn (requires custom registry in mason.lua)
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    dependencies = { "nvim-lua/plenary.nvim" },
    init = function()
      -- LSP settings via Neovim 0.11+ vim.lsp.config API.
      -- Keymaps are in keymaps.lua FileType autocmd (more reliable than on_attach).
      vim.lsp.config("roslyn", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_provide_regex_completions = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "fullSolution",
            dotnet_compiler_diagnostics_scope = "fullSolution",
          },
        },
      })
    end,
    opts = {
      broad_search = true,   -- search parent dirs for .sln files
      filewatching = "auto",
      extensions = {
        -- Disable razor: suppresses "no path provided" warnings for non-web projects
        razor = { enabled = false },
      },
    },
  },

  -- CSharpier formatter via conform
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

  -- DAP: netcoredbg for C# debugging
  -- Uses init (not config) so it doesn't overwrite nvim-dap.lua's main config
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = { "jay-babu/mason-nvim-dap.nvim" },
    init = function()
      -- Defer until after nvim-dap's own config has run
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "cs",
        once = true,
        callback = function()
          local dap = require("dap")
          if dap.adapters.coreclr then return end  -- already configured
          dap.adapters.coreclr = {
            type = "executable",
            command = vim.fn.exepath("netcoredbg") ~= "" and vim.fn.exepath("netcoredbg")
              or vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
            args = { "--interpreter=vscode" },
          }
          dap.configurations.cs = {
            {
              type = "coreclr",
              name = "Launch .NET",
              request = "launch",
              program = function()
                local cwd = vim.fn.getcwd()
                local dlls = vim.fn.glob(cwd .. "/bin/Debug/**/*.dll", false, true)
                for _, dll in ipairs(dlls) do
                  if not dll:match("%.Tests?%.dll$") and not dll:match("xunit") and not dll:match("testhost") then
                    return dll
                  end
                end
                return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
              end,
            },
          }
        end,
      })
    end,
  },
}

