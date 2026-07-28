local Light = {}

function Light.point(e, x, y, z, size, diffuse, dir)
	assert(e.__isEntity, e)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	assert(type(z) == "number", z)
	assert(type(size) == "number", size)
	assert(type(diffuse) == "table", diffuse)
	if dir then
		assert(type(dir) == "number", dir)
	end

	e:give("id", "point_light")
		:give("pos", x, y, z)
		:give("point_light", size)
		:give("diffuse", diffuse)

	if dir then
		e:give("light_dir", dir)
	end
end

function Light.spot(e, x, y, z, dir, size, diffuse)
	assert(e.__isEntity, e)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	assert(type(z) == "number", z)
	assert(type(dir) == "table", dir)
	assert(type(size) == "number", size)
	assert(type(diffuse) == "table", diffuse)

	e:give("id", "spot_light")
		:give("pos", x, y, z)
		:give("point_light", size)
		:give("diffuse", diffuse)
		:give("light_dir", dir)
end

function Light.fl_spot(e, e_player, sync_data)
	assert(e.__isEntity, e)
	assert(e_player.__isEntity, e_player)
	assert(type(sync_data) == "table", sync_data)

	local p = 16
	e:assemble(Light.spot, 0, 0, 1, { 1, 0, 0, 0.85 }, 164, { p, p, p })
		:give("id", "flashlight_fl")
		:give("flashlight")
		:give("anim_sync_with", e_player)
		:give("anim_sync_data", "fl_spawn_offset", { "x", "y", "dy" }, sync_data)
end

function Light.fl_start(e) --near the player
	local p = 1
	e:assemble(Light.point, 0, 0, 7, 32, { p, p, p })
		:give("id", "flashlight_start_pl")
		:give("flashlight_light")
end

function Light.fl_end(e) --away from the player
	local p = 1.3
	e:assemble(Light.point, 0, 0, 7, 64, { p, p, p })
		:give("id", "flashlight_end_pl")
		:give("flashlight_light")
end

function Light.flame_stack(e, x, y, z, power, diffuse_key, max_health, consumption_rate, id)
	assert(e.__isEntity, e)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	assert(type(z) == "number", z)
	assert(type(power) == "number", power)
	assert(type(diffuse_key) == "string", diffuse_key)
	assert(type(max_health) == "number", max_health)
	assert(type(consumption_rate) == "number", consumption_rate)
	assert(type(id) == "string", id)

	e:assemble(Light.point, x, y, z, power, Palette.get_diffuse(diffuse_key))
		:give("id", id)
		:give("flame")
		:give("flame_health", max_health, consumption_rate)
		:give("flame_fuel_drain")
		:give("flame_flicker")
		:give("flame_windable")
		:give("flame_anchor", x, y, 1)
		:give("light_disabled")

	return e
end

function Light.lighter_flame(e, power)
	assert(e.__isEntity, e)
	assert(type(power) == "number", power)

	Light.flame_stack(e, 0, 0, 9, power, "lighter_flame", 100, 0.15, "lighter_flame_pl")
		:give("lighter_flame", power)
		:give("flame_fuel_tiers", {
			{
				id = Enums.lighter_fuel_tier.full,
				min_ratio = 0.75,
				color = Palette.colors.lighter_flame_full,
				strength_cap = 1.0,
			},
			{
				id = Enums.lighter_fuel_tier.medium,
				min_ratio = 0.50,
				color = Palette.colors.lighter_flame_medium,
				strength_cap = 0.90,
			},
			{
				id = Enums.lighter_fuel_tier.low,
				min_ratio = 0.25,
				color = Palette.colors.lighter_flame_low,
				strength_cap = 0.72,
			},
			{
				id = Enums.lighter_fuel_tier.critical,
				min_ratio = 0.00,
				color = Palette.colors.lighter_flame_critical,
				strength_cap = 0.28,
			},
		})
end

function Light.candle_flame(e, x, y, power)
	assert(e.__isEntity, e)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	power = power or 14

	Light.flame_stack(e, x, y, 9, power, "candle_flame", 100, 0.08, "candle_flame_pl")
end

return Light
