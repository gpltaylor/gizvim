local M = {}

-- Function to check if .vimspector.json exists in current working directory
function M.has_vimspector_config()
  local cwd = vim.fn.getcwd()
  local vimspector_file = cwd .. "/.vimspector.json"
  return vim.fn.filereadable(vimspector_file) == 1
end

-- Function to parse .vimspector.json and extract DAP configurations
function M.parse_vimspector_config()
  local cwd = vim.fn.getcwd()
  local vimspector_file = cwd .. "/.vimspector.json"
  
  if vim.fn.filereadable(vimspector_file) == 0 then
    return nil
  end
  
  local content = vim.fn.readfile(vimspector_file)
  local json_str = table.concat(content, "\n")
  
  local ok, config = pcall(vim.fn.json_decode, json_str)
  if not ok then
    vim.notify("Failed to parse .vimspector.json: " .. config, vim.log.levels.ERROR)
    return nil
  end
  
  return config
end

-- Function to convert vimspector config to DAP format
function M.vimspector_to_dap_config(vimspector_config)
  if not vimspector_config or not vimspector_config.configurations then
    return {}
  end
  
  local dap_configs = {}
  
  for name, config in pairs(vimspector_config.configurations) do
    if config.configuration then
      local dap_config = {
        type = "coreclr",
        name = name,
        request = config.configuration.request or "launch",
        program = config.configuration.program,
        args = config.configuration.args or {},
        cwd = config.configuration.cwd,
        env = config.configuration.env or {},
        stopOnEntry = config.configuration.stopOnEntry or false,
        justMyCode = false,
      }
      
      -- Handle variable substitution
      if dap_config.program then
        dap_config.program = M.substitute_variables(dap_config.program)
      end
      if dap_config.cwd then
        dap_config.cwd = M.substitute_variables(dap_config.cwd)
      end
      
      -- Handle attach configurations
      if dap_config.request == "attach" then
        if config.configuration.processId then
          if config.configuration.processId == "${command:pickProcess}" then
            dap_config.processId = function()
              local input = vim.fn.input("Enter process ID: ")
              return tonumber(input)
            end
          else
            dap_config.processId = config.configuration.processId
          end
        end
      end
      
      table.insert(dap_configs, dap_config)
    end
  end
  
  return dap_configs
end

-- Function to substitute variables like ${workspaceRoot}
function M.substitute_variables(str)
  if not str then return str end
  
  local cwd = vim.fn.getcwd()
  -- Replace ${workspaceRoot} with current working directory
  str = string.gsub(str, "${workspaceRoot}", cwd)
  -- Replace ${workspaceFolder} with current working directory (VSCode compatibility)
  str = string.gsub(str, "${workspaceFolder}", cwd)
  
  return str
end

-- Function to get configurations for current project
function M.get_project_configs()
  local vimspector_config = M.parse_vimspector_config()
  if vimspector_config then
    return M.vimspector_to_dap_config(vimspector_config)
  end
  return {}
end

-- Function to find the most likely main DLL for quick launch
function M.find_main_dll()
  local cwd = vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(cwd, ":t")
  
  -- Look for specific patterns - prioritize API/web projects over tests
  local search_paths = {
    -- Look for API projects first
    cwd .. "/*api*/bin/Debug/net*/",
    cwd .. "/*API*/bin/Debug/net*/",
    cwd .. "/*web*/bin/Debug/net*/",
    cwd .. "/*Web*/bin/Debug/net*/",
    -- Look for main project DLL
    cwd .. "/" .. project_name .. "/bin/Debug/net*/",
    -- Look for any executable project (not tests)
    cwd .. "/*/bin/Debug/net*/",
    -- Fallback to root bin folder
    cwd .. "/bin/Debug/net*/",
  }
  
  for _, search_path in ipairs(search_paths) do
    local dll_pattern = search_path .. "*.dll"
    local files = vim.fn.glob(dll_pattern, false, true)
    
    if #files > 0 then
      -- Sort files, prioritizing main executable DLLs
      local main_dlls = {}
      local other_dlls = {}
      
      for _, file in ipairs(files) do
        local filename = vim.fn.fnamemodify(file, ":t"):lower()
        local is_test = string.match(filename, "test") or string.match(filename, "spec")
        local is_dependency = string.match(filename, "microsoft%.") or 
                              string.match(filename, "system%.") or
                              string.match(filename, "newtonsoft%.") or
                              string.match(filename, "^test")
        
        if not is_test and not is_dependency then
          -- Check if it matches project structure
          local dir_name = vim.fn.fnamemodify(vim.fn.fnamemodify(file, ":h"), ":h:h:t"):lower()
          if string.match(filename, "api") or string.match(filename, "web") or 
             string.match(dir_name, "api") or string.match(dir_name, "web") then
            table.insert(main_dlls, file)
          else
            table.insert(other_dlls, file)
          end
        end
      end
      
      -- Return the first main DLL, or first other DLL if no main found
      if #main_dlls > 0 then
        return main_dlls[1]
      elseif #other_dlls > 0 then
        return other_dlls[1]
      end
    end
  end
  
  return nil
end

return M