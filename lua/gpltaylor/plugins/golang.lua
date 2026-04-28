return {
  -- Treesitter for Go
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "go", "gomod", "gowork", "gotmpl" })
      end
    end,
  },

  -- Mason installation for Go tools
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { 
        "gopls",           -- Go language server
        "delve",           -- Go debugger
        "gofumpt",         -- Go formatter
        "golines",         -- Go line formatter (for max_line_len)
        "goimports",       -- Go imports organizer
        "golangci-lint",   -- Go linter
        "gomodifytags",    -- Go struct tag modifier
        "gotests",         -- Go test generator
        "impl",            -- Go interface implementation generator
      },
    },
  },

  -- LSP configuration for Go with gopls
  {
    "neovim/nvim-lspconfig",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      servers = {
        gopls = {
          cmd = { "gopls" },
          filetypes = { "go", "gomod", "gowork", "gotmpl" },
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
                unreachable = true,
                nilness = true,
                unusedwrite = true,
                useany = true,
              },
              experimentalPostfixCompletions = true,
              gofumpt = true,
              staticcheck = true,
              usePlaceholders = true,
              completeUnimported = true,
              matcher = "Fuzzy",
              diagnosticsDelay = "500ms",
              symbolMatcher = "fuzzy",
              ["local"] = "",
              buildFlags = { "-tags", "integration" },
              env = {
                GOFLAGS = "-tags=integration",
              },
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
        },
      },
    },
  },

  -- Go-specific tools and enhanced functionality
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        goimports = "gopls", -- Use gopls for imports
        gofmt = "golines",   -- Use golines for formatting to make max_line_len work
        max_line_len = 120,  -- This only works with golines
        tag_transform = false,
        test_dir = "",
        comment_placeholder = "   ",
        lsp_cfg = false, -- lspconfig.lua handles gopls via setup_handlers
        lsp_gofumpt = false, -- handled in gopls settings
        lsp_on_attach = false, -- lspconfig.lua on_attach handles it
        dap_debug = true,
        dap_debug_gui = true,
        dap_debug_keymap = true,
        dap_vt = true, -- Virtual text for debugging
        build_tags = "integration",
        textobjects = true,
        test_runner = "go", -- Use go test
        verbose_tests = true,
        run_in_floaterm = false,
        luasnip = true,
      })

      -- Auto format on save
      local format_sync_grp = vim.api.nvim_create_augroup("goimports", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require("go.format").goimports()
        end,
        group = format_sync_grp,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()',
  },

  -- DAP configuration for Go debugging
  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup({
        dap_configurations = {
          {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
        delve = {
          path = "dlv",
          initialize_timeout_sec = 20,
          port = "${port}",
          args = {},
          build_flags = "-tags=integration",
          detached = vim.fn.has("win32") == 0, -- false on Windows
          cwd = nil,
        },
      })
    end,
    ft = "go",
  },

  -- Enhanced Go DAP configuration
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = { "jay-babu/mason-nvim-dap.nvim" },
    config = function()
      require("mason-nvim-dap").setup({ ensure_installed = { "delve" } })
      local dap = require("dap")
      
      dap.adapters.delve = {
        type = "server",
        port = "${port}",
        executable = {
          command = "dlv",
          args = { "dap", "-l", "127.0.0.1:${port}" },
          detached = vim.fn.has("win32") == 0,
        },
      }

      dap.configurations.go = {
        {
          type = "delve",
          name = "Debug",
          request = "launch",
          program = "${file}",
          buildFlags = "-tags=integration",
        },
        {
          type = "delve",
          name = "Debug test", -- configuration for debugging test files
          request = "launch",
          mode = "test",
          program = "${file}",
          buildFlags = "-tags=integration",
        },
        {
          type = "delve",
          name = "Debug test (go.mod)",
          request = "launch",
          mode = "test",
          program = "./${relativeFileDirname}",
          buildFlags = "-tags=integration",
        },
        {
          type = "delve",
          name = "Attach to process",
          request = "attach",
          mode = "local",
          processId = function()
            local input = vim.fn.input("Enter process ID: ")
            return tonumber(input)
          end,
        },
      }
    end,
  },

  -- Formatting configuration
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = { 
        go = { "goimports", "gofumpt" },
        gomod = { "gofumpt" },
      },
      formatters = {
        goimports = {
          command = "goimports",
          args = { "-w", "$FILENAME" },
          stdin = false,
        },
        gofumpt = {
          command = "gofumpt",
          args = { "-w", "$FILENAME" },
          stdin = false,
        },
      },
    },
  },

}
