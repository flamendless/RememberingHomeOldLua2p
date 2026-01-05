Concord.component("ref_e_key", function(c, e)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	e:ensure("key")
	c.value = e.key.value
end)

Concord.component("refs", function(c, ...)
	local t = { ... }
	if not (#t > 0) then
		error("Assertion failed: #t > 0")
	end
	local v = {}
	for i, e in ipairs(t) do
		if not e.__isEntity then
			error("Assertion failed: e.__isEntity")
		end
		e:ensure("key")
		v[i] = e.key.value
	end
	if not (#t == #v) then
		error("Assertion failed: #t == #v")
	end
	c.value = v
end)
