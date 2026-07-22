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
	e:assemble(Light.spot, 0, 0, 1, { 1, 0, 0, 0.85 }, 164, {p, p, p})
		:give("id", "flashlight_fl")
		:give("flashlight")
		:give("anim_sync_with", e_player)
		:give("anim_sync_data", "fl_spawn_offset", { "x", "y", "dy" }, sync_data)
end

function Light.fl_start(e) --near the player
	local p = 1
	e:assemble(Light.point, 0, 0, 7, 32, {p, p, p})
		:give("id", "flashlight_start_pl")
		:give("flashlight_light")
end

function Light.fl_end(e) --away from the player
	local p = 1.3
	e:assemble(Light.point, 0, 0, 7, 64, {p, p, p})
		:give("id", "flashlight_end_pl")
		:give("flashlight_light")
end

return Light
