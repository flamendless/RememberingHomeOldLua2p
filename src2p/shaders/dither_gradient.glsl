//https://github.com/steincodes/godot-shader-tutorials/blob/master/Shaders/displace.shader

extern Image u_tex_dither;
extern Image u_tex_palette;

extern ivec2 u_size_tex_dither;
extern ivec2 u_size_tex_palette;

extern int u_depth;
extern int u_dither_size;
extern float u_contrast;
extern float u_offset;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 _)
{
	vec2 screen_size = love_ScreenSize.xy / float(u_dither_size);
	vec2 screen_sample_uv = floor(uv * screen_size) / screen_size;
	vec3 screen_col = Texel(tex, screen_sample_uv).rgb;

	float lum = (screen_col.r * 0.299) + (screen_col.g * 0.587) + (screen_col.b * 0.114);
	float contrast = u_contrast;
	lum = (lum - 0.5 + u_offset) * contrast + 0.5;
	lum = clamp(lum, 0.0, 1.0);

	float bits = float(u_depth);
	lum = floor(lum * bits) / bits;

	ivec2 col_size = u_size_tex_palette;
	col_size /= col_size.y;

	float col_x = float(col_size.x) - 1.0f;
	float col_texel_size = 1.0 / col_x;
	lum = max(lum - 0.00001, 0.0);
	float lum_lower = floor(lum * col_x) * col_texel_size;
	float lum_upper = (floor(lum * col_x) + 1.0f) * col_texel_size;
	float lum_scaled = lum * col_x - floor(lum * col_x);

	ivec2 noise_size = u_size_tex_dither;
	vec2 inv_noise_size = vec2(1.0 / float(noise_size.x), 1.0 / float(noise_size.y));
	vec2 noise_uv = uv * inv_noise_size * vec2(float(screen_size.x), float(screen_size.y));
	float threshold = Texel(u_tex_dither, noise_uv).r;
	threshold = threshold * 0.99 + 0.005;

	float ramp_val = lum_scaled < threshold ? 0.0f : 1.0f;
	float col_sample = mix(lum_lower, lum_upper, ramp_val);
	vec3 final_col = Texel(u_tex_palette, vec2(col_sample, 0.5)).rgb;

	vec4 px = Texel(tex, uv);
	px.rgb = final_col;
	return px;
}
