local Light = {}

function Light.point(e, x, y, z, size, diffuse, dir)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not (type(x) == "number") then
		error('Assertion failed: type(x) == "number"')
	end
	if not (type(y) == "number") then
		error('Assertion failed: type(y) == "number"')
	end
	if not (type(z) == "number") then
		error('Assertion failed: type(z) == "number"')
	end
	if not (type(size) == "number") then
		error('Assertion failed: type(size) == "number"')
	end
	if not (type(diffuse) == "table") then
		error('Assertion failed: type(diffuse) == "table"')
	end
	if dir then
		if not (type(dir) == "number") then
			error('Assertion failed: type(dir) == "number"')
		end
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
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not (type(x) == "number") then
		error('Assertion failed: type(x) == "number"')
	end
	if not (type(y) == "number") then
		error('Assertion failed: type(y) == "number"')
	end
	if not (type(z) == "number") then
		error('Assertion failed: type(z) == "number"')
	end
	if not (type(dir) == "table") then
		error('Assertion failed: type(dir) == "table"')
	end
	if not (type(size) == "number") then
		error('Assertion failed: type(size) == "number"')
	end
	if not (type(diffuse) == "table") then
		error('Assertion failed: type(diffuse) == "table"')
	end

	e:give("id", "spot_light")
		:give("pos", x, y, z)
		:give("point_light", size)
		:give("diffuse", diffuse)
		:give("light_dir", dir)
end

function Light.fl_spot(e, e_player, sync_data)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not e_player.__isEntity then
		error("Assertion failed: e_player.__isEntity")
	end
	if not (type(sync_data) == "table") then
		error('Assertion failed: type(sync_data) == "table"')
	end

	e:assemble(Light.spot, 0, 0, 7, { 1, 0, 0, 0.85 }, 164, { 4, 4, 4 })
		:give("id", "flashlight_fl")
		:give("flashlight")
		:give("anim_sync_with", e_player)
		:give("anim_sync_data", "fl_spawn_offset", { "x", "y", "dy" }, sync_data)
end

function Light.fl_start(e) --near the player
	e:assemble(Light.point, 0, 0, 7, 32, {1, 1, 1})
		:give("id", "flashlight_start_pl")
		:give("flashlight_light")
end

function Light.fl_end(e) --away from the player
	e:assemble(Light.point, 0, 0, 7, 64, { 1.3, 1.3, 1.3 })
		:give("id", "flashlight_end_pl")
		:give("flashlight_light")
end

return Light
