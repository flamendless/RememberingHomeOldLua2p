local maps = {
	--map_wasd
	{
		a = "left",
		d = "right",
		w = "up",
		s = "down",
		e = "interact",
		q = "cancel",
		t = "inventory",
		f = "flashlight",
		g = "lighter",
		lshift = "run_mod",
		rshift = "run_mod",
		p = "pause",
	},
	--map_arrows
	{
		left = "left",
		right = "right",
		up = "up",
		down = "down",
		z = "interact",
		x = "cancel",
		c = "inventory",
		f = "flashlight",
		g = "lighter",
		lshift = "run_mod",
		rshift = "run_mod",
		p = "pause",
	},
}

local scancodes = {}
for i, t in ipairs(maps) do
	scancodes[i] = {}
	for k, v in pairs(t) do
		local sc = love.keyboard.getScancodeFromKey(k)
		scancodes[i][sc] = v
	end
end
maps = scancodes

local Inputs = {
	map = maps[1],
	rev_map = {},
	rev_maps = {},
	previous = {},
	current = {},
	hold_timers = {},
	default_hold_threshold = 0.15,
}
local map_names = { "WASD", "Arrows" }

if DEV then
	Inputs.dev_map = {
		m = "play",
		down = "camera_down",
		up = "camera_up",
		left = "camera_left",
		right = "camera_right",
	}
end

function Inputs.init(key_map)
	if key_map then
		assert(type(key_map) == "number", key_map)
	end
	local n = key_map or Settings.current.key_map
	assert(maps[n], n)
	Inputs.map = maps[n]

	if DEV then
		tablex.overlay(Inputs.map, Inputs.dev_map)
	end

	tablex.clear(Inputs.previous)
	tablex.clear(Inputs.current)
	tablex.clear(Inputs.rev_map)
	for k, v in pairs(Inputs.map) do
		Inputs.previous[v] = false
		Inputs.current[v] = false
		Inputs.rev_map[v] = k
	end

	for i, map in ipairs(maps) do
		Inputs.rev_maps[i] = {}
		for k, v in pairs(map) do
			Inputs.rev_maps[i][v] = k
		end
	end
end

function Inputs.pressed(key)
	assert(type(key) == "string", key)
	assert(Inputs.current[key] ~= nil, key)
	return Inputs.current[key] and not Inputs.previous[key]
end

function Inputs.released(key)
	assert(type(key) == "string", key)
	assert(Inputs.current[key] ~= nil, key)
	return not Inputs.current[key] and Inputs.previous[key]
end

function Inputs.down(key)
	assert(type(key) == "string", key)
	assert(Inputs.current[key] ~= nil, key)
	return Inputs.current[key]
end

function Inputs.held(key, threshold)
	assert(type(key) == "string", key)
	assert(Inputs.current[key] ~= nil, key)
	if not threshold then
		threshold = Inputs.default_hold_threshold
	end
	return Inputs.current[key] and (Inputs.hold_timers[key] or 0) >= threshold
end

function Inputs.keypressed(_, scancode)
	assert(type(scancode) == "string", scancode)
	if not Inputs.map[scancode] then
		return
	end

	if Slab.IsAnyInputFocused() then
		return
	end

	Inputs.current[Inputs.map[scancode]] = true
end

function Inputs.keyreleased(_, scancode)
	assert(type(scancode) == "string", scancode)
	if not Inputs.map[scancode] then
		return
	end

	if Slab.IsAnyInputFocused() then
		return
	end

	Inputs.current[Inputs.map[scancode]] = false
end

function Inputs.update(dt)
	for k, v in pairs(Inputs.current) do
		Inputs.previous[k] = v
		if v then
			Inputs.hold_timers[k] = (Inputs.hold_timers[k] or 0) + dt
		else
			Inputs.hold_timers[k] = 0
		end
	end
end

function Inputs.flush()
	for k in pairs(Inputs.current) do
		Inputs.previous[k] = false
		Inputs.current[k] = false
		Inputs.hold_timers[k] = 0
	end
end

function Inputs.get_map_keys()
	return tablex.copy(maps)
end

function Inputs.get_map_names()
	return tablex.copy(map_names)
end

function Inputs.get_current_map_name()
	return map_names[Settings.current.key_map]
end

return Inputs
