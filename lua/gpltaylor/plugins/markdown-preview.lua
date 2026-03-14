return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function()
    -- Ensure we're in the right directory and install dependencies
    local install_path = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim"
    vim.fn.system("cd " .. install_path .. "/app && npm install")
  end,
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  config = function()
    -- Configuration for markdown-preview.nvim
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_command_for_global = 0
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_open_ip = ''
    vim.g.mkdp_browser = ''
    vim.g.mkdp_echo_preview_url = 0
    vim.g.mkdp_browserfunc = ''
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = 'middle',
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {}
    }
    vim.g.mkdp_markdown_css = ''
    vim.g.mkdp_highlight_css = ''
    vim.g.mkdp_port = ''
    vim.g.mkdp_page_title = '「${name}」'
    vim.g.mkdp_theme = 'dark'

    -- Keymap for markdown files only
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        local opts = { noremap = true, silent = true, buffer = 0 }
        vim.keymap.set("n", "<leader>P", "<cmd>MarkdownPreviewToggle<cr>", 
          vim.tbl_extend("force", opts, { desc = "Toggle markdown preview" }))
      end,
    })
  end,
}