local Enums = {
	bt = {},
	ordered = {}
}

Enums.mode = Enum("fill", "line")
Enums.arc_type = Enum("pie", "open", "closed")
Enums.bump_filter = Enum("touch", "slide", "cross", "bounce")
Enums.align_mode = Enum("center", "left", "right", "justify")
Enums.anchor = Enum("top", "left", "center", "bottom", "right")
Enums.item = Enum("note", "inventory", "choice")
Enums.light_shape = Enum("round", "rectangle", "cone", "custom")
Enums.pause_at = Enum("first", "last")
Enums.stop_at = Enum("pauseAtStart", "pauseAtEnd")
Enums.anim8_status = Enum("playing", "paused")

Enums.ease = Enum(
	"linear",
	"quadin",
	"quadout",
	"quadinout",
	"cubicin",
	"cubicout",
	"cubicinout",
	"quartin",
	"quartout",
	"quartinout",
	"quintin",
	"quintout",
	"quintinout",
	"expoin",
	"expoout",
	"expoinout",
	"sinein",
	"sineout",
	"sineinout",
	"circin",
	"circout",
	"circinout",
	"backin",
	"backout",
	"backinout",
	"elasticin",
	"elasticout",
	"elasticinout"
)

Enums.splash_state = Enum("love", "wits", "flam")
Enums.menu_state = Enum("menu", "sub_menu", "play", "settings", "about", "exit")
Enums.camera_state = Enum("zoomed_in", "zoomed_out")
Enums.battery_state = Enum("full", "low", "critical", "empty")

Enums.face_dir = Enum("left", "right")

Enums.anim_state = Enum(
	"idle",
	"idle_left",
	"walk",
	"run",
	"open_door",
	"open_door_left",
	"open_locked_door",
	"open_locked_door_left",
	"open_lighter",
	"open_lighter_left",
	"close_lighter",
	"close_lighter_left"
)

Enums.enemy_type = Enum("suit")
Enums.enemy_suit_anim = Enum("idle", "walk")

Enums.bt.enemy = Enum("idle", "walk", "chase", "lean_back", "lean_return_back", "caught_other")

Enums.timeline = Enum("created", "playing", "paused", "killed")
Enums.fade = Enum("none", "fade_in", "fade_out")

Enums.shaders = Enum(
	"blur",
	"dissolve",
	"dither_gradient",
	"film_grain",
	"glitch",
	"motion_blur",
	"ngrading",
	"ngrading_multi",
	"vignette_ex",
	"hand"
)

Enums.survival_state = Enum(
	"normal",
	"engaged",
	"okayish",
	"warning",
	"critical",
	"dead"
)

Enums.tutorial_beat = Enum(
	"interact",
	"move_left",
	"interact_left",
	"move_right",
	"interact_right",
	"lighter",
	"explore",
	"done"
)

Enums.show_keys = Enum(
	"dialogue",
	"left",
	"right",
	"inventory",
	"notes",
	"lighter"
)

Enums.dialogue_knot = Enum(
	"start",
	"fin",
	"car_doors",
	"test"
)

Enums.input = Enum(
	"left",
	"right",
	"up",
	"down",
	"interact",
	"cancel",
	"inventory",
	"flashlight",
	"lighter",
	"run_mod",
	"pause",
	"play",
	"camera_down",
	"camera_up",
	"camera_left",
	"camera_right"
)

Enums.list_group = Enum(
	"main_menu",
	"sub_menu",
	"about",
	"inventory_cells",
	"inventory_choices",
	"pause_choices",
	"notes"
)

Enums.ui_system = Enum(
	"dialogues",
	"inventory",
	"notes"
)

Enums.item_id = Enum(
	"flashlight",
	"frontdoor_key",
	"storage_room_drawer_key",
	"lighter1",
	"lighter2"
)

Enums.player_cap = Enum(
	"can_move",
	"can_interact",
	"can_run",
	"can_lighter",
	"can_open_door",
	"can_move_left_only",
	"can_move_right_only"
)

Enums.light_group = Enum(
	"player_flashlight",
	"side_pl",
	"mid_pl",
	"pl_mid"
)

Enums.glow_group = Enum(
	"car_glow",
	"pc_glow"
)

Enums.decals = Enum(
-- TODO: foot decal for walking/running?
	"hand"
)
Log.debug("TODO: foot decal for walking/running?")

Enums.dialogue_tags = Enum(
	"important"
)

Enums.game_state = Enum(
	"Splash",
	"Menu",
	"Intro",
	"Outside",
	"StorageRoom",
	"UtilityRoom",
	"Kitchen",
	"LivingRoom",
	"TotallyDarkRoom",
	"Office1",
	"Office2"
)

Enums.sfx = Enum(
	"car_door_open",
	"car_door_hit",
	"trunk_open",
	"light_switch",
	"lights_shutdown",
	"inventory_invalid",
	"flashlight_on",
	"car_power",
	"lighter_empty",
	"static",
	"motion_blur"
)

if DEV then
	Enums.ordered.game_state = {
		Enums.game_state.Splash,
		Enums.game_state.Menu,
		Enums.game_state.Intro,
		Enums.game_state.Outside,
		Enums.game_state.StorageRoom,
		Enums.game_state.UtilityRoom,
		Enums.game_state.Kitchen,
		Enums.game_state.LivingRoom,
		Enums.game_state.TotallyDarkRoom,
	}
	Enums.ordered.survival_state = {
		Enums.survival_state.normal,
		Enums.survival_state.engaged,
		Enums.survival_state.okayish,
		Enums.survival_state.warning,
		Enums.survival_state.critical,
		Enums.survival_state.dead,
	}
end

return Enums
