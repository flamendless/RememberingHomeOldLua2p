local Tween = Concord.system()

function Tween:init(world)
	self.world = world
end

function Tween:tween_camera_pos(camera, dur, dx, dy, ease)
	assert(Gamera.isCamera(camera), camera)
	assert:type(dur, "number")
	assert:type(dx, "number")
	assert:type(dy, "number")
	assert:type_or_nil(ease, "string")
	Flux.to(camera, dur, {
		x = dx,
		y = dy,
	}):ease(ease or Enums.ease.linear)
end

function Tween:tween_camera_pos_rel(camera, dur, dx, dy, ease)
	assert(Gamera.isCamera(camera), camera)
	assert:type(dur, "number")
	assert:type(dx, "number")
	assert:type(dy, "number")
	assert:type_or_nil(ease, "string")
	local cx, cy = camera:getPosition()
	Flux.to(camera, dur, {
		x = cx + dx,
		y = cy + dy,
	}):ease(ease or Enums.ease.linear)
end

function Tween:tween_camera_scale(camera, dur, scale, ease)
	assert(Gamera.isCamera(camera), camera)
	assert:type(dur, "number")
	assert:type(scale, "number")
	assert:type_or_nil(ease, "string")
	local _ = Flux.to(camera, dur, { scale = scale })
		:ease(ease or Enums.ease.linear)
end

return Tween
