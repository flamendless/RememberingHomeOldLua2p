local Concord = require("modules.concord.concord")
local Flux = require("modules.flux.flux")
local Gamera = require("modules.gamera.gamera")

local Enums = require("enums")

local Tween = Concord.system()

function Tween:init(world)
	self.world = world
end

function Tween:tween_camera_pos(camera, dur, dx, dy, ease)
	if not (Gamera.isCamera(camera)) then
		error("Assertion failed: Gamera.isCamera(camera)")
	end
	if not (type(dur) == "number") then
		error('Assertion failed: type(dur) == "number"')
	end
	if not (type(dx) == "number") then
		error('Assertion failed: type(dx) == "number"')
	end
	if not (type(dy) == "number") then
		error('Assertion failed: type(dy) == "number"')
	end
	if ease then
		if not (type(ease) == "string") then
			error('Assertion failed: type(ease) == "string"')
		end
	end
	Flux.to(camera, dur, {
		x = dx,
		y = dy,
	}):ease(ease or Enums.ease.linear)
end

function Tween:tween_camera_pos_rel(camera, dur, dx, dy, ease)
	if not (Gamera.isCamera(camera)) then
		error("Assertion failed: Gamera.isCamera(camera)")
	end
	if not (type(dur) == "number") then
		error('Assertion failed: type(dur) == "number"')
	end
	if not (type(dx) == "number") then
		error('Assertion failed: type(dx) == "number"')
	end
	if not (type(dy) == "number") then
		error('Assertion failed: type(dy) == "number"')
	end
	if ease then
		if not (type(ease) == "string") then
			error('Assertion failed: type(ease) == "string"')
		end
	end
	local cx, cy = camera:getPosition()
	Flux.to(camera, dur, {
		x = cx + dx,
		y = cy + dy,
	}):ease(ease or Enums.ease.linear)
end

function Tween:tween_camera_scale(camera, dur, scale, ease)
	if not (Gamera.isCamera(camera)) then
		error("Assertion failed: Gamera.isCamera(camera)")
	end
	if not (type(dur) == "number") then
		error('Assertion failed: type(dur) == "number"')
	end
	if not (type(scale) == "number") then
		error('Assertion failed: type(scale) == "number"')
	end
	if ease then
		if not (type(ease) == "string") then
			error('Assertion failed: type(ease) == "string"')
		end
	end
	local f = Flux.to(camera, dur, {
		scale = scale,
	}):ease(ease or Enums.ease.linear)
end

return Tween
