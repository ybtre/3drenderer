#pragma once

#include "triangle.h"
#include "vector.h"

#define N_CUBE_VERTICES 8
extern vec3 cube_vert[N_CUBE_VERTICES];

#define N_CUBE_FACES (6 * 2) //6 cube faces, 2 triangles per face
extern face cube_faces[N_CUBE_FACES];


typedef struct{
    vec3* vertices; //dynamic array of verts
    face* faces;    //dynamic array of faces
    vec3 rotation;
} mesh;

extern mesh MESH;

void load_cube_mesh_data(void);
void load_obj_file_data(char* filename);
