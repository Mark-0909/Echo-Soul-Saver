shader_type canvas_item;

uniform bool is_ghost = false;
uniform float spread_radius = 200.0;

void fragment() {
    vec4 input_color = texture(TEXTURE, UV);

    if (is_ghost) {
        // A very subtle dark blue tint
        vec3 dark_blue = vec3(0.1, 0.2, 0.4);
        float blend_factor = 0.1; // Less intense blend

        input_color.rgb = mix(input_color.rgb, dark_blue, blend_factor);
    }

    COLOR = input_color;
}
