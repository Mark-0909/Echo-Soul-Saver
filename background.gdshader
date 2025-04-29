shader_type canvas_item;

void fragment() {
	// Get the current texture color
	vec4 color = texture(TEXTURE, UV);
	
	// Darken it by multiplying RGB channels
	color.rgb *= 0.3; // Change 0.3 to a value between 0.0 (black) and 1.0 (original brightness)

	COLOR = color;
}
