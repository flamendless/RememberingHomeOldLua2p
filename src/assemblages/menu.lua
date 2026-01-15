local Menu = {}

function Menu.desk_fast(e, ww, wh)
	e:give("id", "desk_fast")
		:give("animation_data", {
			resource_id = "sheet_desk",
			frames = { "1-3", 1, "1-3", 2, "1-1", 3 },
			delay = 0.001,
			rows_count = 3,
			columns_count = 3,
			n_frames = 7,
		})
		:give("pos", ww * 0.5, wh * 0.5)
		:give("animation", false)
		:give("transform", 0, 1, 1, 0.5, 0.5)
		:give("auto_scale", ww, wh, true)
		:give("color", Palette.get("white"))
end

function Menu.desk(e, ww, wh)
	e:give("id", "desk")
		:give("animation_data", {
			resource_id = "sheet_desk",
			frames = { "1-3", 1, "1-3", 2, "1-1", 3 },
			delay = { 1, 0.1, 1, 0.1, 0.1, 0.1, 1 },
			rows_count = 3,
			columns_count = 3,
			n_frames = 7,
		})
		:give("pos", ww * 0.5, wh * 0.5)
		:give("animation", false)
		:give("transform", 0, 1, 1, 0.5, 0.5)
		:give("auto_scale", ww, wh, true)
		:give("color", Palette.get("white"))
end

function Menu.bg_door(e, x, y, scale, ox, oy)
	e:give("id", "bg_door"):give("sprite", "bg_door"):give("pos", x, y):give("transform", 0, scale, scale, ox, oy)
end

function Menu.bg_hallway(e, x, y, scale, ox, oy)
	e:give("id", "bg_hallway"):give("sprite", "bg_hallway"):give("pos", x, y):give("transform", 0, scale, scale, ox, oy)
end

--INFO: Single frame title
function Menu.title(e, x, y, scale, ox, oy)
	e:give("id", "title")
		:give("sprite", "title")
		:give("pos", x, y)
		:give("transform", 0, scale, scale, ox, oy)
		:give("color", Palette.get("white", 0.75))
		:give("menu_text")
end

function Menu.sheet_title(e, ww, wh)
	e:give("id", "title")
		:give("animation_data", {
			resource_id = "sheet_title",
			frames = { "1-3", 1, "1-3", 1, "1-1", 1 },
			delay = { 1, 0.1, 1, 0.1, 0.1, 0.1, 1 },

			rows_count = 1,
			columns_count = 3,
			n_frames = 3,
		})
		:give("pos", 24, wh * 0.5)
		:give("animation", false)
		:give("transform", 0, 1, 1, 0, 0.5)
		:give("auto_scale", ww/3, wh, true)
		:give("color", Palette.get("white", 0))
		:give("color_fade_in", 8, 4)
		:give("fade_in_target_alpha", 0.5)
		:give("menu_text")
end

-- function Menu.subtitle(e, x, y, target, scale, ox, oy)
-- 	e:give("id", "subtitle")
-- 		:give("sprite", "subtitle")
-- 		:give("pos", x, y)
-- 		:give("anchor", target, Enums.anchor.center, Enums.anchor.bottom)
-- 		:give("transform", 0, scale, scale, ox, oy)
-- 		:give("color", Palette.get("white", 0.5))
-- 		:give("menu_text")
-- end

function Menu.option_item(e, id, str, fnt, png, x, y, scale, i, sub_i, list_id)
	e:give("id", id)
		:give("text", str)
		:give("font_sdf", fnt, png)
		:give("pos", x, y)
		:give("sdf", scale, scale)
		:give("option_key", i, sub_i)
		:give("color", Palette.get("menu_text"))
		:give("list_item")
		:give("list_group", list_id)
end

function Menu.about_text(e, id, resource_id, str, x, y, color)
	e:give("id", id)
		:give("static_text", str)
		:give("font", resource_id)
		:give("pos", x, y)
		:give("color", color)
		:give("camera")
end

function Menu.about_ext_link(e, id, resource_id, x, y)
	local image = Resources.data.images[resource_id]
	local w, h = image:getDimensions()
	e:give("id", id)
		:give("sprite", resource_id)
		:give("pos", x, y)
		:give("color", Palette.get("white"))
		:give("camera")
		:give("bounding_box", x, y, w, h)
		:give("clickable")
		:give("hoverable")
		:give("transform", 0, 0.75, 0.75, 0, 0.5)
		:give("hover_change_color", Palette.get("about_hint"), 0.25)
end

function Menu.btn_back(e, x, y)
	e:give("id", "btn_back")
		:give("sprite", "btn_back")
		:give("pos", x, y)
		:give("color", Palette.get("ui_not_hovered"))
		:give("camera")
		:give("bounding_box", x, y, 59, 45)
		:give("clickable")
		:give("hoverable")
		:give("hover_change_color", Palette.get("ui_hovered"), 0.2)
end

return Menu
