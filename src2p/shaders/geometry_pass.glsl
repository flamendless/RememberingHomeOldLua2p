//credits to @a13X_B over at Discord

varying vec4 u_world_pos;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	u_world_pos = TransformMatrix * vertex_position;
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
uniform ArrayImage MainTex;

void effect()
{
	vec4 n = Texel(MainTex, vec3(VaryingTexCoord.xy, 1.0));
	vec4 c = Texel(MainTex, vec3(VaryingTexCoord.xy, 0.0));
	if(c.a == 0.0) discard;
	if(n == c){
		//c = vec4(1.0, 0.0, 1.0, 1.0);
		n = vec4(0.5, 0.5, 1.0, n.a);
	}
	//love_Canvases[0] = ngrading(c);
	love_Canvases[0] = c;
	love_Canvases[1] = n;
}
#endif
