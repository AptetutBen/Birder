shader_type spatial;

render_mode unshaded, cull_disabled; // remove lighting, keep flat textured look

uniform sampler2D base_texture : hint_default_white;  // main texture
uniform sampler2D pixel_texture : hint_default_white; // overlay / effect texture
uniform vec2 screen_size = vec2(128.0, 128.0);

void fragment() {
    // UVs from the mesh
    vec2 uv = UV * screen_size;
    uv -= floor(uv);

    // Sample textures
    vec4 crt_overlay = texture(pixel_texture, uv);
    vec4 base_color = texture(base_texture, UV);

    // Apply effect
    ALBEDO = crt_overlay.rgb * base_color.rgb * base_color.a;
    ALPHA = base_color.a; // preserve transparency if needed
}
