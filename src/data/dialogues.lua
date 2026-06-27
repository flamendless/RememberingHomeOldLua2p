local Dialogues = {}

--TODO: Move this
-- local Speakers = {
-- 	narrator = "narrator",
-- 	player = "player",
-- }

Dialogues.items = {
	start = {},
	fin = {},
	no_batteries = {
		"Batteries ran out of juice",
	},
}

Dialogues.common = {
	start = {},
	fin = {},
	item_without = {
		"there is nothing to use this item with",
	},
	cant_search_yet = {
		"I don't need any of these for now",
	},
}

Dialogues.outside = {
	start = {},
	fin = {},
	car = {
		"An old but reliable car",
		choices = {
			{ "drive",         "Maybe tomorrow",    "For now I need to get in shelter and rest" },
			{
				"search",
				"There might be something in the glove box",
				"_get_flashlight",
				get_flashlight = {
					"A very handy flashlight",
					"Let's hope the power is not out",
					"Or else it will be a fumbling in the dark again",
				},
				has_flashlight_already = {
					"There is nothing useful here anymore",
				},
			},
			{ "toggle lights", "__toggle_car_power" },
			{ "nothing" },
		},
	},

	frontdoor_locked = {
		"This door leads to the house",
		choices = {
			{
				"open",
				"__check_frontdoor",
				door_locked = {
					"the door is locked",
					"I do not have the key",
					"I must have left it in work",
				},
				door_unlocked = {
					"the door is unlocked",
					--TODO: (Brandon) remove dialogue component
				},
			},
			{ "do nothing" },
		},
	},

	backdoor = {
		"_check_backdoor",
		no_flashlight_yet = {
			"I need to get my things first from the car",
			"_make_car_interactive",
		},
	},
}

Dialogues.utility_room = {
	start = {},
	fin = {},
	light_switch = {
		"_toggle_light_switch",
	},
	washing_machine = {
		"a washing machine",
		"it's too late to do the laundry",
	},
	basket = {
		"a basket for used clothes",
		"but there's also trash",
	},
	electrical_box = {
		"an electrical junction box",
	},
	shelf = {
		"shelf for various items",
		"I seriously need to get this organized",
	},
}

Dialogues.storage_room = {
	start = {},
	fin = {},
	light_switch = {
		"_toggle_light_switch",
	},

	shelf = {
		"A shelf for storage",
		choices = {
			{
				"search",
				"boxes and boxes of old paperworks from past cases",
				"worn out and dirty clothes",
				"various equipments and tools",
				"__search_shelf",
			},
			{ "nothing" },
		},
	},

	filing_cabinet = {
		"A sturdy filing cabinet",
		choices = {
			{
				"open",
				choices = {
					{ "first",  "spools of wires and cables", "taken from old electronics" },
					{ "second", "tapes, used pens, markers,", "screws, nails, and so on" },
					{
						"third",
						"__check_drawer_key",
						no_key_yet = {
							"it's locked. I need a key",
						},
					},
					{ "fourth", "Folders and envelopes of more materials from cases" },
				},
			},
			{ "nothing" },
		},
	},
	table = {},
}

Dialogues.kitchen = {
	start = {},
	fin = {},
	ref = {
		"A refrigerator",
	},
	light_switch = {
		"which switch to toggle?",
		choices = {
			{ "top",    "_toggle_light_switch" },
			{ "bottom", "_toggle_light_switch" },
			{ "nothing" },
		},
	},
}

Dialogues.outside = {
	start = {},
	car1 = {
		LoveInk.Helpers.text("Test from LoveInk"),
		LoveInk.Helpers.choice("check shelf?", {
			{ "yes",       divert = DIALOGUE_FIN },
			{ "im scared", divert = "car1" },
		}),
		LoveInk.Helpers.divert(DIALOGUE_FIN),
	},
	fin = {},
}

Dialogues.office2 = {
	start = {},
	test = {
		LoveInk.Helpers.text("Test from LoveInk"),
		LoveInk.Helpers.choice("check shelf?", {
			{ "yes",       divert = DIALOGUE_FIN },
			{ "im scared", divert = "test" },
		}),
		LoveInk.Helpers.divert(DIALOGUE_FIN),
	},
	fin = {},
}

if DEV then
	for k, v in pairs(Dialogues) do
		if not v.start then
			error("make sure it has start node for dialogue " .. k)
		end
		if not v.fin then
			error("make sure it has fin node for dialogue " .. k)
		end

		for id, subt in pairs(v) do
			for _, d in ipairs(subt) do
				if d.type == "choice" then
					assert(#d.options == 2, "enforce 2 options for choice " .. id .. " of dialogue " .. k)
				end
			end
		end
	end
end

return Dialogues
