local M = {}

-- Configuration for NuGet source mappings
M.config = {
  -- Base directories where RedBear projects are located
  redbear_base_dirs = {
    "d:/redbear/honeycomb/",
    "d:/redbear/",
    "c:/code/redbear/",
  },
  
  -- Additional source mappings for other packages
  source_mappings = {
    -- Add more mappings as needed
    -- ["PackageName"] = "path/to/source"
  },
  
  -- GitHub source mappings for public packages
  github_mappings = {
    ["Microsoft.Extensions.Hosting"] = {
      repo = "dotnet/runtime",
      path_prefix = "src/libraries/Microsoft.Extensions.Hosting/src",
      branch = "main"
    },
    ["Microsoft.Extensions.DependencyInjection"] = {
      repo = "dotnet/runtime", 
      path_prefix = "src/libraries/Microsoft.Extensions.DependencyInjection/src",
      branch = "main"
    },
    ["Microsoft.Extensions.Configuration"] = {
      repo = "dotnet/runtime",
      path_prefix = "src/libraries/Microsoft.Extensions.Configuration/src", 
      branch = "main"
    },
    ["Microsoft.Extensions.Logging"] = {
      repo = "dotnet/runtime",
      path_prefix = "src/libraries/Microsoft.Extensions.Logging/src",
      branch = "main"
    },
    ["Microsoft.AspNetCore"] = {
      repo = "dotnet/aspnetcore",
      path_prefix = "src",
      branch = "main"
    },
    ["System.Text.Json"] = {
      repo = "dotnet/runtime",
      path_prefix = "src/libraries/System.Text.Json/src",
      branch = "main"
    },
    ["Newtonsoft.Json"] = {
      repo = "JamesNK/Newtonsoft.Json",
      path_prefix = "Src/Newtonsoft.Json",
      branch = "master"
    },
    ["EntityFramework"] = {
      repo = "dotnet/efcore",
      path_prefix = "src",
      branch = "main"
    },
    ["AutoMapper"] = {
      repo = "AutoMapper/AutoMapper",
      path_prefix = "src/AutoMapper",
      branch = "master"
    },
    ["Serilog"] = {
      repo = "serilog/serilog",
      path_prefix = "src/Serilog",
      branch = "dev"
    },
    ["NUnit"] = {
      repo = "nunit/nunit",
      path_prefix = "src/NUnitFramework/framework",
      branch = "master"
    },
    ["xunit"] = {
      repo = "xunit/xunit",
      path_prefix = "src/xunit.core",
      branch = "main"
    },
  },
  
  -- Cache for resolved paths to improve performance
  path_cache = {},
  
  -- Downloaded source cache directory
  source_cache_dir = vim.fn.stdpath("cache") .. "/csharp_sources",
}

-- Parse C# metadata URI to extract package information
M.parse_metadata_uri = function(uri)
  -- Example URI: csharp:/metadata/projects/RedBear.MoneyBot.Api/assemblies/RedBear.Common.Containers/symbols/RedBear.Common.Containers.ContainerLifecycle.cs
  
  if not uri:match("^csharp:/metadata/") then
    return nil
  end
  
  local parts = {}
  for part in uri:gmatch("[^/]+") do
    table.insert(parts, part)
  end
  
  if #parts < 6 then
    return nil
  end
  
  -- Extract information from URI parts
  local project_name = parts[4]  -- RedBear.MoneyBot.Api
  local assembly_name = parts[6] -- RedBear.Common.Containers
  local file_path = parts[8]     -- RedBear.Common.Containers.ContainerLifecycle.cs
  
  return {
    project = project_name,
    assembly = assembly_name,
    file = file_path,
    full_uri = uri
  }
end

-- Find the actual source file for a NuGet package
M.find_source_file = function(metadata_info)
  if not metadata_info then
    return nil
  end
  
  -- Check cache first
  local cache_key = metadata_info.full_uri
  if M.config.path_cache[cache_key] then
    return M.config.path_cache[cache_key]
  end
  
  local assembly = metadata_info.assembly
  local file_path = metadata_info.file
  
  -- Convert C# file path to actual file path
  -- RedBear.Common.Containers.ContainerLifecycle.cs -> ContainerLifecycle.cs
  local actual_filename = file_path:match("([^%.]+%.cs)$") or file_path
  
  -- For RedBear packages, try to find in known locations
  if assembly:match("^RedBear%.") then
    for _, base_dir in ipairs(M.config.redbear_base_dirs) do
      local project_dir = base_dir .. assembly .. "/"
      
      -- Try common source locations within the project
      local search_paths = {
        project_dir .. actual_filename,
        project_dir .. "src/" .. actual_filename,
        project_dir .. "Source/" .. actual_filename,
      }
      
      -- Also search recursively in the project directory
      if vim.fn.isdirectory(project_dir) == 1 then
        -- Windows-compatible recursive search
        local search_cmd
        if vim.fn.has("win32") == 1 then
          search_cmd = string.format(
            'dir "%s" /s /b /a-d | findstr /i "\\%s$"',
            project_dir:gsub("/", "\\"),
            actual_filename:gsub("%.", "\\.")
          )
        else
          search_cmd = string.format(
            'find "%s" -name "%s" -type f 2>/dev/null',
            project_dir,
            actual_filename
          )
        end
        
        local find_result = vim.fn.system(search_cmd)
        
        if vim.v.shell_error == 0 and find_result:len() > 0 then
          local found_path = find_result:gsub("\n.*", ""):gsub("\\", "/")
          if vim.fn.filereadable(found_path) == 1 then
            M.config.path_cache[cache_key] = found_path
            return found_path
          end
        end
      end
      
      -- Try the predefined search paths
      for _, path in ipairs(search_paths) do
        if vim.fn.filereadable(path) == 1 then
          M.config.path_cache[cache_key] = path
          return path
        end
      end
    end
  end
  
  -- Check custom source mappings
  local mapping = M.config.source_mappings[assembly]
  if mapping then
    local mapped_path = mapping .. "/" .. actual_filename
    if vim.fn.filereadable(mapped_path) == 1 then
      M.config.path_cache[cache_key] = mapped_path
      return mapped_path
    end
  end
  
  -- Try to download from GitHub for public packages
  local github_source = M.download_github_source(metadata_info)
  if github_source then
    M.config.path_cache[cache_key] = github_source
    return github_source
  end
  
  return nil
end

-- Download source file from GitHub
M.download_github_source = function(metadata_info)
  if not metadata_info then
    return nil
  end
  
  local assembly = metadata_info.assembly
  local file_path = metadata_info.file
  
  -- Check if we have GitHub mapping for this assembly
  local github_info = M.config.github_mappings[assembly]
  if not github_info then
    -- Try to find a partial match (e.g., Microsoft.Extensions.Hosting.Abstractions -> Microsoft.Extensions.Hosting)
    for mapped_assembly, info in pairs(M.config.github_mappings) do
      if assembly:match("^" .. mapped_assembly:gsub("%.", "%%.") .. "%.") then
        github_info = info
        break
      end
    end
  end
  
  if not github_info then
    return nil
  end
  
  -- Convert C# file path to actual file name
  local actual_filename = file_path:match("([^%.]+%.cs)$") or file_path
  
  -- Create cache directory if it doesn't exist
  local cache_dir = M.config.source_cache_dir .. "/" .. assembly
  vim.fn.mkdir(cache_dir, "p")
  
  -- Check if file already exists in cache
  local cached_file = cache_dir .. "/" .. actual_filename
  if vim.fn.filereadable(cached_file) == 1 then
    return cached_file
  end
  
  -- Construct GitHub raw URL
  local github_url = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/%s",
    github_info.repo,
    github_info.branch,
    github_info.path_prefix,
    actual_filename
  )
  
  vim.notify("Downloading source from GitHub: " .. actual_filename, vim.log.levels.INFO)
  
  -- Download the file using curl (Windows compatible)
  local curl_cmd
  if vim.fn.has("win32") == 1 then
    curl_cmd = string.format('curl -s -L -o "%s" "%s"', cached_file, github_url)
  else
    curl_cmd = string.format('curl -s -L -o "%s" "%s"', cached_file, github_url)
  end
  
  local result = vim.fn.system(curl_cmd)
  
  if vim.v.shell_error == 0 and vim.fn.filereadable(cached_file) == 1 then
    -- Check if we actually got source code (not a 404 page)
    local content = vim.fn.readfile(cached_file, "", 10) -- Read first 10 lines
    local has_code = false
    for _, line in ipairs(content) do
      if line:match("namespace%s+") or line:match("class%s+") or line:match("using%s+") then
        has_code = true
        break
      end
    end
    
    if has_code then
      return cached_file
    else
      -- Delete the invalid file
      vim.fn.delete(cached_file)
    end
  end
  
  return nil
end

-- Open GitHub page in browser as fallback
M.open_github_page = function(metadata_info)
  if not metadata_info then
    return false
  end
  
  local assembly = metadata_info.assembly
  local file_path = metadata_info.file
  
  local github_info = M.config.github_mappings[assembly]
  if not github_info then
    -- Try partial match
    for mapped_assembly, info in pairs(M.config.github_mappings) do
      if assembly:match("^" .. mapped_assembly:gsub("%.", "%%.") .. "%.") then
        github_info = info
        break
      end
    end
  end
  
  if not github_info then
    return false
  end
  
  local actual_filename = file_path:match("([^%.]+%.cs)$") or file_path
  
  local github_url = string.format(
    "https://github.com/%s/blob/%s/%s/%s",
    github_info.repo,
    github_info.branch,
    github_info.path_prefix,
    actual_filename
  )
  
  vim.notify("Opening GitHub page: " .. github_url, vim.log.levels.INFO)
  
  -- Open in default browser
  local open_cmd
  if vim.fn.has("win32") == 1 then
    open_cmd = "start " .. github_url
  elseif vim.fn.has("mac") == 1 then
    open_cmd = "open " .. github_url
  else
    open_cmd = "xdg-open " .. github_url
  end
  
  vim.fn.system(open_cmd)
  return true
end

-- Enhanced jump function that tries to resolve source first
M.enhanced_jump_to_location = function(location, offset_encoding)
  local uri = location.uri or location.targetUri
  local range = location.range or location.targetSelectionRange
  
  -- Try to resolve to actual source if it's a metadata URI
  local metadata_info = M.parse_metadata_uri(uri)
  local actual_source_path = nil
  
  if metadata_info then
    actual_source_path = M.find_source_file(metadata_info)
    
    if actual_source_path then
      vim.notify(string.format("Jumping to source: %s", actual_source_path), vim.log.levels.INFO)
      
      -- Open the actual source file safely
      local ok, err = pcall(function()
        vim.cmd("edit " .. vim.fn.fnameescape(actual_source_path))
      end)
      
      if not ok then
        vim.notify("Failed to open source file: " .. err, vim.log.levels.ERROR)
        return false
      end
      
      -- Wait for buffer to load properly
      vim.schedule(function()
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        
        if #lines == 0 then
          vim.notify("Source file is empty", vim.log.levels.WARN)
          return
        end
        
        -- Try to jump to the same line if possible
        local row = range.start.line + 1
        local col = range.start.character
        
        -- Ensure row and col are within bounds
        if row > #lines then
          row = #lines
        end
        if row < 1 then
          row = 1
        end
        
        local line_length = #lines[row]
        if col > line_length then
          col = line_length
        end
        if col < 0 then
          col = 0
        end
        
        -- Safe cursor positioning
        local cursor_ok, cursor_err = pcall(function()
          vim.api.nvim_win_set_cursor(0, { row, col })
        end)
        
        if not cursor_ok then
          vim.notify("Cursor positioning failed, going to line 1: " .. cursor_err, vim.log.levels.WARN)
          vim.api.nvim_win_set_cursor(0, { 1, 0 })
        end
        
        vim.cmd("normal! zz")
      end)
      
      return true
    else
      -- If source not found locally, try GitHub browser fallback
      local opened_browser = M.open_github_page(metadata_info)
      if opened_browser then
        vim.notify("Source not found locally, opened GitHub page in browser", vim.log.levels.INFO)
        return true
      end
      
      vim.notify(string.format("Source not found for %s, falling back to metadata", metadata_info.assembly), vim.log.levels.WARN)
    end
  end
  
  -- Fall back to original behavior for metadata files or when source not found
  local bufnr = vim.uri_to_bufnr(uri)
  vim.fn.bufload(bufnr)

  if vim.api.nvim_buf_line_count(bufnr) == 0 then
    vim.notify("Cannot jump: buffer is empty (likely a .NET metadata file)", vim.log.levels.WARN)
    return false
  end

  local ok, err = pcall(function()
    vim.api.nvim_set_current_buf(bufnr)
    local row = range.start.line
    local col = range.start.character
    vim.api.nvim_win_set_cursor(0, { row + 1, col })
    vim.cmd("normal! zz")
  end)

  if not ok then
    vim.notify("Jump failed: " .. err, vim.log.levels.WARN)
    return false
  end
  
  return true
end

-- Telescope integration for finding source files (better than fzf integration)
M.telescope_find_source = function(assembly_name)
  assembly_name = assembly_name or vim.fn.input("Assembly name: ")
  
  if assembly_name == "" then
    return
  end
  
  local search_dirs = {}
  
  -- Add RedBear directories if it's a RedBear package
  if assembly_name:match("^RedBear%.") then
    for _, base_dir in ipairs(M.config.redbear_base_dirs) do
      if vim.fn.isdirectory(base_dir) == 1 then
        table.insert(search_dirs, base_dir .. assembly_name)
      end
    end
  end
  
  -- Add custom mappings
  if M.config.source_mappings[assembly_name] then
    table.insert(search_dirs, M.config.source_mappings[assembly_name])
  end
  
  if #search_dirs == 0 then
    vim.notify("No source directories configured for " .. assembly_name, vim.log.levels.WARN)
    return
  end
  
  -- Find all .cs files in the search directories
  local cs_files = {}
  for _, dir in ipairs(search_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      local find_cmd
      if vim.fn.has("win32") == 1 then
        find_cmd = string.format('dir "%s" /s /b /a-d', dir:gsub("/", "\\"))
      else
        find_cmd = string.format('find "%s" -name "*.cs" -type f', dir)
      end
      
      local result = vim.fn.system(find_cmd)
      if vim.v.shell_error == 0 then
        for line in result:gmatch("[^\r\n]+") do
          if line:match("%.cs$") then
            local normalized_path = line:gsub("\\", "/")
            table.insert(cs_files, normalized_path)
          end
        end
      end
    end
  end
  
  if #cs_files == 0 then
    vim.notify("No .cs files found in source directories for " .. assembly_name, vim.log.levels.WARN)
    return
  end
  
  -- Use Telescope to display the files
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  
  pickers.new({}, {
    prompt_title = "C# Source Files: " .. assembly_name,
    finder = finders.new_table({
      results = cs_files,
      entry_maker = function(entry)
        local filename = vim.fn.fnamemodify(entry, ":t")
        local dir = vim.fn.fnamemodify(entry, ":h")
        return {
          value = entry,
          display = filename .. " (" .. dir .. ")",
          ordinal = filename .. " " .. entry,
          filename = entry,
        }
      end,
    }),
    previewer = conf.file_previewer({}),
    sorter = conf.file_sorter({}),
    attach_mappings = function(_, map)
      actions.select_default:replace(function(prompt_bufnr)
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd("edit " .. vim.fn.fnameescape(selection.value))
      end)
      return true
    end,
  }):find()
end

-- Command to manually configure source mappings
M.add_source_mapping = function()
  local assembly = vim.fn.input("Assembly name: ")
  local path = vim.fn.input("Source path: ", "", "dir")
  
  if assembly ~= "" and path ~= "" then
    M.config.source_mappings[assembly] = path
    vim.notify(string.format("Added mapping: %s -> %s", assembly, path), vim.log.levels.INFO)
  end
end

-- Command to show current mappings
M.show_mappings = function()
  print("RedBear base directories:")
  for _, dir in ipairs(M.config.redbear_base_dirs) do
    print("  " .. dir)
  end
  
  print("\nCustom source mappings:")
  for assembly, path in pairs(M.config.source_mappings) do
    print("  " .. assembly .. " -> " .. path)
  end
  
  print("\nGitHub source mappings:")
  for assembly, info in pairs(M.config.github_mappings) do
    print("  " .. assembly .. " -> github.com/" .. info.repo)
  end
  
  print("\nCached paths:")
  for uri, path in pairs(M.config.path_cache) do
    local short_uri = uri:sub(1, 50) .. (uri:len() > 50 and "..." or "")
    print("  " .. short_uri .. " -> " .. path)
  end
  
  print("\nSource cache directory: " .. M.config.source_cache_dir)
end

-- Clear downloaded source cache
M.clear_source_cache = function()
  if vim.fn.isdirectory(M.config.source_cache_dir) == 1 then
    if vim.fn.has("win32") == 1 then
      vim.fn.system('rmdir /s /q "' .. M.config.source_cache_dir:gsub("/", "\\") .. '"')
    else
      vim.fn.system('rm -rf "' .. M.config.source_cache_dir .. '"')
    end
    vim.notify("Cleared source cache", vim.log.levels.INFO)
  else
    vim.notify("Source cache directory doesn't exist", vim.log.levels.INFO)
  end
end

-- Add GitHub mapping
M.add_github_mapping = function()
  local assembly = vim.fn.input("Assembly name: ")
  local repo = vim.fn.input("GitHub repo (owner/repo): ")
  local path_prefix = vim.fn.input("Path prefix in repo: ")
  local branch = vim.fn.input("Branch (default: main): ")
  
  if branch == "" then
    branch = "main"
  end
  
  if assembly ~= "" and repo ~= "" and path_prefix ~= "" then
    M.config.github_mappings[assembly] = {
      repo = repo,
      path_prefix = path_prefix,
      branch = branch
    }
    vim.notify(string.format("Added GitHub mapping: %s -> %s", assembly, repo), vim.log.levels.INFO)
  end
end

-- Force download a specific file
M.force_download_source = function()
  local assembly = vim.fn.input("Assembly name: ")
  local filename = vim.fn.input("File name (e.g., Host.cs): ")
  
  if assembly == "" or filename == "" then
    return
  end
  
  -- Create fake metadata info
  local metadata_info = {
    assembly = assembly,
    file = filename,
    full_uri = "manual_download"
  }
  
  local source_path = M.download_github_source(metadata_info)
  if source_path then
    vim.cmd("edit " .. vim.fn.fnameescape(source_path))
    vim.notify("Downloaded and opened: " .. source_path, vim.log.levels.INFO)
  else
    vim.notify("Failed to download source for " .. assembly .. "/" .. filename, vim.log.levels.ERROR)
  end
end

return M
