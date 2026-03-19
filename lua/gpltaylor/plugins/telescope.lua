return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        -- Use a Windows-compatible buffer previewer
        buffer_previewer_maker = function(filepath, bufnr, opts)
          opts = opts or {}
          
          filepath = vim.fn.expand(filepath)
          
          -- Read file content directly with Lua instead of using external commands
          local lines = {}
          local file = io.open(filepath, "r")
          if file then
            for line in file:lines() do
              table.insert(lines, line)
            end
            file:close()
            
            -- Set buffer content
            vim.schedule(function()
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
              
              -- Set filetype for basic syntax highlighting
              local ft = vim.filetype.match({ filename = filepath })
              if ft then
                vim.api.nvim_buf_set_option(bufnr, 'filetype', ft)
              end
            end)
          else
            -- Fallback if file can't be read
            vim.schedule(function()
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"[Error: Cannot read file]"})
            end)
          end
        end,
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next,     -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
    })

    -- telescope.load_extension("fzf")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
    keymap.set("n", "<leader>fn", function()
      require 'telescope.builtin'.find_files({
        search_dirs = { vim.fn.stdpath('config') },
        hidden = true
      })
    end, { desc = "Fuzzy find files in Neovim config", silent = true })

  end,
}
