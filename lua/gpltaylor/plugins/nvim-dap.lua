-- ============================================================
-- nvim-dap: base DAP setup + UI
-- Language-specific adapter configs live in their plugin files:
--   csharp.lua  → coreclr / netcoredbg
--   golang.lua  → delve
-- ============================================================
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dapui = require("dapui")
      local dap = require("dap")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- mason-nvim-dap: kept for ensure_installed (tool installation only).
  -- automatic_installation is DISABLED: its built-in adapter handlers use
  -- .cmd batch wrappers on Windows which cannot be used as DAP executables.
  -- Each language plugin configures its own adapter with the correct binary path.
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      automatic_installation = false,
      ensure_installed = {},
    },
  },
}
