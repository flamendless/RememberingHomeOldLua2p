local BgAssets = {}

local function make_entry(key, label, rel_path, light_defaults)
	return {
		key = key,
		label = label,
		rel_path = rel_path,
		gen_path = rel_path:gsub("%.png$", "_gen.png"),
		light_defaults = light_defaults,
	}
end

local interior_light = {
	light_enabled = false,
}

BgAssets.list = {
	make_entry("storage_room", "Storage Room", "res/images/storage_room/storage_room.png", interior_light),
	make_entry("utility_room", "Utility Room", "res/images/utility_room/utility_room.png", interior_light),
	make_entry("kitchen", "Kitchen", "res/images/kitchen/kitchen.png", interior_light),
	make_entry("living_room", "Living Room", "res/images/living_room/living_room.png", interior_light),
	make_entry("office1", "Office 1", "res/images/office1/office1.png", interior_light),
	make_entry("office2", "Office 2", "res/images/office2/office2.png", interior_light),
	make_entry("bg_sky", "Outside Sky", "res/images/outside/bg_sky.png", {
		light_enabled = false,
	}),
	make_entry("bg_house", "Outside House", "res/images/outside/bg_house.png", interior_light),
	make_entry("intro", "Intro", "res/images/intro/bg.png", interior_light),
}

BgAssets.default_preset = {
	cell_size = 2,
	levels = 32,
	dither_amount = 2,
	hue_preserve = 1,
	contrast = 1,
	offset = 0,
	grain = 1,
	seed = 0,
	light_enabled = false,
	light_pos = { 0.35, 0.45 },
	light_radius = 0.55,
	light_falloff = 0.35,
}

return BgAssets
