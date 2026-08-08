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
				return TestHooks.tutorial_beat_is("lighter")
					or TestHooks.tutorial_waiting_dialogue()
			end,
		},
		{
			label = "dialogue (trunk pre)",
			until_fn = function()
				return TestHooks.tutorial_beat_is("lighter")
					and TestHooks.tutorial_wait_is("lighter")
			end,
		},
		{
			label = "lighter",
			do_fn = tap_lighter,
			until_fn = function()
				local tutorial = TestHooks.get_tutorial()
				if not tutorial then
					return false
				end
				if tutorial.beat == Enums.tutorial_beat.lighter
					and tutorial.wait_kind ~= "lighter" then
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
			until_fn = TestHooks.tutorial_explore_ready,
		},
		{
			label = "tutorial_complete",
			pass = true,
		},
	},
}
