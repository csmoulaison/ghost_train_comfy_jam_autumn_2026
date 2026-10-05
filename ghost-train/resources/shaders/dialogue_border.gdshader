shader_type canvas_item;

// Procedural dialogue box: a dark blob with a glowing, drifting border, and an
// optional tiled pattern inside it.
// Drawn on a rect that is `padding` pixels bigger than the box on every side,
// so the glow has room to fade out before the rect ends. dialogue_panel.gd
// sets that rect up.

// Size of that rect in pixels. dialogue_panel.gd keeps this up to date.
uniform vec2 rect_size = vec2(800.0, 270.0);
uniform float padding = 40.0;
uniform float corner_radius = 56.0;

// Off draws a plain rounded box instead: no wobble, glow or ribbons, just a
// flat colour that the pattern and soft edge can still be applied to.
// dialogue_panel.gd sets all three of these.
uniform bool border_enabled = true;
uniform float plain_corner_radius = 12.0;
uniform vec4 plain_fill_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);

// Width in pixels of the fade at the edge of the box. dialogue_panel.gd sets
// this from its edge_softness export.
uniform float edge_softness = 0.0;

uniform vec4 fill_color : source_color = vec4(0.035, 0.03, 0.05, 0.9);
uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.22, 1.0);

// Optional image tiled across the fill at its own pixel size, so it repeats
// instead of stretching and is cut off by the box edge. dialogue_panel.gd
// sets the first three from its exports.
uniform sampler2D pattern_texture : source_color, repeat_enable, filter_linear_mipmap, hint_default_transparent;
uniform float pattern_opacity : hint_range(0.0, 1.0) = 0.1;
uniform float pattern_scale = 1.0;
// Drift in pixels per second.
uniform vec2 pattern_scroll = vec2(0.0);

uniform float glow_width = 14.0;
uniform float glow_strength : hint_range(0.0, 1.0) = 0.4;

// How far the edge bulges in and out, and how big each bulge is, in pixels.
uniform float wobble_amount = 10.0;
uniform float wobble_size = 150.0;
uniform float speed = 0.18;

uniform int ribbon_count : hint_range(0, 6) = 3;
uniform float ribbon_thickness = 0.8;
// How far the ribbons stray from the edge, in pixels.
uniform float ribbon_spread = 20.0;
// 0 lets every ribbon wander on its own, 1 pulls them all onto the box edge.
// dialogue_panel.gd sets this from its line_tightness export.
uniform float ribbon_tightness : hint_range(0.0, 1.0) = 0.5;
uniform float ribbon_brightness : hint_range(0.0, 1.0) = 0.6;

float hash(vec3 p) {
	p = fract(p * 0.3183099 + 0.1);
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float value_noise(vec3 x) {
	vec3 i = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(mix(hash(i), hash(i + vec3(1.0, 0.0, 0.0)), f.x),
			mix(hash(i + vec3(0.0, 1.0, 0.0)), hash(i + vec3(1.0, 1.0, 0.0)), f.x), f.y),
		mix(mix(hash(i + vec3(0.0, 0.0, 1.0)), hash(i + vec3(1.0, 0.0, 1.0)), f.x),
			mix(hash(i + vec3(0.0, 1.0, 1.0)), hash(i + vec3(1.0, 1.0, 1.0)), f.x), f.y),
		f.z);
}

// Two layers of noise, remapped to roughly -1..1.
float wobble(vec3 p) {
	float n = value_noise(p) * 0.65 + value_noise(p * 2.03 + 7.1) * 0.35;
	return n * 2.0 - 1.0;
}

// Distance to the edge of a rounded box: negative inside, positive outside.
float rounded_box(vec2 p, vec2 half_size, float radius) {
	vec2 q = abs(p) - half_size + radius;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

void fragment() {
	vec2 p = (UV - 0.5) * rect_size;
	vec2 half_size = rect_size * 0.5 - padding;
	float radius = min(border_enabled ? corner_radius : plain_corner_radius, min(half_size.x, half_size.y));
	float dist = rounded_box(p, half_size, radius);

	// Time is the third noise axis, so the shape morphs instead of sliding.
	float t = TIME * speed;
	vec2 noise_pos = p / wobble_size;

	float edge_offset = border_enabled ? wobble(vec3(noise_pos, t)) * wobble_amount : 0.0;
	float edge = dist + edge_offset;
	// Never thinner than 2 pixels, so the edge is at least anti-aliased.
	float feather = max(edge_softness, 2.0) * 0.5;
	float fill_mask = smoothstep(feather, -feather, edge);
	float glow = exp(-abs(edge) / glow_width) * glow_strength;

	float ribbons = 0.0;
	for (int i = 0; i < 6; i++) {
		if (i >= ribbon_count) {
			break;
		}
		float fi = float(i);
		vec3 ribbon_pos = vec3(noise_pos + vec2(fi * 13.7, fi * 5.3), t * (1.0 + fi * 0.35) + fi * 31.0);
		// Each ribbon also sits a little further in or out than the last, so
		// they don't all bunch up on the same line.
		float lane = (fi + 0.5) / float(ribbon_count) - 0.5;
		float ribbon_offset = mix((wobble(ribbon_pos) + lane) * ribbon_spread, edge_offset, ribbon_tightness);
		float ribbon_dist = abs(dist + ribbon_offset);
		ribbons += 1.0 - smoothstep(ribbon_thickness, ribbon_thickness + 1.5, ribbon_dist);
	}
	ribbons = clamp(ribbons, 0.0, 1.0) * ribbon_brightness;

	// Fade to nothing before the rect ends so the glow is never cut off.
	vec2 to_bounds = rect_size * 0.5 - abs(p);
	float bounds_fade = smoothstep(0.0, padding * 0.5, min(to_bounds.x, to_bounds.y));

	float glow_alpha = clamp(glow + ribbons, 0.0, 1.0) * glow_color.a * bounds_fade;
	vec3 glow_rgb = mix(glow_color.rgb, vec3(1.0), ribbons * 0.5);
	float fill_alpha = fill_color.a * fill_mask;

	vec2 pattern_size = vec2(textureSize(pattern_texture, 0)) * pattern_scale;
	vec4 pattern = texture(pattern_texture, (p + rect_size * 0.5 - TIME * pattern_scroll) / pattern_size);
	vec3 fill_rgb = mix(fill_color.rgb, pattern.rgb, pattern.a * pattern_opacity);

	// Glow drawn over the fill.
	float alpha = glow_alpha + fill_alpha * (1.0 - glow_alpha);
	vec3 rgb = (glow_rgb * glow_alpha + fill_rgb * fill_alpha * (1.0 - glow_alpha)) / max(alpha, 0.0001);
	if (!border_enabled) {
		// Pattern drawn over the plain fill.
		float pattern_alpha = pattern.a * pattern_opacity;
		alpha = pattern_alpha + plain_fill_color.a * (1.0 - pattern_alpha);
		rgb = (pattern.rgb * pattern_alpha + plain_fill_color.rgb * plain_fill_color.a * (1.0 - pattern_alpha)) / max(alpha, 0.0001);
		alpha *= fill_mask;
	}
	// COLOR arrives holding the node's modulate. Multiplying, rather than
	// replacing it, is what lets the box fade in and out with the panel.
	COLOR *= vec4(rgb, alpha);
}
