shader_type canvas_item;
uniform sampler2D control_map : filter_nearest, repeat_disable;
uniform sampler2D ground_atlas : source_color, filter_nearest, repeat_enable;
uniform sampler2D grass_texture : source_color, filter_nearest, repeat_enable;
uniform vec2 grid_size = vec2(50.0, 38.0);
uniform vec2 world_size = vec2(2400.0, 1800.0);
uniform vec2 sun_direction = vec2(-0.7, 0.7);

float type_at(vec2 cell) {
	return floor(texture(control_map, (clamp(cell, vec2(0.0), grid_size - 1.0) + 0.5) / grid_size).r * 255.0 + 0.5);
}
float height_at(vec2 cell) {
	return texture(control_map, (clamp(cell, vec2(0.0), grid_size - 1.0) + 0.5) / grid_size).g * 255.0 - 4.0;
}
vec4 ground(float kind, vec2 p) {
	if (kind < 0.5) {
		vec4 color = texture(grass_texture, fract(p / 420.0));
		color.rgb = mix(color.rgb * vec3(0.94, 1.18, 0.94), vec3(0.57, 0.80, 0.35), 0.16);
		return color;
	}
	if (kind > 6.5) {
		float ripple = step(0.92, sin(p.y * 0.12 - TIME * 1.2 + sin(p.x * 0.05)));
		return vec4(vec3(0.27, 0.70, 0.80) + ripple * 0.05, 1.0);
	}
	float index = kind - 1.0;
	vec2 tile = vec2(mod(index, 3.0), floor(index / 3.0));
	vec2 uv = (tile + 0.015 + fract(p / 150.0) * 0.97) / vec2(3.0, 2.0);
	vec4 earth = texture(ground_atlas, uv);
	earth.rgb *= vec3(1.08, 1.08, 1.04);
	return earth;
}
void fragment() {
	vec2 p = floor(UV * world_size / 3.0) * 3.0;
	vec2 cell = p / 48.0 - 0.5;
	vec2 origin = floor(cell);
	vec2 blend = smoothstep(vec2(0.24), vec2(0.76), fract(cell));
	vec4 a = mix(ground(type_at(origin), p), ground(type_at(origin + vec2(1.0, 0.0)), p), blend.x);
	vec4 b = mix(ground(type_at(origin + vec2(0.0, 1.0)), p), ground(type_at(origin + vec2(1.0, 1.0)), p), blend.x);
	vec4 color = mix(a, b, blend.y);
	vec2 slope = vec2(height_at(origin + vec2(1.0, 0.0)) - height_at(origin - vec2(1.0, 0.0)), height_at(origin + vec2(0.0, 1.0)) - height_at(origin - vec2(0.0, 1.0)));
	float relief_shade = clamp(1.0 - dot(slope, sun_direction) * 0.12, 0.78, 1.12);
	color.rgb *= relief_shade;
	COLOR = color;
}
