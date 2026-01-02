local Concord = require("modules.concord.concord")

Concord.component("list_item_skip")

Concord.component("list_item", function(c)
	c.on_current_page = false
end)

Concord.component("list_cursor", function(c, cursor_index)
	if not (type(cursor_index) == "number") then
		error('Assertion failed: type(cursor_index) == "number"')
	end
	c.value = cursor_index
end)

Concord.component("list_group", function(c, group_id)
	if not (type(group_id) == "string") then
		error('Assertion failed: type(group_id) == "string"')
	end
	c.value = group_id
	c.is_focused = false
end)
