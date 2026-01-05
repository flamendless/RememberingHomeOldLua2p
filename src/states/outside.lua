local Outside = Concord.system({
	pool_splashes = { "splashes" },
	pool_bump = { "bump" },
	pool_car_lights = { "car_lights" },
})

local function tle_log(msg)
	local str = string.format("TLE: %s", msg)
	Log.debug(str)
end

function Outside:init(world)
	self.world = world
	self.is_raining = false
	self.rain_state = { current = 128 }
	self.overlay = { 0, 0, 0, 1 }
	self.main_car_light = nil
end

function Outside:state_setup()
	local bg_house = Resources.data.images.bg_house
	local w, h = bg_house:getDimensions()
	local ww, wh = love.graphics.getDimensions()

	self.canvas = Canvas.create_main()
	self.scale = math.min(ww / w, wh / h)

	self.camera = Gamera.new(0, 0, w, h)
	self.camera:setWindow(0, 0, ww, wh)
	Concord.entity(self.world):assemble(Assemblages.Common.camera, self.camera, self.scale, w, h)
	Concord.entity(self.world):assemble(Assemblages.Common.bg, "bg_sky")

	local _, _, cw, _ = self.camera:getVisible()
	self.ps1 = ParticleSystems.RainOutside(Resources.data.images.rain_drop, 128, cw)
	self.ps2 = ParticleSystems.RainOutside(Resources.data.images.rain_drop2, 128, cw)

	local bg_house_w, bg_house_h = bg_house:getDimensions()
	local div = 4
	local qw = bg_house_w / div
	local qh = bg_house_h

	for i = 1, div do
		local x = bg_house_w * ((i - 1) % div) / div
		local y = bg_house_h * math.floor((i - 1) / div) / div
		local quad = love.graphics.newQuad(x, y, qw, qh, bg_house_w, bg_house_h)
		Concord.entity(self.world):assemble(Assemblages.Outside.bg_house, x, y, quad)
	end

	--setup colliders
	for _, v in pairs(Assemblages.Outside.colliders) do
		Concord.entity(self.world):assemble(v, w, h)
	end
	self.world:emit("parse_room_items", "outside")

	Concord.entity(self.world):assemble(Assemblages.Outside.splashes)
	self.world:emit("generate_fireflies")

	self.world:emit("setup_post_process", {
		Shaders.NGrading("lut_dusk"),
		Shaders.Blur(),
		Shaders.Glitch(),
	})

	--setup lights
	for k, v in pairs(Assemblages.Outside.lights) do
		local e = Concord.entity(self.world):assemble(v, k)
		if e.id.value == "pl_car_headlight" then
			self.main_car_light = e
		end
	end

	--setup end of headlights
	local bx, by = 585, 323
	local r, s = 4, 64
	local color = Palette.get_diffuse("car_headlight_sl")
	local ix, iy = 10, 1
	for i = 1, 4 do
		local d = i - 1
		Concord.entity(self.world)
			:assemble(Assemblages.Light.point, bx + ix * d, by - iy * d, r, s, color)
			:give("id", "pl_headlight_end" .. i)
			:give("car_lights")
	end
	self.world:emit("set_ambiance", Palette.get_diffuse("ambiance_outside"))
	self.world:emit("set_draw", "ev_draw_ex")
end

function Outside:state_init()
	if self.prev_id == "StorageRoom" then
		self.world:emit("spawn_player", function(e_player)
			self.world:emit("toggle_component", e_player, "can_move", true)
			self.world:emit("toggle_component", e_player, "can_interact", true)
			self.world:emit("camera_follow", e_player, 0.25)
			self.camera:setScale(3)
			self.camera:setPosition(e_player.pos.x, e_player.pos.y)
			self.camera:setScale(3)
		end)
		Fade.set_alpha(0)

		for _, e in ipairs(self.pool_bump) do
			local id = e.id.value
			if id == "backdoor" then
				e:remove("dialogue_meta"):give("is_door")
			end
		end
		return
	end

	if Save.data.outside_intro_done then
		return
	end

	--TEST

	-- self.world:emit("spawn_player", function(e_player)
	-- 	e_player:give("color_fade_in", 0.25)
	-- 	self.world:emit("player_can_move", true, e_player)
	-- 	self.world:emit("player_can_interact", true, e_player)
	-- 	self.world:emit("camera_follow", e_player, 0.25)
	-- 	self.camera:setScale(3)
	-- 	self.camera:setPosition(e_player.pos.x, e_player.pos.y)
	-- end)

	self.timeline = TLE.Do(function()
		self.timeline:Pause()

		Fade.set_alpha(0)
		self.is_raining = true
		self.overlay_flag = true
		self.ps1.system:setEmissionRate(self.rain_state.current)
		self.ps2.system:setEmissionRate(self.rain_state.current)

		tle_log("begin timeline")
		self.world:emit("set_camera_transform", self.camera, { x = 0, y = 0, scale = 6 })

		tle_log("start fade in")
		Flux.to(self.overlay, 4, { [4] = 0 }):oncomplete(function()
			self.overlay_flag = false
			tle_log("end fade in")
		end)

		tle_log("start camera pan and zoom")
		local dt_cam = {}
		dt_cam.x, dt_cam.y = self.camera:getPosition()
		dt_cam.scale = self.camera:getScale()
		Flux.to(dt_cam, 6, { x = 532, y = 235, scale = 5 })
			:delay(2)
			:onupdate(function()
				self.world:emit("set_camera_transform", self.camera, {
					x = dt_cam.x,
					y = dt_cam.y,
					scale = dt_cam.scale,
				})
			end)
			:oncomplete(function()
				self.timeline:Unpause()
			end)
		self.timeline:Pause()

		Flux.to(dt_cam, 10, { x = 720, y = 263, scale = 3 })
			:onupdate(function()
				self.camera:setPosition(dt_cam.x, dt_cam.y)
				self.camera:setScale(dt_cam.scale)
			end)
			:oncomplete(function()
				self.timeline:Unpause()
			end)
		self.timeline:Pause()

		tle_log("begin rain fade")
		self:start_rain_fade()
		self.timeline:Pause()

		tle_log("car light off")
		self.main_car_light
			:give("d_light_flicker", 2.5, 0.75, 0.25)
			:give("on_d_light_flicker_during", "flicker_sync", 0, self.main_car_light, self.pool_car_lights)
			:give("on_d_light_flicker_after", "on_car_light_flicker_after")
			:give("d_light_flicker_remove_after")
		self.timeline:Pause()

		tle_log("show player")
		local dur_camera_follow = 1.5
		local e_player
		self.world:emit("spawn_player", function(e)
			e_player = e
			e_player:give("color_fade_in", 0.25)
		end)
		dt_cam.x, dt_cam.y = self.camera:getPosition()
		dt_cam.scale = self.camera:getScale()
		Flux.to(dt_cam, 3, { x = e_player.pos.x, y = e_player.pos.y, scale = 3 })
			:onupdate(function()
				self.world:emit("set_camera_transform", self.camera, {
					x = dt_cam.x,
					y = dt_cam.y,
					scale = dt_cam.scale,
				})
			end)
			:oncomplete(function()
				self.world:emit("camera_follow", e_player, dur_camera_follow)
				self.world:emit("toggle_component", e_player, "can_move", true)
				self.world:emit("toggle_component", e_player, "can_interact", true)
			end)
		self.timeline:Pause()
	end)
end

function Outside:state_update(dt)
	self.world:emit("preupdate", dt)

	if Inputs.pressed("play") then
		self.timeline:Unpause()
	elseif Inputs.pressed("inventory") then
		if not Items.has("flashlight") then
			Items.add("flashlight")
		end
	end

	self.world:emit("update", dt)

	if self.is_raining then
		self.ps1:update(dt)
		self.ps2:update(dt)
	end
end

function Outside:state_draw()
	self.world:emit("begin_deferred_lighting", self.camera, self.canvas)
	if self.is_raining then
		local l, t = self.camera:getVisible()
		local s = self.camera:getScale()
		love.graphics.push()
		love.graphics.translate(l, t)
		love.graphics.scale(s)
		self.ps1:draw(0, -16)
		self.ps2:draw(0, -16)
		love.graphics.pop()
	end
	self.world:emit("end_deferred_lighting")
	self.world:emit("apply_post_process", self.canvas)

	self.world:emit("draw_ui")

	if self.overlay_flag then
		self.camera:attach()
		local l, t, w, h = self.camera:getVisible()
		love.graphics.setColor(self.overlay)
		love.graphics.rectangle("fill", l, t, w, h)
		self.camera:detach()
	end
	Fade.draw()
end

function Outside:ev_draw_ex()
	self.world:emit("draw_bg")
	self.world:emit("draw")
end

function Outside:start_rain_fade()
	local dur_fade_rain = 8
	for _, e in ipairs(self.pool_splashes) do
		e:give("color_fade_out", dur_fade_rain)
	end

	Flux.to(self.rain_state, dur_fade_rain, { current = 0 })
		:onupdate(function()
			self.ps1.system:setEmissionRate(self.rain_state.current)
			self.ps2.system:setEmissionRate(self.rain_state.current)
		end)
		:oncomplete(function()
			for _, e in ipairs(self.pool_splashes) do
				e:destroy()
			end
			self.is_raining = false
			self.ps1.system:stop()
			self.ps2.system:stop()
			tle_log("splashes stopped")

			tle_log("fireflies start")
			self.world:emit("show_fireflies", 5)
			self.world:emit("move_fireflies")
			self.timeline:Unpause()

			self.world:emit("cleanup_rain")
			tle_log("end rain fade")
		end)
end

function Outside:on_car_light_flicker_after()
	for _, e in ipairs(self.pool_car_lights) do
		local diff = e.diffuse
		diff.value[1] = diff.orig_value[1]
		diff.value[2] = diff.orig_value[2]
		diff.value[3] = diff.orig_value[3]
		self.world:emit("update_light_diffuse", e)
	end
	self.timeline:Unpause()
end

function Outside:get_flashlight(e, dialogues_t)
	if not (e.__isEntity and e.dialogue_meta) then
		error("Assertion failed: e.__isEntity and e.dialogue_meta")
	end
	if not (type(dialogues_t) == "table") then
		error('Assertion failed: type(dialogues_t) == "table"')
	end
	local has_flashlight = Items.has("flashlight")
	if not has_flashlight then
		Items.add("flashlight")
		self.world:emit("wait_dialogue", true)
		Timer.after(2, function()
			self.world:emit("wait_dialogue", false)
			local t = tablex.copy(dialogues_t.get_flashlight)
			self.world:emit("spawn_dialogue_ex", t)
		end)
	else
		local t = tablex.copy(dialogues_t.has_flashlight_already)
		self.world:emit("spawn_dialogue_ex", t)
	end
end

function Outside:toggle_car_power(ent)
	--TODO play sound
	self.world:emit("wait_dialogue", true)
	self.world:emit("remove_choices")
	local mcl = self.main_car_light.light_disabled
	for _, e in ipairs(self.pool_car_lights) do
		e:remove("light_disabled")
	end
	self.main_car_light
		:give("d_light_flicker", 2, 0.75, 0.25)
		:give("on_d_light_flicker_during", "flicker_sync", 0, self.main_car_light, self.pool_car_lights)
		:give("on_d_light_flicker_after", "toggle_car_power_after", 0, ent, mcl)
		:give("d_light_flicker_remove_after")
end

function Outside:toggle_car_power_after(ent, flag)
	for _, e in ipairs(self.pool_car_lights) do
		if flag then
			e:remove("light_disabled")
		else
			e:give("light_disabled")
		end
	end
	self.world:emit("wait_dialogue", false)
	self.world:emit("on_dialogue_reached_end")
end

function Outside:check_frontdoor(e, dialogues_t)
	if not (e.__isEntity and e.dialogue_meta) then
		error("Assertion failed: e.__isEntity and e.dialogue_meta")
	end
	if not (type(dialogues_t) == "table") then
		error('Assertion failed: type(dialogues_t) == "table"')
	end
	self.world:emit("remove_choices")
	local has_frontdoor_key = Items.has("frontdoor_key")
	if not has_frontdoor_key then
		local t = tablex.copy(dialogues_t.door_locked)
		self.world:emit("spawn_dialogue_ex", t)
	end
end

function Outside:make_car_interactive()
	for _, e in ipairs(self.pool_bump) do
		if e.id.value == "car" then
			e:give("interactive")
			break
		end
	end
end

function Outside:check_backdoor(e, dialogues_t)
	if not (e.__isEntity and e.dialogue_meta) then
		error("Assertion failed: e.__isEntity and e.dialogue_meta")
	end
	if not (e.__isEntity and e.player) then
		error("Assertion failed: e.player")
	end
	if not (type(dialogues_t) == "table") then
		error('Assertion failed: type(dialogues_t) == "table"')
	end
	local has_flashlight = Items.has("flashlight")
	if not has_flashlight then
		local t = tablex.copy(dialogues_t.no_flashlight_yet)
		self.world:emit("spawn_dialogue_ex", t)
	else
		self.world:emit("wait_dialogue", true)
		self.world:emit("toggle_component", e, "can_move", true)
		self.world:emit("toggle_component", e, "can_interact", true)
		self.world:emit("anim_open_door", e)
		self.world:emit("switch_state", "StorageRoom", 3, 2)
	end
end

function Outside:cleanup()
	if self.timeline then
		self.timeline:Die()
	end
end

return Outside
