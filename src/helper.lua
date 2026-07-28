local Helper = {}

function Helper.check_point_rect(px, py, x, y, w, h)
	return px > x and px < x + w and py > y and py < y + h
end

function Helper.get_real_size(e)
	assert(e.__isEntity, e)
	local box = e:get("bounding_box")
	local bw, bh = box.w, box.h
	if e:has("transform") then
		local t = e:get("transform")
		bw = bw * t.sx
		bh = bh * t.sy
	end
	return bw, bh
end

function Helper.get_frame_size(e)
	if e:has("animation") then
		local anim = e:get("animation")
		if anim.obj then
			local clip = anim.obj:current_clip()
			if clip then
				return clip.frame_width, clip.frame_height
			end
		end
	end
	if e:has("sprite") then
		local sprite = e:get("sprite")
		return sprite.iw, sprite.ih
	end
end

function Helper.get_offset(e)
	assert(e.__isEntity, e)
	local transform = e:get("transform")
	local fw, fh = Helper.get_frame_size(e)
	local ox = transform.ox
	local oy = transform.oy

	if fw and fh then
		if transform.ox == 0.5 then
			ox = fw / 2
		elseif transform.ox == 1 then
			ox = fw
		end

		if transform.oy == 0.5 then
			oy = fh / 2
		elseif transform.oy == 1 then
			oy = fh
		end
	end

	return ox, oy
end

function Helper.get_real_pos_box(e)
	assert(e.__isEntity, e)
	local box = e:get("bounding_box")
	local pos = e:get("pos")
	local x = pos.x
	local y = pos.y

	if e:has("camera") then
		x = box.screen_pos.x
		y = box.screen_pos.y
	end

	if e:has("transform") then
		local transform = e:get("transform")
		local ox, oy = Helper.get_offset(e)
		x = x - ox * transform.orig_sx
		y = y - oy * transform.orig_sy
	end

	return x, y
end

function Helper.get_ltwh(e)
	assert(e.__isEntity, e)
	--get the size
	local sprite = e:get("sprite")
	local w, h = sprite.iw, sprite.ih
	local fw, fh = Helper.get_frame_size(e)

	if e:has("collider") then
		local collider = e:get("collider")
		w = collider.w
		h = collider.h
	elseif fw and fh then
		w = fw
		h = fh
	end

	--get the scale
	local sx, sy = 1, 1
	local t
	if e:has("transform") then
		t = e:get("transform")
		sx = t.orig_sx
		sy = t.orig_sy
	end

	--get the offset
	local ox, oy = 0, 0
	if t and not e:has("collider") then
		ox = t.ox
		oy = t.oy
		if ox == 0.5 then
			ox = w/2
		elseif ox == 1 then
			ox = w
		end
		if oy == 0.5 then
			ox = h/2
		elseif oy == 1 then
			oy = h
		end
	end

	--get the pos
	local pos = e:get("pos")
	local x, y = pos.x, pos.y

	--calculate
	x = x - ox * sx
	y = y - oy * sy
	w = w * sx
	h = h * sy

	return x, y, w, h
end

return Helper
