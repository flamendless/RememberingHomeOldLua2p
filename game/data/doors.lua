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

function Doors.get_next(current_id, door_id)
	if not (type(current_id) == "string" and type(door_id) == "string") then error("Assertion failed: type(current_id) == \"string\" and type(door_id) == \"string\"") end
	if not (Doors[current_id][door_id]) then error("Assertion failed: Doors[current_id][door_id]") end
	return Doors[current_id][door_id]
end

return Doors
