# gizvim

My Neovim setup (lazy.nvim-based).

## Requirements (new machine)

See the full list in: **[`docs/requirements.md`](./docs/requirements.md)**

Quick summary:
- Neovim (recent stable)
- Git
- **Node.js + npm** (required for `markdown-preview.nvim`)
- **tree-sitter CLI** (`npm install -g tree-sitter-cli`) for `nvim-treesitter`
- A C compiler toolchain (Windows: MSVC Build Tools or GCC/MSYS2) for Treesitter parsers

## Install

1. Clone this repo into your Neovim config folder.
2. Start Neovim:
   ```powershell
   nvim
   ```
3. If needed:
   - `:Lazy sync`
   - `:TSUpdate`
   - `:Lazy build markdown-preview.nvim`

## Markdown Preview

In a Markdown buffer:
- Toggle preview: `<leader>P`
- Or run: `:MarkdownPreviewToggle`

## References

Lazy Neovim setup inspiration:
- https://www.youtube.com/watch?v=6pAG3BHurdM&ab_channel=JoseanMartinez
- https://www.youtube.com/watch?v=w7i4amO_zaE&ab_channel=ThePrimeagen

