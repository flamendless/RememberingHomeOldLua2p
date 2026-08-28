-- https://github.com/EngineerSmith/Export-TextureAtlas
-- check run.sh create_atlas
local Data = {
	frames = {
		["shed"] = {
			x = 4,
			y = 4,
			w = 154,
			h = 98
		},
		["backdoor"] = {
			x = 166,
			y = 4,
			w = 10,
			h = 67
		},
		["car"] = {
			x = 4,
			y = 110,
			w = 126,
			h = 48
		},
		["frontdoor"] = {
			x = 138,
			y = 110,
			w = 33,
			h = 67
		}
	},
	meta = {
		padding = 4,
		extrude = 0,
		atlasWidth = 180,
		atlasHeight = 181,
		quadCount = 4
	}
}
return Data
