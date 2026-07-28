local EnemyController = Concord.system({
	pool = { "id", "enemy_controller", "behavior_tree" },
})

local anim_mapping = {
	walk = "walk",
	chase = "walk",
	lean_back = "lean_back",
	lean_return_back = "lean_return_back",
}

function EnemyController:init(world)
	self.world = world

	self.pool.onAdded = function(_, e)
		local e_player = self.world:getResource("e_player")
		if e_player then
			e:give("ref_e_key", e_player)
		end
		self.world:setResource("e_enemy", e)
	end
end

function EnemyController:spawn_enemy(enemy_type, x, y)
	assert:type(enemy_type, "string")
	assert:type(x, "number")
	assert:type(y, "number")
	Concord.entity(self.world):assemble(Assemblages.Enemy.base, enemy_type, x, y)
end

local function base_tag_for(anim_name)
	return anim_name:gsub("_left$", "")
end

function EnemyController:update(dt)
	for _, e in ipairs(self.pool) do
		local body = e:get("body")
		body.dx = 0

		local current_node = e:get("behavior_tree").current_node
		if current_node == Enums.bt.enemy.walk then
			if not e:has("random_walk") then
				local line_of_sight = e:get("line_of_sight").value
				local dir = 1 - love.math.random(0, 1) * 2
				local distance = love.math.random(line_of_sight * 0.25, line_of_sight)
				local pos = e:get("pos")
				e:give("random_walk", dir, distance, pos.x, pos.y)
			end
		elseif current_node == Enums.bt.enemy.chase then
			local other_e = self.world:getEntityByKey(e:get("ref_e_key").value)
			local other_pos = other_e:get("pos")
			local other_key = other_e:get("key")
			if not e:has("collide_with") or e:get("collide_with").value ~= other_key.value then
				local pos = e:get("pos")
				if pos.x <= other_pos.x then
					body.dx = 1
				else
					body.dx = -1
				end
			end
		end

		local anim_name = anim_mapping[current_node] or "idle"
		if body.dir == -1 then
			anim_name = anim_name .. "_left"
		end

		e:get("animation").obj:play(anim_name, base_tag_for(anim_name))
		self.world:emit("update_speed_data", e, current_node or anim_name)
	end
end

local cb_line_of_sight = true

function EnemyController:debug_update(dt)
	if not self.debug_show then
		return
	end
	self.debug_show = Slab.BeginWindow("enemy_controller", {
		Title = "EnemyController",
		IsOpen = self.debug_show,
	})
	if Slab.CheckBox(cb_line_of_sight, "Line of Sight") then
		cb_line_of_sight = not cb_line_of_sight
	end
	if Slab.Button("flip") then
		for _, e in ipairs(self.pool) do
			local body = e:get("body")
			body.dir = body.dir * -1
		end
	end
	Slab.EndWindow()
end

function EnemyController:debug_draw()
	if not self.debug_show then
		return
	end

	if cb_line_of_sight then
		local r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(1, 0, 0, 1)

		for _, e in ipairs(self.pool) do
			local line_of_sight = e:get("line_of_sight").value
			local dir = e:get("body").dir
			local controller_origin = e:get("controller_origin")
			local x = controller_origin.x
			local y = controller_origin.y
			love.graphics.line(x, y, x + line_of_sight * dir, y)
		end

		love.graphics.setColor(r, g, b, a)
	end
end

return EnemyController
