package renderer

import "core:mem"
import "core:fmt"
import sdl "vendor:sdl2"

window_width  :: 800
window_height :: 600

is_running : = false
window     : ^sdl.Window
renderer   : ^sdl.Renderer
//NOTE: 
//- could later be changed to a static array
//- pointer to first element
color_buffer : ^u32


initialize_window :: proc() -> bool
{
  if sdl.Init(sdl.INIT_EVERYTHING) != 0
  {
    fmt.printf("Error initializing SDL. \n")
    return false
  }

  window = sdl.CreateWindow(
    nil,
    sdl.WINDOWPOS_CENTERED,
    sdl.WINDOWPOS_CENTERED,
    window_width, 
    window_height,
    sdl.WINDOW_BORDERLESS
  )
  if window == nil
  {
    fmt.printf("Error creating SDL Window. \n")
    return false
  }

  renderer = sdl.CreateRenderer(
    window,
    -1,
    sdl.RENDERER_SOFTWARE
  )
  if renderer == nil
  {
    fmt.printf("Error creating SDL Renderer. \n")
    return false
  }
  
  return true
}

setup :: proc()
{
  //NOTE:
  //- [^]u32 is a like a c style array, with a pointer to the first element and unknown length
  //- []u32 is an odin slice. Under the hood it's a struct with a length and a pointer to the data.
  color_buffer = make([^]u32, window_width * window_height)
}

process_input :: proc()
{
  event : sdl.Event

  for sdl.PollEvent(&event)
  {
    #partial switch event.type
    {
    case sdl.EventType.QUIT:
      {
        is_running = false;
      }
    case sdl.EventType.KEYDOWN:
      {
        if event.key.keysym.sym == sdl.Keycode.ESCAPE
        {
          is_running = false
        }
      }
    }
  }
}

update :: proc()
{

}

render :: proc()
{
  sdl.SetRenderDrawColor(renderer, 222, 83, 7, 255)
  sdl.RenderClear(renderer)

  sdl.RenderPresent(renderer)

}

destroy_window :: proc()
{
  free(color_buffer)

  sdl.DestroyRenderer(renderer)
  sdl.DestroyWindow(window)
  sdl.Quit()
}

main :: proc()
{
  track : mem.Tracking_Allocator
  mem.tracking_allocator_init(&track, context.allocator)
  defer mem.tracking_allocator_destroy(&track)

  context.allocator = mem.tracking_allocator(&track)

  /////////////////////////////////////////////////////////
  is_running = initialize_window();

  setup()

  for is_running
  {
    process_input();
    update();
    render();
  }

  destroy_window()

  /////////////////////////////////////////////////////////
  for _, leak in track.allocation_map {
      fmt.printf("%v leaked %m\n", leak.location, leak.size)
  }
  for bad_free in track.bad_free_array {
      fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
  }

}
