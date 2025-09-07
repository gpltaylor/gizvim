# Neovim Configuration Documentation

This directory contains comprehensive documentation for your Neovim development environment configuration.

## Documentation Files

### 📚 Core Documentation

#### [`configuration-overview.md`](./configuration-overview.md)
Complete overview of your Neovim configuration architecture, including:
- Configuration structure and organization
- Language support matrix (C# and Go)
- Key design patterns and philosophies
- Plugin dependencies and relationships

#### [`csharp-source-resolution.md`](./csharp-source-resolution.md)
**NEW**: Enhanced C# development with NuGet source resolution:
- Automatic jumping to actual source code instead of metadata
- RedBear package integration
- Custom source mappings
- Telescope-based source browsing

#### [`go-development-setup.md`](./go-development-setup.md)
Detailed documentation of the Go development environment:
- LSP configuration (gopls)
- Debugging setup (delve)
- Enhanced tooling (ray-x/go.nvim)
- Complete keymap reference
- Project structure support (including `/src/` folders)

### 🚀 Getting Started

#### [`go-quick-start.md`](./go-quick-start.md)
Quick start guide for Go development:
- Prerequisites and installation
- Essential keymaps
- Example workflows
- Common commands and tips
- Troubleshooting guide

### 💡 Future Development

#### [`improvements-and-ideas.md`](./improvements-and-ideas.md)
Roadmap for future enhancements:
- Immediate improvements
- Language-specific enhancements
- Multi-language features
- Advanced tooling integration
- Performance optimizations

## Configuration Summary

Your Neovim setup now provides consistent, professional development environments for:

### C# Development
- **LSP**: OmniSharp with extended handlers + **NuGet source resolution**
- **Debugging**: netcoredbg via DAP
- **Formatting**: csharpier
- **Features**: Definition jumping to actual source, references, debugging

### Go Development  
- **LSP**: gopls with comprehensive analysis
- **Debugging**: delve via DAP
- **Formatting**: gofumpt + goimports
- **Enhanced Tools**: struct tags, test generation, coverage, interface implementation

## Key Features

### ✅ Consistent Experience
- Identical keymaps for navigation and debugging across languages
- Same function key mappings (F1-F9) for debugging
- Unified formatting commands

### ✅ Enhanced C# Development
- **NuGet Source Resolution** - Jump to actual source code instead of metadata
- **GitHub Integration** - Automatically download Microsoft.Extensions.*, ASP.NET Core, and other public packages
- **RedBear Package Support** - Automatic mapping to local source repositories
- **Smart Caching** - Downloaded sources persist between sessions
- **Browser Fallback** - Opens GitHub page when download fails

### ✅ Smart Project Structure
- **Go**: Automatic detection of `/src/`, `/cmd/`, `/app/` folders
- **C#**: NuGet source resolution with local repository mapping
- **Universal**: Project-aware build and run commands

### ✅ Comprehensive Tooling
- Automatic tool installation via Mason
- Language-specific enhancements
- Integrated testing and debugging

### ✅ Professional Quality
- Auto-formatting on save
- Real-time diagnostics
- Code completion and snippets

## Quick Reference

### Universal Keymaps (Both Languages)
| Key | Action |
|-----|--------|
| `<leader>gd` | Go to Definition |
| `<leader>gR` | Find References |
| `<leader>gi` | Go to Implementation |
| `<leader>gt` | Type Definition |
| `<leader>fb` | Format Buffer |

### Debugging (Both Languages)
| Key | Action |
|-----|--------|
| `<F1>` | Toggle Debug UI |
| `<F2>` | Toggle Breakpoint |
| `<F6>` | Continue |
| `<F7>` | Step Over |
| `<F8>` | Step Into |
| `<F9>` | Terminate |

### C#-Specific Features
| Key | Action |
|-----|--------|
| `<leader>csf` | Find source files in assembly |
| `<leader>csm` | Add source mapping |
| `<leader>csg` | Add GitHub mapping |
| `<leader>csd` | Download source from GitHub |
| `<leader>css` | Show source mappings |

### Go-Specific Features
| Key | Action |
|-----|--------|
| `<leader>gsj` | Add JSON tags |
| `<leader>gtn` | Run nearest test |
| `<leader>gbr` | Build project (src-aware) |
| `<leader>gor` | Run project (src-aware) |
| `<leader>gdt` | Debug test |
| `<leader>gdm` | Debug main (src-aware) |

## Project Structure Support

The Go configuration intelligently handles different project structures:
- **Root level**: `project-root/main.go`
- **Source folder**: `project-root/src/main.go`
- **Command folder**: `project-root/cmd/main.go`
- **App folder**: `project-root/app/main.go`

Build, run, and debug commands automatically detect the correct directory structure.

## Installation Notes

The configuration automatically installs required tools:

### C# Tools
- omnisharp (LSP server)
- netcoredbg (debugger) 
- csharpier (formatter)

### Go Tools
- gopls (LSP server)
- delve (debugger)
- gofumpt (formatter)
- goimports (import organizer)
- golangci-lint (linter)
- gomodifytags (struct tag tool)
- gotests (test generator)
- impl (interface implementer)

## Support

For issues or questions about the configuration:

1. Check the relevant documentation file
2. Use `:checkhealth` to verify setup
3. Use `:Mason` to check tool installation
4. Use `:LspInfo` for LSP diagnostics

## Contributing

When making changes to the configuration:

1. Update the relevant documentation
2. Test changes with both languages
3. Maintain consistency in keymaps
4. Update this README if adding new docs

---

This documentation ensures your configuration is maintainable, extensible, and provides an excellent development experience for both C# and Go development! 🎉
