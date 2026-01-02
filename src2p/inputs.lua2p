local Settings = require("settings")

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
		lshift = "run_mod",
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
		lshift = "run_mod",
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
}
local map_names = {"WASD", "Arrows"}

!if _DEV then
local Slab = require("modules.slab")
Inputs.dev_map = {
	m = "play",
	k = "camera_down",
	i = "camera_up",
	j = "camera_left",
	l = "camera_right",
}
!end

function Inputs.init(key_map)
	@@sassert(key_map, type(key_map) == "number")
	local n = key_map or Settings.current.key_map
	@@assert(maps[n])
	Inputs.map = maps[n]
	!if _DEV then
	tablex.overlay(Inputs.map, Inputs.dev_map)
	!end
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
	@@assert(type(key) == "string")
	@@assert(Inputs.current[key] ~= nil)
	return Inputs.current[key] and not Inputs.previous[key]
end

function Inputs.released(key)
	@@assert(type(key) == "string")
	@@assert(Inputs.current[key] ~= nil)
	return not Inputs.current[key] and Inputs.previous[key]
end

function Inputs.down(key)
	@@assert(type(key) == "string")
	@@assert(Inputs.current[key] ~= nil)
	return Inputs.current[key]
end

function Inputs.keypressed(_, scancode)
	@@assert(type(scancode) == "string")
	if not Inputs.map[scancode] then return end
	!if _DEV then
	if Slab.IsAnyInputFocused() then return end
	!end
	Inputs.current[Inputs.map[scancode]] = true
end

function Inputs.keyreleased(_, scancode)
	@@assert(type(scancode) == "string")
	if not Inputs.map[scancode] then return end
	!if _DEV then
	if Slab.IsAnyInputFocused() then return end
	!end
	Inputs.current[Inputs.map[scancode]] = false
end

function Inputs.update()
	for k, v in pairs(Inputs.current) do
		Inputs.previous[k] = v
	end
end

function Inputs.flush()
	for k in pairs(Inputs.current) do
		Inputs.previous[k] = false
		Inputs.current[k] = false
	end
end

function Inputs.get_map_keys()
	return tablex.copy(maps)
end

function Inputs.get_map_names()
	return tablex.copy(map_names)
end

function Inputs.get_current_map_name()
	return tablex.copy(map_names[Settings.current.key_map])
end

return Inputs
