extern Image vignette_tex;

extern number time;
extern number intensity;
extern number pulse_strength;
extern number darkness;
extern number panic;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
	vec4 scene = Texel(tex, uv);

	vec2 center = vec2(0.5, 0.5);

	// normalized distance from screen center
	float dist = distance(uv, center);

	// heartbeat / breathing pulse
	float pulse =
		sin(time * (2.0 + panic * 4.0))
		* pulse_strength;

	// base vignette falloff
	float vignette =
		smoothstep(
			0.35 + pulse,
			0.9 - panic * 0.08,
			dist
		);

	// organic texture overlay
	vec2 tex_uv =
		(uv - 0.5) * 1.2 + 0.5;

	vec4 organic =
		Texel(vignette_tex, tex_uv);

	float splat =
		organic.a * 0.5;

	// combine
	float final_vignette =
		(vignette + splat)
		* intensity;

	// darken edges
	scene.rgb *=
		1.0 - final_vignette * darkness;

	return scene;
}
