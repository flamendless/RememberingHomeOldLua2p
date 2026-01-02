local Palette = require("palette")

local Common = {}

function Common.bg(e, bg_id)
	if not (type(bg_id) == "string") then
		error('Assertion failed: type(bg_id) == "string"')
	end
	e:give("id", "bg"):give("pos", 0, 0):give("sprite", bg_id):give("bg")
end

function Common.text(e, pos, str, font, color)
	e:give("id", "text"):give("text", str):give("font", font):give("pos", pos):give("color", color)
end

function Common.static_text(e, pos, str, font, color)
	e:give("id", "static_text"):give("static_text", str):give("font", font):give("pos", pos):give("color", color)
end

function Common.animated_sprite(e, animation_data, x, y, stop_on_last)
	e:give("id", "animated_sprite")
		:give("animation_data", animation_data)
		:give("pos", x, y)
		:give("animation", stop_on_last)
end

function Common.camera(e, cam, scale, w, h, clip_col)
	e:give("id", "camera")
		:give("camera", cam, true)
		:give("camera_transform", 0, scale)
		:give("camera_clip", w, h, clip_col or Palette.get("camera_clip"))
end

return Common
