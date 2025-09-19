cmake_minimum_required(VERSION 3.22)

# Setup cmake module path and compiler settings
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
message("Build type: "              ${CMAKE_BUILD_TYPE})
set(PROJ_PATH                       ${CMAKE_CURRENT_SOURCE_DIR})

# Project configuration (PROJECT_NAME and LINKER_SCRIPT now defined in CMakePresets.json)
project(${PROJECT_NAME})
enable_language(C CXX ASM)

# Linker File - Auto-discover from CubeMX directory
file(GLOB LINKER_FILES "${CMAKE_SOURCE_DIR}/CubeMX/*.ld")
list(LENGTH LINKER_FILES NUM_LINKER_FILES)
if(NUM_LINKER_FILES EQUAL 0)
    message(FATAL_ERROR "No .ld files found in CubeMX directory")
elseif(NUM_LINKER_FILES GREATER 1)
    message(WARNING "Multiple .ld files found in CubeMX directory: ${LINKER_FILES}")
endif()
list(GET LINKER_FILES 0 linker_script_SRC)
message(STATUS "Auto-discovered linker script: ${linker_script_SRC}")

set(EXECUTABLE                      ${CMAKE_PROJECT_NAME})

# MCU Parameters - I am storing all created profiles. Pick one to use.
# include(STM32G431xx_HAL_PARA)
# include(STM32L432xx_HAL_PARA)
include(STM32G071xx_HAL_PARA)

# Auto-discover source files in specific directories
file(GLOB_RECURSE source_list
    "Application/*.c" "Application/*.cpp"
    "src/*.c" "src/*.cpp"
    "CubeMX/Core/*.c"
    "CubeMX/Drivers/*.c"
    "CubeMX/*.s"
)

# Auto-discover headers in the same directories
file(GLOB_RECURSE ALL_HEADERS
    "Application/*.h" "Application/*.hpp"
    "src/*.h" "src/*.hpp"
    "CubeMX/Core/*.h"
    "CubeMX/Drivers/*.h"
)

# Extract unique include directories
set(include_list "")
foreach(HEADER ${ALL_HEADERS})
    get_filename_component(HEADER_DIR ${HEADER} DIRECTORY)
    list(APPEND include_list ${HEADER_DIR})
endforeach()
list(REMOVE_DUPLICATES include_list)

# Executable files
add_executable(${EXECUTABLE} ${source_list})

# Include paths
target_include_directories(${EXECUTABLE} PRIVATE ${include_list})

# Project symbols
target_compile_definitions(${EXECUTABLE} PRIVATE ${compiler_define})

# Compiler options
target_compile_options(${EXECUTABLE} PRIVATE
	${CPU_PARAMETERS}
	-Wall
	-Wpedantic
	-Wno-unused-parameter
)

# Linker options
target_link_options(${EXECUTABLE} PRIVATE
	-T${linker_script_SRC}
	${CPU_PARAMETERS}
	-Wl,-Map=${CMAKE_PROJECT_NAME}.map
	--specs=nosys.specs
	#-u _printf_float                # STDIO float formatting support
	-Wl,--start-group
	-lc
	-lm
	-lstdc++
	-lsupc++
	-Wl,--end-group
	-Wl,--print-memory-usage
)

# Execute post-build to print size
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
	COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${EXECUTABLE}>
)

# Convert output to hex and binary
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
	COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${EXECUTABLE}> ${EXECUTABLE}.hex
)

# Convert to bin file -> add conditional check?
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
	COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${EXECUTABLE}> ${EXECUTABLE}.bin
)

