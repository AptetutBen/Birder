shader_type spatial; // or canvas_item if for 2D

render_mode unshaded; // don't let lights affect grading

// Input textures
uniform sampler2D source_texture;   // base input image/texture
uniform sampler3D lut_texture;                    // 3D LUT texture

// LUT parameters
uniform float lut_size = 32.0;  // resolution of the LUT texture (32, 64, etc.)

void fragment() {
    // Sample base image
    vec4 base_color = texture(source_texture, UV);

    // Normalize RGB to [0,1] and map into LUT coordinates
    // (Make sure LUT is correctly sampled between texel centers!)
    vec3 lut_uv = base_color.rgb * (lut_size - 1.0) / lut_size + (0.5 / lut_size);

    // Fetch color from LUT
    vec4 graded_color = texture(lut_texture, lut_uv);

    // Output
    ALBEDO = graded_color.rgb;
    ALPHA  = base_color.a;
}
