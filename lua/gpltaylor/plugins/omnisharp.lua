return {
  "OmniSharp/omnisharp-vim",
  config= function()

    vim.keymap.set("n", "<leader>gu", ":OmniSharpFindUsages<cr>", { desc = "Omnishap  - Find References"})
    -- I want to do to the implementation of a method when jumping - I know this is backwards but so am I
    vim.keymap.set("n", "<leader>gd", ":OmniSharpFindImplementation<cr>", { desc = "Omnishap  - Find Implementation"})
    vim.keymap.set("n", "<leader>gs", ":OmniSharpFindSymbol<cr>", { desc = "Omnishap  - Find Symbol"})

    vim.keymap.set("n", "<leader>od", ":OmniSharpDocumentation<cr>", { desc = "Omnishap  - Documentation"})
    vim.keymap.set("n", "<leader>ofi", ":OmniSharpFindImplementation<cr>", { desc = "Omnishap  - Find Implementation"})
    vim.keymap.set("n", "<leader>ogd", ":OmniSharpGotoDefinition<cr>", { desc = "Omnishap  - Find definition"})
    vim.keymap.set("n", "<leader>ofs", ":OmniSharpFindSymbol<cr>", { desc = "Omnishap  - Find Symbol"})
    vim.keymap.set("n", "<leader>ofu", ":OmniSharpFindUsages<cr>", { desc = "Omnishap  - Find References"})

    --OmniSharpGotoDefinition 
  
--    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })

end

}
