Concord.component("cullable", function(c)
	c.value = false
end)

Concord.component("bar_height", function(c, h)
	if type(h) ~= "number" then
		error('Assertion failed: type(h) == "number"')
	end
	c.value = h
end)

local c_cam = Concord.component("camera", function(c, camera, is_main)
	if camera then
		if not (Gamera.isCamera(camera)) then
			error("Assertion failed: Gamera.isCamera(camera)")
		end
	end
	if is_main then
		if type(is_main) ~= "boolean" then
			error('Assertion failed: type(is_main) == "boolean"')
		end
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
	if type(rot) ~= "number" then
		error('Assertion failed: type(rot) == "number"')
	end
	if type(scale) ~= "number" then
		error('Assertion failed: type(scale) == "number"')
	end
	c.rot = rot
	c.scale = scale
end)

Concord.component("camera_clip", function(c, w, h, color)
	if type(w) ~= "number" then
		error('Assertion failed: type(w) == "number"')
	end
	if type(h) ~= "number" then
		error('Assertion failed: type(h) == "number"')
	end
	if type(color) ~= "table" then
		error('Assertion failed: type(color) == "table"')
	end
	c.w = w
	c.h = h
	c.color = color
end)

Concord.component("camera_follow_offset", function(c, x, y)
	if x then
		if type(x) ~= "number" then
			error('Assertion failed: type(x) == "number"')
		end
	end
	if y then
		if type(y) ~= "number" then
			error('Assertion failed: type(y) == "number"')
		end
	end
	c.x = x or 0
	c.y = y or 0
end)
