local Lights = {}

Lights.storage_room = {
	pl = {
		lz = 26,
		ls = 106,
		fade = 12,
		fixture_drop = 17,
		pos = {
			{ x = 92 },
			{ x = 242 },
		},
	},
}

Lights.utility_room = {
	pl = {
		lz = 26,
		ls = 106,
		fade = 12,
		fixture_drop = 17,
		pos = {
			{ x = 92 },
			{ x = 242 },
		},
	},
}

Lights.kitchen = {
	pl = {
		lz = 48,
		ls = 128,
		fade = 6,
		fixture_drop = 6,
		pos = {
			{ x = 86, fixture_drop = 5 },
			{ x = 386 },
		},
	},
	pl_mid = {
		lz = 7,
		ls = 128,
		fade = 6,
		zone = "mid",
		fixture_drop = 8,
		pos = {
			{ x = 184 },
			{ x = 215 },
			{ x = 242 },
		},
	},
}

Lights.living_room = {
	pl = {
		lz = 90,
		ls = 128,
		fade = 8,
		fixture_drop = 17,
		pos = {
			{ x = 91 },
			{ x = 329 },
		},
	},
	pl_mid = {
		lz = 2,
		ls = 64,
		fade = 32,
		zone = "mid",
		pos = {
			{ x = 186, y = 53 },
			{ x = 193, y = 45 },
			{ x = 202, y = 45 },
			{ x = 209, y = 53 },
		},
	},
}

Lights.office1 = {
	pl = {
		lz = 60,
		ls = 156,
		fade = 8,
		fixture_drop = 19,
		pos = {
			{ x = 123 },
			{ x = 275 },
			{ x = 484 },
			{ x = 657 },
		},
	},
	pc_light = {
		x = 70,
		y = 108,
		z = 3,
		intensity = 6,
		w = 16,
		h = 11,
		rows = 4,
		cols = 4,
	},
}

Lights.office2 = {
	pl = {
		lz = 60,
		ls = 156,
		fade = 8,
		fixture_drop = 19,
		pos = {
			{ x = 123 },
			{ x = 275 },
			{ x = 484 },
			{ x = 657 },
		},
	},
}

function Lights.get_light_y(room_id, group_key, index)
	local room = Lights[room_id]
	local group = room[group_key]
	local pos = group.pos[index]
	if pos.y then
		return pos.y
	end
	local drop = pos.fixture_drop or group.fixture_drop or 0
	return Data.RoomBounds.get_ceiling_bottom_y(room_id, group.zone) + drop
end

return Lights
