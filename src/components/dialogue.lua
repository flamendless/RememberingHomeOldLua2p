Concord.component("text_can_proceed")
Concord.component("text_skipped")

Concord.component("has_choices", function(c, ...)
	c.value = { ... }

	if #c.value == 0 then
		error("Assertion failed: #c.value ~= 0")
	end
	for _, str in ipairs(c.value) do
		if type(str) ~= "string" then
			error('Assertion failed: type(str) == "string"')
		end
	end

	if #c.value == 0 then
		error("Assertion failed: #c.value ~= 0")
	end
end)

Concord.component("dialogue_item")
Concord.component("dialogue_meta", function(c, main, sub)
	if type(main) ~= "string" then
		error('Assertion failed: type(main) == "string"')
	end
	if type(sub) ~= "string" then
		error('Assertion failed: type(sub) == "string"')
	end
	if not (Dialogues.get(main, sub)) then
		error("Assertion failed: Dialogues.get(main, sub)")
	end
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
