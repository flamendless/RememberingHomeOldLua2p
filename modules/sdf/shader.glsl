uniform float weight = 0.2;
uniform float edge = 0.05;

float median(vec3 v) {
    return max(min(v.x, v.y), min(max(v.x, v.y), v.z));
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
#ifdef MSDF
    vec3 sample = Texel(tex, texture_coords).rgb;
    float dist = 1.0 - median(sample) - 0.5;
#else
    float dist = 1.0 - Texel(tex, texture_coords).a;
#endif

    float alpha = 1.0 - smoothstep(weight, weight + edge, dist);

    color.a *= alpha;
    return color;
}
