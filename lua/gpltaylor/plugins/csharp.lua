-- ============================================================
-- C# support: roslyn.nvim (LSP) + netcoredbg (DAP)
-- ============================================================
-- Key design decisions:
--   • roslyn.nvim uses config (not init) so cmp-nvim-lsp is guaranteed loaded
--   • DAP adapter is configured inside roslyn's config — this is reliable because
--     lazy.nvim only runs ONE config per plugin; optional nvim-dap specs have
--     their config silently ignored when nvim-dap.lua already defines one
--   • Adapter uses the Mason .exe directly — never the .cmd batch wrapper
--     (Windows cannot use .cmd files as DAP executables via jobstart)
--   • Keymaps live in core/keymaps.lua FileType autocmd (F1-F9, LSP navigation)
--
--   Note: Sometimes F5 will not work as it can't find the DLL or code to launch form. 
--   In this case you can run the lanch manually.
--   require("dap").run({type="coreclr",request="launch",
--    name="test",
--    program="D:/redbear/honeycomb/RedBear.GizHex/bin/Debug/net10.0/RedBear.GizHex.dll",
--    cwd="D:/redbear/honeycomb/RedBear.GizHex",
--    stopAtEntry=true,
--    justMyCode=false})
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
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/cmp-nvim-lsp",
      -- nvim-dap listed here so it is loaded before config() runs;
      -- the coreclr adapter is set up below (cannot use a separate optional
      -- nvim-dap spec because lazy.nvim only executes one config per plugin)
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- ── LSP ──────────────────────────────────────────────────────────────
      -- vim.lsp.config sets per-server LSP options (Neovim 0.11+ API).
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
        broad_search = true,   -- search parent dirs for .sln files
        filewatching = "auto",
        extensions = {
          razor = { enabled = false }, -- avoids noise on non-web projects
        },
      })

      -- ── DAP (coreclr / netcoredbg) ───────────────────────────────────────
      -- Configured here rather than in a separate optional nvim-dap spec
      -- because lazy.nvim only runs one config per plugin.
      local dap = require("dap")

      -- Use c:\bin\netcoredbg.exe directly (user preferred, 3.1.2).
      -- Mason installs only a .CMD batch shim that jobstart() cannot execute.
      -- Fallback to Mason's real .exe if c:\bin is absent.
      local netcoredbg_cmd
      if vim.fn.has("win32") == 1 then
        if vim.fn.filereadable("c:\\bin\\netcoredbg.exe") == 1 then
          netcoredbg_cmd = "c:\\bin\\netcoredbg.exe"
        else
          netcoredbg_cmd = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe"
        end
      else
        netcoredbg_cmd = "netcoredbg"
      end

      dap.adapters.coreclr = {
        type    = "executable",
        command = netcoredbg_cmd,
        args    = { "--interpreter=vscode" },
        -- On Windows, Neovim buffer paths use forward slashes but PDB files embed backslashes.
        -- enrich_config runs at launch time (after function values in the config are resolved)
        -- so we can safely read cwd and build the correct sourceFileMap.
        enrich_config = function(config, on_config)
          if vim.fn.has("win32") == 1 then
            local raw_cwd = type(config.cwd) == "function" and config.cwd()
              or (config.cwd or vim.fn.getcwd())
            local bwd = raw_cwd:gsub("/", "\\")  -- backslash  (PDB key)
            local fwd = raw_cwd:gsub("\\", "/")  -- forward    (Neovim value)
            config = vim.tbl_extend("keep", config, {
              requireExactSource = false,
              sourceFileMap      = { [bwd] = fwd },
            })
          end
          on_config(config)
        end,
      }

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
          cwd              = vim.fn.getcwd,
          env              = { ASPNETCORE_ENVIRONMENT = "Development" },
          justMyCode       = false,
        },
        {
          type    = "coreclr",
          name    = "Launch: select DLL",
          request = "launch",
          program = function()
            return vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
          cwd              = vim.fn.getcwd,
          env              = { ASPNETCORE_ENVIRONMENT = "Development" },
          justMyCode       = false,
        },
        {
          -- Useful for attaching to a running process (e.g. VSTEST_HOST_DEBUG scenarios)
          type       = "coreclr",
          name       = "Attach to process",
          request    = "attach",
          justMyCode = false,
          processId  = function()
            return require("dap.utils").pick_process()
          end,
        },
      }

      -- Prepend any project-level configs from .vimspector.json
      local ok, vimspector = pcall(require, "utils.vimspector_config")
      if ok then
        local project_configs = vimspector.get_project_configs()
        for i, cfg in ipairs(project_configs) do
          table.insert(configs, i, cfg)
        end
      end

      dap.configurations.cs = configs
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
}

