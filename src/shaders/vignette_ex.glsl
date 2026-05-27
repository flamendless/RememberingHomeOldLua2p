extern Image tex_vignette;

extern number time;
extern number intensity;
extern number pulse_strength;
extern number darkness;
extern number panic;
extern number scale;
extern number layers;
extern number rot_speed;
extern number noise_intensity;

vec2 rotate(vec2 uv, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	mat2 rot = mat2(c, -s, s, c);
	return rot * uv;
}

float noise(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float smoothNoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = noise(i);
	float b = noise(i + vec2(1.0, 0.0));
	float c = noise(i + vec2(0.0, 1.0));
	float d = noise(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x)
		+ (c - a) * u.y * (1.0 - u.x)
		+ (d - b) * u.x * u.y;
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px) {
	vec4 scene = Texel(tex, uv);
	vec2 center = vec2(0.5, 0.5);
	vec2 aspect = vec2(love_ScreenSize.x / love_ScreenSize.y, 1.0);
	float dist = distance(uv, center);
	float pulse = (sin(time * (2.0 + panic * 4.0)) * 0.5 + 0.5);
	float pulsing_scale = scale + pulse * pulse_strength;
	float vignette = smoothstep(
		0.35 + pulse * 0.02,
		0.9 - panic * 0.08,
		dist
	);

	float splat = 0.0;
	for (int i = 0; i < layers; i++) {
		float fi = float(i);
		float angle = fi * 1.7 + sin(time * rot_speed + fi) * 0.15;
		float local_scale = pulsing_scale + fi * 0.12;
		vec2 local_uv = uv - center;
		local_uv *= aspect;
		local_uv += vec2(
			sin(time * 0.08 + fi) * 0.02,
			cos(time * 0.06 + fi) * 0.02
		);
		local_uv = rotate(local_uv, angle);
		local_uv /= local_scale;
		local_uv += center;
		vec2 noise_uv = local_uv * 6.0 +
			vec2(
				time * 0.03,
				-time * 0.02
			) +
			fi * 17.3;

		float noise_x = smoothNoise(noise_uv);
		float noise_y = smoothNoise(noise_uv + 42.7);
		vec2 distortion = vec2(noise_x, noise_y) - 0.5;
		float animated_noise_strength = clamp(sin(time * 0.5) * 0.5 + 0.5, 0.2, 0.5);
		distortion *= noise_intensity * animated_noise_strength * (1.0 + panic * 0.5);
		vec2 distorted_uv = local_uv + distortion;
		vec4 organic = Texel(tex_vignette, distorted_uv);
		float layer = 1.0 - organic.a * 0.85;
		layer *= 0.22 - fi * 0.04;
		splat += layer;
	}

	float final_vignette = (vignette + splat) * intensity;
	scene.rgb *= 1.0 - final_vignette * darkness;

	return scene;
}
