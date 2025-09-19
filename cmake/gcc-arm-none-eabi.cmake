set(CMAKE_SYSTEM_NAME               Generic)
set(CMAKE_SYSTEM_PROCESSOR          arm)

# Some default GCC settings
# Use configurable toolchain path instead of relying on PATH environment
if(DEFINED ENV{ARM_TOOLCHAIN_PATH})
    set(ARM_TOOLCHAIN_PATH $ENV{ARM_TOOLCHAIN_PATH})
elseif(DEFINED ARM_TOOLCHAIN_PATH)
    # Already set as cache variable or normal variable
else()
    message(FATAL_ERROR "ARM_TOOLCHAIN_PATH must be defined. Set it in CMakePresets.json environment section or pass it to cmake with -DARM_TOOLCHAIN_PATH=/path/to/toolchain/bin")
endif()

set(TOOLCHAIN_PREFIX                ${ARM_TOOLCHAIN_PATH}/arm-none-eabi-)

# Define compiler settings
set(CMAKE_C_COMPILER                ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER              ${CMAKE_C_COMPILER})
set(CMAKE_CXX_COMPILER              ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_OBJCOPY                   ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE                      ${TOOLCHAIN_PREFIX}size)

# Compiler flags
set(CMAKE_C_FLAGS                   "-fdata-sections -ffunction-sections --specs=nano.specs")
set(CMAKE_CXX_FLAGS                 "-fdata-sections -ffunction-sections --specs=nano.specs -fno-rtti -fno-exceptions -fno-threadsafe-statics")
set(CMAKE_EXE_LINKER_FLAGS          "-Wl,--gc-sections")

set(CMAKE_EXECUTABLE_SUFFIX_ASM     ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_C       ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_CXX     ".elf")

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)