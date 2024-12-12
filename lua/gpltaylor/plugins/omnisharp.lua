return {
  "OmniSharp/omnisharp-vim",
  config = function()
    -- Create a group for omnisharp keymaps only within .cs files
    vim.api.nvim_create_augroup('OmniSharpKeymaps', { clear = true })

    vim.api.nvim_create_autocmd('FileType', {
      group = 'OmniSharpKeymaps',
      pattern = 'cs',
      callback = function()
        local opts = { noremap = true, silent = true, buffer = 0 }
        vim.keymap.set('n', '<leader>gu', ':OmniSharpFindUsages<cr>', { desc = "Omnisharp - Find References", unpack(opts) })
        vim.keymap.set('n', '<leader>gd', ':OmniSharpFindImplementation<cr>', { desc = "Omnisharp - Find Implementation", unpack(opts) })
        vim.keymap.set('n', '<leader>gs', ':OmniSharpFindSymbol<cr>', { desc = "Omnisharp - Find Symbol", unpack(opts) })

        vim.keymap.set('n', '<leader>od', ':OmniSharpDocumentation<cr>', { desc = "Omnisharp - Documentation", unpack(opts) })
        vim.keymap.set('n', '<leader>ofi', ':OmniSharpFindImplementation<cr>', { desc = "Omnisharp - Find Implementation", unpack(opts) })
        vim.keymap.set('n', '<leader>ogd', ':OmniSharpGotoDefinition<cr>', { desc = "Omnisharp - Find definition", unpack(opts) })
        vim.keymap.set('n', '<leader>ofs', ':OmniSharpFindSymbol<cr>', { desc = "Omnisharp - Find Symbol", unpack(opts) })
        vim.keymap.set('n', '<leader>ofu', ':OmniSharpFindUsages<cr>', { desc = "Omnisharp - Find References", unpack(opts) })
      end
    })
  end
}

