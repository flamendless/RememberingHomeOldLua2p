local Concord = require("modules.concord.concord")

Concord.component("movement")

Concord.component("random_walk", function(c, dir, distance, x, y)
	if not (type(dir) == "number" and (dir == -1 or dir == 1)) then
		error('Assertion failed: type(dir) == "number" and (dir == -1 or dir == 1)')
	end
	if not (type(distance) == "number" and distance > 0) then
		error('Assertion failed: type(distance) == "number" and distance > 0')
	end
	if not (type(x) == "number") then
		error('Assertion failed: type(x) == "number"')
	end
	if not (type(y) == "number") then
		error('Assertion failed: type(y) == "number"')
	end
	c.dir = dir
	c.distance = distance
	c.orig_pos = vec2(x, y)
end)
