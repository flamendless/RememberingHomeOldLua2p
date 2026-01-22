local Path = Concord.system({
	pool = { "path", "pos" },
	pool_move = { "path", "pos", "path_move", "path_speed" },
})

function Path:init(world)
	self.world = world
end

function Path:get_points(e)
	local path = e.path
	local bezier_curve = e.apply_bezier_curve
	local low = path.current_point
	local high = low + path.max

	if high > path.n_points then
		high = path.n_points
	end

	local points = {}
	for i = low, high do
		local p = path.points[i]
		if bezier_curve then
			table.insert(points, p.x)
			table.insert(points, p.y)
		else
			table.insert(points, { x = p.x, y = p.y })
		end
	end

	if bezier_curve then
		points = love.math.newBezierCurve(unpack(points))
	end

	return points, high
end

function Path:move_linear(dt, e, points)
	local pos = e.pos
	local path = e.path
	local speed = e.path_speed.value

	-- always target FIRST point in window
	local target = points[1]
	if not target then return false end

	local dx = target.x - pos.x
	local dy = target.y - pos.y
	local dist = math.sqrt(dx * dx + dy * dy)

	if dist == 0 then
		return true
	end

	local step = speed * dt
	if step >= dist then
		pos.x, pos.y = target.x, target.y
		return true
	else
		pos.x = pos.x + dx / dist * step
		pos.y = pos.y + dy / dist * step
	end

	return false
end

function Path:move_curve(dt, e, points)
	local pos = e.pos
	local speed = e.path_speed.value
	local bz = e.apply_bezier_curve

	bz.t = (bz.t or 0) + dt / speed
	if bz.t > 1 then
		bz.t = 1
	end

	--TODO: Errors 'Invalid Bezier curve: Not enough control points.'
	local x, y = points:evaluate(bz.t)
	pos.x, pos.y = x, y

	return bz.t >= 1
end

function Path:update(dt)
	for _, e in ipairs(self.pool_move) do
		local path = e.path
		local points, _ = self:get_points(e)

		local reached = false
		if e.apply_bezier_curve then
			reached = self:move_curve(dt, e, points)
		else
			reached = self:move_linear(dt, e, points)
		end

		if reached then
			path.current_point = path.current_point + 1

			if path.current_point > path.n_points then
				path.current_point = 1

				if e.path_repeat then
					local p = path.points[1]
					e.pos.x, e.pos.y = p.x, p.y
				end

				if e.on_path_reached_end then
					self.world:emit(
						e.on_path_reached_end.signal,
						unpack(e.on_path_reached_end.args)
					)
				end
			end
		end
	end
end

if DEV then
	local flags = {
		path = true,
		bezier = false,
	}
	local component_filter = "path"
	local alpha = 0.3

	function Path:debug_toggle_path(bool, filter)
		if not (type(bool) == "boolean") then
			error('Assertion failed: type(bool) == "boolean"')
		end
		if filter and type(filter) ~= "string" then
			error('Assertion failed: type(filter) == "string"')
		end
		self.debug_show = bool
		flags.path = bool
		component_filter = filter
	end

	function Path:debug_update(dt)
		if not self.debug_show then
			return
		end
		self.debug_show = Slab.BeginWindow("Path", { Title = "Path", IsOpen = self.debug_show })

		if Slab.CheckBox(flags.path, "Path") then
			flags.path = not flags.path
		end

		if Slab.CheckBox(flags.bezier, "Bezier") then
			flags.bezier = not flags.bezier
		end

		Slab.EndWindow()
	end

	function Path:debug_draw()
		if not self.debug_show then
			return
		end
		if flags.path then
			local scale = 1
			local camera = self.world:getResource("camera")
			if camera then
				scale = 1 / camera:getScale()
			end
			love.graphics.setLineWidth(scale)
			for _, e in ipairs(self.pool) do
				if component_filter and e[component_filter] then
					local path = e.path
					if not flags.bezier then
						for i = 1, path.n_points - 1 do
							local a = path.points[i]
							local b = path.points[i + 1]
							if i < path.current_point then
								love.graphics.setColor(1, 0, 0, alpha)
							else
								love.graphics.setColor(1, 1, 0, alpha)
							end
							love.graphics.line(a.x, a.y, b.x, b.y)
						end
					else
						for i = 1, path.n_points - 2, 2 do
							local a = path.points[i]
							local b = path.points[i + 1]
							local c = path.points[i + 2]
							local bc = love.math.newBezierCurve({
								a.x,
								a.y,
								b.x,
								b.y,
								c.x,
								c.y,
							})
							if i < path.current_point then
								love.graphics.setColor(1, 0, 0, alpha)
							else
								love.graphics.setColor(1, 1, 0, alpha)
							end
							love.graphics.line(bc:render())
						end
					end
				end
			end
		end
	end
end

return Path
