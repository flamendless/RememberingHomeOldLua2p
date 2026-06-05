Concord.component("decals", function(c, kind)
	assert(Enums.decals[kind], kind)
	c.kind = kind
end)

Concord.component("decals_shaders", function(c, shader, data)
	assert(Enums.shaders[shader], shader)
	assert(Shaders.paths[shader], shader)
	assert(data and type(data) == "table")
	c.value = shader
	c.shader = nil -- INFO: to be populated in Decals system
	c.data = data
	c.orig_data = tablex.copy(data)
end)
