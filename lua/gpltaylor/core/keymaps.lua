vim.g.mapleader = " "
-- Set scrolloff to 5 using Lua in Neovim
vim.o.scrolloff = 5

local keymap = vim.keymap

--keymap.set("i", "<leader>cc", "<ESC>:w<CR>", { desc = "Exit insert mode" })


-- Move Lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move block up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move block down" })

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

-- Telescope keymaps
-- builtin = require('telescope.builtin')
-- vim.keymap.set("n", "<leader>fR", function() builtin.lsp_references() end, {})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "cs",
  callback = function()
    local opts = { noremap = true, silent = true, buffer = 0 }

    -- Telescope-powered reference search


    local jump = require("utils.lsp_jump_patch")

    vim.keymap.set("n", "<leader>gR", function()
      local params = vim.lsp.util.make_position_params()

      vim.lsp.buf_request(0, "textDocument/references", params, jump.make_handler("LSP References"))
    end, vim.tbl_extend("force", opts, { desc = "Safe LSP: Find References" }))

    vim.keymap.set("n", "<leader>gd", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/definition", params, jump.make_handler("LSP Definitions"))
    end, vim.tbl_extend("force", opts, { desc = "Safe LSP: Go to Definition" }))

    vim.keymap.set("n", "<leader>gi", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/implementation", params, jump.make_handler("LSP Implementations"))
    end, vim.tbl_extend("force", opts, { desc = "Safe LSP: Go to Implementation" }))

    vim.keymap.set("n", "<leader>gt", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/typeDefinition", params, jump.make_handler("LSP Type Definitions"))
    end, vim.tbl_extend("force", opts, { desc = "Safe LSP: Go to Type Definition" }))

    -- Debugging keymaps
    vim.keymap.set("n", "<F2>", ":lua require'dap'.toggle_breakpoint()<CR>", opts) -- Toggle Breakpoint
    vim.keymap.set("n", "<F1>", ":lua require'dapui'.toggle()<CR>", opts)          -- Toggle I
    vim.keymap.set("n", "<F6>", ":lua require'dap'.continue()<CR>", opts)          -- Start/Continue
    vim.keymap.set("n", "<F7>", ":lua require'dap'.step_over()<CR>", opts)         -- Step Over
    vim.keymap.set("n", "<F8>", ":lua require'dap'.step_into()<CR>", opts)         -- Step Into
    vim.keymap.set("n", "<F9>", ":lua require'dap'.terminate()<CR>", opts)         -- Stop Debugging
  end,
})

-- Go specific keymaps (mirroring C# setup)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function()
    local opts = { noremap = true, silent = true, buffer = 0 }

    -- LSP navigation (same as C#)
    local jump = require("utils.lsp_jump_patch")

    vim.keymap.set("n", "<leader>gR", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/references", params, jump.make_handler("LSP References"))
    end, vim.tbl_extend("force", opts, { desc = "Safe LSP: Find References" }))

    vim.keymap.set("n", "<leader>gd", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/definition", params, jump.make_handler("LSP Definitions"))
    end, vim.tbl_extend("force", opts, { desc = "Safe LSP: Go to Definition" }))

    vim.keymap.set("n", "<leader>gi", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/implementation", params, jump.make_handler("LSP Implementations"))
    end, vim.tbl_extend("force", opts, { desc = "Safe LSP: Go to Implementation" }))

    vim.keymap.set("n", "<leader>gt", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/typeDefinition", params, jump.make_handler("LSP Type Definitions"))
    end, vim.tbl_extend("force", opts, { desc = "Safe LSP: Go to Type Definition" }))

    -- Debugging keymaps (same function keys as C#)
    vim.keymap.set("n", "<F2>", ":lua require'dap'.toggle_breakpoint()<CR>", opts) -- Toggle Breakpoint
    vim.keymap.set("n", "<F1>", ":lua require'dapui'.toggle()<CR>", opts)          -- Toggle DAP UI
    vim.keymap.set("n", "<F6>", ":lua require'dap'.continue()<CR>", opts)          -- Start/Continue
    vim.keymap.set("n", "<F7>", ":lua require'dap'.step_over()<CR>", opts)         -- Step Over
    vim.keymap.set("n", "<F8>", ":lua require'dap'.step_into()<CR>", opts)         -- Step Into
    vim.keymap.set("n", "<F9>", ":lua require'dap'.terminate()<CR>", opts)         -- Stop Debugging

    -- Go-specific keymaps
    vim.keymap.set("n", "<leader>gsj", "<cmd>GoAddTag json<cr>", vim.tbl_extend("force", opts, { desc = "Add JSON tags" }))
    vim.keymap.set("n", "<leader>gsy", "<cmd>GoAddTag yaml<cr>", vim.tbl_extend("force", opts, { desc = "Add YAML tags" }))
    vim.keymap.set("n", "<leader>gsr", "<cmd>GoRmTag<cr>", vim.tbl_extend("force", opts, { desc = "Remove tags" }))
    vim.keymap.set("n", "<leader>gsf", "<cmd>GoFillStruct<cr>", vim.tbl_extend("force", opts, { desc = "Fill struct" }))
    vim.keymap.set("n", "<leader>gsi", "<cmd>GoIfErr<cr>", vim.tbl_extend("force", opts, { desc = "Add if err" }))
    vim.keymap.set("n", "<leader>gie", "<cmd>GoImpl<cr>", vim.tbl_extend("force", opts, { desc = "Implement interface" }))
    
    -- Test keymaps
    vim.keymap.set("n", "<leader>gtn", "<cmd>GoTest -n<cr>", vim.tbl_extend("force", opts, { desc = "Run nearest test" }))
    vim.keymap.set("n", "<leader>gtf", "<cmd>GoTest -f<cr>", vim.tbl_extend("force", opts, { desc = "Run file tests" }))
    vim.keymap.set("n", "<leader>gta", function()
      require("utils.go_utils").go_test_package()
    end, vim.tbl_extend("force", opts, { desc = "Run package tests" }))
    vim.keymap.set("n", "<leader>gtv", "<cmd>GoTest -v<cr>", vim.tbl_extend("force", opts, { desc = "Run tests verbose" }))
    vim.keymap.set("n", "<leader>gtc", "<cmd>GoCoverage<cr>", vim.tbl_extend("force", opts, { desc = "Show coverage" }))
    
    -- Build and run (updated to handle src directory)
    vim.keymap.set("n", "<leader>gbr", function()
      require("utils.go_utils").go_build_terminal()
    end, vim.tbl_extend("force", opts, { desc = "Build (src-aware)" }))
    vim.keymap.set("n", "<leader>gor", function()
      require("utils.go_utils").go_run_terminal()
    end, vim.tbl_extend("force", opts, { desc = "Run (src-aware)" }))
    vim.keymap.set("n", "<leader>goc", function()
      require("utils.go_utils").go_run_compile()
    end, vim.tbl_extend("force", opts, { desc = "Run with compile" }))
    
    -- Debugging specific for Go (updated for src directory)
    vim.keymap.set("n", "<leader>gdt", "<cmd>lua require('dap-go').debug_test()<cr>", vim.tbl_extend("force", opts, { desc = "Debug test" }))
    vim.keymap.set("n", "<leader>gdl", "<cmd>lua require('dap-go').debug_last()<cr>", vim.tbl_extend("force", opts, { desc = "Debug last" }))
    vim.keymap.set("n", "<leader>gdm", function()
      require("utils.go_utils").debug_main()
    end, vim.tbl_extend("force", opts, { desc = "Debug main (src-aware)" }))
  end,
})
