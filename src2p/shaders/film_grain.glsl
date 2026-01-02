//credits to alex @a13X-B

extern vec2 u_random_offset;
extern Image u_noise_texture;
extern float u_size;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc)
{
    vec4 c = Texel(tex, uv);
    // noise sampling coordinates, scale down for bigger grains
    vec2 nuv = sc/u_size * 0.5 + u_random_offset;
    vec3 n = Texel(u_noise_texture, nuv).xyz;
    float l = dot(c.xyz, vec3(0.2, 0.7, 0.1)); //luma to attenuate the noise

    // mix has highest and lowest possible noise intensity
    // third parameter is a curve, can be linear with just l
    return vec4(c.xyz + n * mix(0.08, 0.02, sqrt(l)), 1.0);
}
