local Shed = Concord.system()

local SHED_ANT_TRAIL_COUNT = 2
local SHED_ANT_TRAIL_LANE_INSET = 0.2

function Shed:init(world)
	assert:world(world)
	self.id = "shed"
	self.world = world
end

function Shed:state_setup()
	local w, h = Resources.data.images.bg_shed:getDimensions()
	local ww, wh = love.graphics.getDimensions()

	self.canvas = Canvas.create_main()
	self.scale = math.min(ww / w, wh / h)
	self.camera = Gamera.new(0, 0, w, h)
	self.camera:setWindow(0, 0, ww, wh)
	Concord.entity(self.world):assemble(Assemblages.Common.camera, self.camera, self.scale, w, h)
	Concord.entity(self.world):assemble(Assemblages.Common.bg, "bg_shed")

	self.world:emit("create_room_bounds", w, h, { room_id = Enums.game_state.Shed })
	self.world:emit("parse_room_items", self.id)
	self.world:emit("setup_post_process", {
		Shaders.ngrading("lut_dusk"),
		Shaders.film_grain(),
		Shaders.blur(),
		Shaders.glitch(),
	})

	for _, v in pairs(Assemblages.Shed.lights) do
		Concord.entity(self.world):assemble(v)
	end
	self.world:emit("set_ambiance", Palette.get_diffuse("ambiance_shed"))
	self.world:emit("set_visibility", true, Data.Visibility.shed)
	self.world:emit("set_draw", "ev_draw_ex")
end

local function floor_to_ceiling_ant_path(room_w, room_h, floor_x)
	local room_id = Enums.game_state.Shed
	local floor_y = Data.Rooms.ground_top_y(room_id, room_h) - love.math.random(2, 6)
	local ceiling_y = Data.Rooms.get_ceiling_bottom_y(room_id)
		+ love.math.random(4, 12)
	local floor_min_x = 32
	local floor_max_x = room_w - 32
	local end_x = mathx.clamp(floor_x + love.math.random(-8, 8), floor_min_x, floor_max_x)
	return vec2(floor_x, floor_y), vec2(end_x, ceiling_y)
end

local function shed_ant_trail_floor_xs(room_w)
	local floor_min_x = 32
	local floor_max_x = room_w - 32
	local span = floor_max_x - floor_min_x
	local lane_w = span / SHED_ANT_TRAIL_COUNT
	local xs = {}
	for i = 1, SHED_ANT_TRAIL_COUNT do
		local lane_lo = floor_min_x + (i - 1) * lane_w + lane_w * SHED_ANT_TRAIL_LANE_INSET
		local lane_hi = floor_min_x + i * lane_w - lane_w * SHED_ANT_TRAIL_LANE_INSET
		xs[i] = love.math.random(math.floor(lane_lo), math.ceil(lane_hi))
	end
	return xs
end

local function spawn_shed_bugs(world)
	local room_size = world:getResource("room_size")
	assert(room_size and room_size.width and room_size.height, "room_size missing for shed bugs")

	local rw, rh = room_size.width, room_size.height
	local trail_xs = shed_ant_trail_floor_xs(rw)

	for i = 1, SHED_ANT_TRAIL_COUNT do
		local start_p, end_p = floor_to_ceiling_ant_path(rw, rh, trail_xs[i])
		world:emit("generate_ants", 72, start_p, end_p, true, 10, {
			ant_id_prefix = "shed_trail" .. i .. "_",
			path_segment_count = 20,
			path_sway = 3,
			uniform_path_speed = true,
		})
	end
	world:emit("generate_flies_for_room_lights", Enums.game_state.Shed, {
		max_speed = 80,
		max_speed_var = 15,
		sharp_impulse = 120,
		initial_vel = 3.5,
		pull_radius_min = 1,
		pull_radius_max = 2,
	})
	world:__flush()
	world:emit("move_ants")
end

function Shed:state_init()
	self.world:emit("spawn_player", function(e_player)
		self.e_player = e_player
		self.world:emit("camera_follow", e_player, 0.25)
		self.world:emit("toggle_component", e_player, Enums.player_cap.can_move, true)
		self.world:emit("toggle_component", e_player, Enums.player_cap.can_interact, true)
		self.world:emit("toggle_component", e_player, Enums.player_cap.can_run, true)

		local bag = Session.take("tutorial")
		if bag then
			local tutorial = self.world:getSystem(ECS.get_system_class("tutorial"))
			tutorial:import_session(bag)
			if bag.phase == "shed" then
				tutorial:begin_shed_open_lighter(e_player)
			end
		end

		spawn_shed_bugs(self.world)
	end)

	self.timeline = TLE.Do(function()
		Fade.fade_in(nil, 1)
		self.camera:setScale(4)
		self.timeline:Pause()
	end)
end

function Shed:state_update(dt)
	assert:type(dt, "number")
	self.world:emit("preupdate", dt)
	self.world:emit("update", dt)
end

function Shed:state_draw()
	self.world:emit("begin_deferred_lighting", self.camera, self.canvas)
	self.world:emit("draw_billboard_glow", self.camera)
	self.world:emit("end_deferred_lighting")
	self.world:emit("apply_post_process", self.canvas)
	self.world:emit("draw_ui")
	Fade.draw()
end

function Shed:ev_draw_ex()
	self.world:emit("draw_bg")
	self.world:emit("draw")
end

return Shed
