local Doors = {}

Doors.Outside = {
	backdoor = "StorageRoom",
}

Doors.StorageRoom = {
	left_door = "Kitchen",
	right_door = "Outside",
}

Doors.UtilityRoom = {
	left_door = "Kitchen",
}

Doors.Kitchen = {
	utility_door = "UtilityRoom",
	right_door = "StorageRoom",
}

Doors.LivingRoom = {
	door = "DiningArea",
}

Doors.Office1 = {
	door_right = "Office2",
}

Doors.Office2 = {
	door_left = "Office1",
}

function Doors.get_next(current_id, door_id)
	assert((type(current_id) == "string" and type(door_id) == "string"), current_id)
	assert(Doors[current_id], "No defined current_id " .. current_id .. " in Doors data")
	assert(Doors[current_id][door_id], "No defined door_id " .. door_id .. " for current_id " .. current_id)
	return Doors[current_id][door_id]
end

return Doors
