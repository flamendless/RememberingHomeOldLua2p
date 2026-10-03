//credits to @a13X_B over at Discord

varying vec2 u_ndc_p;
varying vec3 u_w_p;
varying float u_scale;
varying vec3 u_diff;
varying vec3 u_dir;
varying float u_angle;
varying vec4 u_ring_params;
varying float u_ring_outer;

#ifdef VERTEX
attribute vec4 u_lpos;
attribute vec4 u_ldir;
attribute vec3 u_diffuse;
attribute vec4 u_lrings;
attribute float u_lring_outer;

vec4 position(mat4 transform_projection, vec4 vertex_position) {
	u_ndc_p = (transform_projection * vec4(u_lpos.xy, 0.0, 1.0)).xy;
	u_scale = u_lpos.w;
	u_diff = u_diffuse;
	u_dir = normalize(u_ldir.xyz);
	u_angle = u_ldir.w;
	u_w_p = u_lpos.xyz;
	u_ring_params = u_lrings;
	u_ring_outer = u_lring_outer;
	vec4 vp = vec4(vertex_position.xyz * u_lpos.w, vertex_position.w);
	return transform_projection * (vp + vec4(u_lpos.xy, 0.0, 0.0));
}
#endif

#ifdef PIXEL
uniform Image u_cb;

const float DEFERRED_LIGHT_TAU = 6.28318530718;

float deferred_light_radial(float ld) {
	float z_term = u_w_p.z / u_scale;
	float rim = sqrt(1.0 + z_term * z_term);
	return clamp((ld - z_term) / max(rim - z_term, 1e-4), 0.0, 1.0);
}

float deferred_light_atten(float ld) {
	float r = deferred_light_radial(ld);
	float base = max(1.0 - r * r, 0.0);
	if (u_ring_params.y <= 0.0) {
		return base;
	}
	float ripple = 0.5 + 0.5 * cos(r * u_ring_params.x * DEFERRED_LIGHT_TAU);
	ripple = pow(ripple, u_ring_params.z);
	float edge_fade = smoothstep(0.0, u_ring_params.w, r) * smoothstep(1.0, u_ring_outer, r);
	float ring_mix = mix(1.0, ripple, u_ring_params.y * edge_fade);
	return base * ring_mix;
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc) {
	sc /= love_ScreenSize.xy;
	vec2 ndc = (sc - vec2(0.5)) * 2.0;
	vec3 c = Texel(u_cb, sc).xyz;

	vec3 tl = vec3(normalize(u_ndc_p - ndc) * color.x, u_w_p.z/u_scale); //vector towards the light
	float ld = length(tl);
	vec3 l = normalize(tl);

	if ((ld / u_scale > 1.0) || (u_angle != 0 && (dot(-l, u_dir) < u_angle))) return vec4(0.0);
	c = c * l.z * deferred_light_atten(ld) * u_diff;

	return vec4(c, 1.0);
}
#endif
