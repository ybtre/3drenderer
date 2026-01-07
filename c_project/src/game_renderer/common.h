#ifndef COMMON_H
#define COMMON_H

//NOTE: should probably be removed for macos build...
#define SDL_MAIN_HANDLED

#include "../include/SDL2/SDL.h"
#include "../include/SDL2/SDL_image.h"
#include "../include/SDL2/SDL_mixer.h"
#include "../include/SDL2/SDL_ttf.h"

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <assert.h>


#define ASSERTIF(cond, msg)                                   \
    do {                                                        \
        if ((cond)) {                                          \
            fprintf(stderr, "%s\n", (msg));                     \
            assert(cond);                                       \
        }                                                       \
    } while (0)

#endif
