local Doors = {}
local G = Enums.game_state

Doors[G.Outside] = {
	backdoor = G.StorageRoom,
}

Doors[G.StorageRoom] = {
	left_door = G.Kitchen,
	right_door = G.Outside,
}

Doors[G.UtilityRoom] = {
	left_door = G.Kitchen,
}

Doors[G.Kitchen] = {
	utility_door = G.UtilityRoom,
	right_door = G.StorageRoom,
}

Doors[G.LivingRoom] = {
	door = "DiningArea",
}

Doors[G.Office1] = {
	door_right = G.Office2,
}

Doors[G.Office2] = {
	door_left = G.Office1,
}

function Doors.get_next(current_id, door_id)
	assert((type(current_id) == "string" and type(door_id) == "string"), current_id)
	assert(Doors[current_id], "No defined current_id " .. current_id .. " in Doors data")
	assert(Doors[current_id][door_id], "No defined door_id " .. door_id .. " for current_id " .. current_id)
	return Doors[current_id][door_id]
end

return Doors
