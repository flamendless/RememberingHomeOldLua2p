local Animation = require("src.animation")
local Colliders = require("data.colliders")
local Enums = require("src.enums")
local BTEnemy = require("behaviors.enemy")

local Enemy = {}

local speed_data = {
	idle = {x = 0, y = 0},
	walk = {x = 16, y = 0},
	chase = {x = 32, y = 0},
}

function Enemy.get_multi_anim_data(enemy_type)
	if not (type(enemy_type) == "string") then error("Assertion failed: type(enemy_type) == \"string\"") end
	local tbl_anim = {"idle", "walk", "lean_back", "lean_return_back"}
	local data, mods = Animation.get_multi_by_id("enemy_" .. enemy_type, tbl_anim)
	return data, mods
end

function Enemy.base(e, enemy_type, x, y)
	if not (e.__isEntity) then error("Assertion failed: e.__isEntity") end
	if not (type(enemy_type) == "string") then error("Assertion failed: type(enemy_type) == \"string\"") end
	if not (type(x) == "number" and type(y) == "number") then error("Assertion failed: type(x) == \"number\" and type(y) == \"number\"") end
	local data, mods = Enemy.get_multi_anim_data(enemy_type)
	local collider = Colliders.enemy[enemy_type].idle

	e:give("id", "enemy", "suit")
	:give("enemy", enemy_type)
	:give("pos", vec2(x, y))
	:give("multi_animation_data", Enums.enemy_suit_anim.idle, data, mods)
	:give("transform", 0, 1, 1, collider.ox, 0)
	:give("collider", collider.w, collider.h, Enums.bump_filter.cross)
	:give("bump")
	:give("controller")
	:give("enemy_controller")
	:give("body")
	:give("animation")
	:give("current_frame")
	:give("movement")
	:give("z_index", 10)
	:give("behavior_tree", BTEnemy, Enums.bt.enemy)
	:give("line_of_sight", 96)
	:give("controller_origin")
	:give("speed")
	:give("speed_data", speed_data)
	:give("gravity", 320)
	:give("can_move")

	return e
end

return Enemy
