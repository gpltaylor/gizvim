print("Welcome to GplTaylor/Lua")
-- Update location for python3 exe as we are using pyenv to manage python versions but we want to use the python3 version in vim
vim.g.python3_host_prog = 'C:/Users/GarryTaylor/.pyenv/pyenv-win/versions/3.11.9-win32/python.exe'

require("gpltaylor.core")
require("gpltaylor.lazy")

local autocmd = vim.api.nvim_create_autocmd

local yankgroup = vim.api.nvim_create_augroup("HighlightYank", { clear = true })

autocmd('TextYankPost', {
    group = yankgroup,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

