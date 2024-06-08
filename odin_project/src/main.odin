package renderer

import "core:fmt"
import "core:mem"
import sdl "vendor:sdl2"

is_running := false
window: ^sdl.Window
renderer: ^sdl.Renderer

//NOTE:
//- could later be changed to a static array
//- pointer to first element
color_buffer: []u32
color_buffer_texture: ^sdl.Texture

window_width :: 800
window_height :: 600


initialize_window :: proc() -> bool {
  if sdl.Init(sdl.INIT_EVERYTHING) != 0 {
    fmt.printf("Error initializing SDL. \n")
    return false
  }

  window = sdl.CreateWindow(
    nil,
    sdl.WINDOWPOS_CENTERED,
    sdl.WINDOWPOS_CENTERED,
    window_width,
    window_height,
    sdl.WINDOW_BORDERLESS,
  )
  if window == nil {
    fmt.printf("Error creating SDL Window. \n")
    return false
  }

  renderer = sdl.CreateRenderer(window, -1, sdl.RENDERER_SOFTWARE)
  if renderer == nil {
    fmt.printf("Error creating SDL Renderer. \n")
    return false
  }

  return true
}

setup :: proc() {
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

update :: proc() {

}

render_color_buffer :: proc()
{
  //NOTE:
  //A rawptr is like a void * in C. A pointer to anything at all. So for a []T you'll want raw_data (or &thing[0], but that does a bounds check).
  sdl.UpdateTexture(
    color_buffer_texture,
    nil,
    &color_buffer[0],
    i32(window_width * size_of(u32))
  )

  sdl.RenderCopy(renderer, color_buffer_texture, nil, nil)
}

clear_color_buffer :: proc(color: u32) {
  for y in 0 ..< window_height {
    for x in 0 ..< window_width {
      color_buffer[(window_width * y) + x] = color
    }
  }
}

render :: proc() {
  sdl.SetRenderDrawColor(renderer, 222, 83, 7, 255)
  sdl.RenderClear(renderer)

  render_color_buffer()
  clear_color_buffer(0xFFFFFF00)

  sdl.RenderPresent(renderer)

}

destroy_window :: proc() {
  delete(color_buffer)

  sdl.DestroyRenderer(renderer)
  sdl.DestroyWindow(window)
  sdl.Quit()
}

main :: proc() {
  track: mem.Tracking_Allocator
  mem.tracking_allocator_init(&track, context.allocator)
  defer mem.tracking_allocator_destroy(&track)

  context.allocator = mem.tracking_allocator(&track)

  /////////////////////////////////////////////////////////
  is_running = initialize_window()

  setup()

  for is_running {
    process_input()
    update()
    render()
  }

  destroy_window()

  /////////////////////////////////////////////////////////
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
