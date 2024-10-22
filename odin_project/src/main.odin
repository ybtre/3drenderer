package renderer

import "core:fmt"
import "core:mem"
import "core:math"
import sdl "vendor:sdl2"

/////////////////////////////////////////////////////////////////////
// Array of triangles that should be rendered frame by frame
/////////////////////////////////////////////////////////////////////
triangles_to_render     : = make([dynamic]triangle_t)
normals_to_render_DEBUG : = make([dynamic]normal_DEBUG)

/////////////////////////////////////////////////////////////////////
// Global varialbes for execution status and game loop
/////////////////////////////////////////////////////////////////////
is_running          : = false
prev_frame_time     : u32

camera_position     : vec3 = { 0, 0, 0 }
proj_matrix         : mat4

toggle_wireframe        : bool = true
toggle_vertex           : bool = true
toggle_filled           : bool = true
toggle_backface_culling : bool = true
toggle_normals          : bool = false

/////////////////////////////////////////////////////////////////////
// Debugging related
/////////////////////////////////////////////////////////////////////
swaps      : int
most_swaps : int

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

  //Initialize the perspective projection matrix
  fov    : f32 = math.PI / 3.0  // the same as 180 / 3 or 60deg
  aspect : f32 = f32(window_height) / f32(window_width)
  zNear  : f32 = 0.1
  zFar   : f32 = 100.0
  proj_matrix = mat4_make_perspective(fov, aspect, zNear, zFar)


  load_cube_mesh_data()
  mesh.scale = { 1, 1, 1 }
  // load_obj_file_data("../assets/f22.obj")
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
        if event.key.keysym.sym == sdl.Keycode.ESCAPE 
        {
          is_running = false
        }

        if event.key.keysym.sym == sdl.Keycode.NUM1 
        {
          toggle_wireframe = !toggle_wireframe
        }

        if event.key.keysym.sym == sdl.Keycode.NUM2
        {
          toggle_vertex = !toggle_vertex
        }

        if event.key.keysym.sym == sdl.Keycode.NUM3
        {
          toggle_filled = !toggle_filled
        }

        if event.key.keysym.sym == sdl.Keycode.NUM4
        {
          toggle_backface_culling = !toggle_backface_culling
        }

        if event.key.keysym.sym == sdl.Keycode.NUM5
        {
          toggle_normals = !toggle_normals
        }
      }
    }
  }
}

/////////////////////////////////////////////////////////////////////
update :: proc()
{
  swaps = 0

  //Wait some time untill we reach the target frame time in ms
  time_to_wait := FRAME_TARGET_TIME - (sdl.GetTicks() - prev_frame_time)

  //Only delay execution if we are running too fast
  if time_to_wait > 0 && time_to_wait <= FRAME_TARGET_TIME
  {
    sdl.Delay(time_to_wait)
  }

  prev_frame_time = sdl.GetTicks()
 
  //change the mesh scale/rot values per animation frame
  mesh.rotation.x += 0.01
  //mesh.rotation.y += 0.01
  //mesh.rotation.z += 0.01
  // mesh.scale.x += 0.002
  // mesh.scale.y += 0.001
  //mesh.translation.x += 0.01
  mesh.translation.z = 5

  //create a scale, rotation and translation matrices that will be used to multiply mesh vertices
  scale_matrix := mat4_make_scale(mesh.scale.x, mesh.scale.y, mesh.scale.z)
  translation_matrix := mat4_make_translation(mesh.translation.x, mesh.translation.y, mesh.translation.z)
  rotation_matrix_x := mat4_make_rotation_x(mesh.rotation.x)
  rotation_matrix_y := mat4_make_rotation_y(mesh.rotation.y)
  rotation_matrix_z := mat4_make_rotation_z(mesh.rotation.z)


  //Loop all triangle faces of our mesh
  for i in 0 ..< len(mesh.faces)
  {
    mesh_face : face_t = mesh.faces[i]

    face_vertices : [3]vec3 = {
      mesh.vertices[mesh_face.a - 1],
      mesh.vertices[mesh_face.b - 1],
      mesh.vertices[mesh_face.c - 1],
    }

    transformed_vertices : [3]vec4
    //create a world matric combining scale, rotation and translation matrices
    world_matrix := mat4_identity()
    world_matrix = mat4_mul_mat4(scale_matrix, world_matrix)
    world_matrix = mat4_mul_mat4(rotation_matrix_x, world_matrix)
    world_matrix = mat4_mul_mat4(rotation_matrix_y, world_matrix)
    world_matrix = mat4_mul_mat4(rotation_matrix_z, world_matrix)
    world_matrix = mat4_mul_mat4(translation_matrix, world_matrix)

    //Loop all three vertices of this current face and apply transformations
    for j in 0 ..< 3
    {
      transformed_vertex := vec4_from_vec3(face_vertices[j])

      transformed_vertex = mat4_mul_vec4(world_matrix, transformed_vertex)

      //NOTE: scale first, then rotate, then translate, order matters
      // transformed_vertex = mat4_mul_vec4(scale_matrix, transformed_vertex)
      // transformed_vertex = mat4_mul_vec4(rotation_matrix_x, transformed_vertex)
      // transformed_vertex = mat4_mul_vec4(rotation_matrix_y, transformed_vertex)
      // transformed_vertex = mat4_mul_vec4(rotation_matrix_z, transformed_vertex)
      // transformed_vertex = mat4_mul_vec4(translation_matrix, transformed_vertex)

      //Save the transformed vertex in the array of transformed vertices
      transformed_vertices[j] = transformed_vertex
    }


    //Check backface culling
    vector_a := vec3_from_vec4(transformed_vertices[0]) //  A
    vector_b := vec3_from_vec4(transformed_vertices[1]) // / \
    vector_c := vec3_from_vec4(transformed_vertices[2]) //C---B

    // get the vector sub of B-A and C-A
    vector_ab := vec3_sub(vector_b, vector_a)
    vector_ac := vec3_sub(vector_c, vector_a)
    vec3_normalize(&vector_ab)
    vec3_normalize(&vector_ac)

    // Computer the face normal (using cross product to find perperndicular)
    normal := vec3_cross(vector_ab, vector_ac)

    // Normalize the face normal vector
    vec3_normalize(&normal)

    if toggle_backface_culling
    {
      //find the vector between a point in the triangle and the camera origin
      camera_ray := vec3_sub(camera_position, vector_a)

      //calculate how aligned the camera ray is with the face normal (using dot product)
      dot_normal_camera := vec3_dot(normal, camera_ray)

      //bypass the triangles that are looking away from the camera
      if dot_normal_camera < 0
      {
        continue
      }
    }

    if toggle_normals
    {
      //Center of triangle vertices
      vec_a_add_b := vec3_add(vector_a, vector_b)
      vec_ab_add_c := vec3_add(vec_a_add_b, vector_c)
      center := vec3_div(vec_ab_add_c, 3)

      //center end point
      scaled_normal := vec3_mul(normal, ((100 * 5)/(0.5 * f32(window_width))))
      center_end := vec3_add(center, scaled_normal)

      //project and translate center
      projected_center := mat4_mul_vec4_project(proj_matrix, vec4_from_vec3(center))
      projected_center.x += f32(window_width /2)
      projected_center.y += f32(window_height /2)

      //project and translate center end
      projected_end := mat4_mul_vec4_project(proj_matrix, vec4_from_vec3(center_end))
      projected_end.x += f32(window_width /2)
      projected_end.y += f32(window_height /2)

      normal_dbg : normal_DEBUG
      normal_dbg.points[0] = { projected_center.x, projected_center.y }
      normal_dbg.points[1] = { projected_end.x, projected_center.y }

      append(&normals_to_render_DEBUG, normal_dbg)
    }

    projected_points : [3]vec4

    //Loop all three vertices to perform the projection
    for j in 0 ..< 3 
    {
      //project the current point
      //projected_points[j] = project(vec3_from_vec4(transformed_vertices[j]))
      projected_points[j] = mat4_mul_vec4_project(proj_matrix, transformed_vertices[j])

      //scale into the view
      projected_points[j].x *= f32( window_width / 2.0 )
      projected_points[j].y *= f32( window_height / 2.0 )

      //translate the projected points to the middle of the screen
      projected_points[j].x += f32(window_width /2)
      projected_points[j].y += f32(window_height /2)
    }

    //Calculate the average depth for each face based on the vertices z value after transformation
    avg_depth : f32 = (transformed_vertices[0].z + transformed_vertices[1].z + transformed_vertices[2].z) / 3

    projected_triangle : triangle_t = {
      { 
        { projected_points[0].x, projected_points[0].y },
        { projected_points[1].x, projected_points[1].y },
        { projected_points[2].x, projected_points[2].y },
      },
      mesh_face.color,
      avg_depth,
    }

    //Save the projected triangle in the array of the triangles to render
    append(&triangles_to_render, projected_triangle)
  }

  quicksort(&triangles_to_render, 0, (len(triangles_to_render) - 1))
  // bubblesort(&triangles_to_render)


  if swaps >= most_swaps
  {
    most_swaps = swaps
  }
  fmt.println(most_swaps)
}

/////////////////////////////////////////////////////////////////////
render :: proc() {
  draw_grid(GREEN)

  //Loop all projected triangles and render the
  for triangle in triangles_to_render
  {
    if toggle_filled 
    {
      //Draw filled triangle
      draw_filled_triangle(
        i32(triangle.points[0].x), i32(triangle.points[0].y),
        i32(triangle.points[1].x), i32(triangle.points[1].y),
        i32(triangle.points[2].x), i32(triangle.points[2].y),
        triangle.color,
      )
    }

    if toggle_wireframe
    {
      // Draw unfilled triangle
      draw_triangle(
        i32(triangle.points[0].x), i32(triangle.points[0].y),
        i32(triangle.points[1].x), i32(triangle.points[1].y),
        i32(triangle.points[2].x), i32(triangle.points[2].y),
        PINK,
      )
    }

    if toggle_vertex
    {
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
  }

  if toggle_normals
  {
    for normal in normals_to_render_DEBUG
    {
      draw_line(
        i32(normal.points[0].x), i32(normal.points[0].y),
        i32(normal.points[1].x), i32(normal.points[1].y), GREEN)
    }
  }

  //clear the array of trinalgers to render every frame loop
  clear(&triangles_to_render)
  clear(&normals_to_render_DEBUG)

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
