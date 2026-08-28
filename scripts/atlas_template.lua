-- https://github.com/EngineerSmith/Export-TextureAtlas
-- check run.sh create_atlas
local Data = {
	frames = {
	{{#quads}}
		["{{{id}}}"] = {
			x = {{x}},
			y = {{y}},
			w = {{w}},
			h = {{h}}
		}{{^last}},{{/last}}
	{{/quads}}
	},
	meta = {
		padding = {{meta.padding}},
		extrude = {{meta.extrude}},
		atlasWidth = {{meta.width}},
		atlasHeight = {{meta.height}},
		quadCount = {{meta.quadCount}}
	{{#meta.fixedSize}},
		fixedSize = {
			width = {{width}},
			height = {{height}},
		}
	{{/meta.fixedSize}}{{^meta.fixedSize}}{{/meta.fixedSize}}
}
}
return Data
