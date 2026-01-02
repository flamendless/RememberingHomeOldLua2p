local UI = {}

function UI.ui_text(e, text, resource_id, x, y)
	e:give("id", "ui_text")
	:give("static_text", text)
	:give("font", resource_id)
	:give("pos", vec2(x, y))
	:give("color", Palette.get("white", 0))
	:give("ui_element")
	:give("hidden")
	:give("layer", "text", 2)
end

function UI.ui_text_paint(e, text, font, x, y)
	e:assemble(UI.ui_text, text, font, x, y)
	:give("text_with_paint")
	:give("transform", 0, vec2(1, 1), vec2(0.5, 0.5))
end

function UI.choice(e, id, text, text_t, x, y)
	e:give("id", id)
	:give("text", text)
	:give("text_t", text_t)
	:give("font", "ui")
	:give("pos", vec2(x, y))
	:give("color", Palette.get("ui_dialogue"))
	:give("item_id", Enums.item.choice)
	:give("ui_element")
	:give("transform", 0, vec2(1, 1), vec2(0, 0.5))
	:give("layer", "dialogue", 3)
end

function UI.speech_bubble(e, player, x, y)
	local sx = 0.5
	if player.body.dir == -1 then
		sx = -sx
	end

	e:give("id", "speech_bubble")
	:give("pos", vec2(x, y))
	:give("color", {1, 1, 1, 1})
	:give("animation_data", Animation.get("speech_bubble"))
	:give("animation")
	:give("z_index", 99)
	:give("transform", 0, vec2(sx, 0.5), vec2(0, 1))
	:give("current_frame")
	:give("animation_on_update", "speech_bubble_update")
	:give("notification", "speech_bubble")
	:give("attach_to", player)
	:give("attach_to_offset", 16, 18)
end

return UI
