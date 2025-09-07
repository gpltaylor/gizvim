# Neovim Go Development Setup

This document describes the Go development configuration in your Neovim setup, mirroring the existing C# development experience.

## Overview

The Go setup provides a complete development environment with:
- Language Server Protocol (LSP) support via `gopls`
- Debug Adapter Protocol (DAP) support via `delve`
- Enhanced Go tooling via `ray-x/go.nvim`
- Consistent keymaps matching the C# setup
- Formatting, linting, and testing capabilities

## Key Components

### 1. Language Server - gopls

**File**: `lua/gpltaylor/plugins/golang.lua`

The Go language server (`gopls`) is configured with:
- Advanced analysis features (unused params, unreachable code, nilness)
- Fuzzy matching for completions
- Static analysis integration
- Integration tags support for testing
- Semantic tokens and code lenses
- Inlay hints for better code understanding

**Key Features**:
- Auto-completion with unimported packages
- Real-time diagnostics
- Code navigation (definitions, references, implementations)
- Refactoring support

### 2. Debugging - Delve

**Files**: 
- `lua/gpltaylor/plugins/golang.lua`
- `lua/dap-config.lua`
- `lua/gpltaylor/plugins/nvim-dap-go.lua`

Debugging is handled by the Delve debugger with multiple configurations:
- Debug current file
- Debug package
- Debug tests
- Attach to running process
- Debug with custom arguments

**Debug Configurations Available**:
1. **Debug**: Debug the current file or auto-detect main.go
2. **Debug Package (src-aware)**: Debug the package, checking src/ directory
3. **Debug test**: Debug test files
4. **Debug test (go.mod)**: Debug tests in the current directory
5. **Attach to process**: Attach to a running Go process
6. **Debug with arguments**: Debug with custom command-line arguments (src-aware)

## Project Structure Support

The configuration intelligently handles different Go project structures:

### Supported Layouts
```
project-root/
├── go.mod
├── main.go              # Root level main
└── ...

project-root/
├── go.mod
├── src/
│   ├── main.go          # Source in src/ folder
│   └── ...
└── ...

project-root/
├── go.mod
├── cmd/
│   ├── main.go          # Command in cmd/ folder
│   └── ...
└── ...
```

### Smart Detection Features
- **Auto-detection**: Automatically finds main.go in common locations (root, src/, cmd/, app/)
- **Go module root**: Uses go.mod to determine project root
- **Build/Run directory**: Intelligently switches to the correct directory for build/run operations
- **Debugging**: Debug configurations automatically locate the correct main.go file

### 3. Enhanced Go Tooling - ray-x/go.nvim

**File**: `lua/gpltaylor/plugins/golang.lua`

Provides additional Go-specific functionality:
- Struct tag management (JSON, YAML)
- Interface implementation generation
- Test generation and running
- Code coverage visualization
- Import organization
- Error handling helpers

## Keymaps

### Navigation (Same as C#)

All navigation keymaps mirror the C# setup and use the same LSP jump patch for safety:

| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>gd` | Go to Definition | Jump to symbol definition |
| `<leader>gR` | Find References | Find all references to symbol |
| `<leader>gi` | Go to Implementation | Jump to implementation |
| `<leader>gt` | Type Definition | Jump to type definition |

### Debugging (Same Function Keys as C#)

| Keymap | Action | Description |
|--------|--------|-------------|
| `<F1>` | Toggle DAP UI | Show/hide debug interface |
| `<F2>` | Toggle Breakpoint | Add/remove breakpoint |
| `<F6>` | Continue | Start/continue debugging |
| `<F7>` | Step Over | Execute next line |
| `<F8>` | Step Into | Step into function |
| `<F9>` | Terminate | Stop debugging session |

### Go-Specific Features

#### Struct Management
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>gsj` | Add JSON tags | Add JSON struct tags |
| `<leader>gsy` | Add YAML tags | Add YAML struct tags |
| `<leader>gsr` | Remove tags | Remove struct tags |
| `<leader>gsf` | Fill struct | Fill struct fields |
| `<leader>gsi` | Add if err | Add error handling |
| `<leader>gie` | Implement interface | Generate interface implementation |

#### Testing
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>gtn` | Run nearest test | Run test under cursor |
| `<leader>gtf` | Run file tests | Run all tests in file |
| `<leader>gta` | Run package tests | Run all tests in package |
| `<leader>gtv` | Run tests verbose | Run tests with verbose output |
| `<leader>gtc` | Show coverage | Display test coverage |

#### Build and Run
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>gbr` | Build | Build project (src-aware) |
| `<leader>gor` | Run | Run project (src-aware) |
| `<leader>goc` | Run with compile | Run with fresh compilation |

#### Debugging Specific
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>gdt` | Debug test | Debug nearest test |
| `<leader>gdl` | Debug last | Debug last test/program |
| `<leader>gdm` | Debug main | Debug main.go (src-aware) |

## Installation and Setup

### Prerequisites

Ensure you have the following installed:
- Go 1.19+ 
- Delve debugger: `go install github.com/go-delve/delve/cmd/dlv@latest`

### Automatic Installation

The configuration automatically installs required tools via Mason:
- `gopls` - Go language server
- `delve` - Go debugger
- `gofumpt` - Go formatter (stricter than gofmt)
- `goimports` - Import organizer
- `golangci-lint` - Comprehensive linter
- `gomodifytags` - Struct tag modifier
- `gotests` - Test generator
- `impl` - Interface implementation generator

## Formatting and Linting

### Auto-formatting
- **On Save**: Automatically runs `goimports` to organize imports and format code
- **Format Command**: `<leader>fb` formats the current buffer
- **Formatter**: Uses `gofumpt` for stricter formatting than standard `gofmt`

### Linting
- **Real-time**: `golangci-lint` provides comprehensive linting
- **Integration**: Runs through `null-ls` for seamless editor integration

## Build Tags Support

The configuration includes support for build tags:
- Default build tag: `integration`
- Applied to debugging, testing, and language server
- Enables conditional compilation for different environments

## Comparison with C# Setup

### Similarities
| Feature | C# | Go |
|---------|----|----|
| LSP Navigation | ✓ | ✓ |
| Same Debug Keys | ✓ | ✓ |
| DAP Integration | ✓ | ✓ |
| Auto-formatting | ✓ | ✓ |
| Mason Integration | ✓ | ✓ |
| Telescope Integration | ✓ | ✓ |
| Safe LSP jumping | ✓ | ✓ |

### Go-Specific Advantages
- More comprehensive tooling via `go.nvim`
- Better test integration
- Struct tag management
- Interface implementation generation
- Built-in coverage support
- More granular debugging options

## Configuration Files

| File | Purpose |
|------|---------|
| `lua/gpltaylor/plugins/golang.lua` | Main Go plugin configuration |
| `lua/gpltaylor/core/keymaps.lua` | Go-specific keymaps |
| `lua/dap-config.lua` | Debug configurations |
| `lua/gpltaylor/plugins/lsp/mason.lua` | Tool installation |
| `lua/utils/go_utils.lua` | Go project structure utilities |

## Usage Examples

### Debugging a Test
1. Open a Go test file
2. Set breakpoint with `<F2>`
3. Use `<leader>gdt` to debug the nearest test
4. Use `<F6>`, `<F7>`, `<F8>` to control execution

### Adding Struct Tags
1. Place cursor on struct
2. Use `<leader>gsj` for JSON tags or `<leader>gsy` for YAML tags
3. Tags are automatically added to all fields

### Running Tests with Coverage
1. Use `<leader>gta` to run package tests
2. Use `<leader>gtc` to view coverage
3. Coverage highlights show in the buffer

This setup provides a comprehensive, professional Go development environment that matches the quality and consistency of your existing C# configuration.
