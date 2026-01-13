#pragma once

#include "vector.h"
#include <stdint.h>

typedef struct {
    int a;
    int b;
    int c;
} face;

typedef struct {
    vec2 points[3];
} triangle;

void draw_filled_triangle_from_triangle(triangle tri, uint32_t color);
