extern VolumeImage u_lut;
extern VolumeImage u_lut2;
extern float u_time;

vec4 ngrading(vec4 color)
{
	vec3 color_value = mix(Texel(u_lut, color.rgb).rgb, Texel(u_lut2, color.rgb).rgb, u_time);
	return vec4(color_value, color.a);
}

vec4 ngrading(Image tex, vec2 uv)
{
	return ngrading(Texel(tex, uv));
}
