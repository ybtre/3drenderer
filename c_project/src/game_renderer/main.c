#include "common.h"

#include "display.h"
#include "vector.h"

//9x9x9 cube
// Declare an array of vectors/points
// //
#define N_POINTS (9*9*9)
vec3 cube_points[N_POINTS];
vec2 projected_points[N_POINTS];

vec3 cam_position = { 0, 0, -5 };
vec3 cube_rotation = { 0, 0, 0 };

float fov_factor = 640;

bool is_running = false;

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

    // start loading arr of vectors
    // from -1 to 1
    int point_count = 0;
    vec3 new_point = {0,0,0};
    for (float x = -1; x <= 1; x+=.25f) {
        for (float y = -1; y <= 1; y+=.25f) {
            for (float z = -1; z <= 1; z+=.25f) {
                new_point.x = x;
                new_point.y = y;
                new_point.z = z;
                cube_points[point_count] = new_point;
                point_count += 1;
            }
        }
    }
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

void update(void) {
    cube_rotation.x += 0.005;
    cube_rotation.y += 0.005;
    cube_rotation.z += 0.005;

    for(int i = 0; i < N_POINTS; i++){
        vec3 point = cube_points[i];

        vec3 transformed_point = vec3_rotate_x(point, cube_rotation.x);
        transformed_point = vec3_rotate_y(transformed_point, cube_rotation.y);
        transformed_point = vec3_rotate_z(transformed_point, cube_rotation.z);

        //translate points away from camera
        transformed_point.z -= cam_position.z;

        //save the projects pont
        projected_points[i] = project(transformed_point);
    }
}

void render(void) {
    {
        draw_grid();

        //loop all projected points and render them
        for(int i = 0; i < N_POINTS; i++){
            vec2 proj_point = projected_points[i];
            draw_rect(
                proj_point.x + ((float)window_width / 2),
                proj_point.y + ((float)window_height / 2),
                4,
                4,
                0xFFFFFF00);
        }
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
