return {
	name = "splash",
	state = Enums.game_state.Splash,
	steps = {
		{
			label = "Splash",
			until_fn = function()
				return not TestHooks.state_is(Enums.game_state.Splash)
			end,
		},
	},
}
