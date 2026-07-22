Concord.component("usable_with_item")
Concord.component("item_preview")
Concord.component("room_item")

Concord.component("item_id", function(c, id)
	assert(type(id) == "string", id)
	c.value = Enums.item[id]
end)

Concord.component("item", function(c, id, name, desc)
	assert(type(id) == "string", id)
	assert(type(name) == "string", name)
	assert(type(desc) == "string", desc)
	c.id = id
	c.name = name
	c.desc = desc
end)
