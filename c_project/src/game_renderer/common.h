#ifndef COMMON_H
#define COMMON_H

//NOTE: should probably be removed for macos build...
//#define SDL_MAIN_HANDLED

// SDL include dir comes from the makefile (-I...SDL2) for each platform.
#include <SDL.h>
#include <SDL_image.h>
#include <SDL_mixer.h>
#include <SDL_ttf.h>

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <assert.h>

#include <limits.h>


#define ASSERTIF(cond, msg)                                   \
    do {                                                        \
        if ((cond)) {                                          \
            fprintf(stderr, "%s\n", (msg));                     \
            assert(cond);                                       \
        }                                                       \
    } while (0)

#endif
