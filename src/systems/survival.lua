local Survival = Concord.system()

-- INFO:
-- shutdown lights
-- set ambiance
-- zoom in
-- open flashlight
-- vignette
-- audio muffles slightly
-- vignette slowly closes inward
-- heartbeat sync begins
function Survival:init(world)
	self.world = world

	self.state = Enums.survival_state.normal
	self.is_active = false
end

function Survival:survival_toggle()
	if self.is_active then
		self:survival_off()
	else
		self:survival_on()
		self.state = Enums.survival_state.engaged
		self.world:emit("update_survival_effects", self.state)
	end
end

function Survival:update_survival_effects(state)
	assert(Enums.survival_state[state])
	if state == Enums.survival_state.dead then
		TODO("player dead")

	elseif state == Enums.survival_state.normal then
		self.world:emit("ev_pp_invoke", Enums.shaders.vignette_ex, "update_effects", Data.Vignette.values.zero)

	else
		self.world:emit("ev_pp_invoke", Enums.shaders.vignette_ex, "update_effects",Data.Vignette.values[self.state])
	end
end


function Survival:survival_on()
	self.is_active = true
	self.world:emit("set_post_process_effect", Enums.shaders.vignette_ex, true)
	-- self.world:emit("ev_pp_invoke", Enums.shaders.vignette_ex, "survival_on")
	self.prev_state = {}

	-- self.world:emit("shutdown_lights")
	-- self.world:emit("set_ambiance", Palette.get_diffuse("ambiance_survival"))

	local e_player = self.world:getResource("e_player")
	assert(e_player)

	local camera = self.world:getResource("camera")
	assert(camera)
	self.prev_state.camera = tablex.copy(camera)

	local DUR = 1
	local SCALE = 2

	local cfo = e_player.camera_follow_offset
	if cfo then
		local coll = e_player.collider
		self.prev_state.camera_follow_offset = tablex.copy(cfo)
		cfo.x = coll.w / 2
		cfo.y = coll.h / 4
	end

	local prev_scale = camera.scale
	self.world:emit("tween_camera_scale", camera, DUR, prev_scale * SCALE, Enums.ease.cubicout)

	self.timer_open_flashlight = Timer.new()
	self.timer_open_flashlight_t = self.timer_open_flashlight:after(1, function()
		--TODO: add sound effect of flashlight on
		self.world:emit("toggle_light_group", "player_flashlight", true)
	end)
end

function Survival:survival_off()
	self.is_active = false

	local e_player = self.world:getResource("e_player")
	assert(e_player)

	local camera = self.world:getResource("camera")
	assert(camera)

	camera.scale = self.prev_state.camera.scale

	local cfo = e_player.camera_follow_offset
	if cfo then
		self.prev_state.camera = tablex.copy(camera)
		local prev_cfo = self.prev_state.camera_follow_offset
		e_player.camera_follow_offset = prev_cfo
	end
end

function Survival:update(dt)
	if not self.is_active then return end
	if self.timer_open_flashlight then
		self.timer_open_flashlight:update(dt)
	end
end

function Survival:draw()
	if not self.is_active then return end
end

if DEV then
	function Survival:debug_update(dt)
		if not self.debug_show then return end

		self.debug_show = Slab.BeginWindow("survival", {
			Title = "Survival",
			IsOpen = self.debug_show,
		})
		if Slab.CheckBox(self.is_active, "state") then
			self.is_active = not self.is_active
			if self.is_active then
				self:survival_on()
			else
				self:survival_off()
			end
		end

		Slab.Text("State: " .. self.state)
		if Slab.BeginComboBox("state", { Selected = self.state }) then
			for _, v in ipairs(Enums.ordered.survival_state) do
				if Slab.TextSelectable(v) then
					self.state = v
					self.world:emit("update_survival_effects", self.state)
					break
				end
			end
			Slab.EndComboBox()
		end

		if self.timer_open_flashlight then
			UIWrapper.edit_number("Timer open flashlight", self.timer_open_flashlight_t.time, false)
		end

		Slab.EndWindow()
	end
end

return Survival
