package renderer

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

/////////////////////////////////////////////////////////////////////
// CONST Declarations
/////////////////////////////////////////////////////////////////////
N_CUBE_VERTICES :: 8
N_CUBE_FACES :: (6 * 2) //6 cube faces, 2 triangles per face

/////////////////////////////////////////////////////////////////////
// Declarations
/////////////////////////////////////////////////////////////////////
mesh_t :: struct 
{
  vertices : [dynamic]vec3,
  faces    : [dynamic]face_t,
  rotation : vec3,
}

mesh : mesh_t


cube_vertices : [N_CUBE_VERTICES]vec3 = {
  { -1 , -1 , -1 } , // 1
  { -1 , 1  , -1 } , // 2
  { 1  , 1  , -1 } , // 3
  { 1  , -1 , -1 } , // 4
  { 1  , 1  , 1 }  , // 5
  { 1  , -1 , 1 }  , // 6
  { -1 , 1  , 1 }  , // 7
  { -1 , -1 , 1 }  , // 8
}

cube_faces : [N_CUBE_FACES]face_t = {
  //front
  {1 , 2 , 3} ,
  {1 , 3 , 4} ,
  //right
  {4 , 3 , 5} ,
  {4 , 5 , 6} ,
  //back
  {6 , 5 , 7} ,
  {6 , 7 , 8} ,
  //left
  {8 , 7 , 2} ,
  {8 , 2 , 1} ,
  //top
  {2 , 7 , 5} ,
  {2 , 5 , 3} ,
  //bottom
  {6 , 8 , 1} ,
  {6 , 1 , 4} ,
}

load_cube_mesh_data :: proc()
{
  for i in 0 ..< N_CUBE_VERTICES
  {
    append(&mesh.vertices, cube_vertices[i])
  }

  for i in 0 ..< N_CUBE_FACES
  {
    append(&mesh.faces, cube_faces[i])
  }
}

load_obj_file_data :: proc(FILE : string)
{
  if data, ok := os.read_entire_file(FILE, context.temp_allocator); ok {
    data_lines := string(data)

    line_idx := 0
    for line in strings.split_lines_iterator(&data_lines)
    {
      using fmt
      defer line_idx += 1

      line_elements := strings.split(line, " ", context.temp_allocator)
      if line_elements[0] == "v"
      {
        // printf("VERTICES: %s\n", line_elements)
        vertex : vec3 = { 
          f32(strconv.atof(line_elements[1])),
          f32(strconv.atof(line_elements[2])),
          f32(strconv.atof(line_elements[3]))}

        append(&mesh.vertices, vertex)
      }
      else if line_elements[0] == "f"
      {
        // printf("FACES: %s\n", line_elements)
        face : face_t = {
          i32( strconv.atoi( strings.split( line_elements[1], "/", context.temp_allocator )[0] ) ),
          i32( strconv.atoi( strings.split( line_elements[2], "/", context.temp_allocator )[0] ) ),
          i32( strconv.atoi( strings.split( line_elements[3], "/", context.temp_allocator )[0] ) ),
        }

        append(&mesh.faces, face)
      }
    }
  }

  free_all(context.temp_allocator)
}







































