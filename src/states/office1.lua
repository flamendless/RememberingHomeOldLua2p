local Office1 = Concord.system()

function Office1:init(world)
	self.id = "office1"
	self.world = world
end

function Office1:state_setup()
	local w, h = Resources.data.images.office1:getDimensions()
	local ww, wh = love.graphics.getDimensions()
	local mult = 1.5
	local rw = w * mult

	self.canvas = Canvas.create_main()
	self.scale = math.min(ww / w, wh / h)
	self.camera = Gamera.new(0, 0, rw, h)
	self.camera:setWindow(0, 0, ww, wh)
	Concord.entity(self.world):assemble(Assemblages.Common.camera, self.camera, self.scale, rw, h)
	Concord.entity(self.world):assemble(Assemblages.Common.bg, self.id, rw)

	self.world:emit("create_room_bounds", rw, h, {sx = mult})
	self.world:emit("parse_room_items", self.id)
	self.world:emit("setup_post_process", {
		Shaders.NGrading("lut_dusk"),
		Shaders.FilmGrain(),
		Shaders.Blur(),
		Shaders.DitherGradient(),
		Shaders.Glitch(),
	})

	self.world:emit("set_ambiance", Palette.get_diffuse("ambiance_office1"))
	self.world:emit("set_draw", "ev_draw_ex")
end

function Office1:state_init()
	self.world:emit("spawn_player", function(e_player)
		self.world:emit("camera_follow", e_player, 0.25)
		self.world:emit("toggle_component", e_player, "can_move", true)
		self.world:emit("toggle_component", e_player, "can_interact", true)
		self.world:emit("toggle_component", e_player, "can_run", true)
		self.e_player = e_player
	end)

	self.timeline = TLE.Do(function()
		Fade.fade_in(nil, 1)
		self.camera:setScale(2)
		self.timeline:Pause()
	end)
end

function Office1:state_update(dt)
	self.world:emit("preupdate", dt)
	self.world:emit("update", dt)
end

function Office1:state_draw()
	self.world:emit("begin_deferred_lighting", self.camera, self.canvas)
	self.world:emit("end_deferred_lighting")
	self.world:emit("apply_post_process", self.canvas)
	self.world:emit("draw_ui")
	Fade.draw()
end

function Office1:ev_draw_ex()
	self.world:emit("draw_bg")
	self.world:emit("draw")
end

return Office1
