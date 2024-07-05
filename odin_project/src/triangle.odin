package renderer

/////////////////////////////////////////////////////////////////////
// Declare 
/////////////////////////////////////////////////////////////////////
//NOTE:
//face_t stores vertex index
//triangle_t stores the actual vec2 points of the triangle on the screen
face_t :: struct
{
  a     : i32,
  b     : i32,
  c     : i32,
  color : u32,
}

triangle_t :: struct
{
  points : [3]vec2,
  color  : u32,
}

normal_DEBUG :: struct
{
  points : [2]vec2,
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
i32_swap :: proc(A, B : ^i32)
{
  tmp := A^
  A^ = B^
  B^ = tmp
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Draw a filled a triangle with a flat bottom
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//        (x0,y0)
//          / \
//         /   \
//        /     \
//       /       \
//      /         \
//  (x1,y1)------(x2,y2)
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
fill_flat_bottom_triangle :: proc (x0, y0, x1, y1, x2, y2 : i32, color : u32)
{
  //find the two slopes(two triangle legs)
  inv_slope_1 : f32 = f32(x1 - x0) / f32(y1 - y0)
  inv_slope_2 : f32 = f32(x2 - x0) / f32(y2 - y0)

  //start x_start and x_end from the top vertex (x0,y0)
  x_start : f32 = f32(x0)
  x_end : f32 = f32(x0)

  // loop all the scanlines from the top to bottom
  for y := y0; y <= y2; y += 1
  {
    draw_line(i32(x_start), y, i32(x_end), y, color)

    x_start += inv_slope_1
    x_end += inv_slope_2
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Draw a filled a triangle with a flat top
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  (x0,y0)------(x1,y1)
//      \         /
//       \       /
//        \     /
//         \   /
//          \ /
//        (x2,y2)
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
fill_flat_top_triangle :: proc (x0, y0, x1, y1, x2, y2 : i32, color : u32)
{
  //find the two slopes(two triangle legs)
  inv_slope_1 : f32 = f32(x2 - x0) / f32(y2 - y0)
  inv_slope_2 : f32 = f32(x2 - x1) / f32(y2 - y1)

  //start x_start and x_end from the top vertex (x0,y0)
  x_start : f32 = f32(x2)
  x_end : f32 = f32(x2)

  // loop all the scanlines from the top to bottom
  for y := y2; y >= y0; y -= 1
  {
    draw_line(i32(x_start), y, i32(x_end), y, color)

    x_start -= inv_slope_1
    x_end -= inv_slope_2
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Draw a filled triangle with the flat-top/flat-bottom method
// We split the original triangle in two, half flat-bottom and half flat-top
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//          (x0,y0)
//            / \
//           /   \
//          /     \
//         /       \
//        /         \
//   (x1,y1)------(Mx,My)
//       \_           \
//          \_         \
//             \_       \
//                \_     \
//                   \    \
//                     \_  \
//                        \_\
//                           \
//                         (x2,y2)
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
draw_filled_triangle :: proc(X0, Y0, X1, Y1, X2, Y2 : i32, COLOR : u32)
{
  x0 := X0
  y0 := Y0
  x1 := X1
  y1 := Y1
  x2 := X2
  y2 := Y2

  //sort the vertices by by y-coordinate ascending (y0 < y1 < y2)
  if y0 > y1
  {
    i32_swap(&y0, &y1)
    i32_swap(&x0, &x1)
  }

  if y1 > y2
  {
    i32_swap(&y1, &y2)
    i32_swap(&x1, &x2)
  }

  if y0 > y1
  {
    i32_swap(&y0, &y1)
    i32_swap(&x0, &x1)
  }

  if y1 == y2
  {
    // draw flat-bottom triangle
    fill_flat_bottom_triangle(x0, y0, x1, y1, x2, y2, COLOR)
  }
  else if y0 == y1
  {
    // draw flat-top triangle
    fill_flat_top_triangle(x0, y0, x1, y1, x2, y2, COLOR)
  }
  else
  {
    //calculate the new vertex (Mx, My) using triangle similarity
    My : i32 = y1
    Mx : i32 = i32(( ( f32( x2 - x0 ) * f32( y1 - y0 ) ) / f32( y2 - y0 ) ) + f32(x0))

    // draw flat-bottom triangle
    fill_flat_bottom_triangle(x0, y0, x1, y1, Mx, My, COLOR)

    // draw flat-top triangle
    fill_flat_top_triangle(x1, y1, Mx, My, x2, y2, COLOR)
  }
}
