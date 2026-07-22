Concord.component("id", function(c, id, sub_id)
	assert(type(id) == "string", id)
	if sub_id then
		assert(type(sub_id) == "string", sub_id)
	end
	c.value = id
	c.sub_id = sub_id
end)

Concord.component("preserve_id")
Concord.component("hidden")

if DEV then
	Concord.component("dev_hidden")
end
