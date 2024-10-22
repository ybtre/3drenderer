package renderer

import "core:math"

mat4 :: struct {
  m : [4][4]f32,
}

/////////////////////////////////////////////////////////////////////
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

/////////////////////////////////////////////////////////////////////
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

/////////////////////////////////////////////////////////////////////
mat4_make_translation :: proc(tx, ty, tz : f32) -> mat4
{
  // | 1  0  0  tx |
  // | 0  1  0  ty |
  // | 0  0  1  tz |
  // | 0  0  0   1 |

  m : mat4 = mat4_identity()
  m.m[0][3] = tx
  m.m[1][3] = ty
  m.m[2][3] = tz

  return m
}

/////////////////////////////////////////////////////////////////////
mat4_make_rotation_x :: proc(angle : f32) -> mat4
{
  c := math.cos_f32(angle)
  s := math.sin_f32(angle)
  // 0   0  0  0
  // 0   c -s  0
  // 0   s  c  0
  // 0   0  0  1
  m := mat4_identity()
  m.m[1][1] = c
  m.m[1][2] = -s
  m.m[2][1] = s
  m.m[2][2] = c

  return m
}

/////////////////////////////////////////////////////////////////////
mat4_make_rotation_y :: proc(angle : f32) -> mat4
{
  c := math.cos_f32(angle)
  s := math.sin_f32(angle)
  // c   0  s  0
  // 0   0  0  0
  // -s  0  c  0
  // 0   0  0  1
  m := mat4_identity()
  m.m[0][0] = c
  m.m[0][2] = s
  m.m[2][0] = -s
  m.m[2][2] = c

  return m
}

/////////////////////////////////////////////////////////////////////
mat4_make_rotation_z :: proc(angle : f32) -> mat4
{
  c := math.cos_f32(angle)
  s := math.sin_f32(angle)
  // c  -s  0  0
  // s   c  0  0
  // 0   0  1  0
  // 0   0  0  1
  m := mat4_identity()
  m.m[0][0] = c
  m.m[0][1] = -s
  m.m[1][0] = s
  m.m[1][1] = c

  return m
}

/////////////////////////////////////////////////////////////////////
mat4_make_perspective :: proc(fov, aspect, zNear, zFar : f32) -> mat4 
{
    // | (h/w)*1/tan(fov/2)             0              0                 0 |
    // |                  0  1/tan(fov/2)              0                 0 |
    // |                  0             0     zf/(zf-zn)  (-zf*zn)/(zf-zn) |
    // |                  0             0              1                 0 |
  m : mat4 
  m.m[0][0] = aspect * ( 1 / math.tan( fov / 2 ) )
  m.m[1][1] = 1 / math.tan( fov / 2 )
  m.m[2][2] = zFar / ( zFar - zNear )
  m.m[2][3] = ( -zFar * zNear ) / ( zFar - zNear )
  m.m[3][2] = 1.0

  return m
}

/////////////////////////////////////////////////////////////////////
mat4_mul_vec4_project :: proc(mat_proj : mat4, v : vec4) -> vec4
{
  //multiply the projection matrix by our original vector
  result := mat4_mul_vec4(mat_proj, v)

  //perform perspetive divide with original z-value that is now stored in w
  if result.w != 0.0
  {
    result.x /= result.w
    result.y /= result.w
    result.z /= result.w
  }

  return result
}

/////////////////////////////////////////////////////////////////////
mat4_mul_vec4 :: proc(m : mat4, v : vec4) -> vec4
{
  result : vec4

  result.x = m.m[0][0] * v.x + m.m[0][1] * v.y + m.m[0][2] * v.z + m.m[0][3] * v.w
  result.y = m.m[1][0] * v.x + m.m[1][1] * v.y + m.m[1][2] * v.z + m.m[1][3] * v.w
  result.z = m.m[2][0] * v.x + m.m[2][1] * v.y + m.m[2][2] * v.z + m.m[2][3] * v.w
  result.w = m.m[3][0] * v.x + m.m[3][1] * v.y + m.m[3][2] * v.z + m.m[3][3] * v.w

  return result
}

/////////////////////////////////////////////////////////////////////
mat4_mul_mat4 :: proc(a, b : mat4) -> mat4
{
  m : mat4

  for i := 0; i < 4; i += 1 {
    for j := 0; j < 4; j += 1
    {
      m.m[i][j] = a.m[i][0] * b.m[0][j] + a.m[i][1] * b.m[1][j] + a.m[i][2] * b.m[2][j] + a.m[i][3] * b.m[3][j]
    }
  }

  return m
}
