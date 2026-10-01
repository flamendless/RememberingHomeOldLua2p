local function tap(action)
	Inputs.tap(action)
	Inputs.release(action)
end

local function tap_interact()
	tap("interact")
end

local function tap_lighter()
	tap("lighter")
end

local BACKDOOR_X = 485
local FRONTDOOR_X = 351
local DOOR_APPROACH_SLOW_RADIUS = 96
local DEFAULT_TEST_SPEED = 20
local use_normal_game_speed = false

local function explore_door_approach_slow()
	if use_normal_game_speed then
		return false
	end
	if not TestHooks.state_is(Enums.game_state.Outside) then
		return false
	end
	if not TestHooks.tutorial_wait_is("reach_shed") then
		return false
	end
	return TestHooks.player_near_x(BACKDOOR_X, DOOR_APPROACH_SLOW_RADIUS)
		or TestHooks.player_near_x(FRONTDOOR_X, DOOR_APPROACH_SLOW_RADIUS)
end

local function sync_test_game_speed()
	if not TEST.mode then
		return
	end
	if use_normal_game_speed or explore_door_approach_slow() then
		GAME_SPEED_MULT = 1
	else
		GAME_SPEED_MULT = DEFAULT_TEST_SPEED
	end
end

return {
	name = "Outside Tutorial",
	state = Enums.game_state.Outside,
	keep_running = true,
	on_tick = sync_test_game_speed,
	steps = {
		{
			label = "Outside cutscene",
			until_fn = function()
				return TestHooks.tutorial_wait_is("hold_interact")
			end,
		},
		{
			label = "hold interact (car door)",
			hold = "interact",
			until_fn = function()
				return TestHooks.tutorial_beat_is("move_left")
					and TestHooks.tutorial_wait_is("move_left")
			end,
		},
		{
			label = "move left",
			hold = "left",
			until_fn = function()
				return TestHooks.tutorial_beat_is("interact_left")
					and TestHooks.tutorial_wait_is("press_interact")
			end,
		},
		{
			label = "interact (left)",
			do_fn = tap_interact,
			until_fn = function()
				return TestHooks.dialogue_active()
					or TestHooks.tutorial_beat_is("move_right")
			end,
		},
		{
			label = "dialogue (headlights)",
			until_fn = function()
				return TestHooks.tutorial_beat_is("move_right")
			end,
		},
		{
			label = "move right",
			hold = "right",
			until_fn = function()
				return TestHooks.tutorial_beat_is("interact_right")
					and TestHooks.tutorial_wait_is("press_interact")
			end,
		},
		{
			label = "interact (right)",
			do_fn = tap_interact,
			until_fn = function()
				local tutorial = TestHooks.get_tutorial()
				if not tutorial then
					return false
				end
				if tutorial.beat == Enums.tutorial_beat.interact_right
					and tutorial.wait_kind ~= "press_interact" then
					return true
				end
				return TestHooks.tutorial_beat_is("explore")
					or TestHooks.tutorial_waiting_dialogue()
			end,
		},
		{
			label = "dialogue (trunk + choice)",
			until_fn = function()
				return TestHooks.tutorial_beat_is("explore")
			end,
		},
		{
			label = "explore complete",
			until_fn = function()
				return TestHooks.tutorial_beat_is("reach_shed")
					or TestHooks.tutorial_wait_is("reach_shed")
					or TestHooks.tutorial_wait_is("enter_shed")
			end,
		},
		{
			label = "move to backdoor (explore)",
			hold = "left",
			until_fn = function()
				if TestHooks.player_ready_to_interact_door("backdoor") then
					return true
				end
				return TestHooks.player_west_of_key("backdoor")
			end,
		},
		{
			label = "align at backdoor (explore)",
			hold = "right",
			until_fn = function()
				return TestHooks.player_ready_to_interact_door("backdoor")
			end,
		},
		{
			label = "interact backdoor (explore)",
			do_fn = tap_interact,
			until_fn = function()
				return TestHooks.dialogue_active()
			end,
		},
		{
			label = "backdoor locked (explore)",
			until_fn = function()
				return TestHooks.door_is_locked("backdoor")
					and not TestHooks.dialogue_active()
			end,
		},
		{
			label = "move to frontdoor (explore)",
			hold = "left",
			until_fn = function()
				if TestHooks.player_ready_to_interact_door("frontdoor") then
					return true
				end
				return TestHooks.player_west_of_key("frontdoor")
			end,
		},
		{
			label = "align at frontdoor (explore)",
			hold = "right",
			until_fn = function()
				return TestHooks.player_ready_to_interact_door("frontdoor")
			end,
		},
		{
			label = "interact frontdoor (explore)",
			do_fn = tap_interact,
			until_fn = function()
				return TestHooks.dialogue_active()
			end,
		},
		{
			label = "frontdoor locked (explore)",
			until_fn = function()
				if TestHooks.door_is_locked("frontdoor")
					and not TestHooks.dialogue_active() then
					use_normal_game_speed = true
					return true
				end
				return false
			end,
		},
		{
			label = "reach shed",
			hold = "left",
			until_fn = function()
				if not TestHooks.tutorial_wait_is("enter_shed") then
					return false
				end
				if TestHooks.player_ready_to_interact_shed() then
					return true
				end
				return TestHooks.player_west_of_shed_door()
			end,
		},
		{
			label = "align at shed",
			hold = "right",
			until_fn = function()
				return TestHooks.player_ready_to_interact_shed()
			end,
		},
		{
			label = "interact (shed)",
			do_fn = tap_interact,
			until_fn = function()
				return TestHooks.state_is(Enums.game_state.Shed)
			end,
		},
		{
			label = "dialogue (shed interior)",
			until_fn = function()
				return TestHooks.tutorial_wait_is("open_lighter")
			end,
		},
		{
			label = "open lighter",
			do_fn = tap_lighter,
			until_fn = function()
				return TestHooks.dialogue_active()
					or TestHooks.tutorial_waiting_dialogue()
					or TestHooks.tutorial_wait_is("reach_shed_center")
			end,
		},
		{
			label = "dialogue (shed lit)",
			until_fn = function()
				return TestHooks.tutorial_wait_is("reach_shed_center")
			end,
		},
		{
			label = "move to shed center",
			hold = "left",
			until_fn = function()
				return TestHooks.tutorial_wait_is("close_lighter")
			end,
		},
		{
			label = "close lighter",
			do_fn = tap_lighter,
			until_fn = function()
				local tutorial = TestHooks.get_tutorial()
				return tutorial ~= nil and tutorial.shed_lighter_done
			end,
		},
		{
			label = "move to light switch",
			hold = "left",
			until_fn = function()
				if TestHooks.player_ready_to_interact_key("light_switch") then
					return true
				end
				return TestHooks.player_west_of_key("light_switch")
			end,
		},
		{
			label = "align at light switch",
			hold = "right",
			until_fn = function()
				return TestHooks.player_ready_to_interact_key("light_switch")
			end,
		},
		{
			label = "interact light switch",
			do_fn = tap_interact,
			until_fn = function()
				return TestHooks.shed_room_lights_on()
					and not TestHooks.dialogue_active()
			end,
		},
		{
			label = "move to shed exit door",
			hold = "right",
			until_fn = function()
				return TestHooks.player_ready_to_interact_key("door_right")
			end,
		},
		{
			label = "exit shed",
			do_fn = tap_interact,
			until_fn = function()
				return TestHooks.state_is(Enums.game_state.Outside)
			end,
		},
		{
			label = "dialogue (shed2)",
			until_fn = function()
				return TestHooks.tutorial_beat_is("done")
					and TestHooks.door_is_open("backdoor")
					and TestHooks.player_can_move()
			end,
		},
		{
			label = "move to frontdoor",
			hold = "right",
			until_fn = function()
				if TestHooks.player_ready_to_interact_door("frontdoor") then
					return true
				end
				return TestHooks.player_east_of_key("frontdoor")
			end,
		},
		{
			label = "align at frontdoor",
			hold = "left",
			until_fn = function()
				return TestHooks.player_ready_to_interact_door("frontdoor")
			end,
		},
		{
			label = "interact frontdoor (locked)",
			do_fn = tap_interact,
			until_fn = function()
				return TestHooks.dialogue_active()
			end,
		},
		{
			label = "frontdoor locked",
			until_fn = function()
				return TestHooks.door_is_locked("frontdoor")
					and TestHooks.door_is_open("backdoor")
					and not TestHooks.dialogue_active()
			end,
		},
		{
			label = "move to backdoor",
			hold = "right",
			until_fn = function()
				if TestHooks.player_ready_to_interact_door("backdoor") then
					return true
				end
				return TestHooks.player_east_of_key("backdoor")
			end,
		},
		{
			label = "align at backdoor",
			hold = "left",
			until_fn = function()
				return TestHooks.player_ready_to_interact_door("backdoor")
			end,
		},
		{
			label = "interact backdoor",
			do_fn = tap_interact,
			until_fn = function()
				return TestHooks.state_is(Enums.game_state.StorageRoom)
			end,
		},
		{
			label = "tutorial_complete",
			pass = true,
		},
	},
}
