local RoomBounds = {}

local def = {
	left = { width = 16 },
	right = { width = 16 },
	ground = { height = 16 },
	ceiling = {
		emitter_h = 10,
		emitter_margin_x = 48,
	},
}

local interior = {
	left = { width = def.left.width },
	right = { width = def.right.width },
	ground = { height = def.ground.height },
	ceiling = {
		bottom_y = 21,
		emitter_h = def.ceiling.emitter_h,
		emitter_margin_x = def.ceiling.emitter_margin_x,
		zones = {},
	},
}

RoomBounds.storage_room = {
	left = { width = def.left.width },
	right = { width = def.right.width },
	ground = { height = def.ground.height },
	ceiling = {
		bottom_y = 16,
		emitter_h = def.ceiling.emitter_h,
		emitter_margin_x = def.ceiling.emitter_margin_x,
		zones = {},
	},
}

RoomBounds.utility_room = {
	left = { width = def.left.width },
	right = { width = def.right.width },
	ground = { height = def.ground.height },
	ceiling = {
		bottom_y = 16,
		emitter_h = def.ceiling.emitter_h,
		emitter_margin_x = def.ceiling.emitter_margin_x,
		zones = {},
	},
}

RoomBounds.kitchen = {
	left = { width = def.left.width },
	right = { width = def.right.width },
	ground = { height = def.ground.height },
	ceiling = {
		bottom_y = 21,
		emitter_h = def.ceiling.emitter_h,
		emitter_margin_x = def.ceiling.emitter_margin_x,
		zones = {
			mid = { bottom_y = 49 },
		},
	},
}

RoomBounds.living_room = {
	left = { width = def.left.width },
	right = { width = def.right.width },
	ground = { height = def.ground.height },
	ceiling = {
		bottom_y = 21,
		emitter_h = def.ceiling.emitter_h,
		emitter_margin_x = def.ceiling.emitter_margin_x,
		zones = {
			mid = { bottom_y = 45 },
		},
	},
}

RoomBounds.office1 = interior
RoomBounds.office2 = interior

function RoomBounds.get_ceiling_bottom_y(room_id, zone_key)
	local room = RoomBounds[room_id]
	assert(room, room_id)
	local ceiling = room.ceiling
	if zone_key and ceiling.zones and ceiling.zones[zone_key] then
		return ceiling.zones[zone_key].bottom_y
	end
	return ceiling.bottom_y
end

function RoomBounds.ground_top_y(room_id, room_h)
	return room_h - RoomBounds[room_id].ground.height
end

function RoomBounds.left_width(room_id, opt)
	return RoomBounds[room_id].left.width * (opt and opt.sx or 1)
end

function RoomBounds.right_width(room_id, opt)
	return RoomBounds[room_id].right.width * (opt and opt.sx or 1)
end

function RoomBounds.emitter_rect(room_id, room_w, opts)
	local room = RoomBounds[room_id]
	local c = room.ceiling
	local h = opts and opts.h or c.emitter_h
	local margin = c.emitter_margin_x
	local w = opts and opts.w or (room_w and room_w - margin * 2)
	local x = opts and opts.x or margin
	return { x = x, y = c.bottom_y - h, w = w, h = h }
end

return RoomBounds
