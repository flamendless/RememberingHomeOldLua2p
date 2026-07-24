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
	"anim",
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
	"show_keys",
	"deferred_lighting",
	"dialogues",
	"entity",
	"gamestates",
	"interactive",
	-- "inventory",
	"items",
	"movement",
	"outline",
	"pause",
	"player_controller",
	"anim",
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
	"tutorial",
	"billboard_glow",
	"lighter",
}

state_systems.StorageRoom = {
	"animation",
	"atlas",
	"bump_collision",
	"camera",
	"color",
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
	"anim",
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
	"anim",
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
	"anim",
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
	"show_keys",
	"deferred_lighting",
	"dialogues",
	"entity",
	"gamestates",
	"interactive",
	-- "inventory",
	"items",
	"movement",
	"outline",
	"pause",
	"player_controller",
	"anim",
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
	"lighter",
}
state_systems.TotallyDarkRoom = state_systems.LivingRoom

state_systems.Office1 = {
	"tween",
	"animation",
	"atlas",
	"billboard_glow",
	"bump_collision",
	"camera",
	"color",
	"show_keys",
	"deferred_lighting",
	-- "dialogues_old",
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
	"anim",
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
	"flashlight",
	"survival",
}

state_systems.Office2 = tablex.copy(state_systems.Office1)


local unpausable_list = {
	"pause",
	"renderer",
	"light",
	"color",
	"gamestates",
	"deferred_lighting",
	"post_processing",
	"list",
}

function ECS.load_systems(id, world, prev_id)
	assert((type(id) == "string" and state_systems[id]), id)
	assert(world.__isWorld, world)
	if prev_id then
		assert((type(prev_id) == "string" and state_systems[prev_id]), prev_id)
	end
	local l_id = string.lower(id)
	assert(states[l_id], l_id .. " state system does not exist")

	systems.id.debug_show = DevTools.flags.id
	systems.id.debug_enabled = DevTools.flags.id
	systems.id.debug_title = "ID"
	systems.log.debug_show = false
	systems.log.debug_enabled = true
	systems.log.debug_title = "Log"
	world:addSystem(systems.id)
	world:addSystem(systems.log)

	for _, v in ipairs(state_systems[id]) do
		assert(systems[v], string.format("id = %s, i = %d", v, _))
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
	assert(type(id) == "string", id)
	local l_id = string.lower(id)
	assert(systems[l_id], "system " .. id .. " not found")
	return systems[l_id]
end

function ECS.get_state_class(id)
	assert(type(id) == "string", id)
	local l_id = string.lower(id)
	assert(states[l_id], "state " .. id .. " not found")
	return states[l_id]
end

function ECS.system_in_state(system, state)
	assert(type(system) == "string", system)
	assert(type(state) == "string", state)
	assert(state_systems[state], state .. " not in state_systems")
	return state_systems[state][system]
end

return ECS
