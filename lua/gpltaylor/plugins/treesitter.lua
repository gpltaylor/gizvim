return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = false, -- Disable automatic building to avoid compiler issues
        lazy = false,
        config = function()
            -- The bundled Lua treesitter parser in this Neovim version does not support
            -- the "operator" field referenced in the runtime highlight queries, causing
            -- E5113 errors whenever a Lua buffer's ftplugin fires.
            --
            -- Fix: after the FileType autocmd chain runs (including ftplugin/lua.lua which
            -- calls vim.treesitter.start), use vim.schedule to stop treesitter on that
            -- buffer. vim.cmd('syntax on') keeps regex-based highlighting working.
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'lua',
                callback = function(ev)
                    vim.schedule(function()
                        pcall(vim.treesitter.stop, ev.buf)
                        vim.bo[ev.buf].syntax = 'on'
                    end)
                end,
            })

            -- Enable basic syntax highlighting for common file types
            vim.api.nvim_create_autocmd('BufRead', {
                pattern = { '*.lua', '*.vim', '*.md', '*.js', '*.ts', '*.go', '*.rs', '*.c' },
                callback = function()
                    vim.cmd('syntax on')
                end,
            })
        end,
    },
}
