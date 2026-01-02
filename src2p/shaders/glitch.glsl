//https://github.com/steincodes/godot-shader-tutorials/blob/master/Shaders/displace.shader

extern Image u_tex_displace;
extern float u_dis_amount = 0.1;
extern float u_dis_size = 0.1;
extern float u_abb_amount_x = 0.1;
extern float u_abb_amount_y = 0.1;
extern float u_max_a = 0.5;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 _)
{
	vec4 disp = Texel(u_tex_displace, uv * u_dis_size);
	vec2 new_uv = uv + disp.xy * u_dis_amount;
	color.r = Texel(tex, new_uv - vec2(u_abb_amount_x, u_abb_amount_y)).r;
	color.g = Texel(tex, new_uv).g;
	color.b = Texel(tex, new_uv + vec2(u_abb_amount_x, u_abb_amount_y)).b;
	color.a = Texel(tex, new_uv).a * u_max_a;

	return color;
}
