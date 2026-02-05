local Movement = Concord.system({
	pool = { "speed", "gravity", "body", "movement", "can_move" },
	pool_walk = { "speed", "body", "movement", "can_move", "random_walk" },
})

function Movement:update(dt)
	for _, e in ipairs(self.pool_walk) do
		local random_walk = e.random_walk
		local orig_pos = random_walk.orig_pos
		local diff = random_walk.orig_pos:distance(e.pos_vec2.value)
		local body = e.body

		if diff <= random_walk.distance then
			body.dx = random_walk.dir
		else
			e:remove("random_walk")
		end

		body.dir = random_walk.dir
	end

	for _, e in ipairs(self.pool) do
		local vel_x, vel_y = 0, e.gravity.value * dt
		local body = e.body

		if body.dx ~= 0 then
			vel_x = e.speed.vx * body.dx * dt
		end

		body.vel_x, body.vel_y = vel_x, vel_y
		body.vel.x = body.vel_x
		body.vel.y = body.vel_y
	end
end

function Movement:update_speed_data(e, anim_name)
	if not (e.__isEntity and e.animation and e.speed and e.speed_data and e.body) then
		error("Assertion failed: e.__isEntity and e.animation and e.speed and e.speed_data and e.body")
	end
	if type(anim_name) ~= "string" then
		error('Assertion failed: type(anim_name) == "string"')
	end
	local new_speed = e.speed_data.speed_data[anim_name]
	if not new_speed then
		return
	end
	local speed = e.speed
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
			local gravity = e.gravity
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
	if type(bool) ~= "boolean" then
		error('Assertion failed: type(bool) == "boolean"')
	end
	for _, e in ipairs(self.pool) do
		local gravity = e.gravity
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
