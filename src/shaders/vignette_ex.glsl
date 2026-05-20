extern Image tex_vignette;

extern number time;
extern number intensity;
extern number pulse_strength;
extern number darkness;
extern number panic;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
	vec4 scene = Texel(tex, uv);
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(uv, center);
	float pulse = sin(time * (2.0 + panic * 4.0)) * pulse_strength;
	float vignette = smoothstep(
		0.35 + pulse,
		0.9 - panic * 0.08,
		dist
	);
	vec2 tex_uv = (uv - 0.5) * 1.2 + 0.5;
	vec4 organic = Texel(tex_vignette, tex_uv);
	float splat = 1.0 - organic.a * 0.5;
	float final_vignette = (vignette + splat) * intensity;
	scene.rgb *= 1.0 - final_vignette * darkness;

	return scene;
}
