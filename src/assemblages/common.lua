local Common = {}

function Common.bg(e, bg_id, w, h)
	assert:type(bg_id, "string")
	assert:type_or_nil(w, "number")
	assert:type_or_nil(h, "number")
	local use_gen = Data.BgAssets.get_use_gen(e.world)
	local resource_id = Data.BgAssets.get_resource_id(bg_id, use_gen)
	e:give("id", bg_id)
		:give("pos", 0, 0)
		:give("room_bg", bg_id)
		:give("sprite", resource_id, "images")
		:give("bg")

	if w and h then
		local sprite = e:get("sprite")
		local sx = w / sprite.iw
		local sy = h / sprite.ih
		e:give("transform", 0, sx, sy)
	end
end

function Common.text(e, pos, str, font, color)
	e:give("id", "text"):give("text", str):give("font", font):give("pos", pos):give("color", color)
end

function Common.static_text(e, pos, str, font, color)
	e:give("id", "static_text"):give("static_text", str):give("font", font):give("pos", pos):give("color", color)
end

function Common.animated_sprite(e, clip, x, y, stop_on_last)
	local obj = Animation.new_single(clip, stop_on_last)
	e:give("id", "animated_sprite")
		:give("animation", obj)
		:give("pos", x, y)
end

function Common.camera(e, cam, scale, w, h, clip_col)
	e:give("id", "camera")
		:give("camera", cam, true)
		:give("camera_transform", 0, scale)
		:give("camera_clip", w, h, clip_col or Palette.get("camera_clip"))
end

return Common
