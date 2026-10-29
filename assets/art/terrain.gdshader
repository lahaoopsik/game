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
		float patch = sin(p.x * 0.006) * sin(p.y * 0.004) * 0.018;
		vec3 turf = vec3(0.36, 0.65, 0.28) + patch;
		vec2 pixel = floor(p / 4.0);
		float grain = step(47.0, mod(pixel.x * 7.0 + pixel.y * 13.0, 51.0));
		return vec4(turf + grain * vec3(0.025, 0.03, 0.012), 1.0);
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
	vec2 p = floor(UV * world_size / 2.0) * 2.0;
	// Continuous neighbour mask; only the contact rim blends, texture pixels stay crisp.
	vec2 warp = vec2(sin(p.y*0.083)+sin(p.y*0.031),cos(p.x*0.071)+sin(p.x*0.027))*0.055;
	vec2 cell = p / 48.0 - 0.5 + warp;
	vec2 origin = floor(cell);
	vec2 blend = smoothstep(vec2(0.20),vec2(0.80),fract(cell));
	vec4 a = mix(ground(type_at(origin),p),ground(type_at(origin+vec2(1,0)),p),blend.x);
	vec4 b = mix(ground(type_at(origin+vec2(0,1)),p),ground(type_at(origin+vec2(1,1)),p),blend.x);
	vec4 color = mix(a,b,blend.y);
	vec2 slope = vec2(height_at(origin + vec2(1.0, 0.0)) - height_at(origin - vec2(1.0, 0.0)), height_at(origin + vec2(0.0, 1.0)) - height_at(origin - vec2(0.0, 1.0)));
	float relief_shade = clamp(1.0 - dot(slope, sun_direction) * 0.12, 0.78, 1.12);
	color.rgb *= relief_shade;
	COLOR = color;
}
