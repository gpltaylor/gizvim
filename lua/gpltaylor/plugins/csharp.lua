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

      -- Resolve the real netcoredbg executable; never the .cmd shim.
      -- The Mason .cmd wrapper is a batch script and cannot be used as a
      -- DAP adapter command (jobstart() on Windows won't exec it).
      -- Prefer the system PATH install (was working before Mason was set up).
      local function find_netcoredbg()
        local found = vim.fn.exepath("netcoredbg")
        -- exepath() may return the Mason .cmd shim (e.g. netcoredbg.CMD on Windows).
        -- .cmd batch files cannot be used as DAP adapter executables via jobstart().
        -- Use lower() so the check works regardless of .cmd / .CMD / .Cmd casing.
        if found ~= "" and not found:lower():match("%.cmd$") then
          return found
        end
        -- Fall back to the real .exe inside the Mason package directory.
        local mason_exe = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe"
        if vim.fn.filereadable(mason_exe) == 1 then
          return mason_exe
        end
        -- Last resort: bare name (may work if c:\bin is on PATH without the shim).
        return "netcoredbg"
      end

      dap.adapters.coreclr = {
        type    = "executable",
        command = find_netcoredbg(),
        args    = { "--interpreter=vscode" },
        -- options.detached intentionally omitted: nvim-dap passes adapter.options
        -- to jobstart() which uses the key 'detach' (not 'detached'), so setting
        -- detached here is a no-op. Windows jobstart already defaults to detach=false.
      }

      -- sourceFileMap: PDB embeds source paths with Windows backslashes.
      -- Map the workspace backslash path → forward-slash so netcoredbg can
      -- match the setBreakpoints source path from Neovim against PDB entries.
      --
      -- NOTE: vim.fn.getcwd() returns backslashes on Windows. We must normalise
      -- to forward slashes first so the VALUE matches Neovim's buffer paths
      -- (which always use forward slashes for breakpoint source).
      local function make_source_file_map()
        local cwd_fwd = vim.fn.getcwd():gsub("\\", "/")  -- "D:/redbear/..."
        local cwd_bwd = cwd_fwd:gsub("/", "\\")          -- "D:\redbear\..."
        return { [cwd_bwd] = cwd_fwd }
      end

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
                return dll  -- forward-slash path; matches Neovim breakpoint source paths
              end
            end
            return vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
          -- cwd = DLL directory so appsettings.json (copied there by build) is found
          cwd = function()
            local ok, vimspector = pcall(require, "utils.vimspector_config")
            if ok then
              local dll = vimspector.find_main_dll()
              if dll and dll ~= "" then
                return vim.fn.fnamemodify(dll, ":h")
              end
            end
            return vim.fn.getcwd()
          end,
          env              = { ASPNETCORE_ENVIRONMENT = "Development" },
          justMyCode       = false,
          stopAtEntry      = false,
          sourceFileMap    = make_source_file_map,
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
          stopAtEntry      = false,
          sourceFileMap    = make_source_file_map,
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

