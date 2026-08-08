return {
	name = "intro",
	state = Enums.game_state.Intro,
	steps = {
		{
			label = "Intro",
			until_fn = function()
				return not TestHooks.state_is(Enums.game_state.Intro)
			end,
		},
	},
}
