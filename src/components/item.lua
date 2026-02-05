Concord.component("usable_with_item")
Concord.component("item_preview")
Concord.component("room_item")

Concord.component("item_id", function(c, id)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	c.value = Enums.item[id]
end)

Concord.component("item", function(c, id, name, desc)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if type(name) ~= "string" then
		error('Assertion failed: type(name) == "string"')
	end
	if type(desc) ~= "string" then
		error('Assertion failed: type(desc) == "string"')
	end
	c.id = id
	c.name = name
	c.desc = desc
end)
