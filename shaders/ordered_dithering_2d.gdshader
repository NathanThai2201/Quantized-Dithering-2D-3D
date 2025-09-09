shader_type canvas_item;

const mat4 bayer_matrix_4x4 = mat4(
    vec4(-0.5,    0.0,   -0.375,  0.125),
    vec4(0.25,   -0.25,   0.375, -0.125),
    vec4(-0.3125, 0.1875, -0.4375, 0.0625),
    vec4(0.4375, -0.0625, 0.3125, -0.1875)
);

const vec3 COLOR_PALETTE[29] = vec3[](
    vec3(0.949, 0.941, 0.898), // #f2f0e5
    vec3(0.722, 0.710, 0.725), // #b8b5b9
    vec3(0.525, 0.506, 0.533), // #868188
    vec3(0.392, 0.388, 0.396), // #646365
    vec3(0.271, 0.267, 0.310), // #45444f
    vec3(0.227, 0.220, 0.345), // #3a3858
    vec3(0.129, 0.129, 0.137), // #212123
    vec3(0.208, 0.169, 0.259), // #352b42
    vec3(0.263, 0.263, 0.416), // #43436a
    vec3(0.294, 0.502, 0.792), // #4b80ca
    vec3(0.408, 0.761, 0.827), // #68c2d3
    vec3(0.635, 0.863, 0.780), // #a2dcc7
    vec3(0.929, 0.882, 0.620), // #ede19e
    vec3(0.827, 0.627, 0.408), // #d3a068
    vec3(0.706, 0.322, 0.322), // #b45252
    vec3(0.416, 0.325, 0.431), // #6a536e
    vec3(0.294, 0.255, 0.345), // #4b4158
    vec3(0.502, 0.286, 0.227), // #80493a
    vec3(0.655, 0.482, 0.357), // #a77b5b
    vec3(0.898, 0.808, 0.706), // #e5ceb4
    vec3(0.761, 0.827, 0.408), // #c2d368
    vec3(0.541, 0.690, 0.376), // #8ab060
    vec3(0.337, 0.482, 0.475), // #567b79
    vec3(0.306, 0.345, 0.290), // #4e584a
    vec3(0.482, 0.447, 0.263), // #7b7243
    vec3(0.698, 0.706, 0.494), // #b2b47e
    vec3(0.929, 0.784, 0.769), // #edc8c4
    vec3(0.812, 0.541, 0.796), // #cf8acb
    vec3(0.373, 0.333, 0.416)  // #5f556a
);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

group_uniforms Controls;
uniform float mix_amount : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float spread : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform int block_size : hint_range(1, 16, 1) = 4;
group_uniforms;

vec3 get_nearest_color(vec3 color) {
    float min_diff = 1e6;
    vec3 nearest_color = color;
    for (int i = 0; i < COLOR_PALETTE.length(); i++) {
        float curr_dist = distance(COLOR_PALETTE[i], color);
        if (curr_dist < min_diff) {
            min_diff = curr_dist;
            nearest_color = COLOR_PALETTE[i];
        }
    }
    return nearest_color;
}

void fragment() {
	
    vec2 block_coord = floor(FRAGCOORD.xy / float(block_size));

    vec2 block_origin = block_coord * float(block_size);

    // Screen size
    vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0));

    vec2 uv = block_origin / screen_size;
    vec4 original_sc = texture(SCREEN_TEXTURE, uv);

    int x = int(mod(block_coord.x, 4.0));
    int y = int(mod(block_coord.y, 4.0));
    float threshold = bayer_matrix_4x4[y][x] / 16.0;

    vec3 perturbed = original_sc.rgb + spread * (threshold - 0.5);

    vec3 nearest_color = get_nearest_color(perturbed);

    vec3 final_sc = mix(original_sc.rgb, nearest_color, mix_amount);

    COLOR = vec4(final_sc, 1.0);
}
