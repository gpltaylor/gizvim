return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = false, -- Disable automatic building to avoid compiler issues
        lazy = false,
        config = function()
            -- Basic treesitter setup without automatic parser installation
            vim.notify("Treesitter loaded. Basic syntax highlighting available via Neovim built-ins.", vim.log.levels.INFO)
            
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
