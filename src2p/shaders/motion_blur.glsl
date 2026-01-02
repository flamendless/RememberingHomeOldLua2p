extern float u_angle;
extern float u_strength;
const int SAMPLES = 25;

vec4 blur(Image tex, vec2 uv, vec2 dir)
{
	vec4 l = vec4(0);
	float delta = 1.0/float(SAMPLES);
	for (float i = 0.0; i < 1.0; i += delta)
	{
		l += Texel(tex, uv - vec2(dir.x * i, dir.y * i));
	}
	return vec4(l * delta * 0.5);
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 _)
{
	vec2 blur_vec = vec2(cos(radians(u_angle)), sin(radians(u_angle))) * u_strength;
	vec4 mb = blur(tex, uv, blur_vec);
	return mb;
}
