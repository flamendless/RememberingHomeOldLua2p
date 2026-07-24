local Common = {}

function Common.bg(e, bg_id, w)
	assert(type(bg_id) == "string", bg_id)
	if w then
		assert(type(w) == "number")
	end
	e:give("id", "bg"):give("pos", 0, 0):give("sprite", bg_id):give("bg")

	if w then
		local iw = e.sprite.iw
		local sx = w/iw
		e:give("transform", 0, sx, 1)
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
