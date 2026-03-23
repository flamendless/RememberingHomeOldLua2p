local BillboardGlow = Concord.system({
	pool = { "billboard_glow", "pos" },
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

	self:create_glow_canvas()

	self.pool.onAdded = function(pool, e)
		local g = e.glow_group
		if g then
			if not self.groups[g.id] then
				self.groups[g.id] = {}
			end
			table.insert(self.groups[g.id], e)
		end
	end
end

function BillboardGlow:create_glow_canvas()
	local ww, wh = love.graphics.getDimensions()
	self.glow_canvas = love.graphics.newCanvas(ww, wh)
	self.glow_canvas:setFilter("linear", "linear")
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

function BillboardGlow:update(dt)
	for _, e in ipairs(self.pool) do
		if not e.glow_disabled then
			local glow = e.billboard_glow
			local flicker = e.glow_flicker
			if flicker then
				if love.math.random() < flicker.chance * dt then
					glow.intensity = glow.orig_intensity +
						love.math.random(-flicker.offset, flicker.offset) * glow.orig_intensity
				else
					glow.intensity = glow.orig_intensity
				end
			end

			local pulse = e.glow_pulse
			if pulse then
				pulse.time = pulse.time + dt * pulse.speed
				glow.intensity = glow.orig_intensity + math.sin(pulse.time) * pulse.amplitude
			end
		end
	end
end

function BillboardGlow:draw_billboard_glow(camera)
	if #self.pool == 0 then
		return
	end

	local has_blockers = #self.pool_blocker_rect > 0 or #self.pool_blocker_circle > 0

	local prev_blend = love.graphics.getBlendMode()

	if has_blockers then
		camera:attach()
		love.graphics.setCanvas(self.glow_canvas)
		love.graphics.clear()
		love.graphics.setBlendMode("add")

		for _, e in ipairs(self.pool) do
			if not e.hidden and not e.glow_disabled then
				self:add_to_batch(e)
			end
		end
		love.graphics.draw(self.batch)
		self.batch:clear()

		love.graphics.setBlendMode("alpha")
		love.graphics.setColor(0, 0, 0, 1)

		for _, e in ipairs(self.pool_blocker_rect) do
			if not e.hidden then
				local pos = e.pos
				local rect = e.rect
				local x = pos.x - rect.half_w
				local y = pos.y - rect.half_h
				love.graphics.rectangle("fill", x, y, rect.w, rect.h)
			end
		end

		for _, e in ipairs(self.pool_blocker_circle) do
			if not e.hidden then
				local pos = e.pos
				local circle = e.circle
				love.graphics.circle("fill", pos.x, pos.y, circle.radius, circle.segments)
			end
		end

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setCanvas()
		camera:detach()

		love.graphics.setBlendMode("add")
		camera:attach()
		love.graphics.draw(self.glow_canvas)
		if DEV then
			self:debug_draw_blockers()
		end
		camera:detach()
	else
		love.graphics.setBlendMode("add")
		camera:attach()
		self.batch:clear()
		for _, e in ipairs(self.pool) do
			if not e.hidden and not e.glow_disabled then
				self:add_to_batch(e)
			end
		end
		love.graphics.draw(self.batch)
		camera:detach()
	end

	love.graphics.setBlendMode(prev_blend)
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
						local color2 = e.color.value
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

	function BillboardGlow:debug_draw_blockers()
		local prev_blend = love.graphics.getBlendMode()
		love.graphics.setBlendMode("alpha")

		for _, e in ipairs(self.pool_blocker_rect) do
			if e.debug_shape then
				local pos = e.pos
				local rect = e.rect
				local x = pos.x - rect.half_w
				local y = pos.y - rect.half_h
				local temp = { love.graphics.getColor() }
				love.graphics.setColor(1, 0, 0, 1)
				love.graphics.rectangle("line", x, y, rect.w, rect.h)
				love.graphics.setColor(temp)
			end
		end

		for _, e in ipairs(self.pool_blocker_circle) do
			if e.debug_shape then
				local pos = e.pos
				local circle = e.circle
				local temp = { love.graphics.getColor() }
				love.graphics.setColor(1, 0, 0, 1)
				love.graphics.circle("line", pos.x, pos.y, circle.radius, circle.segments)
				love.graphics.setColor(temp)
			end
		end

		love.graphics.setBlendMode(prev_blend)
	end
end

return BillboardGlow
