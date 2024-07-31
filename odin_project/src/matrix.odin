package renderer

import "core:fmt"

mat4 :: struct {
  m : [4][4]f32,
}

mat4_identity :: proc() -> mat4
{
  // | 1 0 0 0 |
  // | 0 1 0 0 |
  // | 0 0 1 0 |
  // | 0 0 0 1 |
  mat : mat4 = {{
    { 1, 0, 0, 0 },
    { 0, 1, 0, 0 },
    { 0, 0, 1, 0 },
    { 0, 0, 0, 1 },
  }}

  return mat
}

mat4_make_scale :: proc(sx, sy, sz : f32) -> mat4
{
  // | sx 0  0  0 |
  // | 0 sy  0  0 |
  // | 0  0 sz  0 |
  // | 0  0  0  1 |

  m : mat4 = mat4_identity()
  m.m[0][0] = sx
  m.m[1][1] = sy
  m.m[2][2] = sz

  return m
}

mat4_mul_vec4 :: proc(m : mat4, v : vec4) -> vec4
{
  result : vec4

  result.x = m.m[0][0] * v.x + m.m[0][1] * v.y + m.m[0][2] * v.z + m.m[0][3] * v.w
  result.y = m.m[1][0] * v.x + m.m[1][1] * v.y + m.m[1][2] * v.z + m.m[1][3] * v.w
  result.z = m.m[2][0] * v.x + m.m[2][1] * v.y + m.m[2][2] * v.z + m.m[2][3] * v.w
  result.w = m.m[3][0] * v.x + m.m[3][1] * v.y + m.m[3][2] * v.z + m.m[3][3] * v.w

  return result
}
