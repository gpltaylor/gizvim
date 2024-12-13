local dap = require("dap")

-- Configure the .NET Core Debug Adapter
dap.adapters.coreclr = {
  type = "executable",
  command = "netcoredbg.exe",
  args = { "--interpreter=vscode" },
}

-- Set up C# configurations
dap.configurations.cs = {
  {
    type = "coreclr",
    name = "Launch - Console",
    request = "launch",
    program = function()
      return vim.fn.input("Path to DLL > ", vim.fn.getcwd() .. "/bin/Debug/net9.0/", "file")
    end,
  },
}

