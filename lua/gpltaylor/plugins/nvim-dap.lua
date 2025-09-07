return {
  -- Debug Adapter Protocol plugin
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",            -- UI for nvim-dap
      "theHamsta/nvim-dap-virtual-text", -- Virtual text for inline debug info
    },
    config = function()
      -- Load the configurations below
      require("dap-config")
      local dapui = require("dapui")
      local dap = require("dap")

      dapui.setup()

      -- Open DAP UI automatically
      local dap = require("dap")
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

  -- Optional: Auto-detect and configure DAP adapters for languages
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim", -- Install and manage external tools
    },
    opts = {
      automatic_installation = true,
      ensure_installed = { "coreclr" }, -- Install netcoredbg for C#
    },
  },
}
