local Rooms = {}
local G = Enums.game_state
local R = Enums.face_dir.right

-- NODES = rooms
-- DIRECTED EDGES = DOORS
--    has source room
--    default = non-door entries (Menu)
Rooms.nodes = {}

Rooms.nodes[G.Outside] = {
	default = { 800, 258 },
	entries = { [G.Menu] = { 800, 258 } },
	doors = {
		backdoor = { to = G.StorageRoom, spawn = { 312, 48 } },
	},
}

Rooms.nodes[G.StorageRoom] = {
	default = { 312, 48 },
	doors = {
		right_door = { to = G.Outside, spawn = { 446, 258 } },
		left_door = { to = G.Kitchen, spawn = { 443, 64 } },
	},
}

Rooms.nodes[G.UtilityRoom] = {
	default = { 318, 48 },
	doors = {
		left_door = { to = G.Kitchen, spawn = { 398, 64 } },
	},
}

Rooms.nodes[G.Kitchen] = {
	default = { 443, 64 },
	doors = {
		utility_door = { to = G.UtilityRoom, spawn = { 16, 48, R } },
		right_door = { to = G.StorageRoom, spawn = { 16, 48, R } },
	},
}

Rooms.nodes[G.LivingRoom] = {
	default = { 360, 64 },
	doors = {
		door = { to = "DiningArea" },
	},
}

Rooms.nodes[G.TotallyDarkRoom] = { default = Rooms.nodes[G.LivingRoom].default }

Rooms.nodes[G.Office1] = {
	default = { 127, 64 },
	doors = {
		door_right = { to = G.Office2, spawn = { 86, 64, R } },
	},
}

Rooms.nodes[G.Office2] = {
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
