local NotesSystem = Concord.system({
	pool_item = {
		constructor = Ctor.ListByID,
		id = "notes",
	},
})

local c_on_hovered = Palette.get("note_on_hovered")

function NotesSystem:init(world)
	self.world = world
	self.is_open = false
	self:setEnabled(false)
end

function NotesSystem:open_notes()
	self.world:emit("set_system_to", Enums.ui_system.dialogues, false)
	self.is_open = true
	self.world:emit("set_post_process_effect", Enums.shaders.blur, true)
	self:create_notes()
	self.world:emit("create_note_items")
end

function NotesSystem:close_notes(not_close)
	assert:type_or_nil(not_close, "boolean")
	self.world:emit("set_system_to", Enums.ui_system.dialogues, true)
	if not not_close then
		self.world:emit("on_leave_interact_or_inventory")
	end
	self.is_open = false
	self.world:emit("set_post_process_effect", Enums.shaders.blur, false)
	self.world:emit("destroy_key", Enums.show_keys.notes)
	self.e_bg:destroy()
	self.e_cursor:destroy()
	for _, e in ipairs(self.pool_item) do
		e:destroy()
	end
	self.world:emit("destroy_list", Enums.list_group.notes)
	self.world:emit("inventory_to_notes", true)
end

function NotesSystem:update(dt)
	if self.is_open then
		if Inputs.pressed(Enums.input.inventory) then
			Inputs.flush()
			self.world:emit("close_notes", true)
			self.world:emit("open_inventory")
		elseif Inputs.pressed(Enums.input.cancel) then
			self:close_notes()
		end
	end
end

function NotesSystem:create_notes()
	local camera = self.world:getResource("camera")
	local _, _, w, h = camera:getWindow()
	local img = Resources.data.images.bg_notes
	local iw, ih = img:getDimensions()
	local bar_h = self.world:getResource("e_camera").bar_height.value

	local pad = 36
	local nh = h - pad * 2 - bar_h * 2
	local scale = math.min(w / iw, nh / ih)
	local x, y = w/2, h/2

	self.e_bg = Concord.entity(self.world):assemble(Assemblages.Notes.bg, x, y, scale)

	local font = Resources.data.fonts.note_list
	local fh = font:getHeight(" ")
	local padq = pad * 0.25

	local row_y = y - pad - ih * scale/2 + fh * 2 + 48
	local row_h = fh + padq * 2
	local rows = math.floor(ih * scale * 0.75 / row_h)

	self.rows_per_page = rows
	self.world:emit("create_list_group", Enums.list_group.notes, true, rows * 2)

	local acquired_notes = Notes.get_acquired()
	for i, note in ipairs(acquired_notes) do
		local index = (i - 1) % rows
		local offset_x = (i - 1) * 2
		local nx, ox
		if i <= rows then
			local bx = x - iw * scale/2 + padq
			nx = bx - offset_x + 64
			ox = 0
		else
			local bx = x + iw * scale/2 - padq
			nx = bx + offset_x - 96
			ox = 1
		end
		local ny = row_y + row_h * index + padq
		Concord.entity(self.world):assemble(Assemblages.Notes.text, i, note.title, nx, ny, ox)
	end

	self.e_cursor = Concord.entity(self.world):assemble(Assemblages.Notes.cursor)
	self.world:emit("create_notes_key", "notes")
end

NotesSystem["on_list_cursor_update_" .. Enums.list_group.notes] = function(self, e_hovered)
	assert((self.pool_item:has(e_hovered)), self)
	local font = e_hovered:get("font")
	local c_pos = self.e_cursor:get("pos")
	local pos = e_hovered:get("pos")
	local list_cursor = e_hovered:get("list_cursor")
	local on_left = list_cursor.value <= self.rows_per_page
	local dx
	if on_left then
		dx = -1
	else
		dx = 1
	end
	c_pos.x = pos.x + 4 * dx
	c_pos.y = pos.y - font.value:getHeight("")/2
	local transform = self.e_cursor:get("transform")
	if on_left then
		transform.ox = 1
	else
		transform.ox = 0
	end
	self.world:emit("lerp_color", self.e_cursor, { 1, 1, 1, 1 }, 0.25, "circin")
	self.world:emit("lerp_color", e_hovered, c_on_hovered, 0.25, "circin")
end

NotesSystem["on_list_cursor_remove_" .. Enums.list_group.notes] = function(self, e_hovered)
	assert((self.pool_item:has(e_hovered)), self)
	local color = e_hovered:get("color")
	self.world:emit("lerp_color", self.e_cursor, { 1, 1, 1, 0 }, 0.25, "circin")
	self.world:emit("lerp_color", e_hovered, color.original, 0.25, "circin")
end

NotesSystem["on_list_item_interact_" .. Enums.list_group.notes] = function(self, e_hovered)
	print(e_hovered:get("id").value)
end

return NotesSystem
