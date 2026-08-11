extern vec2 u_tex_size;

extern float u_cell_size;
extern int u_levels;
extern float u_dither_amount;
extern float u_hue_preserve;
extern float u_contrast;
extern float u_offset;
extern float u_grain;
extern vec2 u_seed;

extern float u_light_enabled;
extern vec2 u_light_pos;
extern float u_light_radius;
extern float u_light_falloff;

const vec3 luma_w = vec3(0.299, 0.587, 0.114);

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec3 sample_cell_average(Image tex, vec2 cell_ix, vec2 grid_count) {
	vec2 cell_min = cell_ix / grid_count;
	vec2 cell_span = 1.0 / grid_count;
	vec3 sum = vec3(0.0);

	sum += Texel(tex, cell_min).rgb;
	sum += Texel(tex, cell_min + vec2(0.5, 0.0) * cell_span).rgb;
	sum += Texel(tex, cell_min + vec2(1.0, 0.0) * cell_span).rgb;
	sum += Texel(tex, cell_min + vec2(0.0, 0.5) * cell_span).rgb;
	sum += Texel(tex, cell_min + vec2(0.5, 0.5) * cell_span).rgb;
	sum += Texel(tex, cell_min + vec2(1.0, 0.5) * cell_span).rgb;
	sum += Texel(tex, cell_min + vec2(0.0, 1.0) * cell_span).rgb;
	sum += Texel(tex, cell_min + vec2(0.5, 1.0) * cell_span).rgb;
	sum += Texel(tex, cell_min + vec2(1.0, 1.0) * cell_span).rgb;

	return sum / 9.0;
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc) {
	vec2 grid_count = u_tex_size / u_cell_size;
	vec2 cell_ix = floor(uv * grid_count);

	vec3 col = sample_cell_average(tex, cell_ix, grid_count);
	col = (col - 0.5 + u_offset) * u_contrast + 0.5;

	float lum = dot(col, luma_w);

	if (u_light_enabled > 0.5) {
		float dist = distance(uv, u_light_pos);
		float inner = u_light_radius * (1.0 - u_light_falloff);
		float light = 1.0 - smoothstep(inner, u_light_radius, dist);
		lum *= light;
		col *= light;
	}

	float levels_f = float(u_levels);
	vec2 jitter_seed = cell_ix + u_seed;
	float jitter = (hash21(jitter_seed) - 0.5) * u_dither_amount;

	float lum_q = floor(clamp(lum, 0.0, 1.0) * levels_f + jitter) / levels_f;
	vec3 lum_col = col * (lum_q / max(dot(col, luma_w), 0.001));

	vec3 channel_q = floor(clamp(col, 0.0, 1.0) * levels_f + jitter) / levels_f;

	vec3 final_col = mix(channel_q, lum_col, u_hue_preserve);
	final_col = clamp(final_col, 0.0, 1.0);

	if (u_grain > 0.0) {
		float speckle = hash21(sc + u_seed * 13.7) - 0.5;
		final_col += speckle * u_grain / levels_f;
		final_col = clamp(final_col, 0.0, 1.0);
	}

	return vec4(final_col, 1.0);
}
