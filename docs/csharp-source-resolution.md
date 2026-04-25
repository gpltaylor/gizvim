# C# Source Resolution

This Neovim configuration provides intelligent "Go to Definition" functionality for C# development that automatically determines the best way to navigate to different types of code.

## How It Works

When you use `<leader>gd` (Go to Definition) on a C# symbol, the system intelligently routes you based on the type:

### 1. RedBear Types (Highest Priority)
- **Detection**: Any assembly containing "RedBear" in the name
- **Action**: Searches for source files in `d:\RedBear\HoneyComb\` directory
- **Behavior**: Opens the actual source file for editing and debugging
- **Fallback**: Shows warning if source not found in expected location

### 2. Microsoft Core Types (Second Priority)  
- **Detection**: Assemblies starting with `System.*` or `Microsoft.*`
- **Action**: Opens official Microsoft documentation in your default browser
- **Examples**: `String`, `DateTime`, `List<T>`, `ILogger`, `HttpClient`
- **URL Format**: `https://docs.microsoft.com/en-us/dotnet/api/system.string`
- **Fallback**: Falls back to GitHub source if docs URL not available

### 3. Third-Party/Open Source (Third Priority)
- **Detection**: Libraries with configured GitHub mappings
- **Action**: Opens source code on GitHub in your default browser
- **Examples**: Newtonsoft.Json, EntityFramework, etc.
- **Fallback**: Shows metadata buffer if no GitHub mapping exists

### 4. Metadata Fallback
- **When**: All other options fail or for unknown assemblies
- **Action**: Opens the decompiled metadata view in a buffer
- **Limitations**: Read-only, may have formatting issues

## Key Mappings

| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>gd` | Go to Definition | Smart routing as described above |
| `<leader>gR` | Find References | Shows all references using Telescope |
| `<leader>gi` | Go to Implementation | Navigate to implementations |
| `<leader>gt` | Go to Type Definition | Navigate to type definitions |

## Priority Logic

The system follows this decision tree:

1. **Is it a RedBear assembly?** → Open local source file
2. **Is it a Microsoft core type?** → Open Microsoft documentation  
3. **Is it mapped to GitHub?** → Open GitHub source page
4. **Default** → Show metadata buffer

## Configuration

### RedBear Base Directories
```lua
redbear_base_dirs = {
  "d:/redbear/honeycomb/",
  "d:/redbear/",
  "c:/code/redbear/",
}
```

### Microsoft Documentation Mappings
The system automatically maps core .NET assemblies to their documentation:
- `System.Private.CoreLib` → system.*
- `Microsoft.Extensions.*` → microsoft.extensions.*
- `Microsoft.AspNetCore.*` → microsoft.aspnetcore.*

### GitHub Source Mappings
For open-source libraries, the system can open source on GitHub:
```lua
github_mappings = {
  ["Microsoft.Extensions.Hosting"] = {
    repo = "dotnet/runtime",
    path_prefix = "src/libraries/Microsoft.Extensions.Hosting/src",
    branch = "main"
  }
}
```

## Error Handling

The system includes robust error handling:
- **Position encoding**: Automatically detects and uses correct encoding (utf-8/utf-16)  
- **Cursor bounds checking**: Prevents crashes from invalid cursor positions
- **Buffer validation**: Ensures buffers are properly loaded before jumping
- **Network timeouts**: Graceful fallbacks when downloads fail

## Troubleshooting

### "Cursor position outside buffer" Error
- **Cause**: LSP returned invalid position data
- **Fix**: Updated to validate cursor position before jumping
- **Prevention**: Automatic bounds checking now in place

### "position_encoding param is required" Error  
- **Cause**: Newer Neovim versions require explicit encoding parameter
- **Fix**: Updated to detect and pass correct encoding from LSP client
- **Prevention**: Automatic client detection with utf-16 fallback

### Empty Metadata Buffers
- **Cause**: .NET metadata files may not load properly
- **Fix**: Enhanced detection and better error messages
- **Alternative**: Automatic fallback to documentation/GitHub

## Advanced Features

### Manual Source Mapping
```lua
-- Add custom source mappings
:lua require('utils.csharp_source_resolver').add_source_mapping()
```

### Clear Cache  
```lua
-- Clear downloaded source cache
:lua require('utils.csharp_source_resolver').clear_source_cache()
```

### Debug Mode
Enable verbose logging to see routing decisions:
```lua
vim.g.csharp_debug = true
```

## Examples

### RedBear Code
- Press `<leader>gd` on `RedBear.Common.Something`
- → Opens `d:/redbear/honeycomb/src/Common/Something.cs`

### Microsoft Core Type  
- Press `<leader>gd` on `String` from `System`
- → Opens `https://docs.microsoft.com/en-us/dotnet/api/system.string`

### Microsoft Extension Type
- Press `<leader>gd` on `ILogger` from `Microsoft.Extensions.Logging`
- → Opens Microsoft documentation or GitHub source

### Unknown Assembly
- Press `<leader>gd` on third-party library
- → Shows decompiled metadata (original behavior)

## Benefits

1. **Intelligent routing** - Different types of code open in the most appropriate way
2. **Better learning** - Microsoft documentation provides better API understanding than source
3. **Faster navigation** - Direct links to relevant resources
4. **RedBear priority** - Local code always takes precedence for debugging
5. **Graceful fallbacks** - Still works when ideal target isn't available
