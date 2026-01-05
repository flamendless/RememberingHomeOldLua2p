local Ants = Concord.system({
	pool = { "id", "bug", "ant" },
})

function Ants:init(world)
	self.world = world
end

function Ants:generate_ants(n, start_p, end_p, path_repeat, ms)
	if not (type(n) == "number" and n > 0) then
		error('Assertion failed: type(n) == "number" and n > 0')
	end
	if not (start_p:type() == "vec2") then
		error('Assertion failed: start_p:type() == "vec2"')
	end
	if not (end_p:type() == "vec2") then
		error('Assertion failed: end_p:type() == "vec2"')
	end
	if not (type(path_repeat) == "boolean") then
		error('Assertion failed: type(path_repeat) == "boolean"')
	end
	if not (type(ms) == "number") then
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
			:give("point", 4)
			:give("pos", p.x, p.y)
			:give("path", points)
			:give("path_speed", speed)
			:give("no_shader")

		if path_repeat then
			e:give("path_repeat")
		else
			e:give("on_path_reached_end", "destroy_entity", 0, e)
		end
	end
end

function Ants:set_ants_visibility(bool)
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
	n = 1,
	path_repeat = false,
	speed = 32,
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
	data.dur = UIWrapper.edit_range("dur", data.dur, 0, 5)

	if Slab.Button("generate") then
		for _, e in ipairs(self.pool) do
			e:destroy()
		end
		flags.show = false
		self.world:emit("debug_toggle_path", flags.path, "bug")
		self:generate_ants(data.n, vec2(12, 28), vec2(56, 4), data.path_repeat, data.speed)
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
