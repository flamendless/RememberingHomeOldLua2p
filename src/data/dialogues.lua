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
	car_doors = {
		LoveInk.Helpers.text("Handle is a little bit stuck..."),
		LoveInk.Helpers.divert(DIALOGUE_FIN),
	},
	car_doors2 = {
		LoveInk.Helpers.text("Just a little bit more..."),
		LoveInk.Helpers.divert(DIALOGUE_FIN),
	},
	car_doors3 = {
		LoveInk.Helpers.text("There!"),
		LoveInk.Helpers.divert(DIALOGUE_FIN),
	},
	car_headlights = {
		LoveInk.Helpers.text("Headlights busted..."),
		LoveInk.Helpers.text("Doe might have gutted out the trunk..."),
		LoveInk.Helpers.divert(DIALOGUE_FIN),
	},
	car_trunk = {
		LoveInk.Helpers.text("There's a few items here..."),
		LoveInk.Helpers.divert("car_flashlight"),
	},
	car_flashlight = {
		LoveInk.Helpers.choice("Take the flashlight?", {
			{ "yes", divert = DIALOGUE_FIN },
			{ "no",  divert = "car_flashlight_prompt" },
		}),
	},
	car_flashlight_prompt = {
		LoveInk.Helpers.text("It's dark..."),
		LoveInk.Helpers.divert("car_flashlight"),
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
