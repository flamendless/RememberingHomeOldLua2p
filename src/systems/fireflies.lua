local Fireflies = Concord.system({
	pool = { "firefly" },
})

local col_target = Palette.get_diffuse("firefly")

function Fireflies:init(world)
	self.world = world

	if DEV then
		self.debug_fireflies = false
	end
end

function Fireflies:generate_fireflies()
	local n = love.math.random(26, 38)
	local min_x, max_x = 32, 1000
	local min_y, max_y = 220, 300
	for _ = 1, n do
		local x = love.math.random(min_x, max_x)
		local y = love.math.random(min_y, max_y)
		local size = love.math.random(12, 20)
		local points = Generator.path_points_fireflies(x, y, 64)
		local e = Concord.entity(self.world)
			:assemble(Assemblages.Outside.firefly, x, y, size, points)
			:give("light_disabled")
			:give("path", points, love.math.random(2, 6))
			:give("path_speed", love.math.random(4, 8))
			:give("apply_bezier_curve")
			:give("path_loop")
		e:give("on_path_update", "update_light_pos", 0, e)
	end
end

function Fireflies:show_fireflies(dur)
	if type(dur) ~= "number" then
		error('Assertion failed: type(dur) == "number"')
	end
	for _, e in ipairs(self.pool) do
		e:remove("light_disabled")
		Flux.to(e.diffuse.value, dur, {
			[1] = col_target[1],
			[2] = col_target[2],
			[3] = col_target[3],
		})
			:onupdate(function()
				self.world:emit("update_light_diffuse", e)
			end)
			:oncomplete(function()
				local lp = e.point_light.value
				local amount = love.math.random(lp * 0.25, lp * 0.4)
				e:give("light_fading", amount, -1)
			end)
	end

	self.debug_fireflies = true
end

function Fireflies:hide_fireflies(dur)
	if type(dur) ~= "number" then
		error('Assertion failed: type(dur) == "number"')
	end
	for _, e in ipairs(self.pool) do
		e:remove("light_fading")
		Flux.to(e.diffuse.value, dur, {
			[1] = 0,
			[2] = 0,
			[3] = 0,
		})
			:onupdate(function()
				self.world:emit("update_light_diffuse", e)
			end)
			:oncomplete(function()
				e:give("light_disabled")
			end)
	end

	self.debug_fireflies = false
end

function Fireflies:move_fireflies()
	for _, e in ipairs(self.pool) do
		e:give("path_move")
	end

	self.debug_move = true
end

function Fireflies:stop_fireflies()
	for _, e in ipairs(self.pool) do
		e:remove("path_move"):remove("path_loop")
	end

	self.debug_move = false
end

local flags = {
	path = false,
}

function Fireflies:debug_update(dt)
	if not self.debug_show then
		return
	end
	self.debug_show = Slab.BeginWindow("Fireflies", {
		Title = "Fireflies",
		IsOpen = self.debug_show,
	})

	if Slab.CheckBox(self.debug_fireflies, "Show") then
		self.debug_fireflies = not self.debug_fireflies
		if self.debug_fireflies then
			self:show_fireflies(5)
		else
			self:hide_fireflies(5)
		end
	end

	if Slab.CheckBox(self.debug_move, "Move") then
		self.debug_move = not self.debug_move
		if self.debug_move then
			self:move_fireflies()
		else
			self:stop_fireflies()
		end
	end

	if Slab.CheckBox(flags.path, "Path") then
		flags.path = not flags.path
		self.world:emit("debug_toggle_path", flags.path, "firefly")
	end

	Slab.EndWindow()
end

return Fireflies
