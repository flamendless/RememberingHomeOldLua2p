local Ants = Concord.system({
	pool = { "id", "bug", "ant" },
})

local function find_nearest_exit(world, e)
	local room_size = world:getResource("room_size")
	local rx, ry    = 0, 0
	local rw, rh    = room_size.width, room_size.height
	local x         = e.pos.x
	local y         = e.pos.y

	local left      = math.abs(x - rx)
	local right     = math.abs((rx + rw) - x)
	local top       = math.abs(y - ry)
	local bottom    = math.abs((ry + rh) - y)

	local min_edge  = math.min(left, right, top, bottom)
	local tx, ty

	if min_edge == left then
		tx = rx
		ty = ry + love.math.random() * rh
	elseif min_edge == right then
		tx = rx + rw
		ty = ry + love.math.random() * rh
	elseif min_edge == top then
		tx = rx + love.math.random() * rw
		ty = ry
	else
		tx = rx + love.math.random() * rw
		ty = ry + rh
	end

	tx = mathx.clamp(tx + (love.math.random() - 0.5) * 6, rx, rx + rw)
	ty = mathx.clamp(ty + (love.math.random() - 0.5) * 6, ry, ry + rh)

	e.escape_target = vec2(tx, ty)
end

function Ants:init(world)
	self.world = world
	self.cache_center = {}
	self.cache_size = {}

	self.pool.onAdded = function(pool, e)
		local saf = e.scatter_away_from
		if saf then
			find_nearest_exit(world, e)
		end
	end
end

function Ants:generate_ants(n, start_p, end_p, path_repeat, ms, opts)
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
	if opts and type(opts) ~= "table" then
		error('Assertion failed: type(opts) == "table"')
	end

	local sx, sy = start_p:unpack()
	local ex, ey = end_p:unpack()
	local np = love.math.random(2, 5) * 3
	local points = Generator.path_points_ants(sx, sy, ex, ey, np)

	for i = 1, n do
		local idx = love.math.random(1, #points)
		local cp = points[idx]
		local px, py = cp.x, cp.y

		local e = Concord.entity(self.world)
			:give("id", "ant" .. i)
			:give("ant")
			:give("bug")
			:give("color", { 0, 0, 0, love.math.random(0.5, 1) })
			:give("point", love.math.random(2, 4))
			:give("pos", px, py)
			:give("pos_vec2")
			:give("path", points, nil, idx)
			:give("path_speed", ms - (i - 1))
			:give("z_index", 1, false)

		if path_repeat then
			e:give("path_repeat")
		else
			e:give("on_path_reached_end", "destroy_entity", 0, e)
		end

		if opts then
			for k, v in pairs(opts) do
				if type(v) == "table" then
					e:give(k, unpack(v))
				else
					e:give(k, v)
				end
			end
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

function Ants:update(dt)
	for _, e in ipairs(self.pool) do
		local saf = e.scatter_away_from
		if not saf.is_overlap then
			local e_target = self.world:getEntityByKey(saf.key)
			local px, py, iw, ih = Helper.get_ltwh(e_target)
			local iwh, ihh = iw / 2, ih / 2

			if not self.cache_center[saf.key] then
				self.cache_center[saf.key] = vec2(px + iwh, py + ihh)
				self.cache_size[saf.key] = vec2(iwh, ihh)
			end

			local player_center = self.cache_center[saf.key]
			player_center.x = px + iwh
			player_center.y = py + ihh

			local player_size = self.cache_size[saf.key]
			saf.is_overlap = intersect.circle_aabb_overlap(
				e.pos_vec2.value,
				saf.distance,
				player_center,
				player_size
			)
		else
			local dx = e.escape_target.x - e.pos.x
			local dy = e.escape_target.y - e.pos.y
			local dist = math.sqrt(dx * dx + dy * dy)

			local step = saf.speed * dt
			if dist <= step then
				e:destroy()
			else
				e.pos.x = e.pos.x + (dx / dist) * step
				e.pos.y = e.pos.y + (dy / dist) * step
				e.pos.x = e.pos.x + (love.math.random() - 0.5) * 0.4
				e.pos.y = e.pos.y + (love.math.random() - 0.5) * 0.4
			end
		end
	end
end

function Ants:cleanup()
	tablex.clear(self.cache_center)
	tablex.clear(self.cache_size)
end

if DEV then
	local flags = {
		path = true,
		show = false,
		show_distance = true,
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

		if Slab.CheckBox(flags.show_distance, "scatter away from") then
			flags.show_distance = not flags.show_distance
		end

		Slab.EndWindow()
	end

	function Ants:debug_draw()
		if not self.debug_show then
			return
		end

		if flags.show_distance then
			love.graphics.setLineWidth(0.3)
			for _, e in ipairs(self.pool) do
				local saf = e.scatter_away_from
				if saf then
					if saf.is_overlap then
						love.graphics.setColor(1, 0, 0, 0.2)
					else
						love.graphics.setColor(1, 1, 1, 0.2)
					end
					local pos = e.pos
					love.graphics.circle("line", pos.x, pos.y, saf.distance, 32)

					local e_target = self.world:getEntityByKey(saf.key)
					local px, py, iw, ih = Helper.get_ltwh(e_target)
					love.graphics.rectangle("line", px, py, iw, ih)
				end
			end
		end
	end
end

return Ants
