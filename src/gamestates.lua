local Concord = require("modules.concord.concord")
local Log = require("modules.log.log")

local Cache = require("cache")
local ECS = require("ecs")
local Preloader = require("preloader")
local Resources = require("resources")

local GameStates = {
	type_id = "GameStates",
	is_ready = false,
	current_id = nil,
	world = nil,
	prev_id = nil,
	prev_world = nil,
}

function GameStates.preload()
	local resources = {
		atlas = {},
		images = {},
		image_data = {},
		array_images = {},
		fonts = {},
	}
	local list = Resources.get_meta(GameStates.current_id)

	Cache.manage_resources(resources, list, Resources.data)

	Resources.clean()

	Log.info("Preloading: " .. GameStates.current_id)
	Preloader.start(list, resources, function()
		GameStates.start(resources)
	end)
end

function GameStates.start(resources)
	Resources.set_resources(resources)
	GameStates.is_ready = true
	GameStates.world = Concord.world()
	GameStates.world.current_id = GameStates.current_id
	ECS.load_systems(GameStates.current_id, GameStates.world, GameStates.prev_id)

	GameStates.world:emit("state_setup")

	GameStates.world:emit("state_init")

	local sc = ECS.get_state_class(GameStates.current_id)
	local DevTools = require("devtools")
	DevTools.camera = GameStates.world:getSystem(sc).camera
end

function GameStates.switch(next_id)
	if not (type(next_id) == "string") then
		error('Assertion failed: type(next_id) == "string"')
	end

	GameStates.is_ready = false
	if GameStates.world then
		GameStates.prev_world = GameStates.world
		GameStates.prev_id = GameStates.current_id
		GameStates.exit()
	end

	Log.info("Switching to:", next_id)
	GameStates.current_id = next_id

	GameStates.preload()
end

function GameStates.switch_to_previous()
	GameStates.switch(GameStates.prev_id)
end

function GameStates.update(dt)
	if not GameStates.is_ready then
		return
	end
	GameStates.world:emit("state_update", dt)
end

function GameStates.draw()
	if not GameStates.is_ready then
		return
	end
	GameStates.world:emit("state_draw")
end

function GameStates.keypressed(key)
	if not GameStates.is_ready then
		return
	end
	GameStates.world:emit("state_keypressed", key)
end

function GameStates.keyreleased(key)
	if not GameStates.is_ready then
		return
	end
	GameStates.world:emit("state_keyreleased", key)
end

function GameStates.mousemoved(mx, my, dx, dy)
	if not GameStates.is_ready then
		return
	end
	GameStates.world:emit("state_mousemoved", mx, my, dx, dy)
end

function GameStates.mousepressed(mx, my, mb)
	if not GameStates.is_ready then
		return
	end
	GameStates.world:emit("state_mousepressed", mx, my, mb)
end

function GameStates.mousereleased(mx, my, mb)
	if not GameStates.is_ready then
		return
	end
	GameStates.world:emit("state_mousereleased", mx, my, mb)
end

function GameStates.exit()
	GameStates.world:emit("cleanup")
	GameStates.world:clear()
	for _, e in ipairs(GameStates.world:getEntities()) do
		e:destroy()
	end
end

return GameStates
