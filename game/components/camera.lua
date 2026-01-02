Concord.component("cullable", function(c)
	c.value = false
end)

Concord.component("bar_height", function(c, h)
	ASSERT(type(h) == "number")
	c.value = h
end)

local c_cam = Concord.component("camera", function(c, camera, is_main)
	SASSERT(camera, type(camera) == "table")
	SASSERT(is_main, type(is_main) == "boolean")
	c.camera = camera
	c.is_main = is_main
end)

function c_cam:serialize()
	return {
		data = {self.camera:getWorld()},
		is_main = self.is_main,
	}
end

function c_cam:deserialize(data)
	self.camera = Gamera.new(unpack(data.data))
	self.is_main = data.is_main
end

Concord.component("camera_transform", function(c, rot, scale)
	ASSERT(type(rot) == "number")
	ASSERT(type(scale) == "number")
	c.rot = rot
	c.scale = scale
end)

Concord.component("camera_clip", function(c, size, color)
	ASSERT(size:type() == "vec2")
	ASSERT(type(color) == "table" and (#color == 3 or #color == 4))
	c.size = size
	c.color = color
end)

Concord.component("camera_follow_offset", function(c, pos)
	SASSERT(pos, pos:type() == "number")
	c.pos = pos or vec2()
end)
