local Outside = {
	colliders = {},
	lights = {},
}

local Light = require("assemblages.light")

local z_index = {
	bg_house = 0,
	firefly = 2,
	--player = 3,
	splashes = 4,
}

local ground_h = 48
local bounds_w, bounds_h = 52, 72
local bounds_l_w = 28

function Outside.bg_house(e, x, y, quad)
	e:give("id", "bg_house")
	:give("sprite", "bg_house")
	:give("pos", x, y)
	:give("quad", quad)
	:give("z_index", z_index.bg_house, false)
end

function Outside.splashes(e)
	local splashes = Resources.data.images.splashes
	local resource_id = "splashes"
	local is_compatible = SystemInfo.is_texturesize_compatible(splashes:getWidth())
	if not is_compatible then
		resource_id = "splashes_low"
		Log.warn("Texture size for splashes use 'low' version")
	end
	e:give("id", "splashes")
	:give("splashes")
	:give("pos", 0, 4)
	:give("z_index", z_index.splashes)
	:give("color", {1, 1, 1, 1})
	:give("animation")
	:give("animation_data", Animation.get("outside_" .. resource_id))

	if not is_compatible then
		e:give("transform", 0, 4, 4)
	end
end

function Outside.firefly(e, x, y, size)
	e:give("id", "firefly")
	:give("firefly")
	:give("pos", x, y, 2)
	:give("point_light", size)
	:give("diffuse", {0, 0, 0})
end

function Outside.colliders.ground(e, w, h)
	e:give("id", "col_ground")
	:give("pos", 0, h - ground_h)
	:give("collider", w, ground_h)
	:give("bump")
	:give("ground")
end

function Outside.colliders.left_bound(e, w, h)
	e:give("id", "col_left_bound")
	:give("pos", 0, h - ground_h - bounds_h)
	:give("collider", bounds_l_w, bounds_h)
	:give("bump")
	:give("wall")
end

function Outside.colliders.right_bound(e, w, h)
	e:give("id", "col_right_bound")
	:give("pos", w - bounds_w, h - ground_h - bounds_h)
	:give("collider", bounds_w, bounds_h)
	:give("bump")
	:give("wall")
end

function Outside.lights.pl_car_headlight(e, id)
	e:assemble(Light.point, 733, 296, 4, 24, Palette.get_diffuse("car_headlight_pl"))
	:give("id", id)
	:give("car_lights")
end

function Outside.lights.sl_car_headlight(e, id)
	e:assemble(Light.spot,
		751, 290, 6,
		{-1, 0.25, 0, 0.95},
		256,
		Palette.get_diffuse("car_headlight_sl"))
	:give("id", id)
	:give("car_lights")
end

function Outside.lights.pl_backdoor(e, id)
	e:assemble(Light.point, 446, 292, 62, 72, Palette.get_diffuse("door_pl"))
	:give("id", id)
end

function Outside.lights.sl_backdoor(e, id)
	e:assemble(Light.spot,
		446, 241, 4,
		{0, 1, -0.8, 0.77},
		64,
		Palette.get_diffuse("door_sl"))
	:give("id", id)
end

function Outside.lights.pl_frontdoor(e, id)
	e:assemble(Light.point, 316, 262, 62, 72, Palette.get_diffuse("door_pl"))
	:give("id", id)
end

function Outside.lights.sl_frontdoor(e, id)
	e:assemble(Light.spot,
		316, 221, 4,
		{0, 1, -1, 0.73},
		64,
		Palette.get_diffuse("door_sl"))
	:give("id", id)
end

return Outside
