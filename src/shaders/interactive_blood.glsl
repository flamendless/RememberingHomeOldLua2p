extern number time;
extern number opacity;
extern number overlay_strength;
extern vec4 quad;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 localUv(vec2 texturePos, vec2 q1, vec2 q2) {
	return (clamp(texturePos, q1, q2) - q1) / max(q2 - q1, vec2(0.0001));
}

float circleBlob(vec2 p, vec2 center, float radius) {
	float d = length(p - center);
	return smoothstep(radius, radius * 0.42, d);
}

float cellularBlobs(vec2 uv) {
	vec2 wobble = vec2(
		sin(time * 0.5 + uv.y * 6.0) * 0.014,
		cos(time * 0.46 + uv.x * 5.5) * 0.014
	);
	vec2 p = (uv + wobble) * 3.2;
	vec2 cell = floor(p);
	vec2 f = fract(p);

	float cluster = 0.0;

	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 id = cell + g;

			for (int k = 0; k < 3; k++) {
				float fk = float(k);
				vec2 seed = id + vec2(fk * 2.3, fk * 1.7);
				vec2 center = g + vec2(
					hash(seed),
					hash(seed + vec2(9.2, 4.6))
				);
				center += 0.04 * vec2(
					sin(time * 0.62 + hash(seed + 1.1) * 6.283),
					cos(time * 0.58 + hash(seed + 2.4) * 6.283)
				);

				float radius = 0.11 + hash(seed + vec2(3.3, 8.1)) * 0.13;
				cluster += circleBlob(f, center, radius) * 0.55;
			}
		}
	}

	return smoothstep(0.28, 0.95, cluster);
}

vec4 effect(vec4 color, Image tex, vec2 texturePos, vec2 screenCoord) {
	vec2 q1 = quad.xy;
	vec2 q2 = quad.xy + quad.zw;
	vec2 uv = localUv(texturePos, q1, q2);

	vec4 sprite = Texel(tex, clamp(texturePos, q1, q2));
	if (sprite.a < 0.01)
		discard;

	float blob = cellularBlobs(uv);
	vec3 blobColor = vec3(0.12, 0.02, 0.02);
	vec3 baseColor = mix(sprite.rgb, blobColor, blob * overlay_strength * opacity);

	return vec4(baseColor, sprite.a) * color;
}
