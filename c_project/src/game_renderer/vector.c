#include <math.h>
#include "vector.h"

//TODO implement all vector functions (add, mult, get len - lin algebra)
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
