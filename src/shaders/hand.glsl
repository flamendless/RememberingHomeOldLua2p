extern number time;
extern number opacity;
extern number blood_amount;
extern number damage_amount;
extern number distort_amount;
extern vec2 scale;
extern number rotation;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);

	float a = hash(i);
	float b = hash(i + vec2(1.0,0.0));
	float c = hash(i + vec2(0.0,1.0));
	float d = hash(i + vec2(1.0,1.0));
	vec2 u = f*f*(3.0-2.0*f);

	return mix(a,b,u.x)
		+ (c-a)*u.y*(1.0-u.x)
		+ (d-b)*u.x*u.y;
}

vec2 rotateUV(vec2 uv,float r) {
	uv -= 0.5;
	float c = cos(r);
	float s = sin(r);
	uv = mat2(c,-s,s,c) * uv;
	uv += 0.5;
	return uv;
}

vec4 effect(
	vec4 color,
	Image tex,
	vec2 texCoord,
	vec2 screenCoord
) {
	vec2 uv = texCoord;
	uv -= 0.5;
	uv /= scale;
	uv += 0.5;
	uv = rotateUV(uv, rotation);

	float dNoise = noise(uv * 8.0 + time*0.1);
	uv += (dNoise - 0.5) * distort_amount * 0.03;

	vec4 hand = Texel(tex, uv);
	if (hand.a < 0.01)
		discard;

	float damage = noise(uv * 10.0);
	float edgeDamage = noise(uv * 18.0);

	if (damage > (1.0 - damage_amount) && edgeDamage > 0.5)
		discard;

	vec3 baseColor = hand.rgb;
	vec2 p = uv * 64.0;
	float fp = sin(p.x * 2.5 + sin(p.y * 0.6));

	fp = smoothstep(0.15, 0.45, fp);

	fp *= hand.a;
	baseColor *= mix(1.0, 0.85, fp * 0.35);

	float bloodNoise = noise(uv * 16.0);
	float bloodNoise2 = noise(uv * 32.0);
	float bloodMask = smoothstep(0.65, 1.0, bloodNoise * bloodNoise2);
	bloodMask *= blood_amount;

	vec3 bloodColor = vec3(0.45, 0.02, 0.02);
	baseColor = mix(baseColor, bloodColor, bloodMask);

	float dry = smoothstep(0.4, 1.0, bloodNoise);
	baseColor *= mix(1.0, 0.75, dry * bloodMask);

	return vec4(baseColor, hand.a * opacity) * color;
}
