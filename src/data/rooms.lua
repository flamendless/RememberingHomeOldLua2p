local Rooms = {}
local G = Enums.game_state
local R = Enums.face_dir.right

-- NODES = rooms
-- DIRECTED EDGES = DOORS
--    has source room
--    default = non-door entries (Menu)
Rooms.nodes = {}

Rooms.nodes[G.Outside] = {
	default = { 852, 258 },
	entries = { [G.Menu] = { 800, 258 } },
	doors = {
		backdoor = { to = G.StorageRoom, spawn = { 312, 48 } },
		shed = { to = G.Shed, spawn = { 312, 48 } },
	},
}

Rooms.nodes[G.Shed] = {
	bounds = {
		left = { width = 16 },
		right = { width = 16 },
		ground = { height = 16 },
		ceiling = {
			bottom_y = 16,
			emitter_h = 10,
			emitter_margin_x = 48,
			zones = {},
		},
	},
	default = { 312, 48 },
	doors = {
		right_door = { to = G.Outside, spawn = { 100, 263 } },
	},
}

Rooms.nodes[G.StorageRoom] = {
	bounds = {
		left = { width = 16 },
		right = { width = 16 },
		ground = { height = 16 },
		ceiling = {
			bottom_y = 16,
			emitter_h = 10,
			emitter_margin_x = 48,
			zones = {},
		},
	},
	default = { 312, 48 },
	doors = {
		right_door = { to = G.Outside, spawn = { 446, 258 } },
		left_door = { to = G.Kitchen, spawn = { 443, 64 } },
	},
}

Rooms.nodes[G.UtilityRoom] = {
	bounds = {
		left = { width = 16 },
		right = { width = 16 },
		ground = { height = 16 },
		ceiling = {
			bottom_y = 16,
			emitter_h = 10,
			emitter_margin_x = 48,
			zones = {},
		},
	},
	default = { 318, 48 },
	doors = {
		left_door = { to = G.Kitchen, spawn = { 398, 64 } },
	},
}

Rooms.nodes[G.Kitchen] = {
	bounds = {
		left = { width = 16 },
		right = { width = 16 },
		ground = { height = 16 },
		ceiling = {
			bottom_y = 21,
			emitter_h = 10,
			emitter_margin_x = 48,
			zones = {
				mid = { bottom_y = 49 },
			},
		},
	},
	default = { 443, 64 },
	doors = {
		utility_door = { to = G.UtilityRoom, spawn = { 16, 48, R } },
		right_door = { to = G.StorageRoom, spawn = { 16, 48, R } },
	},
}

Rooms.nodes[G.LivingRoom] = {
	bounds = {
		left = { width = 16 },
		right = { width = 16 },
		ground = { height = 16 },
		ceiling = {
			bottom_y = 21,
			emitter_h = 10,
			emitter_margin_x = 48,
			zones = {
				mid = { bottom_y = 45 },
			},
		},
	},
	default = { 360, 64 },
	doors = {
		door = { to = "DiningArea" },
	},
}

Rooms.nodes[G.TotallyDarkRoom] = {
	default = Rooms.nodes[G.LivingRoom].default,
	bounds = Rooms.nodes[G.LivingRoom].bounds,
}

Rooms.nodes[G.Office1] = {
	bounds = {
		left = { width = 16 },
		right = { width = 16 },
		ground = { height = 16 },
		ceiling = {
			bottom_y = 21,
			emitter_h = 10,
			emitter_margin_x = 48,
			zones = {},
		},
	},
	default = { 127, 64 },
	doors = {
		door_right = { to = G.Office2, spawn = { 86, 64, R } },
	},
}

Rooms.nodes[G.Office2] = {
	bounds = {
		left = { width = 16 },
		right = { width = 16 },
		ground = { height = 16 },
		ceiling = {
			bottom_y = 21,
			emitter_h = 10,
			emitter_margin_x = 48,
			zones = {},
		},
	},
	default = { 127, 64 },
	doors = {
		door_left = { to = G.Office1, spawn = { 680, 64, Enums.face_dir.left } },
	},
}

local spawn_index = {}
for from, node in pairs(Rooms.nodes) do
	spawn_index[from] = spawn_index[from] or {}
	spawn_index[from].default = node.default
	for k, v in pairs(node.entries or {}) do
		spawn_index[from][k] = v
	end
	for door_id, edge in pairs(node.doors or {}) do
		if Rooms.nodes[edge.to] and edge.spawn then
			spawn_index[edge.to] = spawn_index[edge.to] or {}
			if DEV and spawn_index[edge.to][from] then
				Log.warn("Rooms: spawn collision entering", edge.to, "from", from, "via door", door_id)
			end
			spawn_index[edge.to][from] = edge.spawn
		end
	end
end

function Rooms.get_bounds(room_id)
	local bounds = Rooms.nodes[room_id].bounds
	assert(bounds, room_id)
	return bounds
end

function Rooms.get_ceiling_bottom_y(room_id, zone_key)
	local bounds = Rooms.get_bounds(room_id)
	local ceiling = bounds.ceiling
	if zone_key and ceiling.zones and ceiling.zones[zone_key] then
		return ceiling.zones[zone_key].bottom_y
	end
	return ceiling.bottom_y
end

function Rooms.ground_top_y(room_id, room_h)
	return room_h - Rooms.get_bounds(room_id).ground.height
end

function Rooms.left_width(room_id, opt)
	return Rooms.get_bounds(room_id).left.width * (opt and opt.sx or 1)
end

function Rooms.right_width(room_id, opt)
	return Rooms.get_bounds(room_id).right.width * (opt and opt.sx or 1)
end

function Rooms.emitter_rect(room_id, room_w, opts)
	local bounds = Rooms.get_bounds(room_id)
	local c = bounds.ceiling
	local h = opts and opts.h or c.emitter_h
	local margin = c.emitter_margin_x
	local w = opts and opts.w or (room_w and room_w - margin * 2)
	local x = opts and opts.x or margin
	return { x = x, y = c.bottom_y - h, w = w, h = h }
end

function Rooms.get_next(current_id, door_id)
	assert((type(current_id) == "string" and type(door_id) == "string"), current_id)
	local node = Rooms.nodes[current_id]
	assert(node, "No defined current_id " .. current_id .. " in Rooms data")
	assert(node.doors and node.doors[door_id], "No defined door_id " .. door_id .. " for current_id " .. current_id)
	return node.doors[door_id].to
end

function Rooms.get_spawn(current_id, prev_id)
	local t = assert(spawn_index[current_id], "No spawn data for current_id " .. tostring(current_id))
	local d = t[prev_id] or t.default
	assert(d, "No spawn data given current_id " .. tostring(current_id) .. " and prev_id " .. tostring(prev_id))
	local face = d[3] or Enums.face_dir.left
	assert(
		type(face) == "string" and (face == Enums.face_dir.left or face == Enums.face_dir.right),
		face
	)
	return d[1], d[2], face
end

function Rooms.get_default_spawn(room_id)
	local t = assert(spawn_index[room_id], "No spawn data for room_id " .. tostring(room_id))
	return t.default
end

if DEV then
	for from, node in pairs(Rooms.nodes) do
		for door_id, edge in pairs(node.doors or {}) do
			if not Rooms.nodes[edge.to] then
				Log.warn("Rooms: door", door_id, "in", from, "targets unknown room", tostring(edge.to))
			end
		end
	end
end

return Rooms
