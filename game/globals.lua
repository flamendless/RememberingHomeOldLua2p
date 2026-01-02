require("modules.sdf").mount()

Anim8 = require("modules.anim8.anim8")
Bitser = require("modules.bitser.bitser")
Bump = require("modules.bump.bump-niji")
Concord = require("modules.concord.concord")
Cron = require("modules.cron.cron")
Enum = require("modules.enum.enum")
Flux = require("modules.flux.flux")
Gamera = require("modules.gamera.gamera")
Lily = require("modules.lily.lily")
Log = require("modules.log.log")
Log.lovesave = true
LoveSplash = require("modules.splashes.o-ten-one")
ReflowPrint = require("modules.reflowprint.reflowprint")
Slab = require("modules.slab")
Tle = require("modules.tle.timeline")
UTF8 = require("utf8")

local Batteries = require("modules.batteries")
class = Batteries.class
intersect = Batteries.intersect
mathx = Batteries.mathx
pretty = Batteries.pretty
stringx = Batteries.stringx
tablex = Batteries.tablex
vec2 = Batteries.vec2


Enums = require("src.enums")

Animation = require("src.animation")
Audio = require("src.audio")
Cache = require("src.cache")
Canvas = require("src.canvas")
DevTools = require("src.devtools")
Dialogues = require("src.dialogues")
ErrorHandler = require("src.error_handler")
Fade = require("src.fade")
GameStates = require("src.gamestates")
Generator = require("src.generator")
Helper = require("src.helper")
Inputs = require("src.inputs")
Items = require("src.items")
ItemsInfo = require("src.items")
LoadingScreen = require("src.loading_screen")
Notes = require("src.notes")
Outliner = require("src.outliner")
Palette = require("src.palette")
Preloader = require("src.preloader")
Resources = require("src.resources")
Save = require("src.save")
Settings = require("src.settings")
Shaders = require("src.shaders")
Shaders.load_shaders()
SystemInfo = require("src.system_info")
Timer = require("src.timer")
UIWrapper = require("src.ui_wrapper")
Utils = require("src.utils")
WindowMode = require("src.window_mode")

--OTHERS
Doors = require("data.doors")
Colliders = require("data.colliders")
BTEnemy = require("behaviors.enemy")
Atlas = require("atlases.atlas_intro")
Lights = require("data.lights")
ListByID = require("ctor.list_by_id")
SortedTable = require("ctor.sorted_table")
PlayerSpawnPoints = require("data.player_spawn_points")
CustomList = require("ctor.custom_list")
AtlasKeys = require("atlases.atlas_keys")

Assemblages = {
	Common = require("assemblages.common"),
	Enemy = require("assemblages.enemy"),
	Intro = require("assemblages.intro"),
	Items = require("assemblages.items"),
	Kitchen = require("assemblages.kitchen"),
	Light = require("assemblages.light"),
	LivingRoom = require("assemblages.living_room"),
	Outside = require("assemblages.outside"),
	Pause = require("assemblages.pause"),
	Player = require("assemblages.player"),
	StorageRoom = require("assemblages.storage_room"),
	UI = require("assemblages.ui"),
	UtilityRoom = require("assemblages.utility_room"),
}


PS = {
	RainIntro = require("particle_systems/rain_intro"),
	RainOutside = require("particle_systems/rain_outside"),
}

--BT
BT_Fail = require("modules.beehive.beehive.fail")
BT_Invert = require("modules.beehive.beehive.invert")
BT_Selector = require("modules.beehive.beehive.selector")
BT_Sequence = require("modules.beehive.beehive.sequence")

Ecs = require("src.ecs")
love.errhand = ErrorHandler.callback
require("modules.strict")
