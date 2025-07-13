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

  end,
}
