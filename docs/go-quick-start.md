# Neovim Go Development - Quick Start Guide

This guide helps you get started with Go development in your newly configured Neovim environment.

## Prerequisites

1. **Go Installation** (1.19+ recommended)
   ```powershell
   # Install Go via chocolatey (Windows)
   choco install golang
   
   # Or download from https://golang.org/dl/
   ```

2. **Verify Installation**
   ```powershell
   go version
   ```

## First Steps

### 1. Open Neovim
Launch Neovim and let Mason install the Go tools automatically:
```powershell
nvim
```

### 2. Check Health
Verify your Go setup:
```vim
:checkhealth
```

### 3. Create a New Go Project
```powershell
mkdir my-go-project
cd my-go-project
go mod init my-go-project
mkdir src
nvim src/main.go
```

The configuration automatically detects whether your main.go is in the root directory or in a src/ folder.

## Essential Keymaps (Same as C#)

### Navigation
- `<leader>gd` - Go to definition
- `<leader>gR` - Find references  
- `<leader>gi` - Go to implementation
- `<leader>gt` - Go to type definition

### Debugging
- `<F2>` - Toggle breakpoint
- `<F1>` - Toggle debug UI
- `<F6>` - Start/continue debugging
- `<F7>` - Step over
- `<F8>` - Step into
- `<F9>` - Stop debugging

### Formatting
- `<leader>fb` - Format buffer (auto-formats on save)

## Go-Specific Features

### Struct Management
- `<leader>gsj` - Add JSON tags to struct
- `<leader>gsy` - Add YAML tags to struct
- `<leader>gsr` - Remove all tags
- `<leader>gsf` - Fill struct with zero values
- `<leader>gsi` - Add `if err != nil` block

### Testing
- `<leader>gtn` - Run nearest test
- `<leader>gtf` - Run tests in current file
- `<leader>gta` - Run all tests in package
- `<leader>gtc` - Show test coverage

### Build & Run
- `<leader>gbr` - Build project (automatically detects src/ folder)
- `<leader>gor` - Run project (automatically detects src/ folder)

### Advanced Debugging
- `<leader>gdt` - Debug nearest test
- `<leader>gdl` - Debug last test/program
- `<leader>gdm` - Debug main.go (auto-detects location)

## Example Workflow

### 1. Create a Simple Program
```go
// src/main.go (or main.go in root)
package main

import "fmt"

func main() {
    name := "World"
    greeting := greet(name)
    fmt.Println(greeting)
}

func greet(name string) string {
    return fmt.Sprintf("Hello, %s!", name)
}
```

The build and run commands (`<leader>gbr`, `<leader>gor`) automatically detect whether your main.go is in the root or src/ directory.

### 2. Add Struct with Tags
```go
type Person struct {
    Name string
    Age  int
}
```
- Place cursor on `Person` struct
- Press `<leader>gsj` to add JSON tags automatically

### 3. Write a Test
Create `main_test.go`:
```go
package main

import "testing"

func TestGreet(t *testing.T) {
    result := greet("Go")
    expected := "Hello, Go!"
    if result != expected {
        t.Errorf("Expected %s, got %s", expected, result)
    }
}
```

### 4. Run and Debug
- Use `<leader>gtn` while cursor is on test function to run it
- Set breakpoint with `<F2>` in the `greet` function
- Use `<leader>gdt` to debug the test
- Step through with `<F7>` and `<F8>`

## Common Commands

### Testing
```vim
:GoTest          " Run tests
:GoTestFunc      " Run test under cursor
:GoCoverage      " Show coverage
```

### Code Generation
```vim
:GoAddTag json   " Add JSON tags
:GoRmTag         " Remove tags
:GoFillStruct    " Fill struct fields
:GoIfErr         " Add error handling
```

### Build and Run
```vim
:GoBuild         " Build project
:GoRun           " Run project
:GoInstall       " Install binary
```

## Tips and Tricks

### 1. Auto-Import
The configuration automatically organizes imports on save. Just write your code and imports will be added/removed automatically.

### 2. Error Handling
Use `<leader>gsi` to quickly add error handling:
```go
result, err := someFunction()
// Cursor here, press <leader>gsi
```
Becomes:
```go
result, err := someFunction()
if err != nil {
    return err
}
```

### 3. Interface Implementation
Use `<leader>gie` to implement interfaces automatically.

### 4. Test Coverage
After running tests with coverage (`<leader>gtc`), coverage information is highlighted directly in your code.

### 5. Debugging Tips
- Set breakpoints before starting debug session
- Use conditional breakpoints for complex scenarios
- Inspect variables in the debug UI (`<F1>`)

## Troubleshooting

### LSP Not Working
```vim
:LspInfo          " Check LSP status
:Mason            " Check installed tools
```

### Debugging Issues
- Ensure `delve` is installed: `go install github.com/go-delve/delve/cmd/dlv@latest`
- Check DAP configuration: `:lua print(vim.inspect(require('dap').configurations.go))`

### Import Issues
- Make sure you're in a Go module directory (has `go.mod`)
- Run `:GoModTidy` to clean up dependencies

## Next Steps

1. **Explore the codebase** - Use `<leader>gd` and `<leader>gR` to navigate
2. **Write tests** - Use the test keymaps to run tests efficiently  
3. **Debug complex issues** - Practice with the debugging keymaps
4. **Try the Go-specific features** - Experiment with struct tags and code generation

For more advanced features and configuration details, see:
- `docs/go-development-setup.md` - Complete feature documentation
- `docs/configuration-overview.md` - Technical configuration details
- `docs/improvements-and-ideas.md` - Future enhancements and ideas

Happy coding! 🚀
