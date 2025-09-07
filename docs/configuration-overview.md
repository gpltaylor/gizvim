# Current Neovim Configuration Overview

This document provides an overview of your current Neovim configuration, focusing on the development environments for C# and Go.

## Architecture

Your configuration follows a modular LazyVim-based structure:

```
lua/gpltaylor/
├── core/
│   ├── init.lua          # Core initialization
│   ├── keymaps.lua       # Global and language-specific keymaps
│   └── options.lua       # Neovim options
├── plugins/
│   ├── csharp.lua        # C# development setup
│   ├── golang.lua        # Go development setup (newly added)
│   ├── lsp/              # LSP configuration
│   │   ├── init.lua
│   │   ├── lspconfig.lua
│   │   └── mason.lua
│   └── [other plugins]
└── utils/
    └── lsp_jump_patch.lua # Safe LSP navigation utility
```

## Language Support Matrix

| Feature | C# | Go | Notes |
|---------|----|----|-------|
| **LSP Server** | OmniSharp | gopls | Both provide full language support |
| **Debugger** | netcoredbg | delve | DAP-compatible debuggers |
| **Formatter** | csharpier | gofumpt + goimports | Auto-format on save |
| **Linter** | Built-in analyzers | golangci-lint | Comprehensive linting |
| **Package Manager** | NuGet (external) | Go modules | Native package management |
| **Test Runner** | Built-in | go test + go.nvim | Integrated test execution |
| **Build System** | MSBuild/dotnet | go build | Native build tools |

## Key Design Patterns

### 1. Consistent Keymap Strategy

Both languages use identical navigation and debugging keymaps:
- **Navigation**: `<leader>gd`, `<leader>gR`, `<leader>gi`, `<leader>gt`
- **Debugging**: `<F1>` through `<F9>`
- **Formatting**: `<leader>fb`

This ensures muscle memory transfers between languages.

### 2. Safe LSP Navigation

The `utils/lsp_jump_patch.lua` module provides safe LSP navigation that:
- Handles empty buffers (common with .NET metadata files)
- Shows Telescope picker for multiple results
- Graceful error handling
- Consistent behavior across languages

### 3. Mason Integration

Both languages use Mason for tool installation:
- Automatic installation of required tools
- Version management
- Cross-platform compatibility

### 4. DAP Configuration

Debug configurations are centralized in `dap-config.lua`:
- Language-specific adapters
- Multiple debug scenarios per language
- Consistent debugging experience

## LSP Configuration Details

### C# (OmniSharp)
```lua
omnisharp = {
  cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
  handlers = {
    -- Enhanced handlers for better navigation
    ["textDocument/definition"] = omnisharp_extended.handler,
    ["textDocument/typeDefinition"] = omnisharp_extended.handler,
    ["textDocument/implementation"] = omnisharp_extended.handler,
    ["textDocument/references"] = omnisharp_extended.handler,
  },
  enable_roslyn_analyzers = true,
  organize_imports_on_format = true,
  enable_debugging = true,
  enable_decompilation_support = true,
}
```

**Enhanced Features**:
- **NuGet Source Resolution**: Automatically jumps to actual source code instead of metadata files
- **RedBear Package Support**: Intelligent mapping to local RedBear source repositories
- **Telescope Integration**: Browse and search source files across assemblies

### Go (gopls)
```lua
gopls = {
  settings = {
    gopls = {
      analyses = { unusedparams = true, unreachable = true, nilness = true },
      experimentalPostfixCompletions = true,
      gofumpt = true,
      staticcheck = true,
      completeUnimported = true,
      buildFlags = { "-tags", "integration" },
      semanticTokens = true,
      codelenses = { test = true, tidy = true, upgrade_dependency = true },
      hints = { assignVariableTypes = true, parameterNames = true },
    },
  },
}
```

## Debug Configurations

### C# Debug Scenarios
1. **Launch Console** - Debug .NET applications
2. **Attach to Process** - Attach to running .NET process

### Go Debug Scenarios
1. **Debug** - Debug current file
2. **Debug Package** - Debug entire workspace
3. **Debug Test** - Debug test files
4. **Debug Test (go.mod)** - Debug directory tests
5. **Attach to Process** - Attach to running Go process
6. **Debug with Arguments** - Debug with custom args

## Plugin Dependencies

### Core Dependencies
- `nvim-lspconfig` - LSP client configuration
- `mason.nvim` - Package manager for LSP servers, formatters, linters
- `nvim-dap` - Debug Adapter Protocol client
- `telescope.nvim` - Fuzzy finder integration
- `nvim-treesitter` - Syntax highlighting and text objects

### Language-Specific Dependencies

#### C#
- `omnisharp-extended-lsp.nvim` - Enhanced OmniSharp support
- `mason-nvim-dap.nvim` - DAP integration with Mason

#### Go
- `ray-x/go.nvim` - Enhanced Go tooling
- `nvim-dap-go` - Go-specific DAP configuration
- `guihua.lua` - UI components for go.nvim

## File Organization Strategy

### Plugin Files
Each language has its own plugin file that configures:
- Treesitter parsers
- Mason tool installation
- LSP server configuration
- DAP setup
- Formatting/linting rules
- Language-specific keymaps

### Keymap Organization
- Global keymaps in `core/keymaps.lua`
- Language-specific keymaps via `FileType` autocmds
- Consistent naming conventions across languages

### Utility Functions
- Shared utilities in `utils/` directory
- Language-agnostic helper functions
- Reusable patterns for LSP navigation
- **C# source resolution** for NuGet packages
- **Go project structure** detection

## Configuration Philosophy

### 1. Consistency First
- Same keymaps across languages where possible
- Consistent user experience
- Predictable behavior

### 2. Language-Specific Enhancement
- Each language gets specialized tooling
- Language idioms are respected
- Best practices for each ecosystem

### 3. Safety and Reliability
- Error handling for edge cases
- Graceful degradation
- User feedback for failures

### 4. Performance
- Lazy loading where appropriate
- Minimal startup impact
- Efficient tool usage

## Best Practices Implemented

1. **Auto-installation** - Required tools are automatically installed
2. **Auto-formatting** - Code is formatted on save
3. **Safe navigation** - LSP jumps handle edge cases gracefully
4. **Integrated debugging** - Debugging works seamlessly with the editor
5. **Test integration** - Tests can be run and debugged from the editor
6. **Error reporting** - Clear feedback when things go wrong

This configuration provides a professional, consistent development environment that scales well as you add more languages or features.
