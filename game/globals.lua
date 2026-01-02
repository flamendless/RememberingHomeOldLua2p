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
TLE = require("modules.tle.timeline")
UTF8 = require("utf8")

local Batteries = require("modules.batteries")
class = Batteries.class
intersect = Batteries.intersect
functional = Batteries.functional
mathx = Batteries.mathx
pretty = Batteries.pretty
stringx = Batteries.stringx
tablex = Batteries.tablex
timer = Batteries.timer
vec2 = Batteries.vec2
vec3 = Batteries.vec3


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

Atlases = {
	Intro = require("atlases.atlas_intro"),
	Keys = require("atlases.atlas_keys"),
}

Behaviors = {
	Enemy = require("behaviors.enemy"),
}

Data = {
	Colliders = require("data.colliders"),
	Doors = require("data.doors"),
	Lights = require("data.lights"),
	PlayerSpawnPoints = require("data.player_spawn_points"),
}

Ctor = {
	BumpStorage = require("ctor.bump_storage"),
	CustomList = require("ctor.custom_list"),
	ListByID = require("ctor.list_by_id"),
	SortedTable = require("ctor.sorted_table"),
}

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
Beehive = {
	Fail = require("modules.beehive.beehive.fail"),
	Invert = require("modules.beehive.beehive.invert"),
	Selector = require("modules.beehive.beehive.selector"),
	Sequence = require("modules.beehive.beehive.sequence"),
}

Ecs = require("src.ecs")
love.errhand = ErrorHandler.callback
require("modules.strict")

function Gamera:attach()
	love.graphics.setScissor(self:getWindow())
	love.graphics.push()
	local scale = self.scale
	love.graphics.scale(scale)
	love.graphics.translate((self.w2 + self.l) / scale, (self.h2 + self.t) / scale)
	love.graphics.rotate(-self.angle)
	love.graphics.translate(-self.x, -self.y)
end

function Gamera:detach()
	love.graphics.pop()
	love.graphics.setScissor()
end
