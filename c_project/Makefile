# Detect OS
OS := $(shell uname -s)

# Source files
SRC_DIR     = ./src/game_renderer
SRC_FILES   = $(wildcard $(SRC_DIR)/*.c)
OBJ_FILES   = $(patsubst $(SRC_DIR)/%.c, $(SRC_DIR)/%.o, $(SRC_FILES))

# Compiler and flags
COMPILER        = gcc
INCLUDE_PATHS   = -Isrc/include/
COMPILER_FLAGS  = -std=c11 -Wall -Wextra -Wpedantic -Wshadow -Wformat=2 -Wundef -Wconversion -Wsign-conversion -g3 -O0 -fno-omit-frame-pointer

# Library paths and flags
LIBRARY_PATHS   =
LINKER_FLAGS    = -lSDL2 -lm

# Platform-specific settings
ifeq ($(OS),Darwin)
    # macOS: Use dynamic libraries from Homebrew
    LIBRARY_PATHS   = -L/opt/homebrew/Cellar/sdl2/2.32.10/lib
    LINKER_FLAGS    += -lSDL2main
else
    # Linux/Other: Use static libraries from src/lib/
    LIBRARY_PATHS   = -Lsrc/lib
    LINKER_FLAGS    += -lSDL2main -lSDL2_image -lSDL2_mixer -lSDL2_ttf
endif

# Output
EXE_NAME        = ./build/Renderer
APP_NAME        = ./build/Renderer.app/Contents/MacOS/Renderer

# Targets
build: $(OBJ_FILES)
	$(COMPILER) $(OBJ_FILES) -o $(EXE_NAME) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(COMPILER_FLAGS) $(LINKER_FLAGS)

run:
ifeq ($(OS),Darwin)
	./build/Renderer
else
	./build/Renderer
endif

clean:
	rm -rf ./build
