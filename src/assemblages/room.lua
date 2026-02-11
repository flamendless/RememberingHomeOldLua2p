local Room = {}

local left_wall_w = 16
local right_wall_w = 16
local ground_h = 16

function Room.ground(e, w, h, opt)
	if opt then assert(type(opt) == "table") end

	e:give("id", "col_ground")
		:give("pos", left_wall_w, h - ground_h)
		:give("collider", w - left_wall_w - right_wall_w, ground_h)
		:give("bump")
		:give("ground")
end

function Room.left_bound(e, w, h, opt)
	if opt then assert(type(opt) == "table") end
	local s = left_wall_w * (opt and opt.sx or 1)

	e:give("id", "col_left_bound")
		:give("pos", 0, 0):
		give("collider", s, h)
		:give("bump")
		:give("wall")
end

function Room.right_bound(e, w, h, opt)
	if opt then assert(type(opt) == "table") end
	local s = right_wall_w * (opt and opt.sx or 1)

	e:give("id", "col_right_bound")
		:give("pos", w - s, 0)
		:give("collider", s, h)
		:give("bump")
		:give("wall")
end

return Room
