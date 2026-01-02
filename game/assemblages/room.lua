local Room = {}

local left_wall_w = 16
local right_wall_w = 16
local ground_h = 16

function Room.ground(e, w, h)
	e:give("id", "col_ground")
	:give("pos", left_wall_w, h - ground_h)
	:give("collider", w - left_wall_w - right_wall_w, ground_h)
	:give("bump")
	:give("ground")
end

function Room.left_bound(e, w, h)
	e:give("id", "col_left_bound")
	:give("pos", 0, 0)
	:give("collider", left_wall_w, h)
	:give("bump")
	:give("wall")
end

function Room.right_bound(e, w, h)
	e:give("id", "col_right_bound")
	:give("pos", w - right_wall_w, 0)
	:give("collider", right_wall_w, h)
	:give("bump")
	:give("wall")
end

return Room
