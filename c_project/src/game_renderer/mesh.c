#include <stdio.h>
#include <string.h>
#include "mesh.h"
#include "array.h"

mesh MESH = {
    .vertices = NULL,
    .faces = NULL,
    .rotation = { 0, 0, 0 },
    .scale = { 1.0f, 1.0f, 1.0f },
    .translation = { 0, 0, 0 }
};

//create impl for mesh.h functions
vec3 cube_vert[N_CUBE_VERTICES] = {
    { .x = -1, .y = -1, .z = -1 }, //1
    { .x = -1, .y =  1, .z = -1 }, //2
    { .x =  1, .y =  1, .z = -1 }, //3
    { .x =  1, .y = -1, .z = -1 }, //4
    { .x =  1, .y =  1, .z =  1 }, //5
    { .x =  1, .y = -1, .z =  1 }, //6
    { .x = -1, .y =  1, .z =  1 }, //7
    { .x = -1, .y = -1, .z =  1 } //8
};

face cube_faces[N_CUBE_FACES] = {
    //front
    { .a = 1, .b = 2, .c = 3 },
    { .a = 1, .b = 3, .c = 4 },
    //right
    { .a = 4, .b = 3, .c = 5 },
    { .a = 4, .b = 5, .c = 6 },
    //back
    { .a = 6, .b = 5, .c = 7 },
    { .a = 6, .b = 7, .c = 8 },
    //left
    { .a = 8, .b = 7, .c = 2 },
    { .a = 8, .b = 2, .c = 1 },
    //top
    { .a = 2, .b = 7, .c = 5 },
    { .a = 2, .b = 5, .c = 3 },
    //bottom
    { .a = 6, .b = 8, .c = 1 },
    { .a = 6, .b = 1, .c = 4 },
};

void load_cube_mesh_data(void){
    for(int i = 0; i < N_CUBE_VERTICES; i++){
        array_push(MESH.vertices, cube_vert[i]);
    }
    for(int i = 0; i < N_CUBE_FACES; i++){
        array_push(MESH.faces, cube_faces[i]);
    }
}

void load_obj_file_data(char* filename){
    FILE* file;
    file = fopen(filename, "r");

    int max_file_lines = 1024;
    char line[max_file_lines];
    while(fgets(line, max_file_lines, file)){
        //vertex info
        if(strncmp(line, "v ", 2) == 0){
            vec3 vertex;
            sscanf_s(line, "v %f %f %f", &vertex.x, &vertex.y, &vertex.z);
            array_push(MESH.vertices, vertex);
        }
        //face info
        if(strncmp(line, "f ", 2) == 0){
            int vertex_indices[3];
            int texture_indices[3];
            int normal_indices[3];
            sscanf(
                line, "f %d/%d/%d %d/%d/%d %d/%d/%d",
                &vertex_indices[0], &texture_indices[0], &normal_indices[0],
                &vertex_indices[1], &texture_indices[1], &normal_indices[1],
                &vertex_indices[2], &texture_indices[2], &normal_indices[2]
            );
            face f = {
                .a = vertex_indices[0],
                .b = vertex_indices[1],
                .c = vertex_indices[2]
            };
            array_push(MESH.faces, f);
        }
    }
    fclose(file);
}
