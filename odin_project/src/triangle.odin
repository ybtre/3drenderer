package renderer

/////////////////////////////////////////////////////////////////////
// Declare 
/////////////////////////////////////////////////////////////////////
//NOTE:
//face_t stores vertex index
//triangle_t stores the actual vec2 points of the triangle on the screen
face_t :: struct
{
  a : i32,
  b : i32,
  c : i32,
}

triangle_t :: struct
{
  points : [3]vec2,
}
