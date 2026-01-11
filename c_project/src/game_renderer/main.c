#include "common.h"

#include "display.h"
#include "vector.h"

//9x9x9 cube
// Declare an array of vectors/points
#define N_POINTS (9*9*9)
vec3 cube_points[N_POINTS];

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
    // TODO:
}

void render(void) {
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);

    draw_grid();

    draw_pixel(20, 20, 0xFFFFFFFF);

    draw_rect(100, 75, 50, 50, 0xFFFF00FF);
    draw_rect(200, 100, 50, 50, 0xFFFF00FF);

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
