local dap = require("dap")
local vimspector_utils = require("utils.vimspector_config")

-- Configure the .NET Core Debug Adapter
dap.adapters.coreclr = {
  type = "executable",
  command = "netcoredbg.exe",
  args = { "--interpreter=vscode" },
}

-- Function to get C# configurations with vimspector.json support
local function get_cs_configurations()
  -- First, try to load configurations from .vimspector.json
  local project_configs = vimspector_utils.get_project_configs()
  
  if #project_configs > 0 then
    -- Add a quick launch option at the top
    table.insert(project_configs, 1, {
      type = "coreclr",
      name = "🚀 Quick Launch (Auto-detect)",
      request = "launch",
      program = function()
        local main_dll = vimspector_utils.find_main_dll()
        if main_dll then
          return main_dll
        end
        return vim.fn.input("Path to DLL > ", vim.fn.getcwd() .. "/bin/Debug/", "file")
      end,
      cwd = vim.fn.getcwd,
      env = {
        ASPNETCORE_ENVIRONMENT = 'Development'
      },
      justMyCode = false,
    })
    
    return project_configs
  end
  
  -- Fallback to default configurations if no .vimspector.json
  return {
    {
      type = "coreclr",
      name = "🚀 Quick Launch (Auto-detect)",
      request = "launch",
      program = function()
        local main_dll = vimspector_utils.find_main_dll()
        if main_dll then
          return main_dll
        end
        return vim.fn.input("Path to DLL > ", vim.fn.getcwd() .. "/bin/Debug/", "file")
      end,
      cwd = vim.fn.getcwd,
      env = {
        ASPNETCORE_ENVIRONMENT = 'Development'
      },
      justMyCode = false,
    },
    {
      type = "coreclr",
      name = "Launch - Select DLL",
      request = "launch",
      program = function()
        return vim.fn.input("Path to DLL > ", vim.fn.getcwd() .. "/bin/Debug/", "file") 
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
end

-- Set up C# configurations
dap.configurations.cs = get_cs_configurations()

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
