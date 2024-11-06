package renderer

light_t :: struct {
  direction : vec3,
}

light : light_t = { { 0, 0, 1 } }

light_apply_intensity :: proc(original_color : u32, percentage_factor : f32) -> u32
{
  perc := percentage_factor
  if perc < 0 
  {
    perc = 0
  }

  if perc > 1
  {
    perc = 1
  }

  //multiply percent by 100 and then cast to int in order to convert from float to int
  a : u32 = (original_color & 0xFF000000)
  r : u32 = (original_color & 0x00FF0000) * u32(perc * 100)
  g : u32 = (original_color & 0x0000FF00) * u32(perc * 100)
  b : u32 = (original_color & 0x000000FF) * u32(perc * 100)

  new_color : u32 = a | ( r & 0x00FF0000 ) | ( g & 0x0000FF00 ) | ( b & 0x000000FF )

  return new_color
}
