#pragma once

#include "triangle.h"
#include "vector.h"

#define N_MESH_VERTICES 8
extern vec3 mesh_vert[N_MESH_VERTICES];

#define N_MESH_FACES (6 * 2) //6 cube faces, 2 triangles per face
extern face mesh_faces[N_MESH_FACES];
