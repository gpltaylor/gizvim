return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "Hoffs/omnisharp-extended-lsp.nvim"
  },
  config = function()
    require("mason").setup()
    require("mason-nvim-dap").setup({ ensure_installed = { "netcoredbg" } })
    -- require 'lspconfig'.gopls.setup()
    require "lsp_signature".setup({
      bind = true,
      handler_opts = {
        border = "rounded"
      }
    })
  end,
}
