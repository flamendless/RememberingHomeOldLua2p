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
	"open_lighter_left"
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

Enums.tutorial_step = Enum(
	"waiting",

	"interact",
	"waiting_interact",
	"done_waiting_interact",

	"show_left",
	"waiting_left",
	"show_left_interact",
	"waiting_left_interact",
	"done_left_interact",

	"show_right",
	"waiting_right",
	"show_right_interact",
	"waiting_right_interact",
	"done_right_interact",

	"show_lighter",
	"wait_lighter_trigger",
	"done_lighter_trigger",

	"explore",

	"run",

	"fin"
)

Enums.show_keys = Enum(
	"dialogue",
	"left",
	"right",
	"inventory",
	"lighter"
)

Enums.decals = Enum(
-- TODO: foot decal for walking/running?
	"hand"
)

Enums.dialogue_tags = Enum(
	"important"
)

if DEV then
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
