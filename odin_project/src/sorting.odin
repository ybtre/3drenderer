package renderer

import "core:fmt"


swap :: proc(ARR : ^[dynamic]triangle_t, i, j : int)
{
  temp := ARR[i]
  ARR[i] = ARR[j]
  ARR[j] = temp
}

partition :: proc(ARR : ^[dynamic]triangle_t, LOW, HIGH : int) -> int
{
  pivot := ARR[HIGH].avg_depth

  //index of smaller elements and indicates
  // the right position of pivot found so far
  i := LOW - 1

  for j := LOW; j <= HIGH - 1; j += 1
  {
    //if current ele is smalller than the pivot
    if ARR[j].avg_depth < pivot
    {
      swaps += 1
      //increment index of smaller ele
      i+=1
      swap(ARR, i, j)
    }
  }
  swap(ARR, i + 1, HIGH)
  return (i + 1)
}

//The Main function that implements quicksort
//ARR --> array to be sorted
//LOW --> starting index
//HIGH --> ending index
quicksort :: proc(ARR : ^[dynamic]triangle_t, LOW, HIGH : int)
{
  if (LOW < HIGH)
  {
    //pi is partitioning index, arr[p] is now at right palce
    pi := partition(ARR, LOW, HIGH)

    //separately sort elements beofre and after partition index
    quicksort(ARR, LOW, pi - 1)
    quicksort(ARR, pi + 1, HIGH)
  }
}

bubblesort :: proc(ARR : ^[dynamic]triangle_t)
{
  i       : int
  j       : int
  temp    : triangle_t
  swapped : bool

  len     := len(ARR)
  for i = 0; i < len - 1; i += 1
  {
    swapped = false
    for j = 0; j < len - i - 1; j += 1
    {
      if ARR[j].avg_depth > ARR[j + 1].avg_depth
      {
        //swap arr[j] and arr[j + 1]
        temp = ARR[j]
        ARR[j] = ARR[j + 1]
        ARR[j + 1] = temp
        swapped = true

        swaps += 1
      }
    }

    //if no two elements were swapped by inner loop then break
    if !swapped
    {
      break
    }
  }
}
