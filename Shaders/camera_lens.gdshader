shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;
uniform float flash_strength : hint_range(0.0, 2.0) = 0.0;
uniform float green_shift : hint_range(-0.5, 0.5) = 0.05;
uniform float bloom_strength : hint_range(0.0, 2.0) = 0.5;

void fragment() {
	vec4 col = texture(screen_tex, SCREEN_UV);

	if (flash_strength > 0.0) {
		// Brighten
		col.rgb *= 1.0 + flash_strength * 2.0;

		// Tint shift
		col.rg *= vec2(1.0, 1.0 + green_shift * flash_strength);

		// Desaturate slightly
		float gray = dot(col.rgb, vec3(0.333));
		col.rgb = mix(col.rgb, vec3(gray), flash_strength * 0.2);

		// --- Bloom pass (cheap blur) ---
		vec2 uv = SCREEN_UV;
		vec4 bloom = vec4(0.0);
		float offset = 0.002 * flash_strength; // bigger when stronger

		bloom += texture(screen_tex, uv + vec2(-offset, 0.0));
		bloom += texture(screen_tex, uv + vec2( offset, 0.0));
		bloom += texture(screen_tex, uv + vec2(0.0, -offset));
		bloom += texture(screen_tex, uv + vec2(0.0,  offset));
		bloom *= 0.25;

		// Mix bloom with base
		col.rgb += bloom_strength * flash_strength * bloom.rgb;
	}

	COLOR = clamp(col, 0.0, 1.0);
}
