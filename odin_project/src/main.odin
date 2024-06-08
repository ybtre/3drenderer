package renderer

import "core:fmt"
import sdl "vendor:sdl2"

is_running : = false
window     : ^sdl.Window
renderer   : ^sdl.Renderer

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
    800, 600,
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

main :: proc()
{
  is_running = initialize_window();

  setup()

  for is_running
  {
    process_input();
    update();
    render();
  }

}
