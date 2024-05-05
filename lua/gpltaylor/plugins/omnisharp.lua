return {
  "OmniSharp/omnisharp-vim",
  config= function()

    vim.keymap.set("n", "<leader>ofu", ":OmniSharpFindUsages<cr>", { desc = "Omnishap  - Find References"})
    vim.keymap.set("n", "<leader>ogd", ":OmniSharpGotoDefinition<cr>", { desc = "Omnishap  - Find definition"})

    --OmniSharpGotoDefinition 
  
--    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })

end

}
