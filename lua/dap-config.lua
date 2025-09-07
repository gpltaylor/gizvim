local dap = require("dap")

-- Configure the .NET Core Debug Adapter
dap.adapters.coreclr = {
  type = "executable",
  command = "netcoredbg.exe",
  args = { "--interpreter=vscode" },
}

-- Set up C# configurations
-- $env:VSTEST_HOST_DEBUG=1
-- dotnet test --filter FullyQualifiedName~GplTaylor.Lua.Tests --logger "console;verbosity=detailed" --no-build --no-restore
dap.configurations.cs = {
  {
    type = "coreclr",
    name = "Launch - Console",
    request = "launch",
    program = function()
      -- return vim.fn.input("Path to DLL > ", vim.fn.getcwd() .. "/bin/Debug/net9.0/", "file")
      return vim.fn.input("A3) Path to DLL >> ", vim.fn.getcwd() .. "/bin/Debug/", "file") 
    end,
    cwd = vim.fn.getcwd,
    env = {
      ASPNETCORE_ENVIRONMENT = 'Development'
    },
    justMyCode = false,
  },
  {
    type = "coreclr",
    name = "Attach to process",
    request = "attach",
    justMyCode = false,
    processId = function()
      local input = vim.fn.input("Enter process ID: ")
      return tonumber(input)
    end
  }
}
