Concord.component("ref_e_key", function(c, e)
	assert(e.__isEntity, e)
	e:ensure("key")
	c.value = e.key.value
end)

Concord.component("refs", function(c, ...)
	local t = { ... }
	assert(#t > 0, t)
	local v = {}
	for i, e in ipairs(t) do
		assert(e.__isEntity, e)
		e:ensure("key")
		v[i] = e.key.value
	end
	assert(#t == #v, t)
	c.value = v
end)
