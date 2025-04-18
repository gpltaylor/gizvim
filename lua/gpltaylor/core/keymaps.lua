vim.g.mapleader = " "
-- Set scrolloff to 5 using Lua in Neovim
vim.o.scrolloff = 5

local keymap = vim.keymap

--keymap.set("i", "<leader>cc", "<ESC>:w<CR>", { desc = "Exit insert mode" })


-- Move Lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move block up"})
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move block down"})

-- Copy and paste
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Format the buffer
vim.keymap.set("n", "<leader>fb", vim.lsp.buf.format, { desc = "Format the buffer" })

-- Search
vim.keymap.set("n", "<leader>ss", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

--8 File8 Endcoding8 as8 UTF8
vim.keymap.set("n", "<leader>utf8", [[:set fileencoding=utf-8<CR>:set encoding=utf-8<CR>]])


-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- highlight the word under the cursor
vim.keymap.set("n", "<leader>hw", ":lua vim.lsp.buf.document_highlight()<CR>")
vim.keymap.set("n", "<leader>hc", ":lua vim.lsp.buf.clear_references()<CR>")

vim.keymap.set("n", "<leader>gR", ": lua require('telescope.builtin').lsp_references()<CR>", { desc = "Find references" })
vim.keymap.set("n", "<leader>gd", ":lua require('telescope.builtin').lsp_definitions()<CR>", { desc = "Find definitions" })
vim.keymap.set("n", "<leader>gi", ":lua require('telescope.builtin').lsp_implementations()<CR>", { desc = "Find implementations" })


