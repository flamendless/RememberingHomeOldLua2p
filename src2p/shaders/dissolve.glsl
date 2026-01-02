extern Image u_tex_noise;
extern number u_time;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 _)
{
	vec4 pixel = Texel(tex, uv);
	vec4 pixel2 = Texel(u_tex_noise, uv);
	return (pixel2.r < u_time) ? (pixel * color) : vec4(0.0);
}
