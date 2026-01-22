local Inventory = Concord.system({
	pool_cell = {
		constructor = Ctor.ListByID,
		id = "inventory_cells",
	},
	pool_choice = {
		constructor = Ctor.ListByID,
		id = "inventory_choices",
	},
	pool_border = { "id", "sprite", "textured_line" },
	pool_item = { "item" },
})

function Inventory:init(world)
	self.world = world
	self.is_open = false
	self.in_choices = false
	self.entities = {}

	self.pool_item.onAdded = function(pool, e)
		local e_cell = self.pool_cell[#pool]
		local c_pos = e_cell.pos
		local c_rect = e_cell.rect
		local refs = e_cell.refs.value
		local e_dline1 = self.world:getEntityByKey(refs[1])
		local e_dline2 = self.world:getEntityByKey(refs[2])
		e_dline1:give("hidden")
		e_dline2:give("hidden")
		local pos = e.pos
		pos.x = c_pos.x + c_rect.half_w
		pos.y = c_pos.y + c_rect.half_h
	end

	self.pool_item.onRemoved = function(pool, e)
		local e_cell = self.pool_cell[#pool + 1]
		local refs = e_cell.refs.value
		local e_dline1 = self.world:getEntityByKey(refs[1])
		local e_dline2 = self.world:getEntityByKey(refs[2])
		e_dline1:remove("hidden")
		e_dline2:remove("hidden")
	end
end

function Inventory:open_inventory()
	if self.is_open then
		return
	end
	self.world:emit("on_interact_or_inventory")
	self.world:emit("set_system_to", "dialogues", false)
	self.world:emit("set_post_process_effect", "Blur", true)
	self:create_inventory()
	self.world:__flush()
	self.world:emit("set_focus_list", "inventory_cells")
	self.world:emit("create_inventory_key")
	self.world:emit("create_items")
	self.is_open = true
end

function Inventory:close_inventory(not_close)
	if not_close then
		if not (type(not_close) == "boolean") then
			error('Assertion failed: type(not_close) == "boolean"')
		end
	end
	self.world:emit("destroy_items")
	self.world:emit("destroy_key", "inventory")
	self.world:emit("set_system_to", "dialogues", true)
	if not not_close then
		self.world:emit("on_leave_interact_or_inventory")
	end
	self.is_open = false
	for _, e in pairs(self.entities) do
		e:destroy()
	end
	for _, e in ipairs(self.pool_border) do
		e:destroy()
	end
	self.world:emit("destroy_list", "inventory_cells")
	self.world:emit("destroy_list", "inventory_choices")
	self.world:emit("set_post_process_effect", "Blur", false)
end

local added = false

function Inventory:update(dt)
	if not self.is_open and Inputs.pressed("inventory") then
		if not added then
			Items.add("flashlight")
			Notes.add("test1")
			Notes.add("test2")
			added = true
		end

		self:open_inventory()
	elseif self.is_open then
		if Inputs.pressed("inventory") then
			Inputs.flush()
			self:close_inventory(true)
			self.world:emit("inventory_to_notes")
			self.world:emit("open_notes")
		elseif Inputs.pressed("cancel") then
			if self.in_choices then
				self["on_list_item_interact_" .. "inventory_choices"](self, self.pool_choice[3])
			else
				self:close_inventory()
			end
		end
	end
end

function Inventory:create_inventory()
	local _, _, w, h = self.world:getResource("camera"):getWindow()
	local img = Resources.data.images.bg_inventory
	local iw, ih = img:getDimensions()
	local bar_h = self.world:getResource("e_camera").bar_height.value
	local pad = 48
	local nh = h - pad * 2 - bar_h * 2
	local scale = math.min(w / iw, nh / ih)
	local x = w/2
	local y = h/2
	local rows, cols = 2, 3
	local bg_w = iw * scale
	local bg_h = ih * scale
	local orig_x = x - bg_w/2
	local orig_y = y - bg_h/2
	self.entities.bg = Concord.entity(self.world):assemble(Assemblages.Inventory.bg, x, y, scale)
	self.world:emit("create_list_group", "inventory_choices", true, 3)

	local c_bx = orig_x + bg_w - pad
	local c_by = orig_y + bg_h/2
	local choices = { "Use", "Equip", "Cancel" }
	for i, str in ipairs(choices) do
		local c_oy = pad * (0.5 + (i - 1) * 1.2)
		local c_y = c_by + c_oy
		Concord.entity(self.world):assemble(Assemblages.Inventory.choice, str, c_bx, c_y)
	end

	self.world:emit("create_list_group_grid", "inventory_cells", rows, cols)

	local rx = orig_x + bg_w * 0.4
	local ry = orig_y + pad * 0.3
	local rw = bg_w - orig_x
	local rh = bg_h * 0.4
	local b_ih = Resources.data.images.inventory_border:getHeight()
	local cw = rw / cols
	local ch = rh / rows

	Concord.entity(self.world):assemble(Assemblages.Inventory.border, 1, rx, ry, rw, rh, b_ih, false)
	Concord.entity(self.world):assemble(Assemblages.Inventory.border, 2, rx + rw, ry, rw, rh, b_ih, false)
	Concord.entity(self.world):assemble(Assemblages.Inventory.border, 3, rx, ry, rw, rh, b_ih, true)
	Concord.entity(self.world):assemble(Assemblages.Inventory.border, 4, rx, ry + rh, rw, rh, b_ih, true)
	Concord.entity(self.world):assemble(Assemblages.Inventory.border, 5, rx + cw, ry, rw, rh, b_ih, false)
	Concord.entity(self.world):assemble(Assemblages.Inventory.border, 6, rx + cw * 2, ry, rw, rh, b_ih, false)
	Concord.entity(self.world):assemble(Assemblages.Inventory.border, 7, rx, ry + ch, rw, rh, b_ih, true)

	for r = 1, rows do
		for c = 1, cols do
			local cx = rx + (c - 1) * cw
			local cy = ry + (r - 1) * ch
			local i = (r - 1) * cols + c
			local l1 = Concord.entity(self.world):assemble(Assemblages.Inventory.dline, i .. "a", cx, cy, cx + cw, cy + ch)
			local l2 = Concord.entity(self.world):assemble(Assemblages.Inventory.dline, i .. "b", cx, cy + ch, cx + cw, cy)
			Concord.entity(self.world):assemble(Assemblages.Inventory.cell, i, cx, cy, cw, ch):give("refs", l1, l2)
		end
	end
end

function Inventory:get_selected_item()
	for i, e in ipairs(self.pool_cell) do
		if e.list_cursor then
			return self.pool_item[i]
		end
	end
	return nil
end

Inventory["on_list_cursor_update_" .. "inventory_cells"] = function(self, e_hovered)
	for _, e in ipairs(self.pool_cell) do
		local alpha_range = e.alpha_range
		e.color.value[4] = e == e_hovered and alpha_range.max or alpha_range.min
	end
end

Inventory["on_list_cursor_update_" .. "inventory_choices"] = function(self, e_hovered)
	if not e_hovered.list_group.is_focused then
		return
	end
	for _, e in ipairs(self.pool_choice) do
		e.color.value[4] = e == e_hovered and 1 or 0.25
	end
end

Inventory["on_list_item_interact_" .. "inventory_cells"] = function(self, e_hovered)
	if not self:get_selected_item() then
		--TODO: (Brandon) play invalid sound
		return
	end
	for _, e in ipairs(self.pool_choice) do
		local alpha_range = e.alpha_range
		e.color.value[4] = alpha_range.max
	end
	self.world:emit("show_key", "inventory", false)
	self.world:emit("set_focus_list", "inventory_choices")
	self.in_choices = true
end

Inventory["on_list_item_interact_" .. "inventory_choices"] = function(self, e_hovered)
	local text = e_hovered.static_text.value
	local item = self:get_selected_item()
	if text == "Use" then
		self.world:emit("on_item_use", item)
	elseif text == "Equip" then
		self.world:emit("on_item_equip", item)
	elseif text == "Cancel" then
		for _, e in ipairs(self.pool_choice) do
			local alpha_range = e.alpha_range
			e.color.value[4] = alpha_range.min
		end
		self.world:emit("set_focus_list", "inventory_cells")
		self.world:emit("show_key", "inventory", true)
		self.in_choices = false
	end
end

return Inventory
