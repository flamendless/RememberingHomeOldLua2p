extern VolumeImage u_lut;

vec4 ngrading(vec4 color)
{
	return vec4(Texel(u_lut, color.rgb).rgb, color.a);
}

vec4 ngrading(Image tex, vec2 uv)
{
	return ngrading(Texel(tex, uv));
}
