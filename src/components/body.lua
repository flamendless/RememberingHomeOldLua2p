local Concord = require("modules.concord.concord")

Concord.component("can_move")
Concord.component("can_run")
Concord.component("can_open_door")
Concord.component("can_interact")

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
end)

Concord.component("prev_can", function(c, e_player)
	if not e_player.__isEntity then
		error("Assertion failed: e_player.__isEntity")
	end
	c.value = {
		move = e_player.can_move,
		run = e_player.can_run,
		interact = e_player.can_interact,
		open_door = e_player.can_open_door,
	}
end)
