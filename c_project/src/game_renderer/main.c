#include "common.h"

#include "display.h"
#include "vector.h"
#include "mesh.h"

triangle triangles_to_render[N_MESH_FACES];

vec3 cam_position = { 0, 0, -5 };
vec3 cube_rotation = { 0, 0, 0 };

float fov_factor = 640;

bool is_running = false;
int previous_frame_time = 0;

void setup(void) {
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
            break;
    }
}

void update_cube(){
    cube_rotation.x += 0.005;
    cube_rotation.y += 0.005;
    cube_rotation.z += 0.005;

    for(int i = 0; i < N_MESH_FACES; i++)
    {
        face mesh_face  = mesh_faces[i];

        vec3 face_verts[3];
        face_verts[0] = mesh_vert[mesh_face.a - 1];
        face_verts[1] = mesh_vert[mesh_face.b - 1];
        face_verts[2] = mesh_vert[mesh_face.c - 1];

        triangle projected_triangle;

        //loop all 3 verts of this current face and apply transformations
        for(int j = 0; j < 3; j++){
            vec3 transformed_vertex = face_verts[j];

            //apply rotation
            transformed_vertex = vec3_rotate_x(transformed_vertex, cube_rotation.x);
            transformed_vertex = vec3_rotate_y(transformed_vertex, cube_rotation.y);
            transformed_vertex = vec3_rotate_z(transformed_vertex, cube_rotation.z);

            //apply translation away from cam
            transformed_vertex.z -= cam_position.z;

            vec2 projected_point = project(transformed_vertex);

            //scale and translare proj point to the middle of the screen
            projected_point.x += ((float)window_width / 2);
            projected_point.y += ((float)window_height /2);

            projected_triangle.points[j] = projected_point;
        }

        //save the projected triangle in the array of triangles to render
        triangles_to_render[i] = projected_triangle;
    }
}

void fixed_time_step(void){
    int time_to_wait = FRAME_TARGET_TIME - (SDL_GetTicks64() - previous_frame_time);

    if(time_to_wait > 0 && time_to_wait <= FRAME_TARGET_TIME){
        SDL_Delay(time_to_wait);
    }

    previous_frame_time = SDL_GetTicks64();
}

void update(void) {
    fixed_time_step();

    update_cube();
}

void render_cube(void){
    //loop all projected triangles and render them
    for(int i = 0; i < N_MESH_FACES; i++){
        triangle triangle = triangles_to_render[i];
        draw_rect(triangle.points[0].x, triangle.points[0].y, 4, 4, 0xFFFFFF00);
        draw_rect(triangle.points[1].x, triangle.points[1].y, 4, 4, 0xFFFFFF00);
        draw_rect(triangle.points[2].x, triangle.points[2].y, 4, 4, 0xFFFFFF00);
    }
}

void render(void) {
    {
        draw_grid();

        render_cube();
    }

    render_color_buffer();
    clear_color_buffer(0xFF000000);

    SDL_RenderPresent(renderer);
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

    return 0;
}
