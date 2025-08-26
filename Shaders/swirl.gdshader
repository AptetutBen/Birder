shader_type spatial;
render_mode unshaded;

uniform float guruguru_power = 10.0;
uniform float vacuum_power = 0.1;
uniform float radius : hint_range(0.0, 4.0) = 0.8;

uniform float swirl_speed : hint_range(0.0, 10.0) = 1.0;
uniform float swirl_amplitude : hint_range(0.0, 10.0) = 2.0;

uniform sampler2D screen_tex : hint_screen_texture;

void fragment() {
	// Object origin in world space
	vec3 world_pos = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

	// Convert to view space
	vec4 center_view = VIEW_MATRIX * vec4(world_pos, 1.0);

	// Difference between fragment and object center
	vec2 diff = (normalize(-center_view.xyz).xy - VIEW.xy) * (-center_view.z);
	float to_center = length(diff);

	// Time-driven modulation
	float time_factor = sin(TIME * swirl_speed) * swirl_amplitude;

	// Compute swirl strength with smooth falloff
	float falloff = smoothstep(radius * 0.5, 0.0, to_center); 
	// 1 at center → 0 at edges
	float swirl_strength = falloff * (guruguru_power + time_factor);

	// Rotation matrix
	float c = cos(swirl_strength);
	float s = sin(swirl_strength);
	mat2 mat = mat2(vec2(c, s), vec2(-s, c));

	// Distorted UV
	vec2 swirl_uv = SCREEN_UV + (diff * vacuum_power) * mat;

	// Blend between normal UV and swirl UV using falloff
	vec2 final_uv = mix(SCREEN_UV, swirl_uv, falloff);

	// Sample screen texture
	vec3 col = texture(screen_tex, final_uv).rgb;

	ALBEDO = col;
}
