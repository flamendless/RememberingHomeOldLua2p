local Items = {}

function Items.flashlight(e)
	local info = ItemsInfo.get_info("flashlight")
	e:give("id", "item_flashlight")
	:give("sprite", "flashlight")
	:give("item", info.id, info.name, info.desc)
	:give("color", {1, 1, 1, 1})
	:give("pos", vec2(0, 0))
	:give("transform", 0, vec2(1, 1), vec2(0.5, 0.5))
	:give("ui_element")
end

return Items
