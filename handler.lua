local args = dataFromCommandLine --from build.sh

local function split(str)
	local t = {}
	for arg in string.gmatch(str, "([^%s]+)") do
		table.insert(t, arg)
	end
	return t
end

function assert(cond, msg)
	if not _DEV then return "" end
	msg = msg or string.format("%q", "Assertion failed: " .. cond)
	return "if not (" .. cond .. ") then error(" .. msg ..") end"
end

function c_not(component)
	return toLua("!" .. evaluate(component))
end

function sassert(v, cond, msg)
	if not _DEV then return "" end
	local str = assert(cond, msg)
	return "if " .. v .. " then " .. str .. " end"
end

function profb(a, b)
	if not _PROF then return "" end
	if b then
		return string.format("JPROF.push(%s, %s)", a, b)
	else
		return "JPROF.push(" .. a .. ")"
	end
end

function profe(a)
	if not _PROF then return "" end
	return "JPROF.pop(" .. a .. ")"
end

local bit = require("bit")
local band = bit.band
local rshift = bit.rshift
function hex_to_rgb(hex)
	local r = rshift(band(hex, 0x00ff0000), 16) / 255.0
	local g = rshift(band(hex, 0x0000ff00), 8)  / 255.0
	local b = rshift(band(hex, 0x000000ff), 0)  / 255.0
	return string.format("{%f, %f, %f}", r, g, b)
end

args = split(args)
assert(type(args[1]) == "string")
assert(type(args[2]) == "string")
assert(type(args[3]) == "number" and args[3] > 0)

if args[1] == "dev" then
	_DEV = true
	_PROF = false
elseif args[1] == "release" then
	_DEV = false
	_PROF = false
elseif args[1] == "prof" then
	_DEV = true
	_PROF = true
end

_IDENTITY = toLua("rememberinghome")
_LOVE_VERSION = toLua("11.3")
_GAME_VERSION = toLua("0.0.1")
_COMMIT_VERSION = toLua(args[2])

_MODE = toLua(args[1])
_LOG_SAVE = true
_CACHED_PRELOAD = true
_OUTLINE_PADDING = toLua(args[3])
_GLSL_NORMALS = false

_OS = "Linux"
_PLATFORM = "desktop" --mobile
_GAME_TITLE  = toLua("Remembering Home")
_GAME_SIZE = {x = 1024, y = 640}
_GAME_BASE_SIZE = toLua({x = 128, y = 32})

_BUMP_CELL_SIZE = toLua(128)
_CULL_PAD = toLua(32)
_MIN_GL_VERSION = toLua("2.1")

_DEFAULT_FILTER = toLua("nearest")
_IMAGE_FILTER = toLua("nearest")
_FONT_FILTER = toLua("nearest")
_CANVAS_FILTER = toLua("nearest")

_WINDOW_MODES = toLua({
	{
		width = _GAME_SIZE.x,
		height = _GAME_SIZE.y
	}
})
_WINDOW_MODES_STR = toLua({
	(_GAME_SIZE.x .. "x" .. _GAME_SIZE.y),
})

_GFX_QUALITY = nil
if _DEV then
	_GFX_QUALITY = toLua("low")
else
	_GFX_QUALITY = toLua("high")
end

_EMAIL = "flamendless.studio@gmail.com"
_GITHUB_URL = "https://github.com/flamendless/RememberingHome"
_GITHUB_URL_RELEASE = ""

_LOG_OUTPUT = toLua("log")
_LOG_INFO = toLua("info.txt")
_SETTINGS_FILENAME = toLua("user_settings")
_SAVE_FILENAME = toLua("save_data")
_SAVESTATE_FILENAME = toLua("save_state")
_SAVE_KEY = toLua("data_store")

_URL_TWITTER = "https://twitter.com/@flam8studio"
_URL_DISCORD = "https://discord.gg/2W4tyyV"
_URL_WEBSITE = "https://flamendless.itch.io"
_URL_MAIL = "mailto:flamendless.studio@gmail.com"

_ABOUT_LINKS = toLua({
	_URL_TWITTER,
	_URL_DISCORD,
	_URL_WEBSITE,
	_URL_MAIL,
})

_NAME_DEVELOPER = "Brandon"
_NAME_ARTIST = "Conrad"
_NAME_DESIGNER = "Piolo Maurice"
_NAME_MUSICIAN = "???"

_FULL_NAME_STUDIO = "flamendless studio"
_FULL_NAME_DEVELOPER = "Brandon Blanker Lim-it"
_FULL_NAME_ARTIST = "Conrad Reyes"
_FULL_NAME_DESIGNER = "Piolo Maurice Laudencia"
_FULL_NAME_MUSICIAN = "???"

_TWITTER_STUDIO = "@flam8studio"
_TWITTER_DEVELOPER = "@flamendless"
_TWITTER_ARTIST = "@Shizzy619"
_TWITTER_DESIGNER = "@piotato"
_TWITTER_MUSICIAN = "@???"

_TOOLS = toLua({
	"Manjaro", "i3-Gaps", "Discord", "Löve Framework",
	"Luapreprocess", "Vim", "Aseprite", "Audacity", "Export-TextureAtlas",
	"makelove", "msdf-bmfont",
})

_LIBS = toLua({
	"Anim8", "Batteries", "beehive", "Bitser", "Bump-niji", "Concord", "Enum",
	"Flux", "Gamera", "HUMP", "JProf", "Lily", "Log", "Lume", "ngrading",
	"Outliner", "Peeker", "ReflowPrint", "SDF", "Semver", "Slab", "Splashes",
	"strict", "TimelineEvents",
})

--PRE CALCULATED
_HALF_PI = toLua(math.pi * 0.5)
_TWO_PI = toLua(math.pi * 2)
_T_H_PI = toLua(3 * _HALF_PI)
_RA = toLua({math.cos(math.pi/32), math.sin(math.pi/32)})

--LUTS
_LUT_DUSK = toLua("lut_dusk")
_LUT_AFTERNOON = toLua("lut_afternoon")

--Beehive
_BT_SUCCESS = toLua("success")
_BT_FAILURE = toLua("failure")
_BT_RUNNING = toLua("running")

--IDS
_ITEMS_ACTION_USE = toLua("Use")
_ITEMS_ACTION_EQUIP = toLua("Equip")
_ITEMS_ACTION_CANCEL = toLua("Cancel")

_LIST_MAIN_MENU = toLua("main_menu")
_LIST_SUB_MENU = toLua("sub_menu")
_LIST_DIALOGUE_CHOICES = toLua("dialogue_choices")
_LIST_NOTES = toLua("notes")
_LIST_INVENTORY_CELLS = toLua("inventory_cells")
_LIST_INVENTORY_CHOICES = toLua("inventory_choices")
_LIST_PAUSE_CHOICES = toLua("pause_choices")

--POST PROCESS IDS
_PP_BLUR = toLua("Blur")
_PP_DISSOLVE = toLua("Dissolve")
_PP_DITHERGRADIENT = toLua("DitherGradient")
_PP_FILMGRAIN = toLua("FilmGrain")
_PP_GLITCH = toLua("Glitch")
_PP_MOTIONBLUR = toLua("MotionBlur")
_PP_NGRADING = toLua("NGrading")
_PP_NGRADING_MULTI = toLua("NGradingMulti")

--PARTICLE SYSTEM IDS
_PS_RAIN_INTRO = toLua("PSRainIntro")
_PS_RAIN_OUTSIDE = toLua("PSRainOutside")

--SIGNALS
_SIGNAL_LIST_REMOVE = toLua("on_list_cursor_remove_")
_SIGNAL_LIST_INTERACT = toLua("on_list_item_interact_")
_SIGNAL_LIST_UPDATE = toLua("on_list_cursor_update_")

--COMPONENTS
_C_ANCHOR = toLua("anchor")
_C_CAN_MOVE = toLua("can_move")
_C_CAN_RUN = toLua("can_run")
_C_CAN_OPEN_DOOR = toLua("can_open_door")
_C_CAN_INTERACT = toLua("can_interact")
_C_IS_RUNNING = toLua("is_running")
_C_IS_INTERACTING = toLua("is_interacting")
_C_BODY = toLua("body")
_C_PREV_CAN = toLua("prev_can")
_C_AUTO_SCALE = toLua("auto_scale")
_C_BOUNDING_BOX = toLua("bounding_box")
_C_ATTACH_TO = toLua("attach_to")
_C_ATTACH_TO_OFFSET = toLua("attach_to_offset")
_C_ATTACH_TO_SPAWN_POINT = toLua("attach_to_spawn_point")
_C_ANIM_SYNC_WITH = toLua("anim_sync_with")
_C_ANIM_SYNC_DATA = toLua("anim_sync_data")
_C_OVERRIDE_ANIMATION = toLua("override_animation")
_C_ANIMATION = toLua("animation")
_C_CHANGE_ANIMATION_TAG = toLua("change_animation_tag")
_C_ANIMATION_PAUSE_AT = toLua("animation_pause_at")
_C_ANIMATION_STOP = toLua("animation_stop")
_C_CURRENT_FRAME = toLua("current_frame")
_C_ANIMATION_EV_UPDATE = toLua("animation_ev_update")
_C_ANIMATION_DATA = toLua("animation_data")
_C_ANGLE = toLua("angle")
_C_ANGULAR_SPEED = toLua("angular_speed")
_C_BUMP = toLua("bump")
_C_WALL = toLua("wall")
_C_GROUND = toLua("ground")
_C_REQ_COL_DIR = toLua("req_col_dir")
_C_COLLIDER = toLua("collider")
_C_COLLIDER_OFFSET = toLua("collider_offset")
_C_COLLIDER_CIRCLE = toLua("collider_circle")
_C_COLLIDE_WITH = toLua("collide_with")
_C_ALPHA_RANGE = toLua("alpha_range")
_C_COLOR = toLua("color")
_C_COLOR_FADE_IN_OUT = toLua("color_fade_in_out")
_C_FADE_TO_BLACK = toLua("fade_to_black")
_C_LERP_COLORS = toLua("lerp_colors")
_C_TARGET_COLOR = toLua("target_color")
_C_COLOR_FADE_IN = toLua("color_fade_in")
_C_COLOR_FADE_OUT = toLua("color_fade_out")
_C_FADE_IN_TARGET_ALPHA = toLua("fade_in_target_alpha")
_C_REMOVE_BLINK_ON_END = toLua("remove_blink_on_end")
_C_BLINK = toLua("blink")
_C_CLICKABLE = toLua("clickable")
_C_ON_CLICK = toLua("on_click")
_C_CULLABLE = toLua("cullable")
_C_BAR_HEIGHT = toLua("bar_height")
_C_CAMERA = toLua("camera")
_C_CAMERA_TRANSFORM = toLua("camera_transform")
_C_CAMERA_CLIP = toLua("camera_clip")
_C_CAMERA_FOLLOW_OFFSET = toLua("camera_follow_offset")
_C_BUG = toLua("bug")
_C_ANT = toLua("ant")
_C_FLY = toLua("fly")
_C_FIREFLY = toLua("firefly")
_C_Z_INDEX = toLua("z_index")
_C_DT_MULTIPLIER = toLua("dt_multiplier")
_C_TEXT_CAN_PROCEED = toLua("text_can_proceed")
_C_TEXT_SKIPPED = toLua("text_skipped")
_C_HAS_CHOICES = toLua("has_choices")
_C_DIALOGUE_ITEM = toLua("dialogue_item")
_C_DIALOGUE_META = toLua("dialogue_meta")
_C_LIGHT_DISABLED = toLua("light_disabled")
_C_LIGHT_ID = toLua("light_id")
_C_LIGHT_GROUP = toLua("light_group")
_C_LIGHT_SWITCH_ID = toLua("light_switch_id")
_C_POINT_LIGHT = toLua("point_light")
_C_LIGHT_DIR = toLua("light_dir")
_C_DIFFUSE = toLua("diffuse")
_C_LIGHT_FADING = toLua("light_fading")
_C_DLIGHT_FLICKER_REMOVE_AFTER = toLua("d_light_flicker_remove_after")
_C_DLIGHT_FLICKER_SURE_ON_AFTER = toLua("d_light_flicker_sure_on_after")
_C_DLIGHT_FLICKER = toLua("d_light_flicker")
_C_DLIGHT_FLICKER_REPEAT = toLua("d_light_flicker_repeat")
_C_CONTROLLER = toLua("controller")
_C_PLAYER_CONTROLLER = toLua("player_controller")
_C_ENEMY_CONTROLLER = toLua("enemy_controller")
_C_EASE = toLua("ease")
_C_FONT = toLua("font")
_C_FONT_SDF = toLua("font_sdf")
_C_SDF = toLua("sdf")
_C_FLASHLIGHT = toLua("flashlight")
_C_FLASHLIGHT_LIGHT = toLua("flashlight_light")
_C_BATTERY = toLua("battery")
_C_BATTERY_STATE = toLua("battery_state")
_C_FL_SPAWN_OFFSET = toLua("fl_spawn_offset")
_C_ENEMY = toLua("enemy")
_C_GRAVITY = toLua("gravity")
_C_HIDDEN = toLua("hidden")
_C_HOVER_EMIT = toLua("hover_emit")
_C_HOVERABLE = toLua("hoverable")
_C_HOVER_CHANGE_COLOR = toLua("hover_change_color")
_C_HOVER_CHANGE_SCALE = toLua("hover_change_scale")
_C_ID = toLua("id")
_C_PRESERVE_ID = toLua("preserve_id")
_C_INTERACTIVE = toLua("interactive")
_C_LOCKED = toLua("locked")
_C_IS_DOOR = toLua("is_door")
_C_TARGET_INTERACTIVE = toLua("target_interactive")
_C_WITHIN_INTERACTIVE = toLua("within_interactive")
_C_INTERACTIVE_REQ_PLAYER_DIR = toLua("interactive_req_player_dir")
_C_INTRO_TEXT = toLua("intro_text")
_C_INTRO_LIGHT = toLua("intro_light")
_C_USABLE_WITH_ITEM = toLua("usable_with_item")
_C_ITEM_PREVIEW = toLua("item_preview")
_C_ROOM_ITEM = toLua("room_item")
_C_ITEM_ID = toLua("item_id")
_C_ITEM = toLua("item")
_C_LIGHT = toLua("light")
_C_LIGHT_TIMER = toLua("light_timer")
_C_LIGHT_FLICKER = toLua("light_flicker")
_C_LIST_ITEM_SKIP = toLua("list_item_skip")
_C_LIST_ITEM = toLua("list_item")
_C_LIST_CURSOR = toLua("list_cursor")
_C_LIST_GROUP = toLua("list_group")
_C_MENU_TEXT = toLua("menu_text")
_C_MOVE_BY = toLua("move_by")
_C_MOVE_REPEAT = toLua("move_repeat")
_C_MOVE_TO_X = toLua("move_to_x")
_C_MOVE_TO_ORIGINAL = toLua("move_to_original")
_C_MOVEMENT = toLua("movement")
_C_NF_RENDERER = toLua("nf_renderer")
_C_MULTI_ANIMATION_DATA = toLua("multi_animation_data")
_C_NOTIFICATION = toLua("notification")
_C_OPTION_KEY = toLua("option_key")
_C_OPTION_DISABLED = toLua("option_disabled")
_C_OUTLINE = toLua("outline")
_C_OUTLINE_VAL = toLua("outline_val")
_C_SPLASHES = toLua("splashes")
_C_CAR_LIGHTS = toLua("car_lights")
_C_PAINT = toLua("paint")
_C_TEXT_WITH_PAINT = toLua("text_with_paint")
_C_PARALLAX_STOP = toLua("parallax_stop")
_C_PARALLAX = toLua("parallax")
_C_PARALLAX_MULTI_SPRITE = toLua("parallax_multi_sprite")
_C_PARALLAX_GAP = toLua("parallax_gap")
_C_PATH = toLua("path")
_C_PATH_SPEED = toLua("path_speed")
_C_APPLY_BEZIER_CURVE = toLua("apply_bezier_curve")
_C_PATH_LOOP = toLua("path_loop")
_C_PATH_REPEAT = toLua("path_repeat")
_C_PATH_MOVE = toLua("path_move")
_C_PLAYER = toLua("player")
_C_HIT_WALL = toLua("hit_wall")
_C_POS_VEC2 = toLua("pos_vec2")
_C_REF_POS_VEC2 = toLua("ref_pos_vec2")
_C_POS = toLua("pos")
_C_SIZE = toLua("size")
_C_GROUPED = toLua("grouped")
_C_ATLAS = toLua("atlas")
_C_QUAD = toLua("quad")
_C_UI_ELEMENT = toLua("ui_element")
_C_LAYER = toLua("layer")
_C_TYPEWRITER_TIMER = toLua("typewriter_timer")
_C_TYPEWRITER = toLua("typewriter")
_C_REFLOWPRINT = toLua("reflowprint")
_C_BG_TREE = toLua("bg_tree")
_C_TRANSFORM = toLua("transform")
_C_QUAD_TRANSFORM = toLua("quad_transform")
_C_DEPTH_ZOOM = toLua("depth_zoom")
_C_TARGET_TEXT = toLua("target_text")
_C_TEXT = toLua("text")
_C_TEXT_T = toLua("text_t")
_C_TEXTF = toLua("textf")
_C_STATIC_TEXT = toLua("static_text")
_C_BG = toLua("bg")
_C_SPRITE = toLua("sprite")
_C_ARRAY_IMAGE = toLua("array_image")
_C_NOISE_TEXTURE = toLua("noise_texture")
_C_SPEED = toLua("speed")
_C_SPEED_DATA = toLua("speed_data")
_C_HSPEED = toLua("hspeed")
_C_SKIP = toLua("skip")
_C_TEXTURED_LINE = toLua("textured_line")
_C_DRAW_MODE = toLua("draw_mode")
_C_POINT = toLua("point")
_C_CIRCLE = toLua("circle")
_C_RECT = toLua("rect")
_C_RECT_BORDER = toLua("rect_border")
_C_LINE_WIDTH = toLua("line_width")
_C_ARC_TYPE = toLua("arc_type")
_C_NO_SHADER = toLua("no_shader")
_C_FOG = toLua("fog")
_C_CUSTOM_RENDERER = toLua("custom_renderer")
_C_REF_ENTITY_KEY = toLua("ref_e_key")
_C_REFS = toLua("refs")
_C_KEY = toLua("key")
_C_BEHAVIOR_TREE = toLua("behavior_tree")
_C_LINE_OF_SIGHT = toLua("line_of_sight")
_C_CONTROLLER_ORIGIN = toLua("controller_origin")
_C_SKIP_COLLIDER_UPDATE = toLua("skip_collider_update")
_C_RANDOM_WALK = toLua("random_walk")

_C_ANIMATION_ON_LOOP = toLua("animation_on_loop")
_C_ANIMATION_ON_UPDATE = toLua("animation_on_update")
_C_ANIMATION_ON_FINISH = toLua("animation_on_finish")
_C_LERP_ON_FINISH = toLua("lerp_on_finish")
_C_TYPEWRITER_ON_FINISH = toLua("typewriter_on_finish")
_C_ON_ENTER_MENU = toLua("on_enter_menu")
_C_COLOR_FADE_OUT_FINISH = toLua("color_fade_out_finish")
_C_COLOR_FADE_IN_FINISH = toLua("color_fade_in_finish")
_C_ON_DIALOGUE_END = toLua("on_dialogue_end")
_C_ON_BLINK_END = toLua("on_blink_end")
_C_ON_DLIGHT_FLICKER_DURING = toLua("on_d_light_flicker_during")
_C_ON_DLIGHT_FLICKER_AFTER = toLua("on_d_light_flicker_after")
_C_ON_PATH_UPDATE = toLua("on_path_update")
_C_ON_PATH_REACHED_END = toLua("on_path_reached_end")
_C_LERP_ON_FINISH_MULTI = toLua("lerp_on_finish_multi")

return {}
