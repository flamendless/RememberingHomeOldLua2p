local Player = {}

local GRAVITY = 320
local player_speed_data = {
	idle = { x = 0, y = 0 },
	walk = { x = 96, y = 0 },
	run = { x = 148, y = 0 },
}

function Player.get_multi_anim_data(for_flashlight, can_open_door)
	local tbl_anim = { "idle", "walk", "run" }
	if can_open_door then
		table.insert(tbl_anim, "open_door")
		table.insert(tbl_anim, "open_locked_door")
	end
	local data, mods = Animation.get_multi_by_id("player", tbl_anim)
	if for_flashlight then
		for _, tag in pairs(data) do
			tag.resource_id = tag.resource_id .. "_f"
		end
	end
	return data, mods
end

function Player.base(e, x, y, speed_data, can)
	if can then
		if not (type(can) == "table") then
			error('Assertion failed: type(can) == "table"')
		end
	end
	if can.move then
		if not (type(can.move) == "boolean") then
			error('Assertion failed: type(can.move) == "boolean"')
		end
	end
	if can.run then
		if not (type(can.run) == "boolean") then
			error('Assertion failed: type(can.run) == "boolean"')
		end
	end
	if can.open_door then
		if not (type(can.open_door) == "boolean") then
			error('Assertion failed: type(can.open_door) == "boolean"')
		end
	end
	local data, mods = Player.get_multi_anim_data(false, can.open_door)
	local collider = Data.Colliders.player

	e:give("id", "player")
		:give("player")
		:give("pos", x, y)
		:give("pos_vec2")
		:give("transform", 0, 1, 1, 18, 0)
		:give("collider", collider.w, collider.h, Enums.bump_filter.cross)
		:give("bump")
		:give("speed")
		:give("speed_data", speed_data)
		:give("gravity", GRAVITY)
		:give("animation")
		:give("animation_ev_update", "player_update_animation")
		:give("controller")
		:give("player_controller")
		:give("body")
		:give("multi_animation_data", Enums.anim_state.idle, data, mods)
		:give("current_frame")
		:give("movement")
		:give("fl_spawn_offset", 7, -16)
		:give("is_running")
		:give("is_interacting")
		:give("controller_origin")

	if can.move then
		e:give("can_move")
	end
	if can.run then
		e:give("can_run")
	end
	if can.interact then
		e:give("can_interact")
	end
	if can.open_door then
		e:give("can_open_door")
	end
end

function Player.outside_house(e, x, y)
	if not (type(x) == "number") then
		error('Assertion failed: type(x) == "number"')
	end
	if not (type(y) == "number") then
		error('Assertion failed: type(y) == "number"')
	end
	e:assemble(Player.base, x, y, player_speed_data, {
		move = false,
		run = false,
		open_door = true,
	})
		:give("z_index", 5)
		:give("color", { 1, 1, 1, 0 })
end

function Player.room(e, x, y)
	if not (type(x) == "number") then
		error('Assertion failed: type(x) == "number"')
	end
	if not (type(y) == "number") then
		error('Assertion failed: type(y) == "number"')
	end
	e:assemble(Player.base, x, y, player_speed_data, {
		move = false,
		run = false,
		open_door = true,
	})
		:give("z_index", 8)
		:give("color", { 1, 1, 1, 1 })
end

return Player
