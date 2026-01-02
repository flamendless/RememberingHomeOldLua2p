//credits to @a13X_B over at Discord

varying vec2 u_ndc_p;
varying vec3 u_w_p;
varying float u_scale;
varying vec3 u_diff;
varying vec3 u_dir;
varying float u_angle;

#ifdef VERTEX
attribute vec4 u_lpos;
attribute vec4 u_ldir;
attribute vec3 u_diffuse;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	u_ndc_p = (transform_projection * vec4(u_lpos.xy, 0.0, 1.0)).xy;
	u_scale = u_lpos.w;
	u_diff = u_diffuse;
	u_dir = normalize(u_ldir.xyz);
	u_angle = u_ldir.w;
	u_w_p = u_lpos.xyz;
	vec4 vp = vec4(vertex_position.xyz * u_lpos.w, vertex_position.w);
	return transform_projection * (vp + vec4(u_lpos.xy, 0.0, 0.0));
}
#endif

#ifdef PIXEL
uniform Image u_cb;
uniform Image u_nb;

vec4 effect(vec4 col, Image tex, vec2 uv, vec2 sc)
{
	sc /= love_ScreenSize.xy;
	vec2 ndc = (sc - vec2(0.5)) * 2.0;
	vec3 c = Texel(u_cb, sc).xyz;
	vec3 n = normalize(Texel(u_nb, sc).xyz - vec3(0.5));
	n.y = -n.y;

	vec3 tl = vec3(normalize(u_ndc_p - ndc) * col.x, u_w_p.z/u_scale); //vector towards the light
	float ld = length(tl);
	vec3 l = normalize(tl);

	vec3 lpos = vec3(u_ndc_p, u_w_p.z);

	if ((length(tl)/u_scale > 1.0) || (dot(-l, u_dir) < u_angle)) discard;
	c = c * dot(n, l) * max(1.0 - ld * ld, 0.0) * u_diff;

	return vec4(c, 1.0);
}
#endif
