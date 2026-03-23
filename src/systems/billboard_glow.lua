local BillboardGlow = Concord.system({
	pool = { "billboard_glow", "pos" },
	pool_pulse = { "glow_pulse", "billboard_glow", "pos" },
	pool_blocker_rect = { "glow_blocker", "pos", "rect" },
	pool_blocker_circle = { "glow_blocker", "pos", "circle" },
})

function BillboardGlow:init(world)
	self.shader = love.graphics.newShader(Shaders.paths.billboard_glow)
	self.groups = {}

	self.world = world
	self.timer = Timer.new()
	local size = 8
	self.glow_texture = self:generate_glow_texture(size)
	self.batch = love.graphics.newSpriteBatch(self.glow_texture, 32, "stream")

	self.mask_canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
	self.blocker_mask = nil

	self.pool.onAdded = function(pool, e)
		local g = e.glow_group
		if not g then return end
		if not self.groups[g.id] then
			self.groups[g.id] = {}
		end
		table.insert(self.groups[g.id], e)
	end
end

function BillboardGlow:update(dt)
	for _, e in ipairs(self.pool_pulse) do
		if not e.hidden and not e.glow_disabled then
			local pulse = e.glow_pulse
			pulse.time = pulse.time + dt * pulse.speed

			local intensity = math.sin(pulse.time) * pulse.amplitude
			local glow = e.billboard_glow
			glow.intensity = glow.orig_intensity + intensity
		end
	end
end

function BillboardGlow:generate_glow_texture(size)
	assert(type(size) == "number")
	local data = love.image.newImageData(size, size)
	local cx, cy = size / 2, size / 2
	local max_dist = math.sqrt(cx * cx + cy * cy)

	data:mapPixel(function(x, y)
		local dx = x - cx
		local dy = y - cy
		local dist = math.sqrt(dx * dx + dy * dy)
		local normalized = dist / max_dist
		local intensity = math.exp(-(normalized * normalized) * 4)
		return intensity, intensity, intensity, 1
	end)

	local img = love.graphics.newImage(data)
	img:setFilter("linear", "linear")
	return img
end

function BillboardGlow:create_blocker_mask(camera)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	if self.mask_canvas:getWidth() ~= w or self.mask_canvas:getHeight() ~= h then
		self.mask_canvas = love.graphics.newCanvas(w, h)
	end

	local prev_canvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.mask_canvas)
	love.graphics.clear(1, 1, 1, 1)

	love.graphics.setBlendMode("subtract")
	love.graphics.setColor(0, 0, 0, 1)

	for _, e in ipairs(self.pool_blocker_rect) do
		if not e.hidden then
			local pos = e.pos
			local rect = e.rect
			local sx, sy = camera:toScreen(pos.x, pos.y)
			local screen_half_w = rect.half_w * camera:getScale()
			local screen_half_h = rect.half_h * camera:getScale()
			local x = sx - screen_half_w
			local y = sy - screen_half_h
			local sw = screen_half_w * 2
			local sh = screen_half_h * 2
			love.graphics.rectangle("fill", x, y, sw, sh)
		end
	end

	for _, e in ipairs(self.pool_blocker_circle) do
		if not e.hidden then
			local pos = e.pos
			local circle = e.circle
			local sx, sy = camera:toScreen(pos.x, pos.y)
			local screen_radius = circle.radius * camera:getScale()
			love.graphics.circle("fill", sx, sy, screen_radius, circle.segments or 32)
		end
	end

	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setCanvas(prev_canvas)

	local img_data = self.mask_canvas:newImageData()
	self.blocker_mask = love.graphics.newImage(img_data)
end

function BillboardGlow:draw_billboard_glow(camera)
	if #self.pool == 0 and #self.pool_blocker_rect == 0 and #self.pool_blocker_circle == 0 then
		return
	end

	self:create_blocker_mask(camera)

	local prev_blend = love.graphics.getBlendMode()
	local prev_shader = love.graphics.getShader()
	love.graphics.setBlendMode("add")
	love.graphics.setShader(self.shader)
	self.shader:send("u_blocker_mask", self.blocker_mask)
	self.shader:send("u_screen_size", {love.graphics.getWidth(), love.graphics.getHeight()})

	camera:attach()
	self.batch:clear()
	for _, e in ipairs(self.pool) do
		if not e.hidden and not e.glow_disabled then
			self:add_to_batch(e)
		end
	end
	love.graphics.draw(self.batch)
	camera:detach()
	love.graphics.setBlendMode(prev_blend)
	love.graphics.setShader(prev_shader)

	if DEV then
		self:debug_draw_outlines(camera)
	end
end

function BillboardGlow:add_to_batch(e)
	local pos = e.pos
	local glow = e.billboard_glow
	local size = glow.size
	local intensity = glow.intensity
	local color = e.color.value

	local tex = self.glow_texture
	local sx = tex:getWidth() / size
	local sy = tex:getHeight() / size
	local ox = tex:getWidth() / 2
	local oy = tex:getHeight() / 2

	local r = color[1] * intensity
	local g = color[2] * intensity
	local b = color[3] * intensity

	self.batch:setColor(r, g, b, 1)
	self.batch:add(pos.x, pos.y, 0, sx, sy, ox, oy)
end

function BillboardGlow:cleanup()
	self.timer:clear()
end

if DEV then
	local flags = {
		group = true,
		blockers = true,
		blockers_outline = true,
	}

	function BillboardGlow:debug_on_toggle(event)
		if event ~= "billboard_glow" then return end
		self.debug_show = not self.debug_show
	end

	function BillboardGlow:debug_update(dt)
		if not self.debug_show then return end
		self.debug_show = Slab.BeginWindow("billboard_glow", {
			Title = "BillboardGlow",
			IsOpen = self.debug_show,
		})

		if Slab.CheckBox(flags.group, "group") then
			flags.group = not flags.group
		end
		Slab.SameLine()
		if Slab.CheckBox(flags.blockers, "blockers") then
			flags.blockers = not flags.blockers
		end
		Slab.SameLine()
		if Slab.CheckBox(flags.blockers_outline, "outline") then
			flags.blockers_outline = not flags.blockers_outline
		end

		if flags.group then
			for k, v in pairs(self.groups) do
				if Slab.BeginTree(k, { Title = k }) then
					self:debug_edit(v, k)
					Slab.EndTree()
				end
			end
		else
			self:debug_edit(self.pool)
		end

		if flags.blockers then
			self:debug_edit_blockers()
		end

		Slab.EndWindow()
	end

	function BillboardGlow:debug_edit(pool, group_id)
		for i, e in ipairs(pool) do
			if group_id and i ~= 1 then
				return
			end

			local id = e.id.value
			if Slab.BeginTree(id, { Title = id }) then
				Slab.Indent()
				local gd = e.glow_disabled
				if Slab.CheckBox(gd, "Disabled") then
					local is_d
					if gd then
						e:remove("glow_disabled")
						is_d = false
					else
						e:give("glow_disabled")
						is_d = true
					end
					if group_id then
						self:glow_group_set_disable(group_id, is_d, e)
					end
				end

				local pos = e.pos
				local nx, _, dx = UIWrapper.edit_number("x", pos.x, true)
				local ny, _, dy = UIWrapper.edit_number("y", pos.y, true)
				local nz, _, dz = UIWrapper.edit_range("z", pos.z, 1, 256, true)

				local g = e.billboard_glow
				local ns, _, _ = UIWrapper.edit_range("size", g.size, 1, 128, true)

				local color = e.color.value
				local nr, _, _ = UIWrapper.edit_range("r", color[1], 0, 1)
				local ng, _, _ = UIWrapper.edit_range("g", color[2], 0, 1)
				local nb, _, _ = UIWrapper.edit_range("b", color[3], 0, 1)

				if group_id then
					for _, e2 in ipairs(self.groups[group_id]) do
						e2.pos.x = e2.pos.x - dx
						e2.pos.y = e2.pos.y - dy
						e2.pos.z = e2.pos.z - dz
						e2.billboard_glow.size = ns
						local color2 = e2.color.value
						color2[1] = nr
						color2[2] = ng
						color2[3] = nb
					end
				else
					e.pos.x = nx
					e.pos.y = ny
					e.pos.z = nz
					g.size = ns
					color[1] = nr
					color[2] = ng
					color[3] = nb
				end

				Slab.EndTree()
				Slab.Unindent()
			end
		end
	end

	function BillboardGlow:debug_edit_blockers()
		for _, e in ipairs(self.pool_blocker_rect) do
			local id = e.id and e.id.value or "rect_blocker"
			if Slab.BeginTree(id, { Title = id }) then
				Slab.Indent()
				local pos = e.pos
				local nx, _, _ = UIWrapper.edit_number("x", pos.x, true)
				local ny, _, _ = UIWrapper.edit_number("y", pos.y, true)
				local nz, _, _ = UIWrapper.edit_range("z", pos.z, 1, 256, true)

				local rect = e.rect
				local nw, _, _ = UIWrapper.edit_range("w", rect.w, 1, 512, true)
				local nh, _, _ = UIWrapper.edit_range("h", rect.h, 1, 512, true)

				e.pos.x = nx
				e.pos.y = ny
				e.pos.z = nz
				rect.w = nw
				rect.h = nh
				rect.half_w = rect.w / 2
				rect.half_h = rect.h / 2

				Slab.EndTree()
				Slab.Unindent()
			end
		end

		for _, e in ipairs(self.pool_blocker_circle) do
			local id = e.id and e.id.value or "circle_blocker"
			if Slab.BeginTree(id, { Title = id }) then
				Slab.Indent()
				local pos = e.pos
				local nx, _, _ = UIWrapper.edit_number("x", pos.x, true)
				local ny, _, _ = UIWrapper.edit_number("y", pos.y, true)
				local nz, _, _ = UIWrapper.edit_range("z", pos.z, 1, 256, true)

				local circle = e.circle
				local nr, _, _ = UIWrapper.edit_range("radius", circle.radius, 1, 512, true)

				e.pos.x = nx
				e.pos.y = ny
				e.pos.z = nz
				circle.radius = nr
				circle.segments = circle.radius

				Slab.EndTree()
				Slab.Unindent()
			end
		end
	end

	function BillboardGlow:debug_draw_outlines(camera)
		if not self.debug_show or not flags.blockers_outline then return end

		local prev_blend = love.graphics.getBlendMode()
		love.graphics.setBlendMode("alpha")
		love.graphics.setColor(1, 0, 0, 1)

		camera:attach()

		for _, e in ipairs(self.pool_blocker_rect) do
			local pos = e.pos
			local rect = e.rect
			local x = pos.x - rect.half_w
			local y = pos.y - rect.half_h
			love.graphics.rectangle("line", x, y, rect.w, rect.h)
		end

		for _, e in ipairs(self.pool_blocker_circle) do
			local pos = e.pos
			local circle = e.circle
			love.graphics.circle("line", pos.x, pos.y, circle.radius, circle.segments)
		end

		camera:detach()

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setBlendMode(prev_blend)
	end

	function BillboardGlow:glow_group_set_disable(group_id, is_d, e)
		for _, other in ipairs(self.groups[group_id]) do
			if e ~= other then
				if is_d then
					other:give("glow_disabled")
				else
					other:remove("glow_disabled")
				end
			end
		end
	end
end

return BillboardGlow
