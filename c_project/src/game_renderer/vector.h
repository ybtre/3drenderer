#pragma once

typedef struct {
    float x;
    float y;
} vec2;

typedef struct {
    float x;
    float y;
    float z;
} vec3;

vec3 vec3_rotate_x(vec3 v, float angle);
vec3 vec3_rotate_y(vec3 v, float angle);
vec3 vec3_rotate_z(vec3 v, float angle);

//TODO: add functions to manipulate 2d and 3d vectors
