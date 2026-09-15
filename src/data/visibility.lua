local Visibility = {}

Visibility.defaults = {
	width = 48,
	height = 16,
	x_offset = 0,
	y_offset = -12,
	diffuse_key = "player_ambient_light",
}

Visibility.dark_room = tablex.copy(Visibility.defaults)
Visibility.shed = tablex.copy(Visibility.defaults)

return Visibility
