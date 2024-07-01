package renderer

import "core:fmt"
import "core:math"
import sdl "vendor:sdl2"

/////////////////////////////////////////////////////////////////////
//                       VARIABLES                                 //
/////////////////////////////////////////////////////////////////////

FPS               : u32 : 60
FRAME_TARGET_TIME : u32 : (1000 / FPS)

window     : ^sdl.Window
renderer   : ^sdl.Renderer

//NOTE:
//- could later be changed to a static array
color_buffer         : []u32
color_buffer_texture : ^sdl.Texture

window_width  : i32 = 800
window_height : i32 = 600

/////////////////////////////////////////////////////////////////////
//                       PROCEDURES                                //
/////////////////////////////////////////////////////////////////////
initialize_window :: proc() -> bool
{
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

/////////////////////////////////////////////////////////////////////
draw_grid :: proc(COLOR : u32)
{
  //NOTE: basic naive grid implementation
  // for y in 0 ..< window_height {
  //   for x in 0 ..< window_width {
  //
  //     if y % 100 == 0 || x % 100 == 0
  //     {
  //       color_buffer[(window_width * y) + x] = COLOR
  //     }
  //   }
  // }

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
  for y :i32 = 0; y < window_height; y += 30 {
    for x :i32 = 0; x < window_width; x += 30 {
        color_buffer[(window_width * y) + x] = COLOR
    }
  }
}

/////////////////////////////////////////////////////////////////////
draw_pixel :: proc(X, Y : i32, COLOR : u32)
{
  if (X > window_width) || (Y > window_height) || (X <= 0) || (Y <= 0)
  {
    return
  }

  color_buffer[(window_width * Y) + X] = COLOR
}

draw_line :: proc(X0, Y0, X1, Y1 : i32, COLOR : u32)
{
    delta_x := (X1 - X0)
    delta_y := (Y1 - Y0)

    longest_side_length := ( math.abs(delta_x) >= math.abs(delta_y) ) ? math.abs(delta_x) : math.abs(delta_y)

    x_step : f32 = f32(delta_x) / f32(longest_side_length)
    y_step : f32 = f32(delta_y) / f32(longest_side_length)

    current_x : f32 = f32(X0)
    current_y : f32 = f32(Y0)
    for i in 0 ..= longest_side_length
    {
        draw_pixel(i32(math.round_f32(current_x)), i32(math.round_f32(current_y)), COLOR)
        current_x += x_step
        current_y += y_step
    }
}

/////////////////////////////////////////////////////////////////////
draw_rect :: proc(X, Y, W, H : i32, COLOR : u32, OUTLINE : bool)
{
  //NOTE: Gustavo
  for i in 0 ..< W {
    for j in 0 ..< H {
      current_x := X + i
      current_y := Y + j
      draw_pixel(current_x, current_y, COLOR)
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

draw_triangle :: proc(X0, Y0, X1, Y1, X2, Y2 : i32, COLOR : u32)
{
    draw_line(X0, Y0, X1, Y1, COLOR)
    draw_line(X1, Y1, X2, Y2, COLOR)
    draw_line(X2, Y2, X0, Y0, COLOR)
}

/////////////////////////////////////////////////////////////////////
render_color_buffer :: proc()
{
  //NOTE:
  //A rawptr is like a void * in C. A pointer to anything at all. So for a []T you'll want raw_data (or &thing[0], but that does a bounds check).
  sdl.UpdateTexture(
    color_buffer_texture,
    nil,
    &color_buffer[0],
    i32(window_width * size_of(u32)),
  )

  sdl.RenderCopy(renderer, color_buffer_texture, nil, nil)
}

/////////////////////////////////////////////////////////////////////
clear_color_buffer :: proc(color: u32)
{
  // for y in 0 ..< window_height {
  //   for x in 0 ..< window_width {
  //     color_buffer[(window_width * y) + x] = color
  //   }
  // }

  for i in 0 ..< window_width * window_height
  {
      color_buffer[i] = color
  }

  free_all(context.temp_allocator)
}

/////////////////////////////////////////////////////////////////////
destroy_window :: proc() {
  sdl.DestroyTexture(color_buffer_texture)

  sdl.DestroyRenderer(renderer)
  sdl.DestroyWindow(window)
  sdl.Quit()
}
