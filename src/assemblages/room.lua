local Room = {}

function Room.ground(e, w, h, opt)
	assert:type_or_nil(opt, "table")
	assert(opt and opt.room_id, "room_id required")

	local b = Data.Rooms.get_bounds(opt.room_id)
	local ground_h = b.ground.height
	local ground_y = b.ground.y or (h - ground_h)
	local ground_x = Data.Rooms.ground_x(opt.room_id, opt)
	local ground_w = Data.Rooms.ground_width(opt.room_id, w, opt)

	e:give("id", "col_ground")
		:give("pos", ground_x, ground_y)
		:give("collider", ground_w, ground_h)
		:give("bump")
		:give("ground")
end

function Room.left_bound(e, w, h, opt)
	assert:type_or_nil(opt, "table")
	assert(opt and opt.room_id, "room_id required")

	local b = Data.Rooms.get_bounds(opt.room_id)
	local s = Data.Rooms.left_width(opt.room_id, opt)
	local left_x = b.left.x or 0

	e:give("id", "col_left_bound")
		:give("pos", left_x, 0):
		give("collider", s, h)
		:give("bump")
		:give("wall")
end

function Room.right_bound(e, w, h, opt)
	assert:type_or_nil(opt, "table")
	assert(opt and opt.room_id, "room_id required")

	local s = Data.Rooms.right_width(opt.room_id, opt)

	e:give("id", "col_right_bound")
		:give("pos", w - s, 0)
		:give("collider", s, h)
		:give("bump")
		:give("wall")
end

return Room
