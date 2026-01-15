if DEV then
	love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";modules/?.lua")
	local os = love.system.getOS()
	print("Loading luajit modules for ", os)
	if os == "Linux" then
		print("Loaded luajit modules for Linux")
	elseif os == "OS X" then
		require("jit_mac.p").start("lz")
	end
	print("Loaded luajit modules for ", os)
end

UTF8 = require("utf8")
FFI = require("ffi")
Socket = require("socket")
Bit = require("bit")

Anim8 = require("modules.anim8.anim8")
Bitser = require("modules.bitser.bitser")
Bump = require("modules.bump.bump-niji")
Concord = require("modules.concord.concord")
Enum = require("modules.enum.enum")
Flux = require("modules.flux.flux")
Gamera = require("modules.gamera.gamera")
Lily = require("modules.lily.lily")
Log = require("modules.log.log")
LoveSplash = require("modules.splashes.o-ten-one")
Lume = require("modules.lume.lume")
ReflowPrint = require("modules.reflowprint.reflowprint")
SDF = require("modules.sdf")
Semver = require("modules.semver.semver")
Slab = require("modules.slab")
Splashes = require("modules.splashes.o-ten-one")
TLE = require("modules.tle.timeline")
Timer = require("modules.hump.timer")

class = require("modules.batteries.class")
functional = require("modules.batteries.functional")
intersect = require("modules.batteries.intersect")
mathx = require("modules.batteries.mathx")
pretty = require("modules.batteries.pretty")
sort = require("modules.batteries.sort")
stringx = require("modules.batteries.stringx")
tablex = require("modules.batteries.tablex")
timer = require("modules.batteries.timer")
unique_mapping = require("modules.batteries.unique_mapping")
vec2 = require("modules.batteries.vec2")
vec3 = require("modules.batteries.vec3")

Enums = require("enums")

Data = {
    AnimationData = require("data.animation_data"),
    AnimationSyncData = require("data.animation_sync_data"),
    Colliders = require("data.colliders"),
    Dialogues = require("data.dialogues"),
    Doors = require("data.doors"),
    Items = require("data.items"),
    Lights = require("data.lights"),
    Notes = require("data.notes"),
    PlayerSpawnPoints = require("data.player_spawn_points"),
    ResourcesList = require("data.resources_list")
}

Renderers = {
    BB = require("renderers.bounding_box"),
    Circle = require("renderers.circle"),
    Point = require("renderers.point"),
    Rect = require("renderers.rect"),
    Sprite = require("renderers.sprite"),
    Text = require("renderers.text"),
    UI = require("renderers.ui")
}

ParticleSystems = {
    RainIntro = require("particle_systems.rain_intro"),
    RainOutside = require("particle_systems.rain_outside")
}

Atlases = {
    AtlasIntro = require("atlases.atlas_intro"),
    AtlasKeys = require("atlases.atlas_keys"),
    KitchenItems = require("atlases.kitchen_items"),
    LivingRoomItems = require("atlases.living_room_items"),
    OutsideItems = require("atlases.outside_items"),
    StorageRoomItems = require("atlases.storage_room_items"),
    UtilityRoomItems = require("atlases.utility_room_items")
}

Ctor = {
    BumpStorage = require("ctor.bump_storage"),
    CustomList = require("ctor.custom_list"),
    ListByID = require("ctor.list_by_id"),
    SortedTable = require("ctor.sorted_table")
}

Beehive = {
    Fail = require("modules.beehive.beehive.fail"),
    Invert = require("modules.beehive.beehive.invert"),
    Repeat = require("modules.beehive.beehive.repeat"),
    Selector = require("modules.beehive.beehive.selector"),
    Sequence = require("modules.beehive.beehive.sequence")
}

Behaviors = {
    Enemy = require("behaviors.enemy")
}

Animation = require("animation")
Audio = require("audio")
Cache = require("cache")
Canvas = require("canvas")
Config = require("config")
Dialogues = require("dialogues")
DevTools = require("devtools")
ErrorHandler = require("error_handler")
Fade = require("fade")
Generator = require("generator")
Helper = require("helper")
Image = require("image")
Info = require("info")
Inputs = require("inputs")
Items = require("items")
LoadingScreen = require("loading_screen")
Notes = require("notes")
Outliner = require("outliner")
Palette = require("palette")
Preloader = require("preloader")
Resources = require("resources")
Save = require("save")
Settings = require("settings")
Shaders = require("shaders")
UIWrapper = require("ui_wrapper")
Utils = require("utils")
Utils = require("utils")
WindowMode = require("window_mode")

Assemblages = {
    Common = require("assemblages.common"),
    Enemy = require("assemblages.enemy"),
    Intro = require("assemblages.intro"),
    Inventory = require("assemblages.inventory"),
    Items = require("assemblages.items"),
    Kitchen = require("assemblages.kitchen"),
    Light = require("assemblages.light"),
    LivingRoom = require("assemblages.living_room"),
    Menu = require("assemblages.menu"),
    Notes = require("assemblages.notes"),
    Outside = require("assemblages.outside"),
    Pause = require("assemblages.pause"),
    Player = require("assemblages.player"),
    Room = require("assemblages.room"),
    StorageRoom = require("assemblages.storage_room"),
    UI = require("assemblages.ui"),
    UtilityRoom = require("assemblages.utility_room")
}

ECS = require("ecs")
GameStates = require("gamestates")

require("modules.batteries"):export()
require("modules.sdf").mount()
require("modules.strict")

if DEV then
	local old_give = Concord.entity.give
	function Concord.entity:give(...)
		local t = {...}
		if not DevTools.metrics.give[t[1]] then
			DevTools.metrics.give[t[1]] = 0
		end
		DevTools.metrics.give[t[1]] = DevTools.metrics.give[t[1]] + 1

		return old_give(self, ...)
	end

	local old_remove = Concord.entity.remove
	function Concord.entity:remove(...)
		local t = {...}
		if not DevTools.metrics.remove[t[1]] then
			DevTools.metrics.remove[t[1]] = 0
		end
		DevTools.metrics.remove[t[1]] = DevTools.metrics.remove[t[1]] + 1

		return old_remove(self, ...)
	end
end
