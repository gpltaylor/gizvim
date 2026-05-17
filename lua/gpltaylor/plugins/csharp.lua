-- ============================================================
-- C# support: roslyn.nvim (LSP) + netcoredbg (DAP)
-- ============================================================
-- Key design decisions:
--   • roslyn.nvim uses config (not init) so cmp-nvim-lsp is guaranteed loaded
--   • DAP adapter uses the Mason .exe directly — never the .cmd batch wrapper
--     (Windows cannot use .cmd files as DAP executables)
--   • mason-nvim-dap is NOT used for coreclr; we configure the adapter manually
--   • Keymaps live in core/keymaps.lua FileType autocmd (F1-F9, LSP navigation)
-- ============================================================
return {
  -- Treesitter grammar for C#
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "c_sharp" })
      end
    end,
  },

  -- roslyn.nvim: Microsoft Roslyn C# language server (replaces OmniSharp)
  -- Server installation: :MasonInstall roslyn  (needs Crashdummyy/mason-registry in mason.lua)
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    -- cmp-nvim-lsp must be loaded before config runs so capabilities are available
    dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      -- vim.lsp.config sets per-server LSP options (Neovim 0.11+ API).
      -- Must be called before the server attaches; config() timing is correct.
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

      require("roslyn").setup({
        -- Search parent directories for .sln files (useful in mono-repo layouts)
        broad_search = true,
        filewatching = "auto",
        extensions = {
          -- Razor disabled: avoids "no path provided" noise on non-web projects
          razor = { enabled = false },
        },
      })
    end,
  },

  -- CSharpier: opinionated C# formatter via conform.nvim
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

  -- C# debugging via netcoredbg
  -- IMPORTANT: we bypass mason-nvim-dap's coreclr handler because on Windows
  -- it resolves netcoredbg to a .cmd batch wrapper which jobstart() cannot
  -- use as a DAP executable. We point directly at the Mason package .exe.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function()
      local dap = require("dap")

      -- Resolve the real netcoredbg executable (never the .cmd shim)
      local function find_netcoredbg()
        local mason_exe = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe"
        if vim.fn.executable(mason_exe) == 1 then
          return mason_exe
        end
        -- System-installed (e.g. c:\bin\netcoredbg.exe)
        local found = vim.fn.exepath("netcoredbg")
        if found ~= "" and not found:match("%.cmd$") then
          return found
        end
        return "netcoredbg" -- last resort: bare name on PATH
      end

      dap.adapters.coreclr = {
        type = "executable",
        command = find_netcoredbg(),
        args = { "--interpreter=vscode" },
        options = { detached = false }, -- required on Windows; prevents orphan processes
      }

      -- Base launch/attach configurations
      local configs = {
        {
          type    = "coreclr",
          name    = "Launch: auto-detect DLL",
          request = "launch",
          program = function()
            local ok, vimspector = pcall(require, "utils.vimspector_config")
            if ok then
              local dll = vimspector.find_main_dll()
              if dll and dll ~= "" then
                vim.notify("netcoredbg launching: " .. vim.fn.fnamemodify(dll, ":t"), vim.log.levels.INFO)
                return dll
              end
            end
            return vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
          cwd           = vim.fn.getcwd,
          env           = { ASPNETCORE_ENVIRONMENT = "Development" },
          justMyCode    = false,
          stopAtEntry   = false,
        },
        {
          type    = "coreclr",
          name    = "Launch: select DLL",
          request = "launch",
          program = function()
            return vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
          cwd           = vim.fn.getcwd,
          env           = { ASPNETCORE_ENVIRONMENT = "Development" },
          justMyCode    = false,
          stopAtEntry   = false,
        },
        {
          type      = "coreclr",
          name      = "Attach to process",
          request   = "attach",
          justMyCode = false,
          processId  = function()
            -- dap.utils.pick_process gives a proper picker UI
            return require("dap.utils").pick_process()
          end,
        },
      }

      -- Prepend any project-level configs from .vimspector.json
      local ok, vimspector = pcall(require, "utils.vimspector_config")
      if ok then
        local project_configs = vimspector.get_project_configs()
        if #project_configs > 0 then
          for i, cfg in ipairs(project_configs) do
            table.insert(configs, i, cfg)
          end
        end
      end

      dap.configurations.cs = configs
    end,
  },
}

