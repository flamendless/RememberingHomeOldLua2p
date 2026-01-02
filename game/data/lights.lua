local Lights = {}

Lights.storage_room = {
	pl = {
		lz = 26,
		ls = 106,
		fade = 12,
		pos = {
			{x = 92, y = 33},
			{x = 242, y = 33},
		}
	}
}

Lights.utility_room = {
	pl = {
		lz = 26,
		ls = 106,
		fade = 12,
		pos = {
			{x = 92, y = 33},
			{x = 242, y = 33},
		}
	}
}

Lights.kitchen = {
	pl = {
		lz = 48,
		ls = 128,
		fade = 6,
		pos = {
			{x = 86, y = 26},
			{x = 386, y = 27},
		}
	},
	pl_mid = {
		lz = 7,
		ls = 128,
		fade = 6,
		pos = {
			{x = 184},
			{x = 215},
			{x = 242},
		}
	}
}

Lights.living_room = {
	pl = {
		lz = 64,
		ls = 128,
		fade = 8,
		pos = {
			{x = 91, y = 38},
			{x = 329, y = 38},
		},
	},
	pl_mid = {
		lz = 2,
		ls = 64,
		fade = 32,
		pos = {
			{x = 186, y = 53},
			{x = 193, y = 45},
			{x = 202, y = 45},
			{x = 209, y = 53},
		}
	}
}

return Lights
