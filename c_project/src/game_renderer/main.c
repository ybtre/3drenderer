#include "common.h"

#include "display.h"
#include "matrix.h"
#include "triangle.h"
#include "vector.h"
#include "mesh.h"
#include "array.h"
#include <stdio.h>

triangle* triangles_to_render = NULL;

//////////////////////////////////////////////////////////////////////////////////////////////////
// Global vars for execution status and game loop
//////////////////////////////////////////////////////////////////////////////////////////////////
bool is_running = false;
Uint64 previous_frame_time = 0;

vec3 cam_position = { 0, 0, 0 };

float fov_factor = 640;

enum cull_method{
    CULL_NONE,
    CULL_BACKFACE
} cull_method;

enum render_method{
    RENDER_WIRE,
    RENDER_WIRE_VERTEX,
    RENDER_FILL_TRIANGLE,
    RENDER_FILL_TRIANGLE_WIRE
} render_method;

//////////////////////////////////////////////////////////////////////////////////////////////////
//FPS Counter related
////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct {
    Uint32 last_time;
    Uint32 frame_count;
    float fps;
    float dt;
    SDL_Renderer* renderer;
} FPSCounter;

void FPSCounter_init(FPSCounter* counter){
    counter->last_time = 0;
    counter->frame_count = 0;
    counter->fps = 0.0f;
    counter->dt = 0.0f;
}

void FPSCounter_update(FPSCounter* counter){
    Uint32 current_time = SDL_GetTicks();
    Uint32 frame_time = current_time - counter->last_time;

    if(frame_time > 0){
        counter->dt = (float)frame_time / 1000.0f;
        counter->fps = 1.0f / counter->dt;
    }

    counter->last_time = current_time;
    counter->frame_count++;

    // Print to console only
    printf("FPS: %.1f | Delta: %.3f\r", counter->fps, counter->dt);
    fflush(stdout);
}

FPSCounter fps_counter;
//////////////////////////////////////////////////////////////////////////////////////////////////

void setup(void) {
    render_method = RENDER_WIRE;
    cull_method = CULL_BACKFACE;

    // Allocate the required memory in bytes to hold the color buffer
    color_buffer = malloc((size_t)window_width * (size_t)window_height * sizeof *color_buffer);
    ASSERTIF(!color_buffer, "Could not malloc color_buffer.\n");

    // Creating a SDL texture that is used to display the color buffer
    color_buffer_texture = SDL_CreateTexture(
        renderer,
        SDL_PIXELFORMAT_ARGB8888,
        SDL_TEXTUREACCESS_STREAMING,
        window_width,
        window_height
    );

    FPSCounter_init(&fps_counter);

    //
    // load_cube_mesh_data();
    load_obj_file_data("./assets/cube.obj");
    // load_obj_file_data("./assets/castle.obj");
    // load_obj_file_data("./assets/well.obj");
    // load_obj_file_data("./assets/f22.obj");
}

//received vec3 and returns projected 2d point
vec2 project (vec3 point){
    vec2 projected_point =
    {
        .x = (fov_factor * point.x) / point.z,
        .y = (fov_factor * point.y) / point.z
    };
    return projected_point;
}

void process_input(void) {
    SDL_Event event;
    SDL_PollEvent(&event);

    switch (event.type) {
        case SDL_QUIT:
            is_running = false;
            break;
        case SDL_KEYDOWN:
            if (event.key.keysym.sym == SDLK_ESCAPE)
                is_running = false;
            if (event.key.keysym.sym == SDLK_1)
                render_method = RENDER_WIRE_VERTEX;
            if (event.key.keysym.sym == SDLK_2)
                render_method = RENDER_WIRE;
            if (event.key.keysym.sym == SDLK_3)
                render_method = RENDER_FILL_TRIANGLE;
            if (event.key.keysym.sym == SDLK_4)
                render_method = RENDER_FILL_TRIANGLE_WIRE;
            if (event.key.keysym.sym == SDLK_c)
                cull_method = CULL_BACKFACE;
            if (event.key.keysym.sym == SDLK_d)
                cull_method = CULL_NONE;
            break;
    }
}

void update_mesh(){
    MESH.rotation.x += 0.005f;
    MESH.rotation.y += 0.005f;
    MESH.rotation.z += 0.005f;

    MESH.scale.x += 0.0008f;
    MESH.scale.y += 0.0008f;

    MESH.translation.x += 0.005f;
    MESH.translation.y += 0.001f;
    MESH.translation.z = -3;

    mat4_t scale_martix = mat4_make_scale(MESH.scale.x, MESH.scale.y, MESH.scale.z);
    mat4_t translation_matrix = mat4_make_translation(MESH.translation.x, MESH.translation.y, MESH.translation.z);
    mat4_t rotation_matrix_x = mat4_make_rotation_x(MESH.rotation.x);
    mat4_t rotation_matrix_y = mat4_make_rotation_y(MESH.rotation.y);
    mat4_t rotation_matrix_z = mat4_make_rotation_z(MESH.rotation.z);


    //init arr of triangles to render
    triangles_to_render = NULL;

    int num_faces = array_length(MESH.faces);
    for(int i = 0; i < num_faces; i++)
    {
        face mesh_face  = MESH.faces[i];

        vec3 face_verts[3];
        face_verts[0] = MESH.vertices[mesh_face.a - 1];
        face_verts[1] = MESH.vertices[mesh_face.b - 1];
        face_verts[2] = MESH.vertices[mesh_face.c - 1];

        vec4 transformed_vertices[3];

        //loop all 3 verts of this current face and apply transformations
        for(int j = 0; j < 3; j++){
            vec4 transformed_vertex = vec4_from_vec3(face_verts[j]);

            mat4_t world_matrix = mat4_identity();
            //multiply world matrix by scale, rotation and translation matricies
            world_matrix = mat4_mul_mat4(scale_martix, world_matrix);

            world_matrix = mat4_mul_mat4(rotation_matrix_z, world_matrix);
            world_matrix = mat4_mul_mat4(rotation_matrix_y, world_matrix);
            world_matrix = mat4_mul_mat4(rotation_matrix_x, world_matrix);

            world_matrix = mat4_mul_mat4(translation_matrix, world_matrix);

            //multiply the world matrix by the original vector
            transformed_vertex = mat4_mul_vec4(world_matrix, transformed_vertex);

            //save transformed vertex in the array of transformed vertices
            transformed_vertices[j] = transformed_vertex;
        }

        if(cull_method == CULL_BACKFACE)
        {
            //check backface culling
            vec3 vector_a = vec3_from_vec4(transformed_vertices[0]);    /*   A      */
            vec3 vector_b = vec3_from_vec4(transformed_vertices[1]);    /*  / \     */
            vec3 vector_c = vec3_from_vec4(transformed_vertices[2]);    /* C---B    */

            //get the vector subtraction of B-A and C-A
            vec3 vector_ab = vec3_sub(vector_b, vector_a);
            vec3 vector_ac = vec3_sub(vector_c, vector_a);

            //compute the face normal (using cross product to find perpendicular)
            vec3 normal = vec3_cross(vector_ab, vector_ac);
            //normalize the normal vector
            vec3_normalize(&normal);

            //find the vector between a point in the triangle and the camera origin
            vec3 camera_ray = vec3_sub(cam_position, vector_a);

            //calculate how aligned the camera ray is with the face normal using dot product
            float dot_normal_camera = vec3_dot(normal, camera_ray);

            //bypass the triangles that are looking away from the camera
            if(dot_normal_camera < 0){
                continue;
            }
        }

        triangle projected_triangle;

        //loop all 3 verts and perform projection
        for(int j = 0; j < 3; j++){
            vec2 projected_point = project(vec3_from_vec4(transformed_vertices[j]));

            //scale and translare proj point to the middle of the screen
            projected_point.x += ((float)window_width / 2);
            projected_point.y += ((float)window_height /2);

            //calculate the average depth for each face based on the vertices after transformation z value
            float avg_depth = (transformed_vertices[0].z + transformed_vertices[1].z + transformed_vertices[2].z) / 3;

            projected_triangle.points[j] = projected_point;
            projected_triangle.color = mesh_face.color;
            projected_triangle.avg_depth = avg_depth;
        }

        //save the projected triangle in the array of triangles to render
        array_push(triangles_to_render, projected_triangle)
    }

    //sort triangles to render by their avg depth
    int num_triangles = array_length(triangles_to_render);
    for(int i = 0; i < num_triangles; i++){
        for(int j = 0; j < num_triangles; j++){
            if(triangles_to_render[i].avg_depth < triangles_to_render[j].avg_depth){
                triangle temp = triangles_to_render[i];
                triangles_to_render[i] = triangles_to_render[j];
                triangles_to_render[j] = temp;
            }
        }
    }
}

void fixed_time_step(void){
    Uint64 current_time = SDL_GetTicks64();
    Uint64 elapsed_time = current_time - previous_frame_time;
    Uint64 time_to_wait = (Uint64)FRAME_TARGET_TIME - elapsed_time;

    Uint32 delay_time = (Uint32)(time_to_wait > INT_MAX ? INT_MAX : time_to_wait);
    if (delay_time > 0 && delay_time <= FRAME_TARGET_TIME) {
        // SDL_Delay(delay_time);
    }

    previous_frame_time = SDL_GetTicks64();
}

void update(void) {
    fixed_time_step();

    FPSCounter_update(&fps_counter);

    update_mesh();
}

void render_mesh(void){
    //loop all projected triangles and render them
    int num_triangles = array_length(triangles_to_render);
    for(int i = 0; i < num_triangles; i++){
        triangle tri = triangles_to_render[i];

        //draw filled triangle face
        if(render_method == RENDER_FILL_TRIANGLE || render_method == RENDER_FILL_TRIANGLE_WIRE)
        {
            draw_filled_triangle_from_triangle(tri, 0xFF555555);
        }

        //draw unfilled triangle face
        if(render_method == RENDER_WIRE || render_method == RENDER_WIRE_VERTEX || render_method == RENDER_FILL_TRIANGLE_WIRE)
        {
            draw_triangle_from_triangle(tri, 0xFFFFFFFF);
        }

        //draw vertex points
        if(render_method == RENDER_WIRE_VERTEX)
        {
            draw_rect((int)tri.points[0].x - 3, (int)tri.points[0].y - 3, 6, 6, 0xFFFF0000);
            draw_rect((int)tri.points[1].x - 3, (int)tri.points[1].y - 3, 6, 6, 0xFFFF0000);
            draw_rect((int)tri.points[2].x - 3, (int)tri.points[2].y - 3, 6, 6, 0xFFFF0000);
        }
    }
}

void render(void) {
    {
        draw_grid();

        render_mesh();

        // triangle tr = {
        //     300, 100, 50, 400, 500, 700
        // };
        // draw_filled_triangle_from_triangle(tr, 0xFFFF0000);
    }

    //clear arr triangles to render every frame loop
    array_free(triangles_to_render);

    render_color_buffer();
    clear_color_buffer(0xFF000000);

    SDL_RenderPresent(renderer);
}


void free_resources(void){
   free(color_buffer);
   array_free(MESH.faces);
   array_free(MESH.vertices);

   color_buffer = NULL;
   MESH.faces = NULL;
   MESH.vertices = NULL;
}

int main(int argc, char* argv[])
{
    //mark as unused to silence error
    (void)argc;
    (void)argv;

    is_running = initialize_window();

    setup();

    while (is_running) {
        process_input();
        update();
        render();
    }

    destroy_window();
    free_resources();

    return 0;
}
