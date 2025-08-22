shader_type spatial;
render_mode unshaded;

uniform sampler2D texture_albedo;
uniform sampler2D distortion_map; // normal map for lens imperfections

uniform float distortion_strength : hint_range(-2.0, 2.0) = 0.5;  // radial distortion
uniform float normal_strength : hint_range(0.0, 0.1) = 0.02;     // normal map strength
uniform float chromatic_offset : hint_range(0.0, 0.05) = 0.005;  // max offset at edge

// Vignette controls
uniform float vignette_strength : hint_range(0.0, 5.0) = 0.5;
uniform float vignette_blur : hint_range(0.0, 1.0) = 0.3;

// --- sRGB → Linear conversion for SubViewport textures ---
vec3 srgb_to_linear(vec3 c) {
	return pow(c, vec3(2.2));
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);

	// --- Normal map distortion ---
	vec3 n = texture(distortion_map, UV).rgb;
	vec2 normal_offset = (n.xy - 0.5) * 2.0 * normal_strength;
	vec2 distorted_uv = UV + normal_offset;

	// --- Radial distortion ---
	vec2 dir = distorted_uv - vec2(0.5);
	float radial_dist = length(dir);
	distorted_uv = vec2(0.5) + dir * (1.0 + radial_dist * distortion_strength);

	// --- If distorted UVs are outside [0,1], draw black ---
	if (distorted_uv.x < 0.0 || distorted_uv.x > 1.0 ||
		distorted_uv.y < 0.0 || distorted_uv.y > 1.0) {
		ALBEDO = vec3(0.0);
		ALPHA = 1.0;
	} else {
		// --- Distance-based chromatic aberration ---
		float edge_factor = dist / 0.707; // 0 at center, 1 at corner
		vec2 chroma_offset_scaled = vec2(chromatic_offset) * edge_factor;

		float r = texture(texture_albedo, distorted_uv + vec2(chroma_offset_scaled.x, 0.0)).r;
		float g = texture(texture_albedo, distorted_uv).g;
		float b = texture(texture_albedo, distorted_uv - vec2(chroma_offset_scaled.x, 0.0)).b;

		vec4 col = vec4(r, g, b, 1.0);

		// --- Vignette ---
		float max_dist = 0.707;
		float vignette = smoothstep(max_dist - vignette_blur, max_dist, dist);
		vignette = 1.0 - vignette * vignette_strength;
		col.rgb *= vignette;

		// --- Convert sampled SubViewport texture from sRGB to linear ---
		ALBEDO = srgb_to_linear(col.rgb);
	}
}
