local M = {}

-- Find the Go module root (directory containing go.mod)
M.find_go_mod_root = function()
  local current_file = vim.fn.expand("%:p")
  local current_dir = vim.fn.fnamemodify(current_file, ":h")
  
  -- Search upward for go.mod
  local go_mod_path = vim.fs.find("go.mod", {
    path = current_dir,
    upward = true,
    type = "file"
  })[1]
  
  if go_mod_path then
    return vim.fn.fnamemodify(go_mod_path, ":h")
  end
  
  return nil
end

-- Find the main.go file in common locations
M.find_main_go = function()
  local go_root = M.find_go_mod_root()
  if not go_root then
    return nil
  end
  
  -- Common locations for main.go
  local common_paths = {
    go_root .. "/main.go",           -- Root level
    go_root .. "/src/main.go",       -- src folder
    go_root .. "/cmd/main.go",       -- cmd folder
    go_root .. "/app/main.go",       -- app folder
  }
  
  for _, path in ipairs(common_paths) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  
  -- If no main.go found, check for any .go files with main function
  local function find_main_func_in_dir(dir)
    local go_files = vim.fn.glob(dir .. "/*.go", false, true)
    for _, file in ipairs(go_files) do
      local content = vim.fn.readfile(file)
      for _, line in ipairs(content) do
        if line:match("^func main%(") then
          return file
        end
      end
    end
    return nil
  end
  
  -- Check src directory first, then root
  local src_main = find_main_func_in_dir(go_root .. "/src")
  if src_main then
    return src_main
  end
  
  local root_main = find_main_func_in_dir(go_root)
  if root_main then
    return root_main
  end
  
  return nil
end

-- Get the appropriate directory for Go commands
M.get_go_run_dir = function()
  local go_root = M.find_go_mod_root()
  if not go_root then
    vim.notify("No go.mod found. Are you in a Go project?", vim.log.levels.WARN)
    return vim.fn.getcwd()
  end
  
  -- Check if main.go is in src directory
  local src_main = go_root .. "/src/main.go"
  if vim.fn.filereadable(src_main) == 1 then
    return go_root .. "/src"
  end
  
  -- Check for any main function in src
  local src_dir = go_root .. "/src"
  if vim.fn.isdirectory(src_dir) == 1 then
    local go_files = vim.fn.glob(src_dir .. "/*.go", false, true)
    for _, file in ipairs(go_files) do
      local content = vim.fn.readfile(file)
      for _, line in ipairs(content) do
        if line:match("^func main%(") then
          return src_dir
        end
      end
    end
  end
  
  return go_root
end

-- Enhanced Go build function
M.go_build = function()
  local run_dir = M.get_go_run_dir()
  local original_cwd = vim.fn.getcwd()
  
  vim.cmd("cd " .. vim.fn.fnameescape(run_dir))
  vim.cmd("GoBuild")
  vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
end

-- Enhanced Go run function
M.go_run = function()
  local run_dir = M.get_go_run_dir()
  local original_cwd = vim.fn.getcwd()
  
  vim.cmd("cd " .. vim.fn.fnameescape(run_dir))
  vim.cmd("GoRun")
  vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
end

-- Enhanced Go run with compile function
M.go_run_compile = function()
  local run_dir = M.get_go_run_dir()
  local original_cwd = vim.fn.getcwd()
  
  vim.cmd("cd " .. vim.fn.fnameescape(run_dir))
  vim.cmd("GoRun -c")
  vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
end

-- Alternative: Use terminal commands for more control
M.go_build_terminal = function()
  local run_dir = M.get_go_run_dir()
  local cmd = string.format("cd /d \"%s\" && go build", run_dir)
  vim.cmd("!" .. cmd)
end

M.go_run_terminal = function()
  local run_dir = M.get_go_run_dir()
  local cmd = string.format("cd /d \"%s\" && go run .", run_dir)
  vim.cmd("!" .. cmd)
end

-- Test functions that work from project root
M.go_test_package = function()
  local go_root = M.find_go_mod_root()
  if not go_root then
    vim.notify("No go.mod found. Are you in a Go project?", vim.log.levels.WARN)
    return
  end
  
  local original_cwd = vim.fn.getcwd()
  vim.cmd("cd " .. vim.fn.fnameescape(go_root))
  vim.cmd("GoTest -p")
  vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
end

-- Debug function that handles src directory
M.debug_main = function()
  local main_file = M.find_main_go()
  if not main_file then
    vim.notify("No main.go file found in project", vim.log.levels.WARN)
    return
  end
  
  -- Update DAP configuration dynamically
  local dap = require('dap')
  if dap.configurations.go then
    for _, config in ipairs(dap.configurations.go) do
      if config.name == "Debug" then
        config.program = main_file
        break
      end
    end
  end
  
  require('dap').continue()
end

return M
