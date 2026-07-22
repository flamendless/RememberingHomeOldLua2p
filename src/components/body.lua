

Concord.component("can_move")
Concord.component("can_run")
Concord.component("can_open_door")
Concord.component("can_interact")

Concord.component("can_move_left_only")
Concord.component("can_move_right_only")

Concord.component("is_running", function(c)
	c.value = false
end)

Concord.component("is_interacting", function(c)
	c.value = false
end)

Concord.component("body", function(c)
	c.dx = 0
	c.dir = 1
	c.vel_x = 0
	c.vel_y = 0
	c.vel = vec2()
end)

Concord.component("prev_can", function(c, e_player)
	assert(e_player.__isEntity, e_player)
	c.value = {
		move = e_player.can_move,
		run = e_player.can_run,
		interact = e_player.can_interact,
		open_door = e_player.can_open_door,
	}
end)
