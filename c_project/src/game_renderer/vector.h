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

typedef struct {
    float x, y, z, w;
} vec4;

float vec2_len(vec2 v);
vec2 vec2_add(vec2 a, vec2 b);
vec2 vec2_sub(vec2 a, vec2 b);
vec2 vec2_mul(vec2 v, float factor);
vec2 vec2_div(vec2 v, float factor);
float vec2_dot(vec2 a, vec2 b);
void vec2_normalize(vec2* v);

float vec3_len(vec3 v);
vec3 vec3_add(vec3 a, vec3 b);
vec3 vec3_sub(vec3 a, vec3 b);
vec3 vec3_mul(vec3 v, float factor);
vec3 vec3_div(vec3 v, float factor);
vec3 vec3_cross(vec3 a, vec3 b);
float vec3_dot(vec3 a, vec3 b);
void vec3_normalize(vec3* v);

vec3 vec3_rotate_x(vec3 v, float angle);
vec3 vec3_rotate_y(vec3 v, float angle);
vec3 vec3_rotate_z(vec3 v, float angle);

vec4 vec4_from_vec3(vec3 v);
vec3 vec3_from_vec4(vec4 v);
