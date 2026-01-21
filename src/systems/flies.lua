local Flies = Concord.system({
	pool = { "id", "bug", "fly" },
})

function Flies:init(world)
	self.world = world
end

function Flies:generate_flies(n, start_p, min_dist)
	if type(n) ~= "number" and n > 0 then
		error('Assertion failed: type(n) == "number" and n > 0')
	end
	if start_p:type() ~= "vec2" then
		error('Assertion failed: start_p:type() == "vec2"')
	end
	if type(min_dist) ~= "number" and min_dist > 0 then
		error('Assertion failed: type(min_dist) == "number" and min_dist > 0')
	end

	local sx, sy = start_p:unpack()

	for i = 1, n do
		local angle = love.math.random(-2 * math.pi, 2 * math.pi)
		local p = vec2(sx, sy)
		p:sadd(love.math.random(-min_dist, min_dist), 0)
		p:rotate_around_inplace(angle, start_p)
		local radius = love.math.random(min_dist, min_dist * 1.5)
		Concord.entity(self.world)
			:give("id", "fly" .. i)
			:give("fly", radius)
			:give("bug")
			:give("color", { 0, 0, 0, 1 })
			:give("point", 4)
			:give("pos", p:unpack())
			:give("ref_pos_vec2", sx, sy)
			:give("z_index", 99, false)
	end
end

function Flies:generate_flies_for_room_lights(scene)
	assert(type(scene) == "string")

	local d = Data.Lights[scene]
	for _, lp in ipairs(d.pl.pos) do
		self:generate_flies(
			love.math.random(8, 16),
			vec2(lp.x, lp.y),
			love.math.random(8, 12)
		)
	end
	if d.pl_mid then
		for _, lp in ipairs(d.pl_mid.pos) do
			self:generate_flies(
				love.math.random(8, 16),
				vec2(lp.x, lp.y),
				love.math.random(4, 8)
			)
		end
	end
end

function Flies:update(dt)
	for _, e in ipairs(self.pool) do
		local pos = e.pos
		local ref = e.ref_pos_vec2.value
		local fly = e.fly

		fly.turn_timer = fly.turn_timer - dt
		if fly.turn_timer <= 0 then
			local a = math.rad(love.math.random(30, 120))
			if love.math.random() < 0.5 then a = -a end

			local cosA = math.cos(a)
			local sinA = math.sin(a)

			local vx = fly.vel_x * cosA - fly.vel_y * sinA
			local vy = fly.vel_x * sinA + fly.vel_y * cosA
			fly.vel_x, fly.vel_y = vx, vy

			fly.turn_timer = 0.05 + love.math.random() * 0.4
		end

		fly.sharp_timer = fly.sharp_timer - dt
		if fly.sharp_timer <= 0 then
			fly.vel_x = fly.vel_x + (love.math.random() - 0.5) * 300
			fly.vel_y = fly.vel_y + (love.math.random() - 0.5) * 300
			fly.sharp_timer = 0.1 + love.math.random() * 0.3
		end

		local dx = ref.x - pos.x
		local dy = ref.y - pos.y
		local dist = math.sqrt(dx * dx + dy * dy)
		local comfortable_dist = fly.max_radius

		if dist > comfortable_dist then
			fly.vel_x = fly.vel_x + (dx / dist) * fly.pull
			fly.vel_y = fly.vel_y + (dy / dist) * fly.pull
		end

		local speed = math.sqrt(fly.vel_x * fly.vel_x + fly.vel_y * fly.vel_y)
		local max_speed = 200 + love.math.random(-50, 50)

		if speed > max_speed then
			fly.vel_x = fly.vel_x / speed * max_speed
			fly.vel_y = fly.vel_y / speed * max_speed
		end

		pos.x = pos.x + fly.vel_x * dt
		pos.y = pos.y + fly.vel_y * dt
	end
end

function Flies:set_flies_visibility(bool)
	if not (type(bool) == "boolean") then
		error('Assertion failed: type(bool) == "boolean"')
	end

	if #self.pool == 0 then
		Log.warn("pool is 0")
	end

	for _, e in ipairs(self.pool) do
		if bool then
			e:remove("hidden")
		else
			e:give("hidden")
		end
	end
end

return Flies
