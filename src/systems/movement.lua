local Movement = Concord.system({
	pool = { "speed", "gravity", "body", "movement", "can_move" },
	pool_walk = { "speed", "body", "movement", "can_move", "random_walk" },
})

function Movement:init(world)
	self.world = world
	self.pool.onRemoved = function(pool, e)
		if e:has("body") then
			local c_body = e:get("body")
			c_body.dx = 0
			c_body.vel_x = 0
		end
	end
end

function Movement:update(dt)
	for _, e in ipairs(self.pool_walk) do
		local random_walk = e:get("random_walk")
		local diff = random_walk.orig_pos:distance(e:get("pos_vec2").value)
		local body = e:get("body")

		local dir = random_walk.dir
		if diff <= random_walk.distance then
			body.dx = dir
			body.dir = dir
		else
			body.dir = dir
			e:remove("random_walk")
		end
	end

	for _, e in ipairs(self.pool) do
		local vel_x, vel_y = 0, e:get("gravity").value * dt
		local body = e:get("body")

		if e:has("override_animation") then
			body.dx = 0
		elseif body.dx ~= 0 then
			vel_x = e:get("speed").vx * body.dx * dt
		end

		body.vel_x, body.vel_y = vel_x, vel_y
		body.vel.x = body.vel_x
		body.vel.y = body.vel_y
	end
end

function Movement:update_speed_data(e, anim_name)
	assert((e.__isEntity and e:has("speed") and e:has("speed_data") and e:has("body")), e)
	assert:type(anim_name, "string")
	local new_speed = e:get("speed_data").speed_data[anim_name]
	if not new_speed then
		Log.warn("No speed data for anim", anim_name)
		return
	end
	local speed = e:get("speed")
	speed.vx = mathx.lerp(speed.vx, new_speed.x, 0.5)
end

local flags = {
	gravity = true,
}

function Movement:debug_update(dt)
	if not self.debug_show then
		return
	end
	self.debug_show = Slab.BeginWindow("Movement", {
		Title = self.debug_title,
		IsOpen = self.debug_show,
	})
	if Slab.CheckBox(flags.gravity, "gravity") then
		flags.gravity = not flags.gravity
		for _, e in ipairs(self.pool) do
			local gravity = e:get("gravity")
			if not flags.gravity then
				gravity.temp = gravity.value
				gravity.value = 0
			else
				gravity.value = gravity.temp
			end
		end
	end
	Slab.EndWindow()
end

function Movement:debug_on_drag(bool)
	assert:type(bool, "boolean")
	for _, e in ipairs(self.pool) do
		local gravity = e:get("gravity")
		if bool then
			gravity.temp = gravity.value
			gravity.value = 0
		else
			gravity.value = gravity.temp
		end
		flags.gravity = not bool
	end
end

return Movement
