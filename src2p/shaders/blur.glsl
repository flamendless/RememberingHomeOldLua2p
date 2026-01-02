//https://github.com/Jam3/glsl-fast-gaussian-blur/blob/master/13.glsl

vec4 effect(vec4 _, Image tex, vec2 uv, vec2 sc)
{
	vec2 direction = vec2(1, 1);
	vec4 color = vec4(0.0);
	vec2 off1 = vec2(1.411764705882353) * direction;
	vec2 off2 = vec2(3.2941176470588234) * direction;
	vec2 off3 = vec2(5.176470588235294) * direction;
	color += texture2D(tex, uv) * 0.1964825501511404;
	color += texture2D(tex, uv + (off1 / sc)) * 0.2969069646728344;
	color += texture2D(tex, uv - (off1 / sc)) * 0.2969069646728344;
	color += texture2D(tex, uv + (off2 / sc)) * 0.09447039785044732;
	color += texture2D(tex, uv - (off2 / sc)) * 0.09447039785044732;
	color += texture2D(tex, uv + (off3 / sc)) * 0.010381362401148057;
	color += texture2D(tex, uv - (off3 / sc)) * 0.010381362401148057;
	return color;
}
