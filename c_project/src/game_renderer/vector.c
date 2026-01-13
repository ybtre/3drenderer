#include <math.h>
#include "vector.h"

float vec2_len(vec2 v){
    return sqrtf(v.x * v.x + v.y * v.y);
}

vec2 vec2_add(vec2 a, vec2 b){
    vec2 res = {
        .x = a.x + b.x,
        .y = a.y + b.y
    };
    return res;
}

vec2 vec2_sub(vec2 a, vec2 b){
    vec2 res = {
        .x = a.x - b.x,
        .y = a.y - b.y
    };
    return res;
}

vec2 vec2_mul(vec2 v, float factor){
   vec2 res = {
       .x = v.x * factor,
       .y = v.y * factor
   } ;
   return res;
}

vec2 vec2_div(vec2 v, float factor){
    vec2 res = {
        .x = v.x / factor,
        .y = v.y / factor
    } ;
    return res;
}

float vec2_dot(vec2 a, vec2 b){
    return (a.x * b.x) + (a.y * b.y);
}

float vec3_len(vec3 v){
    return sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
}

vec3 vec3_add(vec3 a, vec3 b){
    vec3 res = {
        .x = a.x + b.x,
        .y = a.y + b.y,
        .z = a.z + b.z
    };
    return res;
}

vec3 vec3_sub(vec3 a, vec3 b){
    vec3 res = {
        .x = a.x - b.x,
        .y = a.y - b.y,
        .z = a.z - b.z
    };
    return res;
}

vec3 vec3_mul(vec3 v, float factor){
    vec3 res = {
        .x = v.x * factor,
        .y = v.y * factor,
        .z = v.z * factor
    } ;
    return res;
}

vec3 vec3_div(vec3 v, float factor){
    vec3 res = {
        .x = v.x / factor,
        .y = v.y / factor,
        .z = v.z / factor
    } ;
    return res;
}

vec3 vec3_cross(vec3 a, vec3 b){
    vec3 res = {
        .x = a.y * b.z - a.z * b.y,
        .y = a.z * b.x - a.x * b.z,
        .z = a.x * b.y - a.y * b.x
    };
    return res;
}

float vec3_dot(vec3 a, vec3 b){
    return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
}

vec3 vec3_rotate_x(vec3 v, float angle){
    float ca = cosf(angle);
    float sa = sinf(angle);
    vec3 rotated_vec = {
        .x = v.x,
        .y = v.y * ca - v.z * sa,
        .z = v.y * sa + v.z * ca
    };
    return rotated_vec;
}

vec3 vec3_rotate_y(vec3 v, float angle){
    float ca = cosf(angle);
    float sa = sinf(angle);
    vec3 rotated_vec = {
        .x = v.x * ca - v.z * sa,
        .y = v.y,
        .z = v.x * sa + v.z * ca
    };
    return rotated_vec;
}

vec3 vec3_rotate_z(vec3 v, float angle){
    float ca = cosf(angle);
    float sa = sinf(angle);
    vec3 rotated_vec = {
        .x = v.x * ca - v.y * sa,
        .y = v.x * sa + v.y * ca,
        .z = v.z
    };
    return rotated_vec;
}
