Concord.component("id", function(c, id, sub_id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if sub_id then
		if not (type(sub_id) == "string") then
			error('Assertion failed: type(sub_id) == "string"')
		end
	end
	c.value = id
	c.sub_id = sub_id
end)

Concord.component("preserve_id")
Concord.component("hidden")
