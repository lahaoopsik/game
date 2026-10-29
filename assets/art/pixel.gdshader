shader_type canvas_item;
uniform float source_step = 1.0;
uniform bool foliage = false;
uniform vec2 sun_direction = vec2(0.0, 1.0);
varying vec4 item_tint;
varying vec2 local_position;
void vertex() { item_tint = COLOR; local_position = VERTEX; }
void fragment() {
	vec2 pixel_uv = (floor(UV / TEXTURE_PIXEL_SIZE / source_step) * source_step + source_step * 0.5) * TEXTURE_PIXEL_SIZE;
	vec4 color = texture(TEXTURE, pixel_uv);
	color.rgb = clamp(color.rgb * vec3(1.02, 1.03, 1.01), vec3(0.0), vec3(1.0));
	float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	color.rgb = mix(vec3(luminance), color.rgb, 0.92);
	if (foliage) {
		vec2 crown_normal = normalize(vec2(local_position.x / 70.0, (local_position.y + 80.0) / 65.0) + vec2(0.001));
		float sunlight = 0.92 - dot(crown_normal, sun_direction) * 0.08;
		color.rgb *= sunlight;
	}
	color.rgb = floor(color.rgb * 24.0 + 0.5) / 24.0;
	COLOR = color * item_tint;
}
