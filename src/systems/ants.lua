local Ants = Concord.system({
	pool = { "id", "bug", "ant" },
})

function Ants:init(world)
	self.world = world
end

function Ants:generate_ants(n, start_p, end_p, path_repeat, ms)
	if type(n) ~= "number" and n > 0 then
		error('Assertion failed: type(n) == "number" and n > 0')
	end
	if start_p:type() ~= "vec2" then
		error('Assertion failed: start_p:type() == "vec2"')
	end
	if end_p:type() ~= "vec2" then
		error('Assertion failed: end_p:type() == "vec2"')
	end
	if type(path_repeat) ~= "boolean" then
		error('Assertion failed: type(path_repeat) == "boolean"')
	end
	if type(ms) ~= "number" then
		error('Assertion failed: type(ms) == "number"')
	end

	local sx, sy = start_p:unpack()
	local ex, ey = end_p:unpack()
	local np = love.math.random(2, 5) * 3
	local points = Generator.path_points_ants(sx, sy, ex, ey, np)
	local p = points[1]

	for i = 1, n do
		local speed = ms - (i - 1)
		local e = Concord.entity(self.world)
			:give("id", "ant" .. i)
			:give("ant")
			:give("bug")
			:give("color", { 0, 0, 0, 1 })
			:give("point", 2)
			:give("pos", p.x, p.y)
			:give("path", points)
			:give("path_speed", speed)
			:give("z_index", 99, false)

		if path_repeat then
			e:give("path_repeat")
		else
			e:give("on_path_reached_end", "destroy_entity", 0, e)
		end
	end
end

function Ants:set_ants_visibility(bool)
	if type(bool) ~= "boolean" then
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

function Ants:move_ants()
	for _, e in ipairs(self.pool) do
		e:give("path_move")
	end
end

local flags = {
	path = true,
	show = false,
}
local data = {
	n = 64,
	dur = 16,
	path_repeat = true,
	speed = 32,
	start_p = vec2(64, 64),
	end_p = vec2(128, 128),
}

function Ants:debug_update(dt)
	if not self.debug_show then
		return
	end
	self.debug_show = Slab.BeginWindow("Ants", {
		Title = "Ants",
		IsOpen = self.debug_show,
	})
	data.n = UIWrapper.edit_range("n", data.n, 1, 256, true)
	data.dur = UIWrapper.edit_range("dur", data.dur, 0, 128)

	local w, h = love.graphics.getDimensions()
	data.start_p.x = UIWrapper.edit_range("sx", data.start_p.x, 0, w)
	data.start_p.y = UIWrapper.edit_range("sy", data.start_p.y, 0, h)
	data.end_p.x = UIWrapper.edit_range("ex", data.end_p.x, 0, w)
	data.end_p.y = UIWrapper.edit_range("ey", data.end_p.y, 0, h)

	if Slab.Button("randomize") then
		data.n = love.math.random(32, 64)
		data.dur = love.math.random(32, 64)
		data.speed = love.math.random(16, 64)
		data.start_p.x = love.math.random(16, 64)
		data.start_p.y = love.math.random(16, 64)
		data.end_p.x = data.start_p.x + love.math.random(8, 64)
		data.end_p.y = data.start_p.y + love.math.random(8, 64)
	end

	if Slab.Button("generate") then
		for _, e in ipairs(self.pool) do
			e:destroy()
		end
		self.world:emit("debug_toggle_path", flags.path, "bug")
		self:generate_ants(data.n, data.start_p, data.end_p, data.path_repeat, data.speed)
	end

	if Slab.Button("move") then
		self:move_ants()
	end

	if Slab.CheckBox(flags.show, "show") then
		flags.show = not flags.show
		self:set_ants_visibility(flags.show)
	end

	if Slab.CheckBox(flags.path_repeat, "repeat") then
		flags.path_repeat = not flags.path_repeat
	end
	Slab.EndWindow()
end

return Ants
