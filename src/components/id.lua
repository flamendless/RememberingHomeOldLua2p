Concord.component("id", function(c, id, sub_id)
	assert:type(id, "string")
	assert:type_or_nil(sub_id, "string")
	c.value = id
	c.sub_id = sub_id
end)

Concord.component("preserve_id")
Concord.component("hidden")

if DEV then
	Concord.component("dev_hidden")
end
