local Room = {}

function Room.ground(e, w, h, opt)
	assert:type_or_nil(opt, "table")
	assert(opt and opt.scene_id, "scene_id required")

	local b = Data.RoomBounds[opt.scene_id]
	local left_w = Data.RoomBounds.left_width(opt.scene_id, opt)
	local right_w = Data.RoomBounds.right_width(opt.scene_id, opt)
	local ground_h = b.ground.height

	e:give("id", "col_ground")
		:give("pos", left_w, h - ground_h)
		:give("collider", w - left_w - right_w, ground_h)
		:give("bump")
		:give("ground")
end

function Room.left_bound(e, w, h, opt)
	assert:type_or_nil(opt, "table")
	assert(opt and opt.scene_id, "scene_id required")

	local s = Data.RoomBounds.left_width(opt.scene_id, opt)

	e:give("id", "col_left_bound")
		:give("pos", 0, 0):
		give("collider", s, h)
		:give("bump")
		:give("wall")
end

function Room.right_bound(e, w, h, opt)
	assert:type_or_nil(opt, "table")
	assert(opt and opt.scene_id, "scene_id required")

	local s = Data.RoomBounds.right_width(opt.scene_id, opt)

	e:give("id", "col_right_bound")
		:give("pos", w - s, 0)
		:give("collider", s, h)
		:give("bump")
		:give("wall")
end

return Room
