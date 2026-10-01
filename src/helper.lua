local Helper = {}

function Helper.check_point_rect(px, py, x, y, w, h)
	assert:type(px, "number")
	assert:type(py, "number")
	assert:type(x, "number")
	assert:type(y, "number")
	assert:type(w, "number")
	assert:type(h, "number")
	return px > x and px < x + w and py > y and py < y + h
end

function Helper.horizontal_rect_gap(ax, aw, bx, bw)
	assert:type(ax, "number")
	assert:type(aw, "number")
	assert:type(bx, "number")
	assert:type(bw, "number")
	if ax + aw < bx then
		return bx - (ax + aw)
	end
	if bx + bw < ax then
		return ax - (bx + bw)
	end
	return 0
end

function Helper.interact_range_margin(aw, _, bw, _, reach_scale)
	assert:type(aw, "number")
	assert:type(bw, "number")
	assert:type_or_nil(reach_scale, "number")
	reach_scale = reach_scale or 0.58
	return math.max(2, math.min(aw, bw) * reach_scale * 0.5)
end

function Helper.is_in_interact_range(ax, ay, aw, ah, bx, by, bw, bh, reach_scale)
	assert:type(ax, "number")
	assert:type(ay, "number")
	assert:type(aw, "number")
	assert:type(ah, "number")
	assert:type(bx, "number")
	assert:type(by, "number")
	assert:type(bw, "number")
	assert:type(bh, "number")
	assert:type_or_nil(reach_scale, "number")
	if ay >= by + bh or ay + ah <= by then
		return false
	end
	local margin = Helper.interact_range_margin(aw, ah, bw, bh, reach_scale)
	return Helper.horizontal_rect_gap(ax, aw, bx, bw) <= margin
end

function Helper.get_real_size(e)
	assert:entity(e)
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
	assert:entity(e)
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
	assert:entity(e)
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

function Helper.get_animation_draw_params(e)
	assert:entity(e)
	local rot, sx, sy, ox, oy = 0, 1, 1, 0, 0

	if e:has("transform") then
		local transform = e:get("transform")
		rot = transform.rotation
		sx, sy = transform.sx, transform.sy
		ox, oy = Helper.get_offset(e)
	end

	if e:has("animation") then
		local obj = e:get("animation").obj
		if obj and obj.anim8 then
			local _, _, _, _, sx2, sy2, ox2, oy2 = obj.anim8:getFrameInfo(0, 0, rot, sx, sy, ox, oy)
			sx, sy, ox, oy = sx2, sy2, ox2, oy2
		end
	end

	return sx, sy, ox, oy
end

function Helper.get_real_pos_box(e)
	assert:entity(e)
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
	assert:entity(e)
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

function Helper.get_collider_rect(e)
	assert:entity(e)
	assert(e:has("collider"), e)
	local pos = e:get("pos")
	local collider = e:get("collider")
	local x, y = pos.x, pos.y
	local col_offset = e:get("collider_offset")
	if col_offset then
		x = x + col_offset.ox
		y = y + col_offset.oy
	end
	return x, y, collider.w, collider.h
end

function Helper.interact_face_dir(e_player, e_target)
	assert:entity(e_player)
	assert(e_player:has("collider"), e_player)
	assert:entity(e_target)
	assert(e_target:has("collider"), e_target)

	local px, _, pw = Helper.get_collider_rect(e_player)
	local cx, _, cw = Helper.get_collider_rect(e_target)
	local player_cx = px + pw * 0.5
	local target_cx = cx + cw * 0.5

	if player_cx > target_cx then
		return -1
	end
	if player_cx < target_cx then
		return 1
	end
	return nil
end

function Helper.can_proceed_interact(e_player, e_target)
	assert:entity(e_player)
	assert:entity(e_target)
	local face_dir = Helper.interact_face_dir(e_player, e_target)
	if face_dir and e_player:has("body") then
		if e_player:get("body").dir ~= face_dir then
			return false
		end
	end
	local req = e_target:get("req_col_dir")
	if not req then
		return true
	end
	if not face_dir then
		return false
	end
	return face_dir == req.value
end

function Helper.get_fly_ref_xy(room_id, group_key, index)
	assert:type(room_id, "string")
	assert:type(group_key, "string")
	assert:type(index, "number")

	local pos = Data.Lights[room_id][group_key].pos[index]
	local x = pos.x
	local y = Data.Lights.get_light_y(room_id, group_key, index)
	if pos.bulb_quad_h then
		assert:type(pos.y, "number")
		y = pos.y + pos.bulb_quad_h - 8
	end
	if pos.bulb_quad_w then
		x = pos.x + pos.bulb_quad_w * 0.5
	end
	return x, y
end

return Helper
