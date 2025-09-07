local M = {}

-- Safe single-location jump, with C# source resolution
M.safe_jump_to_location = function(location, offset_encoding)
  local uri = location.uri or location.targetUri
  local range = location.range or location.targetSelectionRange

  -- Try enhanced C# source resolution for metadata URIs
  if uri and uri:match("^csharp:/metadata/") then
    local csharp_resolver = require("utils.csharp_source_resolver")
    local success = csharp_resolver.enhanced_jump_to_location(location, offset_encoding)
    if success then
      -- Source resolution succeeded, don't execute fallback logic
      return
    end
    -- If resolver failed, continue with normal behavior below
  end

  local bufnr = vim.uri_to_bufnr(uri)
  vim.fn.bufload(bufnr)

  if vim.api.nvim_buf_line_count(bufnr) == 0 then
    vim.notify("Cannot jump: buffer is empty (likely a .NET metadata file)", vim.log.levels.WARN)
    return
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
  end
end

-- Generic handler for definition, implementation, etc.
M.make_handler = function(prompt_title)
  return function(err, result, ctx)
    if err then
      vim.notify("LSP error: " .. err.message, vim.log.levels.ERROR)
      return
    end

    if not result or vim.tbl_isempty(result) then
      vim.notify("No results found.", vim.log.levels.INFO)
      return
    end

    local locations = vim.islist(result) and result or { result }

    if #locations == 1 then
      M.safe_jump_to_location(locations[1], vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)
    else
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values

      pickers.new({}, {
        prompt_title = prompt_title or "LSP Results",
        finder = finders.new_table({
          results = locations,
          entry_maker = function(entry)
            local filename = vim.uri_to_fname(entry.uri or entry.targetUri)
            local range = entry.range or entry.targetSelectionRange
            local lnum = range.start.line + 1
            local col = range.start.character + 1
            local text = string.format("%s:%d:%d", filename, lnum, col)
            return {
              value = entry,
              display = text,
              ordinal = text,
              filename = filename,
              lnum = lnum,
              col = col,
            }
          end,
        }),
        previewer = conf.qflist_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(_, map)
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          actions.select_default:replace(function(prompt_bufnr)
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            M.safe_jump_to_location(selection.value, "utf-16")
          end)
          return true
        end,
      }):find()
    end
  end
end

return M

