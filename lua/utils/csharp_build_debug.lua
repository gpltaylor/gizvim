local M = {}

-- Function to find solution files and project files in current directory and src subfolder
function M.find_dotnet_projects()
  local cwd = vim.fn.getcwd()
  
  -- Define search paths: current directory and src subfolder
  local search_paths = {
    cwd,                    -- Current directory
    cwd .. "/src"          -- src subfolder
  }
  
  -- Look for solution files first (preferred) in all search paths
  for _, search_path in ipairs(search_paths) do
    local sln_files = vim.fn.glob(search_path .. "/*.sln", false, true)
    if #sln_files > 0 then
      return { type = "solution", files = sln_files, path = search_path }
    end
  end
  
  -- Look for project files in all search paths
  for _, search_path in ipairs(search_paths) do
    local proj_files = vim.fn.glob(search_path .. "/**/*.csproj", false, true)
    if #proj_files > 0 then
      return { type = "project", files = proj_files, path = search_path }
    end
  end
  
  return nil
end

-- Function to build the dotnet project/solution
function M.build_dotnet_project()
  local projects = M.find_dotnet_projects()
  
  if not projects then
    vim.notify("❌ No .sln or .csproj files found in current directory or ./src", vim.log.levels.ERROR)
    return false
  end
  
  local build_target
  local location_info = ""
  
  if projects.type == "solution" then
    build_target = projects.files[1] -- Use first solution file
    local relative_path = vim.fn.fnamemodify(build_target, ":~:.")
    location_info = " (" .. relative_path .. ")"
    vim.notify("🔨 Building solution: " .. vim.fn.fnamemodify(build_target, ":t") .. location_info, vim.log.levels.INFO)
  else
    -- For projects, build the directory containing the projects
    build_target = projects.path
    local relative_path = vim.fn.fnamemodify(build_target, ":~:.")
    location_info = " (" .. relative_path .. ")"
    vim.notify("🔨 Building project(s) in: " .. vim.fn.fnamemodify(build_target, ":t") .. location_info, vim.log.levels.INFO)
  end
  
  -- Run dotnet build
  local build_cmd = "dotnet build \"" .. build_target .. "\""
  vim.notify("Running: " .. build_cmd, vim.log.levels.DEBUG)
  
  local result = vim.fn.system(build_cmd)
  local exit_code = vim.v.shell_error
  
  if exit_code == 0 then
    vim.notify("✅ Build successful!" .. location_info, vim.log.levels.INFO)
    return true
  else
    vim.notify("❌ Build failed!" .. location_info, vim.log.levels.ERROR)
    -- Show build output in a new buffer for user to see errors
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(result, "\n"))
    vim.api.nvim_buf_set_option(bufnr, 'filetype', 'text')
    vim.api.nvim_buf_set_name(bufnr, 'Build Output')
    vim.api.nvim_win_set_buf(0, bufnr)
    return false
  end
end

-- Function to build and then debug (F5 replacement)
function M.build_and_debug()
  local vimspector_utils = require("utils.vimspector_config")
  local dap = require("dap")
  
  -- First, build the project
  vim.notify("🚀 Build and Debug: Starting build...", vim.log.levels.INFO)
  
  if not M.build_dotnet_project() then
    vim.notify("❌ Cannot debug: Build failed", vim.log.levels.ERROR)
    return
  end
  
  -- Build succeeded, now find and launch the DLL
  vim.notify("🔍 Looking for executable...", vim.log.levels.INFO)
  
  -- Check if we have vimspector config
  if vimspector_utils.has_vimspector_config() then
    -- Try quick launch first
    local main_dll = vimspector_utils.find_main_dll()
    if main_dll then
      vim.notify("🚀 Launching: " .. vim.fn.fnamemodify(main_dll, ":t"), vim.log.levels.INFO)
      -- Create a quick launch config
      local quick_config = {
        type = "coreclr",
        name = "Quick Launch (Build & Debug)",
        request = "launch",
        program = main_dll,
        cwd = vim.fn.getcwd(),
        env = { ASPNETCORE_ENVIRONMENT = 'Development' },
        justMyCode = false,
      }
      dap.run(quick_config)
      return
    end
  end
  
  -- Fallback: try to find DLL after build
  local main_dll = vimspector_utils.find_main_dll()
  if main_dll then
    vim.notify("🚀 Launching: " .. vim.fn.fnamemodify(main_dll, ":t"), vim.log.levels.INFO)
    local quick_config = {
      type = "coreclr",
      name = "Quick Launch (Build & Debug)",
      request = "launch",
      program = main_dll,
      cwd = vim.fn.getcwd(),
      env = { ASPNETCORE_ENVIRONMENT = 'Development' },
      justMyCode = false,
    }
    dap.run(quick_config)
  else
    -- No DLL found, show selection menu
    vim.notify("⚠️  No executable found, showing debug menu...", vim.log.levels.WARN)
    dap.continue()
  end
end

return M