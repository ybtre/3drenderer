package renderer

import "core:fmt"
import "core:mem"
import sdl "vendor:sdl2"


/////////////////////////////////////////////////////////////////////
// Declare an array of vectors/points
/////////////////////////////////////////////////////////////////////
N_POINTS :: 9 * 9 * 9
cube_points : [N_POINTS]vec3

is_running : = false

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

  //start loading array of vectors
  //from -1 to 1 (in this 9x9x9 cuve)
  point_count : int = 0
  for x : f32 = -1; x <= 1; x += .25 {
    for y : f32 = -1; y <= 1; y += .25 {
      for z : f32 = -1; z <= 1; z += .25 {
        new_point : vec3 = { x, y, z }
        cube_points[point_count] = new_point

        point_count += 1
      }
    }
  }
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

/////////////////////////////////////////////////////////////////////
update :: proc() {

}

/////////////////////////////////////////////////////////////////////
render :: proc() {
  sdl.SetRenderDrawColor(renderer, 222, 83, 7, 255)
  sdl.RenderClear(renderer)

  draw_grid(PINK)

  draw_pixel(20, 20, DARK_ORANGE)
  draw_rect(900, 600, 200, 200, LIGHT_ORANGE, false)

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
