# STM32 CMake Development Environment

A clean, maintainable STM32 development setup using CMake, VS Code, and CubeMX with minimal manual intervention.

## Project Structure

```
├── Application/         # User application code
├── src/                 # User libraries and utilities
├── CubeMX/              # CubeMX generated code (do not edit manually)
├── .vscode/             # VS Code configuration
├── cmake/               # CMake toolchain and MCU parameters
└── STM32XXXX.svd        # SVD file for register debugging
```

## Features

- **Auto-discovery**: Linker scripts and source files found automatically
- **Clean separation**: User code isolated from CubeMX generated code
- **Regeneration-safe**: CubeMX regeneration preserves user code
- **Multi-MCU ready**: Easy to switch between different STM32 families

## Initial Setup

### 1. Create CubeMX Project

1. **Clean the CubeMX directory** when changing microcontroller
2. Open STM32CubeMX and create new project in `CubeMX/` folder
3. Configure your MCU pins and peripherals
4. **Important**: In Code Generation settings:
   - Set "Copy only the necessary library files"
   - Set "Generate peripheral initialization as a pair of '.c/.h' files per peripheral"
5. Generate code

### 2. Modify CubeMX Generated main.c

Add these modifications to `CubeMX/Core/Src/main.c` in the designated USER CODE sections:

```c
/* USER CODE BEGIN 0 */
extern void app_main(void);
/* USER CODE END 0 */
```

```c
/* USER CODE BEGIN 2 */
app_main();
/* USER CODE END 2 */
```

**Note**: These modifications are preserved across CubeMX regenerations when placed in USER CODE sections.

### 3. Download SVD File

1. Download the appropriate SVD file for your microcontroller:
   - **GitHub**: [STM32 SVD Files Collection](https://github.com/modm-io/cmsis-svd-stm32)
   - **ST Official**: Search "STM32XXXX SVD" on ST website
2. Place it in the project root with a descriptive name (e.g., `STM32G071.svd`)

### 4. Disconnect from Template Repository

Remove the connection to the template repository:

```bash
git remote remove origin
```

**Optional**: Create and connect to a new GitHub repository for your project:

```bash
# Create new repository on GitHub
gh repo create my-project-name --private

# Connect to the new repository (choose one):
# HTTPS (requires token authentication on each push)
git remote add origin https://github.com/yourusername/my-project-name.git

# SSH (requires initial setup, then no authentication needed)
git remote add origin git@github.com:yourusername/my-project-name.git
```

### 5. Enable Tracking of Generated Files

For your project development, modify `.gitignore` to track CubeMX generated files and SVD files by commenting out or removing these lines:

```gitignore
# CubeMX/*
# !CubeMX/*.ioc
# *.svd
```

This ensures all necessary files are versioned in your project repository.

### 6. Update VS Code Configuration

Edit `.vscode/launch.json`:

```json
{
    "device": "STM32G071RB",     // Your MCU part number
    "svdFile": "STM32G071.svd"   // Your SVD filename
}
```

### 5. Update MCU Parameters

Edit `cmake/STM32G071xx_HAL_PARA.cmake` (or create new file for your MCU):

```cmake
set(CPU_PARAMETERS ${CPU_PARAMETERS}
    -mthumb
    -mcpu=cortex-m0plus    # Adjust for your MCU
)
set(compiler_define ${compiler_define}
    "USE_HAL_DRIVER"
    "STM32G071xx"          # Adjust for your MCU
)
```

Update `CMakeLists.txt` to include your parameter file:

```cmake
include(STM32G071xx_HAL_PARA)  # Change to your file
```

## Build and Debug

```bash
# Configure
cmake --preset Debug

# Build
cmake --build build/Debug

# Debug with VS Code
# Use "ST-Link Run" configuration
```

## Development Workflow

### Quick Shortcuts (Recommended)

The template includes pre-configured keyboard shortcuts for faster development:

- **Alt+B** - Build project
- **Alt+L** - Flash firmware to device
- **Alt+X** - Clean build

### Alternative: Tasks Menu

You can also access these functions via:
- **Ctrl+Shift+P** → "Tasks: Run Task"
- Or Terminal menu → "Run Task..."

Available tasks:
- Build Project
- Clean Project
- Flash Firmware
- Reset Device

## User Code Organization

### Application/
Main application code that calls hardware abstractions and implements business logic.

- `app_main.c` - Main application entry point (called from CubeMX main)
- `printf_redirect.c` - Printf redirection to UART

### src/
Reusable libraries, drivers, and utilities.

- Hardware abstraction layers
- Protocol implementations
- Utility functions

## Key Benefits

1. **CubeMX Regeneration Safe**: User code is completely separated from generated code
2. **Automatic Discovery**: No manual path management for most files
3. **Clean Organization**: Clear separation between generated and user code
4. **Easy MCU Migration**: Minimal changes needed to switch microcontrollers

## Manual Steps When Changing MCU

1. Clean `CubeMX/` directory
2. Generate new CubeMX project
3. Add `app_main()` calls to generated main.c
4. Download new SVD file
5. Update launch.json with new MCU name and SVD file
6. Update/create MCU parameter file in cmake/
7. Update CMakeLists.txt include

## VS Code Configuration

### Extensions
The project includes pre-configured extension recommendations in `.vscode/extensions.json`:

**Essential:**
- **C/C++** (`ms-vscode.cpptools`) - IntelliSense and debugging support
- **CMake Tools** (`ms-vscode.cmake-tools`) - Build integration and project configuration
- **Cortex-Debug** (`marus25.cortex-debug`) - ARM debugging with ST-Link support

**Optional:**
- **clangd** (`llvm-vs-code-extensions.vscode-clangd`) - Modern language server (alternative to C/C++)
- **Clang-Format** (`xaver.clang-format`) - Automatic code formatting

### Automatic Configuration
- **compile_commands.json**: Automatically copied to project root by CMake Tools for IntelliSense
- **clangd**: Requires manual configuration in `.clangd` for ARM toolchain includes:

```yaml
CompileFlags:
  Add:
    - -I/opt/gcc-arm-none-eabi/arm-none-eabi/include
    - --target=arm-none-eabi
```

## Dependencies

- ARM GCC toolchain (`gcc-arm-none-eabi`)
- CMake 3.22+
- VS Code with recommended extensions
- ST-Link tools (`stlink-tools`)