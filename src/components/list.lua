Concord.component("list_item_skip")

Concord.component("list_item", function(c)
	c.on_current_page = false
end)

Concord.component("list_cursor", function(c, cursor_index)
	assert(type(cursor_index) == "number", cursor_index)
	c.value = cursor_index
end)

Concord.component("list_group", function(c, group_id)
	assert(type(group_id) == "string", group_id)
	c.value = group_id
	c.is_focused = false
end)
