#pragma once

#include "vector.h"
#include <stdint.h>

typedef struct {
    int a;
    int b;
    int c;
    uint32_t color;
} face;

typedef struct {
    vec2 points[3];
    uint32_t color;
    float avg_depth;
} triangle;

void draw_filled_triangle_from_triangle(triangle tri, uint32_t color);
