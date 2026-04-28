return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      -- Guard: plugin may not be installed on first launch (run :Lazy sync)
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.notify("nvim-treesitter not installed yet — run :Lazy sync", vim.log.levels.WARN)
        return
      end
      configs.setup({
        ensure_installed = {
          "go", "gomod", "gowork", "gotmpl",  -- Go
          "c_sharp",                          -- C#
          "lua", "vim", "vimdoc",             -- Neovim config
          "markdown", "markdown_inline",      -- Docs
          "json", "yaml", "toml",             -- Config files
          "bash",                             -- Scripts
        },
        auto_install = true,
        highlight = {
          enable = true,
          disable = function(lang, buf)
            local max_filesize = 500 * 1024
            local ok2, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok2 and stats and stats.size > max_filesize then return true end
          end,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },
}
