
OBJS            = ./src/game_renderer/*.c

COMPILER        = gcc

INCLUDE_PATHS   = -Isrc/include/

LIBRARY_PATHS   = -Lsrc/lib/

COMPILER_FLAGS  = -Wextra -g -O0

LINKER_FLAGS    = -lSDL2main -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf

EXE_NAME        = ./build/Renderer


build: $(OBJS)
	$(COMPILER) $(OBJS) -o $(EXE_NAME) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(COMPILER_FLAGS) $(LINKER_FLAGS)

run:
	./build/Renderer.exe

clean:
	rm ./build
