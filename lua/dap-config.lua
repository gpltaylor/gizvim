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

-- Configure the Go Debug Adapter (Delve)
dap.adapters.delve = {
  type = "server",
  port = "${port}",
  executable = {
    command = "dlv",
    args = { "dap", "-l", "127.0.0.1:${port}" },
    detached = vim.fn.has("win32") == 0, -- false on Windows, true on Unix
  },
}

-- Set up Go configurations
dap.configurations.go = {
  {
    type = "delve",
    name = "Debug",
    request = "launch",
    program = function()
      local go_utils = require("utils.go_utils")
      local main_file = go_utils.find_main_go()
      if main_file then
        return main_file
      end
      -- Fallback to current file
      return "${file}"
    end,
    buildFlags = "-tags=integration",
  },
  {
    type = "delve",
    name = "Debug Package (src-aware)",
    request = "launch",
    program = function()
      local go_utils = require("utils.go_utils")
      local run_dir = go_utils.get_go_run_dir()
      return run_dir
    end,
    buildFlags = "-tags=integration",
  },
  {
    type = "delve",
    name = "Debug test",
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
  {
    type = "delve",
    name = "Debug with arguments",
    request = "launch",
    program = function()
      local go_utils = require("utils.go_utils")
      local main_file = go_utils.find_main_go()
      if main_file then
        return main_file
      end
      return "${file}"
    end,
    args = function()
      local args_input = vim.fn.input("Enter arguments: ")
      return vim.split(args_input, " ")
    end,
    buildFlags = "-tags=integration",
  },
}
