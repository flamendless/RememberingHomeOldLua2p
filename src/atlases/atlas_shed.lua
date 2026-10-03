-- https://github.com/EngineerSmith/Export-TextureAtlas
-- check run.sh create_atlas
local Data = {
	frames = {
		["bulb"] = {
			x = 314,
			y = 32,
			w = 5,
			h = 18
		},
		["shelf3"] = {
			x = 130,
			y = 4,
			w = 42,
			h = 32
		},
		["shelf2"] = {
			x = 180,
			y = 4,
			w = 42,
			h = 32
		},
		["door_right"] = {
			x = 269,
			y = 4,
			w = 16,
			h = 61
		},
		["generator"] = {
			x = 293,
			y = 4,
			w = 33,
			h = 20
		},
		["light_switch"] = {
			x = 293,
			y = 32,
			w = 13,
			h = 17
		},
		["shelf1"] = {
			x = 230,
			y = 4,
			w = 31,
			h = 43
		},
		["cabinet"] = {
			x = 4,
			y = 4,
			w = 118,
			h = 27
		}
	},
	meta = {
		padding = 4,
		extrude = 0,
		atlasWidth = 330,
		atlasHeight = 69,
		quadCount = 8
	}
}
return Data
