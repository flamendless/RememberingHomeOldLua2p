local Intro = Concord.system({
	pool_intro_text = { "intro_text" },
	pool_light = { "intro_light" },
})

function Intro:init(world)
	self.world = world
	self.is_raining = false
	self.is_switching = false
	self.intro_text_n = 1
end

function Intro:state_setup()
	local w, h = Resources.data.images.intro:getDimensions()
	local ww, wh = love.graphics.getDimensions()
	local ww2 = ww * 2

	self.canvas = Canvas.create_main()
	self.scale = math.min(ww / w, wh / h)
	self.camera = Gamera.new(0, 0, w, h)
	self.camera:setWindow(0, 0, ww, wh)
	Concord.entity(self.world):assemble(Assemblages.Common.camera, self.camera, self.scale, w, h)
	Concord.entity(self.world):assemble(Assemblages.Common.bg, "intro")

	self.world:emit("setup_particle_system", {
		ParticleSystems.RainIntro(Resources.data.images.rain_drop_tilted, 128, w),
		ParticleSystems.RainIntro(Resources.data.images.rain_drop_tilted2, 128, w),
	})
	self.world:emit("setup_post_process", {
		Shaders.NGrading("lut_afternoon"),
		Shaders.NGrading("lut_afternoon", "lut_dusk", false),
	})
	-- self.world:emit("set_ambiance", Palette.get_diffuse("ambiance_intro"))
	self.world:emit("set_draw", "ev_draw_ex")

	local asm_intro = Assemblages.Intro
	local asm_parallax = asm_intro.parallax
	for i = 1, 2 do
		Concord.entity(self.world):assemble(asm_parallax, "clouds")
		Concord.entity(self.world):assemble(asm_parallax, "buildings")
		Concord.entity(self.world):assemble(asm_parallax, "road")
		Concord.entity(self.world):assemble(asm_parallax, "grass")
		Concord.entity(self.world):assemble(asm_parallax, "grass2")
		Concord.entity(self.world):assemble(asm_parallax, "grass_back")
		Concord.entity(self.world):assemble(asm_parallax, "grass_front")
		local e_tree = Concord.entity(self.world):assemble(asm_parallax, "trees_bg")
		if i == 1 then
			Concord.entity(self.world):assemble(asm_intro.bg_tree_cover):give("attach_to", e_tree)
		end
		Concord.entity(self.world):assemble(asm_parallax, "trees_fg", 4)
		local e_post_light =
			Concord.entity(self.world):assemble(Assemblages.Intro.post_light, "post_light", 2):give("parallax_gap", w)
		Concord.entity(self.world)
			:assemble(asm_parallax, "post", 2)
			:give("attach_to", e_post_light)
			:give("attach_to_offset", 108, 0)
	end

	self.e_car = Concord.entity(self.world):assemble(asm_intro.car)
	Concord.entity(self.world):assemble(asm_intro.car_light, self.e_car):give("light_disabled"):give("intro_light")
	self.e_car_reflect = Concord.entity(self.world)
		:assemble(asm_intro.car_reflect, self.e_car)
		:give("animation_on_loop", "car_reflection_flicker")

	local fw, fh = 512, 128
	local fsx = ww2 * 4 / fw
	local fsy = 2
	Concord.entity(self.world)
		:assemble(asm_intro.fog, "fog1", fw, fh, { 0.6, 0.6, 0.6, 1 }, 0, 250, fsx, fsy * 0.45, 0.05)
	Concord.entity(self.world)
		:assemble(asm_intro.fog, "fog2", fw, fh, { 0.75, 0.75, 0.75, 0.55 }, 0, 290, fsx, fsy * 0.35, 3)
	Concord.entity(self.world)
		:assemble(asm_intro.fog, "fog3", fw, fh, { 0.9, 0.9, 0.9, 0 }, 0, 340, fsx, fsy * 0.5, 4)
		:give("fade_in_target_alpha", 0.45)
		:give("hidden")
	Concord.entity(self.world)
		:assemble(asm_intro.fog, "fog4", fw, fh, { 0.6, 0.6, 0.6, 0 }, 0, 290, fsx, fsy * 0.35, 2)
		:give("fade_in_target_alpha", 0.45)
		:give("hidden")

	Concord.entity(self.world)
		:assemble(Assemblages.UI.ui_text, "flamendless studio presents", "ui", 32, 32)
		:give("intro_text")
		:give("animation_data", Animation.get("splat"))

	Concord.entity(self.world)
		:assemble(Assemblages.UI.ui_text, "a game by Brandon", "ui", 32, 32)
		:give("intro_text")
		:give("animation_data", Animation.get("splat"))

	Concord.entity(self.world)
		:assemble(Assemblages.UI.ui_text, "arts by Conrad", "ui", 32, 32)
		:give("intro_text")
		:give("animation_data", Animation.get("splat"))

	Concord.entity(self.world)
		:assemble(Assemblages.UI.ui_text, "music by ???", "ui", 32, 32)
		:give("intro_text")
		:give("animation_data", Animation.get("splat"))

	self.e_title_light =
		Concord.entity(self.world):assemble(asm_intro.title_light, ww * 0.5, wh * 0.5):give("intro_text")

	self.e_title = Concord.entity(self.world):assemble(asm_intro.title, ww * 0.5, wh * 0.5):give("intro_text")

	if Save.data.intro_done or true then
		self.world:emit("show_skip")
	end
end

function Intro:state_init()
	local img_bg = Resources.data.images.intro
	local ww = love.graphics.getWidth()
	local w, h = img_bg:getDimensions()

	self.world:emit("start_timeline", function()
		self.world:emit("set_ambiance", { 0.5, 0.5, 0.5 })
		self.world:emit("pause_timeline")

		--how many times we will scale/move the camera for this cutscene
		local ambient_color = Palette.get_diffuse("ambiance_intro")
		local max_n_cam_t = 4
		self.world:emit("set_ambiance", ambient_color)
		self.world:emit("set_camera_transform", self.camera, { x = 53, y = 544, scale = 15 })

		TLE.Event.Wait(2)
		self.world:emit("fade_in_fog", "fog3", 32)
		self.world:emit("tween_depth_zoom", 5, 1 / max_n_cam_t, "cubicinout")
		self.world:emit("tween_camera_pos_rel", self.camera, 5, 0, -64, "cubicinout")
		self.world:emit("tween_camera_scale", self.camera, 5, 10, "cubicinout")

		TLE.Event.Wait(2)
		self.world:emit("enable_next_intro_text")
		self.world:emit("pause_timeline")

		local car_pos = self.e_car.pos
		self.world:emit("tween_depth_zoom", 5, 2 / max_n_cam_t, "circout")
		self.world:emit("tween_camera_scale", self.camera, 5, 5, "circout")
		self.world:emit("tween_camera_pos_rel", self.camera, 5, 160, -32, "circout")
		Flux.to(car_pos, 5, { x = 128 })

		self.world:emit("update_rain", 16)
		self.world:emit("enable_next_intro_text")
		self.world:emit("pause_timeline")

		--Enter forest
		self.world:emit("fade_out_fog", "fog1", 3)
		self.world:emit("fade_out_fog", "fog2", 3)
		-- self.world:emit("fade_out_fog", "fog3", 2)
		self.world:emit("fade_in_fog", "fog4", 3)
		self.world:emit("start_trees")
		for _, e in ipairs(self.pool_light) do
			e:remove("light_disabled")
		end
		Flux.to(ambient_color, 15, {
			[1] = 0.3,
			[2] = 0.3,
			[3] = 0.3,
		}):onupdate(function()
			self.world:emit("set_ambiance", ambient_color)
		end)

		self.world:emit("set_post_process_effect", "NGrading", false)
		self.world:emit("set_post_process_effect", "NGradingMulti", true)
		-- ngrading.status = 2
		-- current_ngrading = ngrading.multi
		-- Flux.to(ngrading, 15, {dt = 1})
		self.world:emit("tween_depth_zoom", 5, 3 / max_n_cam_t, "backout")
		self.world:emit("tween_camera_scale", self.camera, 5, 3, "backout")
		self.world:emit("tween_camera_pos_rel", self.camera, 5, 72, -32, "backout")
		Flux.to(car_pos, 3, { x = 160 })

		self.world:emit("enable_next_intro_text")
		self.world:emit("pause_timeline")

		self.world:emit("enable_next_intro_text")
		self.world:emit("pause_timeline")

		TLE.Event.Wait(2)
		self.world:emit("update_rain", 32)

		TLE.Event.Wait(1)
		self.world:emit("slow_parallax", 0.75)
		Flux.to(car_pos, 3, { x = ww * 0.5 })

		TLE.Event.Wait(2)
		self.world:emit("tween_depth_zoom", 5, 4 / max_n_cam_t)
		self.world:emit("tween_camera_scale", self.camera, 5, self.scale)
		self.world:emit("tween_camera_pos", self.camera, 5, w * 0.5, h * 0.5)
		self.world:emit("destroy_key", "skip")

		TLE.Event.Wait(1)
		self.e_title_light:remove("hidden")
		self.e_title_light:remove("light_disabled")
		self.e_title:remove("hidden"):give("color_fade_in", 4):give("color_fade_in_finish", "resume_timeline")
		self.world:emit("pause_timeline")

		TLE.Event.Wait(2)
		self.world:emit("stop_parallax")
		Flux.to(car_pos, 5, { x = ww * 1.5 })

		-- TODO implement lightning to quickly black out scene
		if not self.is_switching then
			Fade.fade_out(function()
				Save.toggle_flag("intro_done", true)
				self.is_raining = false
				self.is_switching = true
				self.world:emit("setup_particle_system", "PSRainIntro", "stop")
				self.world:emit("switch_state", "Outside")
			end, 2)
		end
	end)
end

function Intro:state_update(dt)
	self.world:emit("preupdate", dt)

	if Inputs.pressed("play") then
		self.world:emit("resume_timeline")
	end

	if (Save.data.intro_done or true) and not self.is_switching and Inputs.pressed("interact") then
		self.world:emit("destroy_key", "skip")
		Fade.fade_out(function()
			Save.toggle_flag("intro_done", true)
			self.is_raining = false
			self.is_switching = true
			self.world:emit("set_particle_system", "PSRainIntro", "stop")
			self.world:emit("switch_state", "Outside")
		end, 2)
	end

	if self.is_raining then
		self.world:emit("update_particle_system", dt)
	end

	self.world:emit("parallax_move_x", dt, -1)
	self.world:emit("ev_pp_invoke", "NGrading", "set_dt", dt)
	self.world:emit("update", dt)
end

function Intro:state_draw()
	self.world:emit("begin_deferred_lighting", self.camera, self.canvas)
	self.world:emit("end_deferred_lighting")
	self.world:emit("apply_post_process", self.canvas)
	self.world:emit("draw_ui")
	Fade.draw()
end

function Intro:ev_draw_ex()
	self.world:emit("draw_bg")
	self.world:emit("draw")
	if self.is_raining then
		self.world:emit("draw_particle_system", 0, -16)
	end
end

function Intro:state_keypressed(key)
	if key == "space" then
		self.world:emit("start_trees")
	end
end

function Intro:cleanup()
	self.world:emit("kill_timeline")
	self.world:emit("set_particle_system", "PSRainIntro", "stop")
end

function Intro:enable_next_intro_text()
	local e = self.pool_intro_text[self.intro_text_n]
	self.world:emit("fade_text", e, 4, function()
		self.world:emit("resume_timeline")
		self.intro_text_n = self.intro_text_n + 1
	end)
end

function Intro:car_reflection_flicker()
	local chance = Lume.randomchoice({ true, false })
	if chance then
		self.e_car_reflect:remove("hidden")
	else
		self.e_car_reflect:give("hidden")
	end
end

function Intro:update_rain(amount)
	if not (type(amount) == "number") then
		error('Assertion failed: type(amount) == "number"')
	end
	self.is_raining = true
	self.world:emit("set_particle_system", "PSRainIntro", "setEmissionRate", amount)
end

return Intro
