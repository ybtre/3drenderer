package renderer

import "core:math"

vec2 :: struct
{
  x, y : f32, 
}

vec3 :: struct
{
  x, y, z : f32,
}

//TODO: add functions to manipilate vectors 2D and 3D
vec3_rotate_x :: proc (v : vec3, angle : f32) -> vec3
{
  rotated_vec : vec3 = {
    v.x,
    v.y * math.cos(angle) - v.z * math.sin(angle),
    v.y * math.sin(angle) + v.z * math.cos(angle),
  }

  return rotated_vec
}

vec3_rotate_y :: proc (v : vec3, angle : f32) -> vec3
{
  rotated_vec : vec3 = {
    v.x * math.cos(angle) - v.z * math.sin(angle),
    v.y, 
    v.x * math.sin(angle) + v.z * math.cos(angle),
  }

  return rotated_vec
}

vec3_rotate_z :: proc (v : vec3, angle : f32) -> vec3
{
  rotated_vec : vec3 = {
    v.x * math.cos(angle) - v.y * math.sin(angle),
    v.x * math.sin(angle) + v.y * math.cos(angle),
    v.z,
  }

  return rotated_vec
}
