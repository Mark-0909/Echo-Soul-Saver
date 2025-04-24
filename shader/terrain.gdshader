shader_type canvas_item;

uniform bool is_ghost = false;
uniform float spread_radius = 200.0;

void fragment() {
    vec4 input_color = texture(TEXTURE, UV);

    if (is_ghost) {
        // Dark bluish shade to blend with the original color
        vec3 dark_blue = vec3(0.1, 0.2, 0.4);  // Dark blue color
        
        // Blend the original color with the dark blue, using a factor
        float blend_factor = 0.3;  // You can adjust this value for more or less shading
        
        // Apply the dark blue shade without fully covering the texture
        input_color.rgb = mix(input_color.rgb, dark_blue, blend_factor);
    }

    COLOR = input_color;
}
