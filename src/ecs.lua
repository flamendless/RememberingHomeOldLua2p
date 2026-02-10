local ECS = {}

local components = {}
Concord.utils.loadNamespace("components", components)

local systems = {}
Concord.utils.loadNamespace("systems", systems)

local states = {}
Concord.utils.loadNamespace("states", states)

local state_systems = {}
state_systems.Splash = {
	"animation",
	"color",
	"show_keys",
	"renderer",
	"transform",
	"typewriter_splash",
	"gamestates",
	"entity",
	"post_processing",
	"atlas",
}

state_systems.Menu = {
	"animation",
	"bounding_box",
	"click",
	"color",
	"hover_effect",
	"show_keys",
	"menu_settings",
	"mouse_hover",
	"move",
	"renderer",
	"transform",
	"entity",
	"gamestates",
	"list",
}

state_systems.Intro = {
	"animation",
	"atlas",
	"camera",
	"color",
	"deferred_lighting",
	"depth",
	"entity",
	"fog",
	"gamestates",
	"parallax",
	"particle_system",
	"post_processing",
	"renderer",
	"show_keys",
	"text_paint_intro",
	"transform",
	"tree",
	"tween",
	"timeline",
}

state_systems.Outside = {
	"animation",
	"atlas",
	"bump_collision",
	"camera",
	"color",
	"culling",
	"show_keys",
	"deferred_lighting",
	"dialogues",
	"entity",
	"gamestates",
	"interactive",
	"inventory",
	"items",
	"movement",
	"outline",
	"pause",
	"player_controller",
	"renderer",
	"room",
	"systems",
	"transform",
	"typewriter",
	"door",
	"light_switch",
	"notes",
	"list",
	"post_processing",
	"randomize_uv",
	"timeline",
	"animation_state",
	"behavior_tree",
	"enemy_controller",
	"path",
	"fireflies",
	"text_paint",
}

state_systems.StorageRoom = {
	"animation",
	"atlas",
	"bump_collision",
	"camera",
	"color",
	"culling",
	"show_keys",
	"deferred_lighting",
	"dialogues",
	"entity",
	"gamestates",
	"interactive",
	"inventory",
	"items",
	"movement",
	"outline",
	"pause",
	"player_controller",
	"renderer",
	"room",
	"systems",
	"transform",
	"typewriter",
	"door",
	"light_switch",
	"notes",
	"list",
	"post_processing",
	"randomize_uv",
	"timeline",
	"animation_state",
	"behavior_tree",
	"enemy_controller",
	"ants",
	"path",
	"flies",
}

state_systems.UtilityRoom = {
	"animation",
	"atlas",
	"bump_collision",
	"camera",
	"color",
	"culling",
	"show_keys",
	"deferred_lighting",
	"dialogues",
	"entity",
	"gamestates",
	"interactive",
	"inventory",
	"items",
	"movement",
	"outline",
	"pause",
	"player_controller",
	"renderer",
	"room",
	"systems",
	"transform",
	"typewriter",
	"door",
	"light_switch",
	"notes",
	"list",
	"post_processing",
	"randomize_uv",
	"timeline",
	"animation_state",
	"behavior_tree",
	"enemy_controller",
}

state_systems.Kitchen = {
	"animation",
	"atlas",
	"bump_collision",
	"camera",
	"color",
	"culling",
	"show_keys",
	"deferred_lighting",
	"dialogues",
	"entity",
	"gamestates",
	"interactive",
	"inventory",
	"items",
	"movement",
	"outline",
	"pause",
	"player_controller",
	"renderer",
	"room",
	"systems",
	"transform",
	"typewriter",
	"door",
	"light_switch",
	"notes",
	"list",
	"post_processing",
	"randomize_uv",
	"timeline",
	"animation_state",
	"behavior_tree",
	"enemy_controller",
}

state_systems.LivingRoom = {
	"animation",
	"atlas",
	"bump_collision",
	"camera",
	"color",
	"culling",
	"show_keys",
	"deferred_lighting",
	"dialogues",
	"entity",
	"gamestates",
	"interactive",
	"inventory",
	"items",
	"movement",
	"outline",
	"pause",
	"player_controller",
	"renderer",
	"room",
	"systems",
	"transform",
	"typewriter",
	"door",
	"light_switch",
	"notes",
	"list",
	"post_processing",
	"randomize_uv",
	"timeline",
	"animation_state",
	"behavior_tree",
	"enemy_controller",
}
state_systems.TotallyDarkRoom = state_systems.LivingRoom

--TODO: (flam)
state_systems.Office1 = state_systems.LivingRoom

local unpausable_list = {
	"pause",
	"renderer",
	"light",
	"culling",
	"color",
	"gamestates",
	"deferred_lighting",
	"post_processing",
	"list",
}

function ECS.load_systems(id, world, prev_id)
	if not (type(id) == "string" and state_systems[id]) then
		error('Assertion failed: type(id) == "string" and state_systems[id]')
	end
	if not world.__isWorld then
		error("Assertion failed: world.__isWorld")
	end
	if prev_id then
		if not (type(prev_id) == "string" and state_systems[prev_id]) then
			error('Assertion failed: type(prev_id) == "string" and state_systems[prev_id]')
		end
	end
	local l_id = string.lower(id)
	if not states[l_id] then
		error(l_id .. " state system does not exist")
	end

	systems.id.debug_show = DevTools.flags.id
	systems.id.debug_enabled = DevTools.flags.id
	systems.id.debug_title = "ID"
	systems.log.debug_show = false
	systems.log.debug_enabled = true
	systems.log.debug_title = "Log"
	world:addSystem(systems.id)
	world:addSystem(systems.log)

	for _, v in ipairs(state_systems[id]) do
		if not systems[v] then
			error(string.format("id = %s, i = %d", v, _))
		end
		world:addSystem(systems[v])
		local sys = systems[v]
		for _, u in ipairs(unpausable_list) do
			if u == v then
				sys.__unpausable = true
			end
		end

		sys.debug_show = DevTools.flags[v]
		sys.debug_enabled = true
		sys.debug_title = v
	end

	local main_sys = states[l_id]
	main_sys.__unpausable = true
	main_sys.prev_id = prev_id
	world:addSystem(main_sys)
end

function ECS.get_system_class(id)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	local l_id = string.lower(id)
	if not systems[l_id] then
		error("system " .. id .. " not found")
	end
	return systems[l_id]
end

function ECS.get_state_class(id)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	local l_id = string.lower(id)
	if not states[l_id] then
		error("state " .. id .. " not found")
	end
	return states[l_id]
end

return ECS
