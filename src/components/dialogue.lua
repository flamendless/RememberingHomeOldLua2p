Concord.component("text_can_proceed")
Concord.component("text_skipped")

Concord.component("has_choices", function(c, ...)
	c.value = { ... }

	assert(#c.value > 0, c.value)
	for _, str in ipairs(c.value) do
		assert(type(str) == "string", str)
	end

	assert(#c.value > 0, c.value)
end)

Concord.component("dialogue_item")
Concord.component("dialogue_meta", function(c, main, sub)
	assert(type(main) == "string", main)
	assert(type(sub) == "string", sub)
	assert(Dialogues.get(main, sub), main)
	c.main = main
	c.sub = sub
end)

-- New Dialogues system components
Concord.component("dialogue_key", function(c, key)
	assert(type(key) == "string")
	c.value = key
end)

Concord.component("dialogue_force_pause", function(c, keys)
	assert(type(keys) == "table")
	if DEV then
		for _, key in ipairs(keys) do
			assert(type(key) == "string")
		end
	end
	c.values = keys
end)
