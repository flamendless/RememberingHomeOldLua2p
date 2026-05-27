local Vignette = {}

Vignette.values = {
	zero = {
		intensity = 0,
		pulse_strength = 0,
		darkness = 0,
		panic = 0,
		scale = 0,
		layers = 0,
		rot_speed = 0,
		noise_intensity = 0,
	},

	engaged = {
		intensity = 0.75,
		pulse_strength = 0.25,
		darkness = 1.8,
		panic = 0.75,
		scale = 1.7,
		layers = 6,
		rot_speed = 0.2,
		noise_intensity = 0.2,
	},

	okayish = {
		intensity = 0.8,
		pulse_strength = 0.5,
		darkness = 1.9,
		panic = 0.85,
		scale = 1.54,
		layers = 6,
		rot_speed = 0.36,
		noise_intensity = 0.22,
	},

	warning = {
		intensity = 0.85,
		pulse_strength = 0.7,
		darkness = 2.5,
		panic = 0.9,
		scale = 1.0,
		layers = 7,
		rot_speed = 0.53,
		noise_intensity = 0.44,
	},

	critical = {
		intensity = 0.99,
		pulse_strength = 0.99,
		darkness = 3,
		panic = 1.6,
		scale = 0.7,
		layers = 8,
		rot_speed = 0.77,
		noise_intensity = 0.78,
	},
}

return Vignette
