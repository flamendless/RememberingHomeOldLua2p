extern Image u_lut;

vec4 ngrading(vec4 color)
{
	number cdim = cellDimensions.x * cellDimensions.y - 1.0;
	number cw = cellPixels * cellDimensions.x;
	// Sampling must be done at 0.5-increments
	vec2 cpos = clamp(color.rg * cellPixels, 0.0, cellPixels - 1.0) + 0.5;
	number z = clamp(color.b * cdim, 0.0, cdim);
	number zf = fract(z);
	number zp = floor(z);
	// Calculate cell position
	vec2 tp1 = vec2(mod(zp, cellDimensions.x), floor(zp / cellDimensions.x)) * cellPixels + cpos;
	vec2 tp2 = vec2(mod((zp + 1.0), cellDimensions.x), floor((zp + 1.0) / cellDimensions.x)) * cellPixels + cpos;
	// Sample
	vec4 p1 = Texel(u_lut, tp1 / cw);
	vec4 p2 = Texel(u_lut, tp2 / cw);
	return vec4(mix(p1.rgb, p2.rgb, zf), color.a);
}

vec4 ngrading(Image tex, vec2 uv)
{
	return ngrading(Texel(tex, uv));
}
