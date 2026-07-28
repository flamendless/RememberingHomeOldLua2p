local get_dt = love.timer.getDelta
local lm_random = love.math.random

local bt_enemy = Enums.bt.enemy

local function set_node(e, tag)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	assert(type(tag) == "string", tag)
	e:get("behavior_tree").current_node = bt_enemy[tag]
end

local function set_node_bt(e, tag)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	assert(type(tag) == "string", tag)
	return function()
		set_node(e, tag)
		return "success"
	end
end

local function is_current_node_bt(e, ...)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	local nodes = { ... }
	assert((type(nodes) == "table" and #nodes > 0), nodes)
	return function()
		local behavior_tree = e:get("behavior_tree")
		local current_node = behavior_tree.current_node
		for _, node in ipairs(nodes) do
			if current_node == node then
				return "success"
			end
		end
		return "failure"
	end
end

local function is_current_anim(e, tag)
	assert(e.__isEntity and e:has("behavior_tree") and e:has("animation"), e)
	assert(type(tag) == "string", tag)
	local animation = e:get("animation")
	return (animation.obj.base_tag == tag) and "success" or "failure"
end

local function is_current_anim_bt(e, tag)
	assert(e.__isEntity and e:has("behavior_tree") and e:has("animation"), e)
	assert(type(tag) == "string", tag)
	return function()
		return is_current_anim(e, tag)
	end
end

local function is_current_anim_done(e, tag)
	assert(e.__isEntity and e:has("behavior_tree") and e:has("animation"), e)
	assert(type(tag) == "string", tag)
	local animation = e:get("animation")
	local base_tag = animation.obj.base_tag
	if base_tag ~= tag then
		return "running"
	end
	local obj = animation.obj
	return (obj.frame == obj.frame_max) and "success" or "running"
end

local function is_current_anim_done_bt(e, tag)
	assert(e.__isEntity and e:has("behavior_tree") and e:has("animation"), e)
	assert(type(tag) == "string", tag)
	return function()
		return is_current_anim_done(e, tag)
	end
end

local function has_component_bt(e, component)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	assert(type(component) == "string", component)
	return function()
		if e:has(component) then
			return "success"
		end
		return "failure"
	end
end

local function get_distance(world, e, other_e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree") and e:has("ref_e_key"), e)
	if other_e then
		assert(other_e.__isEntity, other_e)
	end
	other_e = other_e or world:getEntityByKey(e:get("ref_e_key").value)
	local controller_origin = e:get("controller_origin")
	return controller_origin.vec2:distance(other_e:get("controller_origin").vec2)
end

local function is_other_behind(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree") and e:has("ref_e_key"), e)
	local other_e = world:getEntityByKey(e:get("ref_e_key").value)
	local pos = e:get("pos")
	local other_pos = other_e:get("pos")
	local diff = (pos.x <= other_pos.x) and -1 or 1
	local body = e:get("body")
	local is_behind = body.dir == diff
	if not is_behind then
		return "failure"
	end
	local distance = get_distance(world, e, other_e)
	local line_of_sight = e:get("line_of_sight")
	local within_distance = distance <= line_of_sight.value
	return within_distance and "success" or "failure"
end

local function random(tbl)
	assert((type(tbl) == "table" and #tbl > 0), tbl)

	for _, bt in ipairs(tbl) do
		assert(type(bt) == "function", bt)
	end

	local r = lm_random(1, #tbl)
	return tbl[r]
end

local function random_bt(tbl)
	assert((type(tbl) == "table" and #tbl > 0), tbl)

	for _, bt in ipairs(tbl) do
		assert(type(bt) == "function", bt)
	end

	return function()
		return random(tbl)()
	end
end

local function wait_random_bt(e, min, max)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	assert(type(min) == "number", min)
	assert(type(max) == "number", max)
	assert((min > 0 and min < max), min)
	local elapsed = 0
	local r = lm_random(min, max)
	return function()
		elapsed = elapsed + get_dt()
		if elapsed >= r then
			elapsed = 0
			r = lm_random(min, max)
			return "success"
		end
		return "running"
	end
end

local function sees_other(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree") and e:has("ref_e_key"), e)
	local distance = get_distance(world, e)
	local line_of_sight = e:get("line_of_sight")
	local sees = distance <= line_of_sight.value
	return sees and "success" or "failure"
end

local function chase_other(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree") and e:has("ref_e_key"), e)
	set_node(e, "chase")
	local sees = sees_other(world, e)
	if sees == "failure" then
		return "failure"
	end
	if e:has("collide_with") then
		return "success"
	end
	return "running"
end

local function has_collide_with(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	if e:has("collide_with") then
		return "success"
	end
	return "failure"
end

local function skip_collider_update(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	e:give("skip_collider_update")
	return "success"
end

local function caught_other(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	return Beehive.Sequence({
		is_current_node_bt(e, bt_enemy.chase, bt_enemy.walk, bt_enemy.caught_other),
		has_collide_with,
		set_node_bt(e, bt_enemy.caught_other),
		skip_collider_update,
	})
end

local function lean_return_back(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	return Beehive.Sequence({
		is_current_anim_bt(e, bt_enemy.lean_back),
		Beehive.Invert(is_other_behind),
		set_node_bt(e, bt_enemy.lean_return_back),
		is_current_anim_done_bt(e, bt_enemy.lean_return_back),
		Beehive.Fail,
	})
end

local function lean_back(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	return Beehive.Sequence({
		is_other_behind,
		set_node_bt(e, bt_enemy.lean_back),
	})
end

local function chase(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	return Beehive.Sequence({
		sees_other,
		random({
			chase_other,
		}),
		set_node_bt(e, bt_enemy.chase),
	})
end

local function walk(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	return Beehive.Sequence({
		has_component_bt(e, "random_walk"),
	})
end

local function wait(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	local min = lm_random(0.5, 0.9)
	local max = min + lm_random(0.5, 0.9)

	return Beehive.Sequence({
		wait_random_bt(e, min, max),
		random_bt({
			set_node_bt(e, bt_enemy.idle),
			set_node_bt(e, bt_enemy.walk),
		}),
	})
end

return function(world, e)
	assert(world.__isWorld, world)
	assert(e.__isEntity and e:has("behavior_tree"), e)
	return Beehive.Selector({
		caught_other(world, e),
		lean_return_back(world, e),
		lean_back(world, e),
		chase(world, e),
		walk(world, e),
		wait(world, e),
	})
end
