local Notes = {}

function Notes.bg(e, x, y, scale)
	e:give("id", "notes_bg")
	:give("pos", x, y)
	:give("sprite", "bg_notes")
	:give("color", {1, 1, 1, 0.75})
	:give("transform", 0, vec2(scale, scale), vec2(0.5, 0.5))
	:give("ui_element")
end

function Notes.text(e, i, title, x, y, ox)
	e:give("id", "note_" .. i)
	:give("font", "note_list")
	:give("static_text", title)
	:give("pos", x, y)
	:give("color", Palette.get("note_list"))
	:give("list_item")
	:give("list_group", "notes")
	:give("transform", 0, vec2(1, 1), vec2(ox, 0), vec2(-0.25, 0))
	:give("ui_element")
end

function Notes.cursor(e)
	e:give("id", "note_cursor")
	:give("color", {1, 1, 1, 1})
	:give("sprite", "note_cursor")
	:give("pos", 0, 0)
	:give("transform", 0, vec2(1, 1), vec2(1, 0))
	:give("ui_element")
end

return Notes
