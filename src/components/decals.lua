Concord.component("decals", function(c, kind)
	assert(Enums.decals[kind], kind)
	c.kind = kind
end)

Concord.component("decals_shaders", function(c, shader, data)
	assert(Enums.shaders[shader], shader)
	assert(Shaders.paths[shader], shader)
	assert(data and type(data) == "table")
	c.value = shader
	c.shader = nil -- INFO: to be created in Decals system
	c.data = data
	c.orig_data = tablex.copy(data)
end)

Concord.component("decals_text", function(c, text)
	assert(type(text) == "string")
	c.value = text
end)

Concord.component("decals_embed", function(c, key)
	assert(type(key) == "string")
	c.value = key
end)
