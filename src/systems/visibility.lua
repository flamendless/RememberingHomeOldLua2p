local Visibility = Concord.system({
	pool = { "player_ambient_light", "point_light", "pos", "diffuse" },
})

local PITCH_BLACK_AMBIANCE = { 0, 0, 0, 0 }

function Visibility:init(world)
	self.world = world
	self.is_active = false
	self.config = nil
	self.e_light = nil
	self.saved_ambiance = nil
	self.pending_spawn = false
	self.last_light_x = nil
	self.last_light_y = nil
	self.last_light_z = nil
	self.light_pos_synced = false
end

function Visibility:get_deferred_lighting()
	return self.world:getSystem(ECS.get_system_class("deferred_lighting"))
end

function Visibility:save_ambiance()
	local dl = self:get_deferred_lighting()
	if not dl then
		return
	end
	self.saved_ambiance = { unpack(dl.ambiance) }
end

function Visibility:spawn_light()
	if self.e_light then
		return
	end

	local config = self.config
	assert(config, "visibility config missing")

	self.e_light = Concord.entity(self.world)
		:assemble(Assemblages.Light.player_ambient, config.width, config.diffuse_key)

	local pos = self.e_light:get("pos")
	pos.z = config.height

	local e_player = self.world:getResource("e_player")
	if e_player then
		self:sync_light_to_player(e_player)
	end

	self.pending_spawn = false
end

function Visibility:destroy_light()
	if not self.e_light then
		return
	end
	self.e_light:destroy()
	self.e_light = nil
	self.last_light_x = nil
	self.last_light_y = nil
	self.last_light_z = nil
	self.light_pos_synced = false
end

function Visibility:sync_light_to_player(e_player)
	if not self.e_light or not e_player then
		return
	end

	local pos = e_player:get("pos")
	local col = e_player:get("collider")
	local light_pos = self.e_light:get("pos")

	local x_offset = self.config.x_offset or 0
	local y_offset = self.config.y_offset or 0
	local lx = pos.x + col.w_h + x_offset
	local ly = pos.y + col.h_h + y_offset
	local lz = self.config.height
	local moved = lx ~= self.last_light_x or ly ~= self.last_light_y or lz ~= self.last_light_z

	light_pos.x = lx
	light_pos.y = ly
	light_pos.z = lz

	if not moved and self.light_pos_synced then
		return
	end

	self.last_light_x = lx
	self.last_light_y = ly
	self.last_light_z = lz

	if self.e_light:has("light_id") then
		self.world:emit("update_light_pos", self.e_light)
		self.light_pos_synced = true
	end
end

function Visibility:set_visibility(active, config)
	assert:type(active, "boolean")
	assert:type_or_nil(config, "table")

	if active then
		self.config = tablex.copy(config or Data.Visibility.dark_room)
		if not self.is_active then
			self:save_ambiance()
		end
		self.is_active = true
		self.pending_spawn = true
		self.world:emit("set_ambiance", PITCH_BLACK_AMBIANCE)
		if self.world:getResource("e_player") then
			self:spawn_light()
		end
	else
		self.is_active = false
		self.pending_spawn = false
		self:destroy_light()
		if self.saved_ambiance then
			self.world:emit("set_ambiance", self.saved_ambiance)
		end
	end
end

function Visibility:update(dt)
	if not self.is_active then
		return
	end

	if self.pending_spawn or not self.e_light then
		local e_player = self.world:getResource("e_player")
		if e_player then
			self:spawn_light()
		end
	end

	local e_player = self.world:getResource("e_player")
	if self.e_light and e_player then
		self:sync_light_to_player(e_player)
	end
end

if DEV then
	function Visibility:debug_update(dt)
		if not self.debug_show then
			return
		end

		self.debug_show = Slab.BeginWindow("visibility", {
			Title = "Visibility",
			IsOpen = self.debug_show,
		})

		if Slab.CheckBox(self.is_active, "active") then
			if self.is_active then
				self:set_visibility(false)
			else
				self:set_visibility(true, self.config or Data.Visibility.dark_room)
			end
		end

		if self.is_active and self.e_light and self.config then
			local pl = self.e_light:get("point_light")
			local light_pos = self.e_light:get("pos")
			local diffuse = self.e_light:get("diffuse").value
			local b_w, b_h, b_x, b_y, b_r, b_g, b_b

			self.config.width, b_w = UIWrapper.edit_range("width", self.config.width, 0, 128, false)
			self.config.height, b_h = UIWrapper.edit_range("height", self.config.height, 0, 64, false)
			self.config.x_offset, b_x = UIWrapper.edit_range("x_offset", self.config.x_offset, -64, 64, false)
			self.config.y_offset, b_y = UIWrapper.edit_range("y_offset", self.config.y_offset, -64, 64, false)
			diffuse[1], b_r = UIWrapper.edit_range("r", diffuse[1], 0, 2, false)
			diffuse[2], b_g = UIWrapper.edit_range("g", diffuse[2], 0, 2, false)
			diffuse[3], b_b = UIWrapper.edit_range("b", diffuse[3], 0, 2, false)

			if b_w then
				pl.value = self.config.width
			end
			if b_h then
				light_pos.z = self.config.height
			end
			if b_w or b_h or b_x or b_y then
				local e_player = self.world:getResource("e_player")
				if e_player then
					self:sync_light_to_player(e_player)
				elseif self.e_light:has("light_id") then
					self.world:emit("update_light_pos", self.e_light)
				end
			end
			if b_r or b_g or b_b then
				self.world:emit("update_light_diffuse", self.e_light)
			end
		end

		if self.config and Slab.Button("Print") then
			local c = self.config
			local d = self.e_light and self.e_light:get("diffuse").value
			print("visibility width", c.width)
			print("visibility height", c.height)
			print("visibility x_offset", c.x_offset)
			print("visibility y_offset", c.y_offset)
			print("visibility diffuse_key", c.diffuse_key)
			if d then
				print("visibility diffuse r", d[1])
				print("visibility diffuse g", d[2])
				print("visibility diffuse b", d[3])
			end
		end

		Slab.EndWindow()
	end
end

return Visibility
