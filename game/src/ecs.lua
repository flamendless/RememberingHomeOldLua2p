local ECS = {}

local components, systems, states = {}, {}, {}
Concord.utils.loadNamespace("components", components)
Concord.utils.loadNamespace("systems", systems)
Concord.utils.loadNamespace("states", states)

local commons = {
	"animation", "atlas", "bump_collision", "camera", "color", "culling",
	"show_keys", "deferred_lighting", "dialogues", "entity", "gamestates",
	"interactive", "inventory", "items", "movement", "outline", "pause",
	"player_controller", "renderer", "room", "systems", "transform",
	"typewriter", "door", "light_switch", "notes", "list", "post_processing",
	"randomize_uv", "timeline", "animation_state", "behavior_tree",
	"enemy_controller",
	--"flashlight", "animation_sync",
}

local function get_commons_ex(...)
	local copy = tablex.shallow_copy(commons)
	for _, str in ipairs({...}) do
		table.insert(copy, str)
	end
	return copy
end

local state_systems = {}
state_systems.Splash = {
	"animation", "color", "show_keys", "renderer", "transform", "typewriter_splash",
	"gamestates", "entity", "post_processing", "atlas",
}

state_systems.Menu = {
	"animation", "bounding_box", "click", "color", "hover_effect", "show_keys",
	"menu_settings", "mouse_hover", "move", "renderer", "transform", "entity",
	"gamestates", "list",
}

state_systems.Intro = {
	"animation", "atlas", "camera", "color", "deferred_lighting", "depth",
	"entity", "fog", "gamestates", "parallax", "particle_system", "post_processing",
	"renderer", "show_keys", "text_paint_intro", "transform", "tree", "tween",
	"timeline",
}

state_systems.Outside = get_commons_ex("path", "fireflies", "text_paint")
state_systems.StorageRoom = get_commons_ex()
state_systems.UtilityRoom = get_commons_ex()
state_systems.Kitchen = get_commons_ex()
state_systems.LivingRoom = get_commons_ex()

local unpausable_list = {
	"pause", "renderer", "light", "culling", "color", "gamestates",
	"deferred_lighting", "post_processing", "list",
}

function ECS.load_systems(id, world, prev_id)
	ASSERT(type(id) == "string" and state_systems[id])
	ASSERT(world.__isWorld)
	SASSERT(prev_id, type(prev_id) == "string" and state_systems[prev_id])
	local l_id = string.lower(id)
	ASSERT(states[l_id], l_id .. " state system does not exist")

	if DEV then
		systems.id.debug_show = DevTools.flags.id
		systems.id.debug_enabled = DevTools.flags.id
		systems.id.debug_title = "ID"
		systems.log.debug_show = false
		systems.log.debug_enabled = true
		systems.log.debug_title = "Log"
		world:addSystem(systems.id)
		world:addSystem(systems.log)
	end

	for i, v in ipairs(state_systems[id]) do
		ASSERT(systems[v], string.format("id = %s, i = %d", v, i))
		world:addSystem(systems[v])
		local sys = systems[v]
		for _, str in ipairs(unpausable_list) do
			if str == v then
				sys.__unpausable = true
			end
		end

		if DEV then
			sys.debug_show = DevTools.flags[v]
			sys.debug_enabled = true
			sys.debug_title = v
		end
	end

	local main_sys = states[l_id]
	main_sys.__unpausable = true
	main_sys.prev_id = prev_id
	world:addSystem(main_sys)
end

function ECS.get_system_class(id)
	ASSERT(type(id) == "string")
	local l_id = string.lower(id)
	ASSERT(systems[l_id], "system " .. id .. " not found")
	return systems[l_id]
end

if DEV then
	function ECS.get_state_class(id)
		ASSERT(type(id) == "string")
		local l_id = string.lower(id)
		ASSERT(states[l_id], "state " .. id .. " not found")
		return states[l_id]
	end
end

return ECS
