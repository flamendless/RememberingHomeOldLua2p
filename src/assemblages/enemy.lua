local Enemy = {}

local enemy_speed_data = {
	idle = { x = 0, y = 0 },
	walk = { x = 16, y = 0 },
	chase = { x = 32, y = 0 },
}

function Enemy.get_multi_anim_data(enemy_type)
	assert(type(enemy_type) == "string", enemy_type)
	local tbl_anim = { "idle", "walk", "lean_back", "lean_return_back" }
	local data, mods = Animation.get_multi_by_id("enemy_" .. enemy_type, tbl_anim)
	return data, mods
end

function Enemy.base(e, enemy_type, x, y)
	assert(e.__isEntity, e)
	assert(type(enemy_type) == "string", enemy_type)
	assert(type(x) == "number" and type(y) == "number", x)
	local data, mods = Enemy.get_multi_anim_data(enemy_type)
	local collider = Data.Colliders.enemy[enemy_type].idle

	e:give("id", "enemy", "suit")
		:give("enemy", enemy_type)
		:give("pos", x, y)
		:give("pos_vec2")
		:give("animation", Animation.new_multi(data, mods, Enums.enemy_suit_anim.idle))
		:give("transform", 0, 1, 1, collider.ox, 0)
		:give("collider", collider.w, collider.h, Enums.bump_filter.cross)
		:give("bump")
		:give("controller")
		:give("enemy_controller")
		:give("body")
		:give("movement")
		:give("z_index", 10)
		:give("behavior_tree", Behaviors.Enemy, Enums.bt.enemy)
		:give("line_of_sight", 96)
		:give("controller_origin")
		:give("speed")
		:give("speed_data", enemy_speed_data)
		:give("gravity", 320)
		:give("can_move")

	return e
end

return Enemy
