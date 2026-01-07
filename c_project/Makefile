
OBJS            = ./src/game_renderer/*.c

COMPILER        = gcc

INCLUDE_PATHS   = -Isrc/include/

LIBRARY_PATHS   = -Lsrc/lib/

COMPILER_FLAGS = -std=c11 -Wall -Wextra -Wpedantic -Wshadow -Wformat=2 -Wundef -Wconversion -Wsign-conversion -g3 -O0 -fno-omit-frame-pointer

LINKER_FLAGS    = -lSDL2 -lSDL2main -lSDL2_image -lSDL2_mixer -lSDL2_ttf

EXE_NAME        = ./build/Renderer


build: $(OBJS)
	$(COMPILER) $(OBJS) -o $(EXE_NAME) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(COMPILER_FLAGS) $(LINKER_FLAGS)

run:
	./build/Renderer.exe

clean:
	rm ./build
