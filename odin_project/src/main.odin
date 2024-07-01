package renderer

import "core:fmt"
import "core:mem"
import sdl "vendor:sdl2"

/////////////////////////////////////////////////////////////////////
// Array of triangles that should be rendered frame by frame
/////////////////////////////////////////////////////////////////////
triangles_to_render := make([dynamic]triangle_t)

/////////////////////////////////////////////////////////////////////
// Global varialbes for execution status and game loop
/////////////////////////////////////////////////////////////////////
is_running          : = false
prev_frame_time     : u32

camera_position     : vec3 = { 0, 0, 0 }
fov_factor          : f32 = 640

/////////////////////////////////////////////////////////////////////
setup :: proc()
{
  //NOTE:
  //- [^]u32 is a like a c style array, with a pointer to the first element and unknown length
  //- []u32 is an odin slice. Under the hood it's a struct with a length and a pointer to the data.
  //Allocate the req memory in bytes to hold the color buffer
  color_buffer = make([]u32, window_width * window_height)

  //Creating a SDL Texture that is used to display the color buffer
  color_buffer_texture = sdl.CreateTexture(
    renderer,
    u32(sdl.PixelFormatEnum.ARGB8888),
    sdl.TextureAccess.STREAMING,
    window_width,
    window_height,
  )

  // load_cube_mesh_data()
  load_obj_file_data("../assets/f22.obj")
  // load_obj_file_data("../assets/cube.obj")
  // load_obj_file_data("../assets/race-future.obj")
}

/////////////////////////////////////////////////////////////////////
process_input :: proc() {
  event: sdl.Event

  for sdl.PollEvent(&event) {
    #partial switch event.type
    {
    case sdl.EventType.QUIT:
      {
        is_running = false
      }
    case sdl.EventType.KEYDOWN:
      {
        if event.key.keysym.sym == sdl.Keycode.ESCAPE {
          is_running = false
        }
      }
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function that receives a 3D vector and returns a projectced 2D Point
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
project :: proc(POINT : vec3) -> vec2
{
  projected_point := vec2{
    ( fov_factor * POINT.x ) / POINT.z,
    ( fov_factor * POINT.y ) / POINT.z }

  return projected_point
}

/////////////////////////////////////////////////////////////////////
update :: proc()
{
  //Wait some time untill we reach the target frame time in ms
  time_to_wait := FRAME_TARGET_TIME - (sdl.GetTicks() - prev_frame_time)

  //Only delay execution if we are running too fast
  if time_to_wait > 0 && time_to_wait <= FRAME_TARGET_TIME
  {
    sdl.Delay(time_to_wait)
  }

  prev_frame_time = sdl.GetTicks()
  
  mesh.rotation.x += 0.02
  mesh.rotation.y += -0.01
  mesh.rotation.z += 0.00

  //Loop all triangle faces of our mesh
  for i in 0 ..< len(mesh.faces)
  {
    mesh_face : face_t = mesh.faces[i]

    face_vertices : [3]vec3 = {
      mesh.vertices[mesh_face.a - 1],
      mesh.vertices[mesh_face.b - 1],
      mesh.vertices[mesh_face.c - 1],
    }

    transformed_vertices : [3]vec3

    //Loop all three vertices of this current face and apply transformations
    for j in 0 ..< 3
    {
      transformed_vertex := face_vertices[j]

      transformed_vertex = vec3_rotate_x(transformed_vertex, mesh.rotation.x)
      transformed_vertex = vec3_rotate_y(transformed_vertex, mesh.rotation.y)
      transformed_vertex = vec3_rotate_z(transformed_vertex, mesh.rotation.z)

      //translate the vertex away from the camera in z
      transformed_vertex.z += 5

      //Save the transformed vertex in the array of transformed vertices
      transformed_vertices[j] = transformed_vertex
    }

    //TODO: Check backface culling
    vector_a := transformed_vertices[0] //  A
    vector_b := transformed_vertices[1] // / \
    vector_c := transformed_vertices[2] //C---B

    // get the vector sub of B-A and C-A
    vector_ab := vec3_sub(vector_b, vector_a)
    vector_ac := vec3_sub(vector_c, vector_a)
    vec3_normalize(&vector_ab)
    vec3_normalize(&vector_ac)

    // Computer the face normal (using cross product to find perperndicular)
    normal := vec3_cross(vector_ab, vector_ac)

    // Normalize the face normal vector
    vec3_normalize(&normal)

    //find the vector between a point in the triangle and the camera origin
    camera_ray := vec3_sub(camera_position, vector_a)

    //calculate how aligned the camera ray is with the face normal (using dot product)
    dot_normal_camera := vec3_dot(normal, camera_ray)

    //bypass the triangles that are looking away from the camera
    if dot_normal_camera < 0
    {
      continue
    }

    //Center of triangle vertices
    vec_a_add_b := vec3_add(vector_a, vector_b)
    vec_ab_add_c := vec3_add(vec_a_add_b, vector_c)
    center := vec3_div(vec_ab_add_c, 3)

    //center end point
    scaled_normal := vec3_mul(normal, (200/(0.5 * f32(window_width))))
    center_end := vec3_add(center, scaled_normal)

    //project and translate center
    projected_center := project(center)
    projected_center.x += f32(window_width /2)
    projected_center.y += f32(window_height /2)

    //project and translate center end
    projected_end := project(center_end)
    projected_end.x += f32(window_width /2)
    projected_end.y += f32(window_height /2)

    draw_line(i32(projected_center.x), i32(projected_center.y), i32(projected_end.x), i32(projected_end.y), GREEN)

    projected_triangle : triangle_t

    //Loop all three vertices to perform the projection
    for j in 0 ..< 3 
    {
      //project the current point
      projected_point := project(transformed_vertices[j])

      //scale and translate the projected points to the middle of the screen
      projected_point.x += f32(window_width /2)
      projected_point.y += f32(window_height /2)

      projected_triangle.points[j] = projected_point
    }

    //Save the projected triangle in the array of the triangles to render
    append(&triangles_to_render, projected_triangle)
  }
}

/////////////////////////////////////////////////////////////////////
render :: proc() {
  draw_grid(GREEN)

  //Loop all projected triangles and render them
  for triangle in triangles_to_render
  {
    //Draw unfilled triangle
    draw_triangle(
      i32(triangle.points[0].x), i32(triangle.points[0].y),
      i32(triangle.points[1].x), i32(triangle.points[1].y),
      i32(triangle.points[2].x), i32(triangle.points[2].y),
      DARK_ORANGE,
    )

    //Draw vertex points
    for vert in triangle.points
    {
      draw_rect(
        i32( vert.x ),
        i32( vert.y ),
        4,
        4,
        LIGHT_ORANGE,
        false)
    }
  }

  //clear the array of trinalgers to render every frame loop
  clear(&triangles_to_render)

  render_color_buffer()

  clear_color_buffer(0xFF000000)

  sdl.RenderPresent(renderer)
}

/////////////////////////////////////////////////////////////////////
// Free the memory that has been dynamically allocated by the program
/////////////////////////////////////////////////////////////////////
free_resources :: proc()
{
  delete(mesh.faces)
  delete(mesh.vertices)
  delete(color_buffer)
  delete(triangles_to_render)
}

/////////////////////////////////////////////////////////////////////
main :: proc() {
  track: mem.Tracking_Allocator
  mem.tracking_allocator_init(&track, context.allocator)
  defer mem.tracking_allocator_destroy(&track)

  context.allocator = mem.tracking_allocator(&track)

  defer {
    for _, leak in track.allocation_map {
      fmt.printf("%v leaked %m\n", leak.location, leak.size)
    }
    for bad_free in track.bad_free_array {
      fmt.printf(
        "%v allocation %p was freed badly\n",
        bad_free.location,
        bad_free.memory,
      )
    }
  }

  /////////////////////////////////////////////////////////
  is_running = initialize_window()

  setup()

  vector : vec3 = {2,2,2}

  for is_running {
    process_input()
    update()
    render()
  }

  destroy_window()
  free_resources()
}
