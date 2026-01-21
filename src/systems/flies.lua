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
		local dist = love.math.random(min_dist, min_dist * 1.5)
		local speed = love.math.random(24, 32)
		Concord.entity(self.world)
			:give("id", "fly" .. i)
			:give("fly")
			:give("bug")
			:give("color", { 0, 0, 0, 1 })
			:give("point", 4)
			:give("pos", p:unpack())
			:give("pos_vec2")
			:give("ref_pos_vec2", sx, sy)
			:give("angle", dist, angle)
			:give("angular_speed", speed, love.math.random(0, 1) * 2 - 1)
			:give("no_shader")
	end
end

function Flies:generate_flies_for_room_lights(scene)
	assert(type(scene) == "string")
	local d = Data.Lights[scene]
	for _, lp in ipairs(d.pl.pos) do
		self:generate_flies(
			love.math.random(8, 26),
			vec2(lp.x, lp.y),
			love.math.random(4, 8)
		)
	end
	if d.pl_mid	then
		for _, lp in ipairs(d.pl_mid.pos) do
			self:generate_flies(
				love.math.random(8, 26),
				vec2(lp.x, lp.y),
				love.math.random(4, 8)
			)
		end
	end
end

function Flies:update(dt)
	for _, e in ipairs(self.pool) do
		local pos = e.pos
		local pv = e.pos_vec2.value
		local ref = e.ref_pos_vec2.value
		local dist = pv:distance(ref)
		local angle = e.angle
		local a_speed = e.angular_speed
		local radius = angle.radius
		local r = angle.orig_radius / dist
		local dir = r < love.math.random() and -1 or 1

		pos.x = ref.x + radius * a_speed.dir * math.cos(angle.angle)
		pos.y = ref.y + radius * a_speed.dir * math.sin(angle.angle)
		angle.angle = angle.angle + dt * a_speed.dir
		angle.radius = angle.radius + a_speed.speed * dir * dt

		if love.math.random() < 0.15 then
			a_speed.dir = a_speed.dir * -1
		end
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
