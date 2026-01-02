//credits to a13X_B over at Discord

uniform float u_time;
uniform float u_fog_speed;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc)
{
	vec2 _uv = sc/256.;

	_uv += vec2(u_time * u_fog_speed, -sin(u_time * u_fog_speed) * .001);
	_uv *= vec2(.001, .2);

	float mask = 1. - abs(pow(2. * uv.y - 1., 3.));

	mask = max(.0, mask - float(pow(1. - mask, 4.) > Texel(tex, vec2(_uv.x * 1.23, .333)).x * .6));

	vec4 c = vec4(1., 1., 1., float(Texel(tex, _uv).x > .35) * .8 * mask);

	return color * c;
}
