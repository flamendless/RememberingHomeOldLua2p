local Parallax = Concord.system({
	pool = {
		"parallax",
		"quad",
		"sprite",
		"quad_transform",
		"!parallax_multi_sprite",
	},
	pool_multi = { "parallax", "sprite", "pos", "parallax_multi_sprite" },
})

function Parallax:init(world)
	self.world = world
	self.tags = {}

	self.pool.onAdded = function(pool, e)
		e:get("sprite").image:setWrap("repeat")
	end

	self.pool_multi.onAdded = function(pool, e)
		local tag = e:get("parallax_multi_sprite").value
		if self.tags[tag] == nil then
			self.tags[tag] = {}
		end

		--NOTE: for now this system only works with horizontal parallax
		local t = self.tags[tag]
		local i = #t
		if i > 0 then
			self:push_to_end(e, t)
		end

		table.insert(t, e)
	end
end

function Parallax:push_to_end(e, t)
	local last_e = t[#t]
	local pos = e:get("pos")
	local gap = 0
	if e:has("parallax_gap") then
		gap = e:get("parallax_gap").value
	end
	local last_pos = last_e:get("pos")
	local last_quad = last_e:get("quad")
	local last_qt = last_e:get("quad_transform")
	pos.x = last_pos.x + last_quad.info.w * last_qt.sx + gap
	Utils.table.rotate(t, -1)
end

function Parallax:start_parallax()
	for _, e in ipairs(self.pool) do
		e:remove("parallax_stop")
	end
	for _, v in pairs(self.tags) do
		for _, e in ipairs(v) do
			e:remove("parallax_stop")
		end
	end
end

function Parallax:stop_parallax()
	for _, e in ipairs(self.pool) do
		e:give("parallax_stop")
	end
	for _, v in pairs(self.tags) do
		for _, e in ipairs(v) do
			e:give("parallax_stop")
		end
	end
end

function Parallax:slow_parallax(amount)
	for _, e in ipairs(self.pool) do
		local parallax = e:get("parallax")
		local dx = parallax.vx * amount
		parallax.vx = dx
	end
end

function Parallax:parallax_move_x(dt, dir)
	for _, e in ipairs(self.pool) do
		if not e:has("parallax_stop") then
			local parallax = e:get("parallax")
			local quad = e:get("quad")
			local x, y, w, h = quad.quad:getViewport()

			x = x + parallax.vx * dir * dt
			quad.quad:setViewport(x, y, w, h)
		end
	end

	for _, v in pairs(self.tags) do
		for _, e in ipairs(v) do
			if not e:has("parallax_stop") then
				local parallax = e:get("parallax")
				local quad = e:get("quad")
				local qt = e:get("quad_transform")
				local pos = e:get("pos")

				pos.x = pos.x + parallax.vx * dir * dt

				if dir == -1 then
					if pos.x + quad.info.w * qt.sx < 0 then
						self:push_to_end(e, v)
					end
				end
			end
		end
	end
end

local is_running = true

function Parallax:debug_update(dt)
	if not self.debug_show then
		return
	end
	self.debug_show = Slab.BeginWindow("parallax", {
		Title = "Parallax",
		IsOpen = self.debug_show,
	})
	if Slab.CheckBox(is_running, "run") then
		is_running = not is_running
		if is_running then
			self:start_parallax()
		else
			self:stop_parallax()
		end
	end
	Slab.EndWindow()
end

return Parallax
