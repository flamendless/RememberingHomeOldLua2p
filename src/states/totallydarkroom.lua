local TotallyDarkRoom = Concord.system()

function TotallyDarkRoom:init(world)
	self.id = "living_room" -- NOTE: (Brandon) intentional
	self.world = world
end

function TotallyDarkRoom:state_setup()
	local w, h = Resources.data.images.living_room:getDimensions()
	local ww, wh = love.graphics.getDimensions()

	self.canvas = Canvas.create_main()
	self.scale = math.min(ww / w, wh / h)
	self.camera = Gamera.new(0, 0, w, h)
	self.camera:setWindow(0, 0, ww, wh)
	Concord.entity(self.world):assemble(Assemblages.Common.camera, self.camera, self.scale, w, h)
	Concord.entity(self.world):assemble(Assemblages.Common.bg, self.id)

	self.world:emit("create_room_bounds", w, h)
	self.world:emit("parse_room_items", self.id)
	self.world:emit("setup_post_process", {
		Shaders.NGrading("lut_dusk"),
		Shaders.FilmGrain(),
		Shaders.Blur(),
		Shaders.DitherGradient(),
		Shaders.Glitch(),
	})

	for _, v in pairs(Assemblages.LivingRoom.lights) do
		Concord.entity(self.world):assemble(v):give("light_disabled")
	end
	self.world:emit("set_ambiance", Palette.get_diffuse("ambiance_totally_dark_room"))
	self.world:emit("set_draw", "ev_draw_ex")
end

function TotallyDarkRoom:state_init()
	self.world:emit("spawn_player", function(e_player)
		self.world:emit("camera_follow", e_player, 0.25)
		self.world:emit("toggle_component", e_player, "can_move", true)
		self.world:emit("toggle_component", e_player, "can_interact", true)
		self.world:emit("toggle_component", e_player, "can_run", true)
	end)

	self.timeline = TLE.Do(function()
		Fade.fade_in(nil, 1)
		self.camera:setScale(4)
		self.timeline:Pause()
	end)
end

function TotallyDarkRoom:state_update(dt)
	self.world:emit("preupdate", dt)
	self.world:emit("update", dt)
end

function TotallyDarkRoom:state_draw()
	self.world:emit("begin_deferred_lighting", self.camera, self.canvas)
	self.world:emit("end_deferred_lighting")
	self.world:emit("apply_post_process", self.canvas)
	self.world:emit("draw_ui")
	Fade.draw()
end

function TotallyDarkRoom:ev_draw_ex()
	self.world:emit("draw_bg")
	self.world:emit("draw")
end

return TotallyDarkRoom
