uniform float u_intensity = 1.0;
uniform Image u_blocker_mask;
uniform vec2 u_screen_size;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
{
    vec4 texel = Texel(tex, tc);
    float glow = texel.r * u_intensity * color.a;
    vec2 mask_uv = sc / u_screen_size;
    float mask = Texel(u_blocker_mask, mask_uv).r;
    glow = glow * mask;
    return vec4(color.rgb * glow, glow);
}
