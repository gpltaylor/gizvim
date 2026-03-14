return {
  {
    'puremourning/vimspector',
    cond = function()
      -- Check if Python3 support is available
      return vim.fn.has('python3') == 1
    end,
    config = function()
      -- Only configure if Python3 is available
      if vim.fn.has('python3') == 1 then
        vim.g.vimspector_enable_mappings = 'HUMAN'
      end
    end,
    cmd = { "VimspectorInstall", "VimspectorUpdate" },
    ft = { "c", "cpp", "python", "rust" },
  }
}
