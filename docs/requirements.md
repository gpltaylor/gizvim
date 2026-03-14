# Requirements / Dependencies

This Neovim config uses `lazy.nvim` to install plugins, but **some plugins need external system dependencies**.

## Core requirements

### Neovim
- Neovim (recent stable recommended)

### Git
- Git (used by lazy.nvim to clone plugins)

### Node.js + npm (required for Markdown Preview)
Used by: `iamcco/markdown-preview.nvim`

- Node.js (LTS recommended)
- npm (ships with Node)

Verify:
```powershell
node --version
npm --version
```

If Markdown Preview fails with missing Node modules (e.g. `Cannot find module 'tslib'`), rebuild the plugin:
```vim
:Lazy build markdown-preview.nvim
```

### tree-sitter CLI (required for Treesitter parser installs)
Used by: `nvim-treesitter/nvim-treesitter`

Install:
```powershell
npm install -g tree-sitter-cli
```

Verify:
```powershell
tree-sitter --version
```

**Windows PATH note**: if `tree-sitter` isn’t found after install, add this directory to your PATH and restart your terminal:
- `%APPDATA%\npm` (typically `C:\Users\<you>\AppData\Roaming\npm`)

## Build tools (Treesitter parser compilation)
Treesitter parsers are compiled locally and require a C toolchain.

### Windows
Install **one** of:
- MSVC Build Tools (Visual Studio Build Tools)
- GCC toolchain (e.g. MSYS2 / MinGW-w64)
- Zig (can act as a C compiler for some setups)

This config currently sets `CC=gcc` (see `lua/gpltaylor/lazy.lua`). If you don’t have `gcc` in PATH, either install GCC or change that setting to a compiler you do have.

## Optional dependencies

### Python + pynvim (for Python-powered plugins)
Some plugins (e.g. `vimspector`) require Neovim Python support.

Verify Python:
```powershell
python --version
python -c "import pynvim; print('pynvim ok')"
```

## Troubleshooting

- Treesitter health:
  ```vim
  :checkhealth nvim-treesitter
  ```
- Treesitter parser install/update:
  ```vim
  :TSUpdate
  :TSInstall markdown
  ```
- Markdown preview toggle (Markdown buffer):
  - `<leader>P`
  - `:MarkdownPreviewToggle`
