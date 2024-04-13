return {
  dir = "/Users/garrytaylor/AppData/Local/nvim/lua/gpltaylor/showcase", -- Your path
  name = "showcase",
  config = function ()
    local showcase = require('showcase')
    showcase.setup()

    -- vim.keymap.set("n", "<leader>px", function() showcase:ExecuteLine() end, { desc = "Showcase: Excute current line"})
    vim.keymap.set("n", "<leader>px", function() showcase:TelescopeExecuteList() end, { desc = "Showcase: Execute lines using Teliscope"})


  end
}
