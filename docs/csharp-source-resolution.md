# C# NuGet Package Source Resolution

This document describes the C# NuGet package source resolution feature that allows you to jump directly to actual source code instead of empty metadata files.

## Overview

When working with C# projects that reference NuGet packages, the LSP often takes you to metadata URIs like:
```
csharp:/metadata/projects/RedBear.MoneyBot.Api/assemblies/RedBear.Common.Containers/symbols/RedBear.Common.Containers.ContainerLifecycle.cs
```

This feature automatically resolves these metadata references to actual source code when available, providing a much better development experience.

## How It Works

### 1. Automatic Source Resolution

When you use `<leader>gd`, `<leader>gi`, `<leader>gR`, or `<leader>gt` and land on a C# metadata URI, the system:

1. **Parses the metadata URI** to extract:
   - Assembly name (e.g., `Microsoft.Extensions.Hosting`)
   - File name (e.g., `Host.cs`)
   - Project context

2. **Searches for actual source** in multiple locations:
   - **Local RedBear repositories**: `d:/redbear/honeycomb/RedBear.Common.Containers/`
   - **Custom source mappings**: User-defined local directories
   - **GitHub repositories**: Downloads source from public repositories
   - **Browser fallback**: Opens GitHub page if download fails

3. **Opens the real source file** if found, with intelligent line positioning

4. **Falls back to metadata** if no source is available anywhere

### 2. GitHub Integration

For public NuGet packages (Microsoft.*, Newtonsoft.Json, etc.), the system:
- **Downloads source files** from GitHub automatically
- **Caches downloaded files** locally for future use
- **Opens GitHub in browser** as fallback if download fails
- **Supports major .NET packages** out of the box

### 2. Smart File Detection

The resolver uses multiple strategies to find source files:
- **Direct path matching**: Looks for exact file paths
- **Common directory structures**: Checks `src/`, `Source/`, root directory
- **Recursive search**: Uses Windows `dir` command to find files recursively
- **Class name matching**: If line numbers don't match, finds class declarations

### 3. Cross-Platform Compatibility

The system works on both Windows and Unix-like systems:
- **Windows**: Uses `dir` and `findstr` commands
- **Unix/Linux**: Uses `find` command
- **Path normalization**: Converts between forward/backward slashes automatically

## Configuration

### Base Directories

Configure where your source code is located:

```lua
-- In utils/csharp_source_resolver.lua
M.config = {
  redbear_base_dirs = {
    "d:/redbear/honeycomb/",
    "d:/redbear/",
    "c:/code/redbear/",
    -- Add your custom paths here
  },
}
```

### Custom Source Mappings

For non-RedBear packages or custom locations:

```lua
M.config.source_mappings = {
  ["MyCompany.Common"] = "c:/code/mycompany/common",
  ["ThirdParty.Library"] = "d:/source/thirdparty/library",
}
```

### GitHub Repository Mappings

For public NuGet packages, the system includes pre-configured GitHub mappings:

```lua
M.config.github_mappings = {
  ["Microsoft.Extensions.Hosting"] = {
    repo = "dotnet/runtime",
    path_prefix = "src/libraries/Microsoft.Extensions.Hosting/src",
    branch = "main"
  },
  ["Microsoft.AspNetCore"] = {
    repo = "dotnet/aspnetcore", 
    path_prefix = "src",
    branch = "main"
  },
  -- Many more pre-configured...
}
```

**Supported packages include**:
- Microsoft.Extensions.* (Hosting, DependencyInjection, Configuration, Logging)
- Microsoft.AspNetCore.*
- System.Text.Json
- Newtonsoft.Json
- Entity Framework Core
- AutoMapper, Serilog, NUnit, xUnit
- And more...

## Keymaps and Commands

### C#-Specific Keymaps (in C# files)

| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>csf` | Find Source | Search for source files in assembly using Telescope |
| `<leader>csm` | Add Mapping | Add custom source directory mapping |
| `<leader>csg` | Add GitHub | Add GitHub repository mapping |
| `<leader>csd` | Download Source | Force download source file from GitHub |
| `<leader>csc` | Clear Cache | Clear downloaded source cache |
| `<leader>css` | Show Mappings | Display all configured source mappings |

### Global Commands

| Command | Description |
|---------|-------------|
| `:CSharpFindSource [assembly]` | Find source files in specified assembly |
| `:CSharpAddMapping` | Add a custom source mapping interactively |
| `:CSharpAddGitHub` | Add a GitHub repository mapping |
| `:CSharpDownload` | Download a specific source file from GitHub |
| `:CSharpClearCache` | Clear the downloaded source cache |
| `:CSharpShowMappings` | Show all current mappings |

### Enhanced LSP Navigation

Your existing LSP keymaps now have enhanced functionality:

| Keymap | Enhanced Behavior |
|--------|-------------------|
| `<leader>gd` | Go to definition → tries source first, falls back to metadata |
| `<leader>gi` | Go to implementation → tries source first, falls back to metadata |
| `<leader>gR` | Find references → shows source locations when available |
| `<leader>gt` | Type definition → tries source first, falls back to metadata |

## Usage Examples

### 1. Basic Navigation (Microsoft Extensions)
```csharp
// In your C# code
return Host.CreateDefaultBuilder(args) // Cursor on CreateDefaultBuilder
```
- Press `<leader>gd`
- System detects it's Microsoft.Extensions.Hosting
- Downloads Host.cs from dotnet/runtime GitHub repository
- Opens the actual source code with CreateDefaultBuilder method

### 2. RedBear Package Navigation
```csharp
// In your C# code
var container = new ContainerLifecycle(); // Cursor here
```
- Press `<leader>gd`
- Finds local RedBear source in `d:/redbear/honeycomb/RedBear.Common.Containers/`
- Opens actual source file locally

### 3. GitHub Fallback
```csharp
// In your C# code
JsonConvert.SerializeObject(data); // Cursor on SerializeObject
```
- Press `<leader>gd`
- If download fails, opens GitHub page in browser
- You can view the source on GitHub directly

### 2. Finding Source Files
- Press `<leader>csf`
- Enter assembly name (e.g., "Microsoft.Extensions.Hosting")
- Telescope shows all .cs files in that assembly (local or cached)
- Select file to open

### 3. Adding Custom Mappings
- Press `<leader>csm` for local directory mapping
- Press `<leader>csg` for GitHub repository mapping
- Future navigation will check these locations

### 4. Force Download
- Press `<leader>csd`
- Enter assembly name and filename
- Downloads directly from GitHub and opens

### 5. Managing Cache
- Press `<leader>csc` to clear downloaded files
- Press `<leader>css` to see all mappings and cache status

## Performance Features

### 1. Path Caching
- Resolved paths are cached for the session
- Subsequent jumps to the same files are instant
- Cache persists until Neovim restart

### 2. Intelligent Search
- Only searches when dealing with metadata URIs
- Skips resolution for regular file URIs
- Falls back gracefully when source unavailable

### 3. Downloaded Source Cache
- Downloaded files are stored in Neovim's cache directory
- Files persist between sessions
- Use `:CSharpClearCache` to clean up space
- Cache location: `~/.cache/nvim/csharp_sources/` (Unix) or `%LOCALAPPDATA%\nvim-data\csharp_sources\` (Windows)

## File Structure Support

The resolver handles various project structures:

```
RedBear.Common.Containers/
├── ContainerLifecycle.cs          # Root level
├── src/
│   └── ContainerLifecycle.cs      # Source directory
├── Source/
│   └── ContainerLifecycle.cs      # Alternative source directory
└── Subfolder/
    └── ContainerLifecycle.cs      # Nested files
```

## Troubleshooting

### Source Not Found
1. Check if the directory exists in base directories
2. Verify the assembly name matches the directory name
3. Add custom mapping if needed: `<leader>csm`

### Wrong File Opened
1. Check if multiple files have the same name
2. Use `<leader>csf` to browse all files in the assembly
3. Verify the directory structure matches expectations

### Performance Issues
1. Check `<leader>css` for cached paths
2. Ensure base directories exist (non-existent dirs are skipped)
3. Consider adding specific mappings for frequently used assemblies

### Windows Path Issues
- The system automatically converts between forward/backward slashes
- Use forward slashes in configuration for cross-platform compatibility
- Windows `dir` command is used for recursive searches

## Integration with Existing Workflow

This feature enhances your existing C# development workflow without changing your muscle memory:

1. **Same keymaps** - `<leader>gd`, `<leader>gi`, etc. work as before
2. **Better results** - Now jump to actual source instead of empty files
3. **Graceful fallback** - Still works with packages that don't have source
4. **Telescope integration** - Consistent with your existing fuzzy finding workflow

The enhancement is completely transparent - when source is available, you get it; when it's not, you get the standard metadata behavior.

## Future Enhancements

Potential improvements for this feature:
- **Git integration**: Clone missing repositories automatically
- **Symbol search**: Find symbols across all source repositories
- **Dependency mapping**: Automatically map related assemblies
- **Source indexing**: Pre-index source locations for faster resolution
- **Remote sources**: Support for remote source repositories
