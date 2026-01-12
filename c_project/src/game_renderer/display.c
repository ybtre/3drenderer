#include "display.h"
#include "common.h"
#include <math.h>
#include <stdint.h>

SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
uint32_t* color_buffer = NULL;
SDL_Texture* color_buffer_texture = NULL;
int window_width = 640;
int window_height = 360;

bool initialize_window(void) {
    if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
        fprintf(stderr, "Error initializing SDL.\n");
        return false;
    }

    // Set width and height of the SDL window with the max screen resolution
    SDL_DisplayMode display_mode;
    SDL_GetCurrentDisplayMode(0, &display_mode);
    //use and overwrite window size to screen res
    window_width = display_mode.w;
    window_height = display_mode.h;

    // Create a SDL Window
    window = SDL_CreateWindow(
        NULL,
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        window_width,
        window_height,
        // SDL_WINDOW_BORDERLESS
        SDL_WINDOW_BORDERLESS | SDL_WINDOW_RESIZABLE | SDL_WINDOW_MOUSE_FOCUS | SDL_WINDOW_INPUT_FOCUS | SDL_WINDOW_MOUSE_GRABBED
    );
    if (!window) {
        fprintf(stderr, "Error creating SDL window.\n");
        return false;
    }

    // Create a SDL renderer
    renderer = SDL_CreateRenderer(window, -1, 0);
    if (!renderer) {
        fprintf(stderr, "Error creating SDL renderer.\n");
        return false;
    }

    return true;
}

void draw_grid(void) {
    for (int y = 0; y < window_height; y += 10) {
        for (int x = 0; x < window_width; x += 10) {
            color_buffer[(window_width * y) + x] = 0xFF444444;
        }
    }
}

void draw_rect(int x, int y, int width, int height, uint32_t color) {
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            int current_x = x + i;
            int current_y = y + j;
            draw_pixel(current_x, current_y, color);
        }
    }
}

void draw_pixel(int x, int y, uint32_t color) {
    if (x < window_width && x >= 0 && y < window_height && y >= 0){
        color_buffer[(window_width * y) + x] = color;
    }
}

void draw_line(int x0, int y0, int x1, int y1, uint32_t color){
    int delta_x = (x1-x0);
    int delta_y = (y1-y0);

    int longest_side_len = (abs(delta_x) >= abs(delta_y)) ? abs(delta_x) : abs(delta_y);

    float x_inc = (float)delta_x / (float)longest_side_len;
    float y_inc = (float)delta_y / (float)longest_side_len;

    float current_x = (float)x0;
    float current_y = (float)y0;
    for(int i = 0; i <= longest_side_len; i++){
        draw_pixel((int)round(current_x), (int)round(current_y), color);
        current_x += x_inc;
        current_y += y_inc;
    }
}

void draw_triangle_from_points(int x0, int y0, int x1, int y1, int x2, int y2, uint32_t color){
    draw_line(x0, y0, x1, y1, color);
    draw_line(x1, y1, x2, y2, color);
    draw_line(x2, y2, x0, y0, color);
}

void draw_triangle_from_triangle(triangle tri, uint32_t color){
    int x0 = (int)tri.points[0].x;
    int y0 = (int)tri.points[0].y;
    int x1 = (int)tri.points[1].x;
    int y1 = (int)tri.points[1].y;
    int x2 = (int)tri.points[2].x;
    int y2 = (int)tri.points[2].y;
    draw_line(x0, y0, x1, y1, color);
    draw_line(x1, y1, x2, y2, color);
    draw_line(x2, y2, x0, y0, color);
}

void render_color_buffer(void) {
    size_t bytes_per_row = (size_t)window_width * sizeof(int);
    int pitch = (int)bytes_per_row;
    SDL_UpdateTexture(
        color_buffer_texture,
        NULL,
        color_buffer,
        pitch
    );
    SDL_RenderCopy(renderer, color_buffer_texture, NULL, NULL);
}

void clear_color_buffer(uint32_t color) {
    for (int y = 0; y < window_height; y++) {
        for (int x = 0; x < window_width; x++) {
            color_buffer[(window_width * y) + x] = color;
        }
    }
}

void destroy_window(void) {
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}
