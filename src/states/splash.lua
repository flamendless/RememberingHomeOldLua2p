local Splash = Concord.system()

local DELAY_SKIP = 0.5

function Splash:init(world)
	self.id = "splash"
	self.world = world
end

function Splash:state_setup()
	self.canvas = Canvas.create_main()
	--TODO: (Brandon) maybe add glitch effect to other sub-splash screens?
	self.world:emit("setup_post_process", {
		Shaders.glitch(),
	})
end

function Splash:state_init()
	if Save.data.splash_done then
		self.world:emit("show_skip")
	end

	self.timeline = TLE.Do(function()
		self.world:emit("set_post_process_effect", Enums.shaders.glitch, true)
		self.current_state = Enums.splash_state.love
		self:set_skippable_timer()
		self:create_splash_love()
		self:do_glitch(3, 2)
		self.timeline:Pause()

		self.world:emit("ev_pp_invoke", Enums.shaders.glitch, "reset_glitch")
		self.world:emit("set_post_process_effect", Enums.shaders.glitch, false)
		self.current_state = Enums.splash_state.wits
		self:set_skippable_timer()
		self:create_splash_wits()
		self.timeline:Pause()

		self.world:emit("ev_pp_invoke", Enums.shaders.glitch, "reset_glitch")
		self.world:emit("set_post_process_effect", Enums.shaders.glitch, true)
		self.current_state = Enums.splash_state.flam
		self:set_skippable_timer()
		self:create_splash_flamendless()
		self:do_glitch(5, 1)
		self.timeline:Pause()
	end)
end

function Splash:set_skippable_timer()
	if Save.data.splash_done then
		self.timer_skip = Timer()
		self.timer_skip:after(DELAY_SKIP, function()
			self.skippable = true
		end)
	end
end

function Splash:create_splash_love()
	self.splash_love = LoveSplash()
	self.splash_love.onDone = function()
		self.timeline:Unpause()
	end
end

function Splash:create_splash_wits()
	self.world:emit("set_post_process_effect", Enums.shaders.glitch, false)
	local ww, wh = love.graphics.getDimensions()
	local anim = Anim.new_single(Animation.get("wits"))
	anim:on("loop", function()
		anim:pause_at_end()
	end)
	anim:once("finish", function()
		self:splash_wits_done()
	end)
	self.splash_wits = Concord.entity(self.world)
		:give("anim", anim)
		:give("id", "splash_wits")
		:give("pos", ww/2, wh/2)
		:give("color", { 1, 1, 1, 1 })
		:give("transform", 0, 1, 1, 0.5, 0.5)
		:give("auto_scale", ww, wh, true)
		:give("fade_to_black", 1.5, 1)
end

function Splash:create_splash_flamendless()
	local ww, wh = love.graphics.getDimensions()
	self.splash_flamendless = Concord.entity(self.world)
		:give("id", "splash_flamendless")
		:give("sprite", "flamendless_logo")
		:give("pos", ww/2, wh/2)
		:give("transform", 0, 1, 1, 0.5, 0.5)
		:give("color", { 1, 1, 1, 1 })

	self.txt_flamendless = Concord.entity(self.world)
		:give("id", "txt_flamendless")
		:give("text", "flamendless")
		:give("font", "ui")
		:give("pos", ww/2, wh * 0.75)
		:give("transform", 0, 1, 1, 0.5, 0.5)
		:give("color", { 1, 1, 1, 1 })
end

function Splash:create_effects()
	local ww, wh = love.graphics.getDimensions()
	self.typewriter = Concord.entity(self.world)
		:give("id", "typewriter")
		:give("color", Palette.colors.white)
		:give("pos", ww/2, wh * 0.2)
		:give("transform", 0, 1, 1, 0.5, 0.5)
		:give("text", "")
		:give("target_text", "a game by")
		:give("font", "uncle_type_32")
		:give("typewriter", 0.2)
		:give("typewriter_timer")
		:give("typewriter_on_finish", "switch_state", 1.25, "Menu")
end

function Splash:splash_wits_done()
	self.world:emit("start_fade")
	self:create_effects()
	GameStates.after(2, function()
		self.world:emit("start_colors_lerp")
		self.world:emit("start_typewriter")
		self.timeline:Unpause()
	end)
end

local c = { none = 0.7, reset = 0.25, glitch = 0.05 }
function Splash:do_glitch(time, delay)
	assert(type(time) == "number", time)
	if delay then
		assert(type(delay) == "number", delay)
	end
	GameStates.after(delay or 0, function()
		Timer.during(time, function()
			local res = Lume.weightedchoice(c)
			if res == "glitch" then
				self.world:emit("ev_pp_invoke", Enums.shaders.glitch, "do_random_glitch")
			elseif res == "reset" then
				self.world:emit("ev_pp_invoke", Enums.shaders.glitch, "reset_glitch")
			end
		end, function()
			self.world:emit("ev_pp_invoke", Enums.shaders.glitch, "reset_glitch")
		end)
	end)
end

function Splash:state_update(dt)
	if self.timer_skip then
		self.timer_skip:update(dt)
	end

	if self.current_state == Enums.splash_state.love then
		self.splash_love:update(dt)
	else
		self.world:emit("update", dt)
	end

	if Save.data.splash_done then
		if Inputs.released("interact") then
			if self.current_state == Enums.splash_state.love and self.skippable then
				self.splash_love:skip()
				self.skippable = false
			end

			if self.current_state == Enums.splash_state.wits and self.skippable then
				self.splash_wits.anim.obj:stop("pauseAtEnd")
				self.skippable = false
			end

			if self.current_state == Enums.splash_state.flam and self.skippable then
				self.world:emit("switch_state", "Menu")
				self.skippable = false
			end
		end
	end
end

function Splash:state_draw()
	love.graphics.setCanvas(self.canvas.canvas)
	love.graphics.clear()
	if self.current_state == Enums.splash_state.love then
		self.splash_love:draw()
	else
		self.world:emit("draw")
	end
	self.world:emit("draw_ui")
	love.graphics.setCanvas()
	self.world:emit("apply_post_process", self.canvas)
	Fade.draw()
end

function Splash:cleanup()
	if self.timer_skip then
		self.timer_skip:clear()
	end
	self.splash_love = nil
end

return Splash
