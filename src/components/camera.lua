Concord.component("cullable", function(c)
	c.value = false
end)

Concord.component("bar_height", function(c, h)
	assert(type(h) == "number", h)
	c.value = h
end)

local c_cam = Concord.component("camera", function(c, camera, is_main)
	if camera then
		assert(Gamera.isCamera(camera), camera)
	end
	if is_main then
		assert(type(is_main) == "boolean", is_main)
	end
	c.camera = camera
	c.is_main = is_main
end)

function c_cam:serialize()
	local x, y, w, h = self.camera:getWorld()
	return {
		data = { x, y, w, h },
		is_main = self.is_main,
	}
end

function c_cam:deserialize(data)
	self.camera = Gamera.new(unpack(data.data))
	self.is_main = data.is_main
end

Concord.component("camera_transform", function(c, rot, scale)
	assert(type(rot) == "number", rot)
	assert(type(scale) == "number", scale)
	c.rot = rot
	c.scale = scale
end)

Concord.component("camera_clip", function(c, w, h, color)
	assert(type(w) == "number", w)
	assert(type(h) == "number", h)
	assert(type(color) == "table", color)
	c.w = w
	c.h = h
	c.color = color
end)

Concord.component("camera_follow_offset", function(c, x, y)
	if x then
		assert(type(x) == "number", x)
	end
	if y then
		assert(type(y) == "number", y)
	end
	c.x = x or 0
	c.y = y or 0
end)
