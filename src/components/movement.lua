Concord.component("movement")

Concord.component("random_walk", function(c, dir, distance, x, y)
	assert((type(dir) == "number" and (dir == -1 or dir == 1)), dir)
	assert((type(distance) == "number" and distance > 0), distance)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	c.dir = dir
	c.distance = distance
	c.orig_pos = vec2(x, y)
end)
