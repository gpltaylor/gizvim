vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("i", "<leader>cc", "<ESC>:w<CR>", { desc = "Exit insert mode" })


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


