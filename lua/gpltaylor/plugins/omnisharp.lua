return {
  "OmniSharp/omnisharp-vim",
  config= function()

    vim.keymap.set("n", "<leader>dfr", ":OmniSharpFindUsages<cr>", { desc = "Omnishap  - Find References"})
  
--    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })

end

}
