local Dust = Concord.system({
	pool = { "id", "dust", "pos", "size" },
})

function Dust:init(world)
	self.world = world
	self.bursts = ParticleSystems.Dust()
	self.active = {}

	if DEV then
		self.debug_show_bbox = true
		self.debug_selected_id = nil
		self.debug_test_counter = 0
		self.debug_default_region = { x = 200, y = 8, w = 200, h = 8 }
	end

	self.pool.onRemoved = function(_, e)
		self.active[e] = nil
		if DEV and self.debug_selected_id and e:has("id") then
			if e:get("id").value == self.debug_selected_id then
				self.debug_selected_id = nil
			end
		end
	end
end

function Dust:build_config(e)
	local pos = e:get("pos")
	local size = e:get("size")
	local dust = e:get("dust")

	return {
		x = pos.x,
		y = pos.y,
		w = size.w,
		h = size.h,
		direction = dust.direction,
		color = dust.color,
		size = dust.size,
		strength = dust.strength,
		size_variation = dust.size_variation,
	}
end

function Dust:find_emitter_by_id(id)
	assert:type(id, "string")
	for _, e in ipairs(self.pool) do
		if e:get("id").value == id then
			return e
		end
	end
end

function Dust:trigger_dust(e)
	assert(e.__isEntity and e:has("dust"), e)
	if e:has("hidden") then
		return
	end

	local burst = self.bursts:trigger(self:build_config(e))
	self.active[e] = burst
end

function Dust:trigger_dust_by_id(id)
	local e = self:find_emitter_by_id(id)
	if not e then
		Log.warn("dust emitter not found", id)
		return
	end
	self:trigger_dust(e)
end

function Dust:update(dt)
	self.bursts:update(dt)

	for e, burst in pairs(self.active) do
		if not burst:is_alive() then
			self.active[e] = nil
		end
	end
end

function Dust:draw_dust()
	self.bursts:draw()
end

if DEV then
	function Dust:get_selected_emitter()
		if not self.debug_selected_id then
			return nil
		end
		return self:find_emitter_by_id(self.debug_selected_id)
	end

	function Dust:spawn_test_emitter()
		self.debug_test_counter = self.debug_test_counter + 1
		local id = "dust_test_" .. self.debug_test_counter
		local region = self.debug_default_region

		local e = Concord.entity(self.world):assemble(
			Assemblages.Dust.emitter,
			id,
			region.x,
			region.y,
			region.w,
			region.h
		)

		self.debug_selected_id = id
		return e
	end

	function Dust:debug_update(dt)
		if not self.debug_show then
			return
		end

		self.debug_show = Slab.BeginWindow("dust", {
			Title = "Dust",
			IsOpen = self.debug_show,
		})

		if Slab.CheckBox(self.debug_show_bbox, "draw bounding box") then
			self.debug_show_bbox = not self.debug_show_bbox
		end

		Slab.Separator()
		Slab.Text("Emitter:")

		if Slab.BeginComboBox("cb_dust_emitter", { Selected = self.debug_selected_id }) then
			for _, e in ipairs(self.pool) do
				local id = e:get("id").value
				if Slab.TextSelectable(id) then
					self.debug_selected_id = id
					break
				end
			end
			Slab.EndComboBox()
		end

		Slab.SameLine()
		if Slab.Button("Spawn test emitter") then
			self:spawn_test_emitter()
		end

		local e = self:get_selected_emitter()
		if e then
			local pos = e:get("pos")
			local size = e:get("size")
			local dust = e:get("dust")

			pos.x = UIWrapper.edit_range("x", pos.x, 0, 2048, true)
			pos.y = UIWrapper.edit_range("y", pos.y, 0, 2048, true)
			size.w = UIWrapper.edit_range("w", size.w, 1, 2048, true)
			size.h = UIWrapper.edit_range("h", size.h, 1, 2048, true)

			dust.size = UIWrapper.edit_range("dust size", dust.size, 0.1, 8, false)
			dust.strength = UIWrapper.edit_range("strength", dust.strength, 0, 4, false)
			dust.direction = UIWrapper.edit_range("direction", dust.direction, -math.pi, math.pi, false)
			dust.size_variation = UIWrapper.edit_range("size variation", dust.size_variation, 0, 1, false)
			UIWrapper.color(dust.color)

			if Slab.Button("Trigger Dust") then
				self:trigger_dust(e)
			end
		else
			Slab.Text("No emitter selected")
		end

		Slab.EndWindow()
	end

	function Dust:debug_draw()
		if not self.debug_show or not self.debug_show_bbox then
			return
		end

		love.graphics.setLineWidth(1)
		for _, e in ipairs(self.pool) do
			local pos = e:get("pos")
			local size = e:get("size")
			local id = e:get("id").value
			local selected = id == self.debug_selected_id

			if selected then
				love.graphics.setColor(1, 1, 0, 0.9)
			else
				love.graphics.setColor(1, 1, 1, 0.5)
			end
			love.graphics.rectangle("line", pos.x, pos.y, size.w, size.h)
		end
		love.graphics.setColor(1, 1, 1, 1)
	end

	function Dust.slab_dust(e)
		if not e:has("dust") then
			return
		end
		local dust = e:get("dust")
		dust.size = UIWrapper.edit_range("dust size", dust.size, 0.1, 8, false)
		dust.strength = UIWrapper.edit_range("strength", dust.strength, 0, 4, false)
		dust.direction = UIWrapper.edit_range("direction", dust.direction, -math.pi, math.pi, false)
		dust.size_variation = UIWrapper.edit_range("size variation", dust.size_variation, 0, 1, false)
		UIWrapper.color(dust.color)
	end

	DevTools.register_slab_component("dust", Dust.slab_dust)
end

return Dust
