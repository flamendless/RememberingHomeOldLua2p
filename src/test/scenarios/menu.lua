local function tap(action)
	Inputs.tap(action)
	Inputs.release(action)
end

local function tap_down()
	tap("down")
end

local function tap_interact()
	tap("interact")
end

local function tap_cancel()
	tap("cancel")
end

return {
	name = "menu",
	state = Enums.game_state.Menu,
	steps = {
		{
			label = "Menu ready",
			until_fn = TestHooks.menu_main_ready,
		},
		{
			label = "interact (Play)",
			do_fn = tap_interact,
			until_fn = TestHooks.menu_sub_ready,
		},
		{
			label = "cancel (main menu)",
			do_fn = tap_cancel,
			until_fn = TestHooks.menu_main_ready,
		},
		{
			label = "down (Settings)",
			do_fn = tap_down,
			min_frames = 1,
		},
		{
			label = "interact (Settings)",
			do_fn = tap_interact,
			until_fn = TestHooks.menu_settings_ready,
		},
		{
			label = "cancel (main menu)",
			do_fn = tap_cancel,
			until_fn = TestHooks.menu_main_ready,
		},
		{
			label = "down (About)",
			do_fn = tap_down,
			min_frames = 1,
		},
		{
			label = "interact (About)",
			do_fn = tap_interact,
			until_fn = TestHooks.menu_about_ready,
		},
		{
			label = "cancel (main menu)",
			do_fn = tap_cancel,
			until_fn = TestHooks.menu_main_ready,
		},
		{
			label = "down (Exit)",
			do_fn = tap_down,
			min_frames = 1,
		},
		{
			label = "down (Play)",
			do_fn = tap_down,
			min_frames = 1,
		},
		{
			label = "interact (Play)",
			do_fn = tap_interact,
			until_fn = TestHooks.menu_sub_ready,
		},
		{
			label = "interact (New Game)",
			do_fn = tap_interact,
			until_fn = function()
				return not TestHooks.state_is(Enums.game_state.Menu)
			end,
		},
	},
}
