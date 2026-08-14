local BgAssets = {}

local function make_entry(key, label, rel_path, light_defaults, container)
	return {
		key = key,
		label = label,
		rel_path = rel_path,
		gen_path = rel_path:gsub("%.png$", "_gen.png"),
		light_defaults = light_defaults,
		container = container,
	}
end

local interior_light = {
	light_enabled = false,
}

BgAssets.list = {
	make_entry("storage_room", "Storage Room", "res/images/storage_room/storage_room.png", interior_light, "array_images"),
	make_entry("utility_room", "Utility Room", "res/images/utility_room/utility_room.png", interior_light, "array_images"),
	make_entry("kitchen", "Kitchen", "res/images/kitchen/kitchen.png", interior_light, "array_images"),
	make_entry("living_room", "Living Room", "res/images/living_room/living_room.png", interior_light, "array_images"),
	make_entry("office1", "Office 1", "res/images/office1/office1.png", interior_light, "array_images"),
	make_entry("office2", "Office 2", "res/images/office2/office2.png", interior_light, "array_images"),
	make_entry("bg_sky", "Outside Sky", "res/images/outside/bg_sky.png", {
		light_enabled = false,
	}, "array_images"),
	make_entry("bg_house", "Outside House", "res/images/outside/bg_house.png", interior_light, "array_images"),
	make_entry("intro", "Intro", "res/images/intro/bg.png", interior_light, "images"),
}

BgAssets.keys = {}
for _, entry in ipairs(BgAssets.list) do
	BgAssets.keys[entry.key] = entry
end

function BgAssets.is_bg_key(id)
	assert:type(id, "string")
	if BgAssets.keys[id] then
		return true
	end
	local base = id:match("^(.+)_gen$")
	return base and BgAssets.keys[base] ~= nil
end

function BgAssets.base_key(id)
	assert:type(id, "string")
	if BgAssets.keys[id] then
		return id
	end
	local base = id:match("^(.+)_gen$")
	if base and BgAssets.keys[base] then
		return base
	end
	error(id .. " is not a bg asset key")
end

function BgAssets.get_use_gen(world)
	if world then
		local room = world:getSystem(ECS.get_system_class("room"))
		if room then
			return room.use_gen
		end
	end
	return true
end

function BgAssets.get_resource_id(key, use_gen)
	assert:type(key, "string")
	assert(BgAssets.keys[key], key .. " is not a bg asset key")
	if use_gen == nil then
		use_gen = true
	end
	if use_gen then
		return key .. "_gen"
	end
	return key
end

function BgAssets.get_image(key, use_gen)
	assert:type(key, "string")
	assert(BgAssets.keys[key], key .. " is not a bg asset key")
	if use_gen == nil then
		use_gen = true
	end
	local resource_id = BgAssets.get_resource_id(key, use_gen)
	local image = Resources.data.images[resource_id]
	assert(image, resource_id .. " is not loaded")
	return image
end

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
