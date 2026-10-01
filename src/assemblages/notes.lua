local Notes = {}

function Notes.bg(e, x, y, scale)
	assert:entity(e)
	assert:type(x, "number")
	assert:type(y, "number")
	e:give("id", "notes_bg")
		:give("pos", x, y)
		:give("sprite", "bg_notes")
		:give("color", { 1, 1, 1, 0.75 })
		:give("transform", 0, scale, scale, 0.5, 0.5)
		:give("ui_element")
end

function Notes.text(e, i, title, x, y, ox)
	assert:entity(e)
	assert:type(i, "number")
	assert:type(x, "number")
	assert:type(y, "number")
	assert:type(ox, "number")
	e:give("id", "note_" .. i)
		:give("font", "note_list")
		:give("static_text", title)
		:give("pos", x, y)
		:give("color", Palette.get("note_list"))
		:give("list_item")
		:give("list_group", Enums.list_group.notes)
		:give("transform", 0, 1, 1, ox, 0, -0.25)
		:give("ui_element")
end

function Notes.cursor(e)
	assert:entity(e)
	e:give("id", "note_cursor")
		:give("color", { 1, 1, 1, 1 })
		:give("sprite", "note_cursor")
		:give("pos", 0, 0)
		:give("transform", 0, 1, 1, 1)
		:give("ui_element")
end

return Notes
