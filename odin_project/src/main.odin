package renderer

import "core:fmt"
import "core:mem"
import sdl "vendor:sdl2"

/////////////////////////////////////////////////////////////////////
// Declarations
/////////////////////////////////////////////////////////////////////
triangles_to_render : [N_MESH_FACES]triangle_t

camera_position     : vec3 = { 0, 0, -5 }
cube_rotation       : vec3 = { 0, 0, 0 }

fov_factor          : f32 = 640

is_running          : = false
prev_frame_time     : u32

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

  cube_rotation.x += 0.01
  cube_rotation.y += 0.01
  cube_rotation.z += 0.01

  //Loop all triangle faces of our mesh
  for i in 0 ..< N_MESH_FACES
  {
    mesh_face :face_t = mesh_faces[i]

    face_vertices : [3]vec3 = {
      mesh_vertices[mesh_face.a - 1],
      mesh_vertices[mesh_face.b - 1],
      mesh_vertices[mesh_face.c - 1],
    }

    projected_triangle : triangle_t

    //Loop all three vertices of this current face and apply transformations
    for j in 0 ..< 3
    {
      transformed_vertex := face_vertices[j]

      transformed_vertex = vec3_rotate_x(transformed_vertex, cube_rotation.x)
      transformed_vertex = vec3_rotate_y(transformed_vertex, cube_rotation.y)
      transformed_vertex = vec3_rotate_z(transformed_vertex, cube_rotation.z)

      //translate the vertex away from the camera in z
      transformed_vertex.z -= camera_position.z

      //project the current point
      projected_point := project(transformed_vertex)

      //scale and translate the projected points to the middle of the screen
      projected_point.x += f32(window_width /2)
      projected_point.y += f32(window_height /2)

      projected_triangle.points[j] = projected_point
    }

    //Save the projected triangle in the array of the triangles to render
    triangles_to_render[i] = projected_triangle
  }
}

/////////////////////////////////////////////////////////////////////
render :: proc() {
  // draw_grid(PINK)

  //Loop all projected triangles and render them
  for i in 0 ..< N_MESH_FACES
  {
    triangle := triangles_to_render[i]

    //Draw unfilled triangle
    draw_triangle(
        i32(triangle.points[0].x), i32(triangle.points[0].y),
        i32(triangle.points[1].x), i32(triangle.points[1].y),
        i32(triangle.points[2].x), i32(triangle.points[2].y),
        DARK_ORANGE
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

  render_color_buffer()

  clear_color_buffer(0xFF000000)

  sdl.RenderPresent(renderer)
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
}
