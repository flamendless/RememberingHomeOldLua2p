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

return {
	name = "Outside Tutorial",
	state = Enums.game_state.Outside,
	keep_running = true,
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
			end,
		},
		{
			label = "reach shed",
			hold = "left",
			until_fn = function()
				return TestHooks.tutorial_wait_is("enter_shed")
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
				return TestHooks.tutorial_beat_is("open_lighter")
					and TestHooks.tutorial_wait_is("null")
			end,
		},
		{
			label = "move to shed exit",
			hold = "right",
			until_fn = function()
				return TestHooks.player_near_x(332, 48)
			end,
		},
		{
			label = "face shed exit",
			hold = "right",
			min_frames = 3,
			until_fn = function()
				return TestHooks.player_faces_dir(1)
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
			end,
		},
		{
			label = "move to frontdoor",
			hold = "right",
			until_fn = function()
				return TestHooks.player_near_x(351, 48)
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
				return TestHooks.player_near_x(485, 48)
			end,
		},
		{
			label = "face backdoor",
			hold = "left",
			min_frames = 3,
			until_fn = function()
				return TestHooks.player_faces_dir(-1)
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
			do_fn = function()
				GAME_SPEED_MULT = 1
			end,
		},
	},
}
