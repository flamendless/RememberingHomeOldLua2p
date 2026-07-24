local Player = {}

local GRAVITY = 320
local player_speed_data = {
	idle = { x = 0, y = 0 },
	walk = { x = 96, y = 0 },
	run = { x = 148, y = 0 },
	open_lighter = { x = 0, y = 0 },
	open_lighter_left = { x = 0, y = 0 },
	close_lighter = { x = 0, y = 0 },
	close_lighter_left = { x = 0, y = 0 },
}

function Player.get_multi_anim_data(for_flashlight, can_open_door)
	local tbl_anim = { "idle", "walk", "run", "open_lighter", "close_lighter" }
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
	if can then assert(type(can) == "table", can) end
	if can.move then assert(type(can.move) == "boolean", can.move) end
	if can.run then assert(type(can.run) == "boolean", can.run) end
	if can.open_door then assert(type(can.open_door) == "boolean", can.open_door) end
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
		:give("animation", Animation.new_multi(data, mods, Enums.anim_state.idle))
		:give("controller")
		:give("player_controller")
		:give("body")
		:give("movement")
		:give("fl_spawn_offset", 7, -16)
		:give("is_running")
		:give("is_interacting")
		:give("controller_origin")
		:give("camera_follow_offset", 0, 0)

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
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	e:assemble(Player.base, x, y, player_speed_data, {
		move = false,
		run = false,
		open_door = true,
	})
		:give("z_index", 5)
		:give("color", { 1, 1, 1, 0 })
end

function Player.room(e, x, y)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	e:assemble(Player.base, x, y, player_speed_data, {
		move = false,
		run = false,
		open_door = true,
	})
		:give("z_index", 8)
		:give("color", { 1, 1, 1, 1 })
end

return Player
