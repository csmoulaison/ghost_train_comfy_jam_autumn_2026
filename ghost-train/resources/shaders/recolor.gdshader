shader_type canvas_item;

// Repaints an image in one colour, keeping its shape (its transparency).
// recolor_texture_rect.gd sets both of these.

uniform vec4 recolor : source_color = vec4(1.0);
// 0 leaves the image as it is, 1 replaces its colours completely.
uniform float amount : hint_range(0.0, 1.0) = 1.0;

varying vec4 modulate;

void vertex() {
	// Keep the node's modulate, so fades and tints from parents still work.
	modulate = COLOR;
}

void fragment() {
	vec4 image = texture(TEXTURE, UV);
	COLOR = vec4(mix(image.rgb, recolor.rgb, amount), image.a * recolor.a) * modulate;
}
