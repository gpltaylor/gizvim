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

      -- DAP logging: enable DEBUG-level protocol log to help diagnose
      -- breakpoint rejections, adapter launch failures, etc.
      -- View with :DapLog  (tail end shown in a split)
      dap.set_log_level("DEBUG")

      vim.api.nvim_create_user_command("DapLog", function()
        local log = vim.fn.stdpath("cache") .. "/dap.log"
        if vim.fn.filereadable(log) == 0 then
          vim.notify("DAP log not found: " .. log, vim.log.levels.WARN)
          return
        end
        vim.cmd("botright split " .. log)
        vim.cmd("normal! G")  -- jump to end (most recent entries)
      end, { desc = "Open DAP debug log (tail)" })

      vim.api.nvim_create_user_command("DapStatus", function()
        local adapter = require("dap").adapters.coreclr
        if adapter then
          vim.notify("coreclr adapter: " .. vim.inspect(adapter.command), vim.log.levels.INFO)
        else
          vim.notify("coreclr adapter: NOT registered", vim.log.levels.WARN)
        end
        local cfgs = require("dap").configurations.cs
        local count = cfgs and #cfgs or 0
        vim.notify("dap.configurations.cs: " .. count .. " configs", vim.log.levels.INFO)
      end, { desc = "Show C# DAP adapter and config status" })
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
