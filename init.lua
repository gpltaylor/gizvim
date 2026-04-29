print("Welcome to GplTaylor/Lua")
-- Update location for python3 exe as we are using pyenv to manage python versions but we want to use the python3 version in vim
vim.g.python3_host_prog = 'C:/Users/GarryTaylor/.pyenv/pyenv-win/versions/3.12.0/python.exe'

-- Patch vim.treesitter.start before any plugin or ftplugin loads.
-- Neovim's bundled Lua ftplugin calls vim.treesitter.start(), but the bundled
-- tree-sitter-lua parser and highlight queries are mismatched (missing "operator"
-- field), causing E5113. Wrapping with pcall silences the error globally until
-- Neovim is updated or the Lua parser is reinstalled.
local _ts_start = vim.treesitter.start
vim.treesitter.start = function(bufnr, lang)
  pcall(_ts_start, bufnr, lang)
end

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

