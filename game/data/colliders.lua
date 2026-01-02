local Colliders = {}

Colliders.player = {
	w = 24, h = 64,
}

Colliders.enemy = {
	suit = {
		idle = {w = 14, h = 64, ox = 26},
		walk = {w = 20, h = 64, ox = 22},
	}
}

return Colliders
