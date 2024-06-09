package renderer

import "core:fmt"
import "core:mem"
import sdl "vendor:sdl2"

is_running : = false
window     : ^sdl.Window
renderer   : ^sdl.Renderer

//NOTE:
//- could later be changed to a static array
//- pointer to first element
color_buffer         : []u32
color_buffer_texture : ^sdl.Texture

window_width  : i32 = 800
window_height : i32 = 600

LIGHT_ORANGE :: 0xFDB750
DARK_ORANGE  :: 0xFD7F20
PINK         :: 0xFFFF00FF


initialize_window :: proc() -> bool {
  if sdl.Init(sdl.INIT_EVERYTHING) != 0 {
    fmt.printf("Error initializing SDL. \n")
    return false
  }

  //Use SDL to query what is the fullscreen max width and height
  display_mode : sdl.DisplayMode
  sdl.GetCurrentDisplayMode(0, &display_mode)

  window_width = i32( display_mode.w )
  window_height = i32( display_mode.h )

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

  //NOTE: Sets fullscreen app regardless of window height and width
  // sdl.SetWindowFullscreen(
  //   window,
  //   sdl.WINDOW_FULLSCREEN
  // )

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

draw_grid :: proc(COLOR : u32)
{
  //NOTE: basic naive grid implementation
  for y in 0 ..< window_height {
    for x in 0 ..< window_width {

      if y % 100 == 0 || x % 100 == 0
      {
        color_buffer[(window_width * y) + x] = COLOR
      }
    }
  }

  //NOTE: single for loop grid implementation
  // temp, row : i32
  // for i in 0 ..< window_width * window_height
  // {
  //   //horizontal lines calculators
  //   if i % window_width == 0
  //   {
  //     row += 1
  //     if row % 100 == 0
  //     {
  //       temp = row
  //     }
  //   }
  //
  //   if temp == row || i % 100 == 0
  //   {
  //     color_buffer[i] = COLOR
  //   }
  // }

  //NOTE: dotted grid implementation
  // for y :i32 = 0; y < window_height; y += 10 {
  //   for x :i32 = 0; x < window_width; x += 10 {
  //       color_buffer[(window_width * y) + x] = COLOR
  //   }
  // }
}

draw_rect :: proc(X, Y, W, H : i32, COLOR : u32, OUTLINE : bool)
{
  //NOTE: Gustavo
  for i in 0 ..< W {
    for j in 0 ..< H {
      current_x := X + i
      current_y := Y + j
      color_buffer[(window_width * current_y) + current_x] = COLOR
    }
  }

  //NOTE: mine
  // for y in 0 ..< window_height {
  //   for x in 0 ..< window_width {
  //
  //     if !OUTLINE 
  //     {
  //       if ( x >= X && x <= X + W ) && ( y >= Y && y <= Y + H)
  //       {
  //         color_buffer[(window_width * y) + x] = COLOR
  //       }
  //     }
  //     else 
  //     {
  //       //top line
  //       if ( x >= X && x <= X + W ) && y == Y
  //       {
  //         color_buffer[(window_width * y) + x] = COLOR
  //       }
  //       //bot line
  //       if ( x >= X && x <= X + W ) && y == Y + H
  //       {
  //         color_buffer[(window_width * y) + x] = COLOR
  //       }
  //       //left line
  //       if ( y >= Y && y <= Y + H ) && x == X 
  //       {
  //         color_buffer[(window_width * y) + x] = COLOR
  //       }
  //       // //right line
  //       if ( y >= Y && y <= Y + H ) && x == X + W
  //       {
  //         color_buffer[(window_width * y) + x] = COLOR
  //       }
  //     }
  //   }
  // }
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
  // for y in 0 ..< window_height {
  //   for x in 0 ..< window_width {
  //     color_buffer[(window_width * y) + x] = color
  //   }
  // }

  for i in 0 ..< window_width * window_height
  {
      color_buffer[i] = color
  }
}

render :: proc() {
  sdl.SetRenderDrawColor(renderer, 222, 83, 7, 255)
  sdl.RenderClear(renderer)

  draw_grid(PINK)

  draw_rect(600, 600, 200, 100, DARK_ORANGE, true)
  draw_rect(900, 600, 200, 200, LIGHT_ORANGE, false)

  render_color_buffer()
  clear_color_buffer(0xFF000000)

  sdl.RenderPresent(renderer)
}

destroy_window :: proc() {
  delete(color_buffer)
  sdl.DestroyTexture(color_buffer_texture)

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
