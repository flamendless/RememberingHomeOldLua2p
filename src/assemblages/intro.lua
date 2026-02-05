local Intro = {}

local speed = {
	clouds = 2,
	buildings = 8,
	road = 512,
	post = 512,
	post_light = 512,
	grass = 640,
	grass2 = 656,
	grass_back = 48,
	grass_front = 496,
	trees_bg = 400,
	trees_fg = 530,
}

--z_index, zoom_factor
local z_index = {
	clouds = { 1, 0.005 },
	buildings = { 1, 0.005 },
	fog1 = { 1, 0.005 },
	grass_back = { 2, 0.01 },
	trees_bg = { 3, 0.015 },
	bg_tree_cover = { 4, 0.02 },
	fog4 = { 5, 0.02 },
	grass_front = { 7, 0.025 },
	post = { 8, 0.03 },
	road = { 9, 0.04 },
	post_light = { 9, 0.03 },
	grass = { 10, 0.05 },
	car = { 11, 0.04 },
	car_reflect = { 12, 0.04 },
	fog2 = { 12, 0.04 },
	grass2 = { 13, 0.06 },
	trees_fg = { 14, 0.07 },
	fog3 = { 15, 0.07 },
}

local positions = {
	buildings = { 0, 260 },
	road = { 0, 360 },
	grass = { 0, 390 },
	grass2 = { 0, 396 },
	grass_back = { 0, 324 },
	grass_front = { 0, 334 },
	trees_bg = { 0, 36 },
	trees_fg = { 0, 108 },
	post = { 108, 106 },
	post_light = { 0, 108 },
}

function Intro.parallax(e, tag, scale)
	if type(tag) ~= "string" then
		error('Assertion failed: type(tag) == "string"')
	end
	if scale then
		if type(scale) ~= "number" then
			error('Assertion failed: type(scale) == "number"')
		end
	end
	if not speed[tag] then
		error("Assertion failed: speed[tag]")
	end
	if not z_index[tag] then
		error("Assertion failed: z_index[tag]")
	end

	local x, y = 0, 0
	local pos = positions[tag]
	if pos then
		x, y = unpack(pos)
	end

	if tag == "trees_bg" then
		x = love.graphics.getWidth()
		e:give("parallax_stop"):give("bg_tree")
	end

	local item = Atlases.AtlasIntro.frames[tag]
	if not scale then
		local ww, wh = love.graphics.getDimensions()
		local w, h = item.w, item.h
		scale = math.min(ww / w, wh / h)
	end

	e:give("id", tag)
		:give("sprite", "atlas_intro")
		:give("pos", x, y)
		:give("atlas", item)
		:give("quad_transform", 0, scale, scale)
		:give("z_index", z_index[tag][1], false)
		:give("parallax", speed[tag], 0)
		:give("parallax_multi_sprite", tag)
		:give("depth_zoom", z_index[tag][2])
end

function Intro.post_light(e, tag, scale)
	Intro.parallax(e, tag, scale)
	e:give("transform")
		:give("light", Enums.light_shape.custom, 1)
		:give("color", Palette.get_diffuse("post"))
		:give("light_flicker", 0.1)
		:give("light_disabled")
		:give("intro_light")
		:give("depth_zoom", z_index.post_light[2])
end

function Intro.bg_tree_cover(e)
	local item = Atlases.AtlasIntro.frames.bg_tree_cover
	local ww, wh = love.graphics.getDimensions()
	local w, h = item.w, item.h
	local scale = math.min(ww / w, wh / h)

	e:give("id", "bg_tree_cover")
		:give("sprite", "atlas_intro")
		:give("atlas", item)
		:give("pos", love.graphics.getWidth(), 110)
		:give("quad_transform", 0, scale, scale, item.w/2)
		:give("z_index", z_index.bg_tree_cover[1])
		:give("depth_zoom", z_index.bg_tree_cover[2])
		:give("bg_tree", true)
end

function Intro.car(e)
	e:give("id", "car")
		:give("animation_data", Animation.get("car"))
		:give("pos", 16, 325)
		:give("animation", false)
		:give("z_index", z_index.car[1])
		:give("depth_zoom", z_index.car[2])
		:give("transform")
end

function Intro.car_reflect(e, car)
	e:give("id", "car_reflect")
		:give("animation_data", Animation.get("car_reflect"))
		:give("pos", car.pos.x, car.pos.y)
		:give("animation", false)
		:give("attach_to", car)
		:give("z_index", z_index.car[1] + 8)
		:give("depth_zoom", z_index.car_reflect[2])
		:give("transform")
end

function Intro.car_light(e, car)
	e:give("id", "car_light")
		:give("pos", 0, 0)
		:give("transform")
		:give("depth_zoom", z_index.car[2])
		:give("color", Palette.get_diffuse("car"))
		:give("light", "cone", 0.8)
		:give("sprite", "atlas_intro")
		:give("atlas", Atlases.AtlasIntro.frames.car_headlight)
		:give("light_flicker", 0.075)
		:give("attach_to", car)
		:give("attach_to_offset", 116, -24)
		:give("z_index", z_index.car[1])
end

--INFO: Single frame title
-- function Intro.title(e, x, y)
-- 	e:give("id", "title")
-- 		:give("sprite", "atlas_intro")
-- 		:give("atlas", Atlases.AtlasIntro.frames.title)
-- 		:give("pos", x, y)
-- 		:give("quad_transform", 0, 6, 6, 0.5, 0.5)
-- 		:give("color", { 1, 1, 1, 0 })
-- 		:give("ui_element")
-- 		:give("hidden")
-- end

-- function Intro.title_light(e, x, y)
-- 	e:give("id", "title_light")
-- 		:give("sprite", "atlas_intro")
-- 		:give("atlas", Atlases.AtlasIntro.frames.title_light)
-- 		:give("pos", x, y)
-- 		:give("quad_transform", 0, 4, 4, 0.5, 0.5)
-- 		:give("color", { 1, 1, 1 })
-- 		:give("light", Enums.light_shape.custom, 1)
-- 		:give("light_flicker", 0.075)
-- 		:give("light_disabled")
-- 		:give("hidden")
-- end

function Intro.sheet_title(e, ww, wh)
	e:give("id", "title")
		:give("animation_data", {
			resource_id = "sheet_title",
			frames = { "1-3", 1, "1-3", 1, "1-1", 1 },
			delay = { 1, 0.1, 1, 0.1, 0.1, 0.1, 1 },

			rows_count = 1,
			columns_count = 3,
			n_frames = 3,
		})
		:give("pos", ww/2, wh/2)
		:give("animation", false)
		:give("animation_pause_at", Enums.pause_at.first)
		:give("transform", 0, 1, 1, 0.5, 0.5)
		:give("auto_scale", ww/2, wh/2, true)
		:give("color", Palette.get("white", 0))
		:give("fade_in_target_alpha", 0.5)
		:give("intro_text")
		:give("ui_element")
		:give("hidden")
end

function Intro.fog(e, id, w, h, color, x, y, fsx, fsy, fog_speed)
	e:give("id", id)
		:give("sprite", "dummy")
		:give("noise_texture", w, h)
		:give("color", color)
		:give("pos", x, y)
		:give("transform", 0, fsx, fsy)
		:give("fog", fog_speed)
		:give("z_index", z_index[id][1], false)
		:give("depth_zoom", z_index[id][2])
		:give("custom_renderer", "draw_fog")
end

return Intro
