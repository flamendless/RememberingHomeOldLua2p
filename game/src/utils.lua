local Utils = {
	file = {},
	serial = {},
	hash = {},
	string = {},
	table = {},
	math = {},
}

function Utils.file.read(filename)
	ASSERT(type(filename) == "string")
	local file = love.filesystem.getInfo(filename)
	Log.info(filename, "exists:", file ~= nil)
	if file then
		local content = love.filesystem.read(filename)
		return content, true
	end
	return false
end

function Utils.file.write(filename, data)
	ASSERT(type(filename) == "string")
	ASSERT(type(data) == "string")
	love.filesystem.write(filename, data)
	Log.info(filename, "written")
end

function Utils.serial.write(filename, data)
	ASSERT(type(filename) == "string")
	ASSERT(type(data) == "table")
	local serialized = Bitser.dumps(data)
	Utils.file.write(filename, serialized)
	return serialized
end

function Utils.serial.read(filename)
	ASSERT(type(filename) == "string")
	local content, exists = Utils.file.read(filename)
	if exists then
		local data = Bitser.loads(content)
		return data, exists
	end
	return false
end

function Utils.serial.de(content)
	ASSERT(type(content) == "string")
	return Bitser.loads(content)
end

function Utils.hash.compare(a, b)
	ASSERT(type(a) == "string")
	ASSERT(type(b) == "string")
	local hashed_a = love.data.hash("md5", a)
	local hashed_b = love.data.hash("md5", b)
	return hashed_a == hashed_b
end

function Utils.math.lerp_range(range, t)
	ASSERT((type(range) == "table") and range.min and range.max)
	ASSERT(type(t) == "number")
	return mathx.lerp(range.min, range.max, t)
end
function Utils.math.check_point_rect(point, pos, size)
	ASSERT(point:type() == "vec2")
	ASSERT(pos:type() == "vec2")
	ASSERT(size:type() == "vec2")
	local hs = size:smul(0.5)
	return intersect.point_aabb_overlap(
		point,
		pos:vsub_inplace(hs),
		hs
	)
end

function Utils.math.get_real_size(e)
	ASSERT(e.__isEntity)
	local box = e.bounding_box
	local bw, bh = box.w, box.h
	local t = e.transform
	if t then
		bw = bw * t.sx
		bh = bh * t.sy
	end
	return bw, bh
end

function Utils.math.get_offset(e)
	ASSERT(e.__isEntity)
	local transform = e.transform
	local anim_data = e.animation_data
	local sprite = e.sprite
	local offset = transform.offset
	local ox, oy = offset:unpack()

	if anim_data then
		if offset.x == 0.5 then
			ox = anim_data.frame_width * 0.5
		elseif offset.x == 1 then
			ox = anim_data.frame_width
		end

		if offset.y == 0.5 then
			oy = anim_data.frame_height * 0.5
		elseif offset.y == 1 then
			oy = anim_data.frame_height
		end
	elseif sprite then
		local iw, ih = sprite.iw, sprite.ih

		if offset.x == 0.5 then
			ox = iw * 0.5
		elseif offset.x == 1 then
			ox = iw
		end

		if offset.y == 0.5 then
			oy = ih * 0.5
		elseif offset.y == 1 then
			oy = ih
		end
	end

	return vec2(ox, oy)
end

function Utils.math.get_real_pos_box(e)
	ASSERT(e.__isEntity)
	local box = e.bounding_box
	local transform = e.transform
	local camera = e.camera
	local res = e.pos.pos:copy()

	if camera then
		res = box.screen_pos:copy()
	end

	if transform then
		local offset = Utils.math.get_offset(e)
		local dt = offset:vmul_inplace(transform.orig_scale)
		res:vsub_inplace(dt)
	end

	return res
end

function Utils.math.get_ltwh(e)
	ASSERT(e.__isEntity)
	--get the size
	local sprite = e.sprite
	local size = sprite.image_size
	local collider = e.collider
	local anim_data = e.animation_data

	if collider then
		size = collider.size
	elseif anim_data then
		size = anim_data.frame_size
	end

	--get the scale
	local scale
	local t = e.transform
	if t then
		scale = t.original_scale
	else
		scale = vec2(1, 1)
	end

	--get the offset
	local offset
	if t and (not collider) then
		offset = t.offset:copy()
		if offset.x == 0.5 then
			offset.x = size.x * 0.5
		elseif offset.x == 1 then
			offset.x = size.x
		end
		if offset.y == 0.5 then
			offset.y = size.y * 0.5
		elseif offset.y == 1 then
			offset.y = size.y
		end
	else
		offset = vec2()
	end

	--get the pos
	local pos = e.pos.pos:copy()

	--calculate
	local dt = offset:vmul_inplace(scale)
	pos:ssub_inplace(dt)
	size:vmul_inplace(scale)
	return pos, size
end


return Utils
