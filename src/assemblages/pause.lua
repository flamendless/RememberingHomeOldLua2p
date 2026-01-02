local Pause = {}

function Pause.bg(e, x, y)
	e:give("id", "pause_bg")
		:give("pos", x, y)
		:give("transform", 0, 4, 3, 0.5, 0.5)
		:give("color", { 1, 1, 1, 1 })
		:give("ui_element")
		:give("sprite", "pause_bg")
end

function Pause.text(e, x, y)
	e:give("id", "pause")
		:give("font", "ui")
		:give("static_text", "PAUSED")
		:give("pos", x, y)
		:give("transform", 0, 1.5, 1.5, 0.5, 0.5)
		:give("color", { 1, 1, 1, 1 })
		:give("ui_element")
end

function Pause.choice(e, str, x, y, scale)
	e:give("id", "pause_choice_" .. string.lower(str))
		:give("font", "ui")
		:give("static_text", str)
		:give("pos", x, y)
		:give("color", { 1, 1, 1, 1 })
		:give("list_item")
		:give("list_group", "pause_choices")
		:give("transform", 0, scale, scale, 0.5, 0.5)
		:give("ui_element")
end

return Pause
