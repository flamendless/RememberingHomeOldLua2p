local RoomEvents = {}

RoomEvents.storage_room = {
	ceiling_emitters = {
		{
			key = "ceiling_main",
			x = 48,
			w = 320,
			dust = {
				direction = math.pi / 2,
				strength = 0.9,
				size = 1.0,
			},
			on_walk = { chance = 0.25 },
		},
	},
	ambient = {
		enabled = true,
		interval = { min = 12, max = 30 },
		events = {
			{ type = "lightning", weight = 1, opts = {} },
			{ type = "sound", weight = 2, opts = { source = "static", volume = 0.3, on_player = true } },
			{ type = "dust_ceiling", weight = 3, opts = { key = "ceiling_main" } },
			{
				type = "light_wind_pass",
				weight = 2,
				opts = { direction = "left", mode = "flicker", stagger = 0.08 },
			},
		},
	},
	sequence = {
		once = true,
		save_key = "storage_intro",
		steps = {
			{ delay = 2.0, type = "sound", opts = { source = "static", volume = 0.25, on_player = true } },
			{ delay = 0.5, type = "dust_ceiling", opts = { key = "ceiling_main" } },
			{ delay = 1.5, type = "lightning", opts = {} },
			{
				delay = 3.0,
				type = "light_wind_pass",
				opts = { direction = "right", mode = "flicker", stagger = 0.06 },
			},
		},
	},
}

RoomEvents.utility_room = {}
RoomEvents.kitchen = {}
RoomEvents.living_room = {}
RoomEvents.office1 = {}
RoomEvents.office2 = {}

return RoomEvents
