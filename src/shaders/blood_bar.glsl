extern number time;
extern number opacity;
extern number fade_width;
extern number tint;
extern vec2 direction = vec2(1.0, 0.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(a, b, u.x)
		+ (c - a) * u.y * (1.0 - u.x)
		+ (d - b) * u.x * u.y;
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc) {
	float fade = fade_width;
	float edgeFade = smoothstep(0.0, fade, uv.x) * smoothstep(1.0, 1.0 - fade, uv.x);

	vec2 dir = normalize(direction);
	if (length(direction) < 0.001)
		dir = vec2(1.0, 0.0);

	vec2 perp = vec2(-dir.y, dir.x);
	vec2 ruv = vec2(dot(uv, dir), dot(uv, perp));

	vec2 flow = vec2(time * 0.18, time * 0.04);
	vec2 warp = vec2(
		noise(ruv * vec2(4.0, 2.0) + flow) - 0.5,
		noise(ruv * vec2(4.0, 2.0) + flow + vec2(4.1, 2.7)) - 0.5
	);
	vec2 wuv = ruv + warp * 0.12;

	vec2 drift1 = vec2(time * 0.22, sin(time * 0.35) * 0.06);
	vec2 drift2 = vec2(-time * 0.14, cos(time * 0.28) * 0.05);
	float n1 = noise(wuv * vec2(11.0, 5.5) + drift1);
	float n2 = noise(wuv * vec2(19.0, 9.0) + drift2 + vec2(3.7, 1.1));
	float n3 = noise((wuv + vec2(n1, n2) * 0.18) * vec2(7.0, 3.5) + vec2(time * 0.1, -time * 0.07));

	float darkA = smoothstep(0.12, 0.58, n1 * n2);
	float darkB = smoothstep(0.2, 0.62, n3);
	float dark = clamp(darkA + darkB * 0.75, 0.0, 1.0);

	vec3 bloodRed = vec3(0.30, 0.05, 0.05);
	vec3 darkRed = vec3(0.04, 0.0, 0.0);
	vec3 col = mix(bloodRed, darkRed, dark * 0.95);

	float topGloss = smoothstep(0.05, 0.0, uv.y);
	float botGloss = smoothstep(0.95, 1.0, uv.y);
	float gloss = max(topGloss, botGloss);
	vec3 glossCol = vec3(0.42, 0.14, 0.14);
	col = mix(col, glossCol, gloss * 0.22);

	float topLine = smoothstep(0.018, 0.0, uv.y);
	float botLine = smoothstep(0.982, 1.0, uv.y);
	col = mix(col, vec3(0.38, 0.12, 0.12), max(topLine, botLine) * 0.18);

	col *= tint;

	float alpha = edgeFade * opacity * color.a;
	return vec4(col * color.rgb, alpha);
}
