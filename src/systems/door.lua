local Door = Concord.system({
	pool = { "id", "is_door" },
})

function Door:init(world)
	self.world = world
end

function Door:on_interact_door(e_player, e_door)
	assert((e_player.__isEntity and e_player.player), e_player)
	assert((e_door.__isEntity and e_door.is_door), e_door)
	self.world:emit("toggle_component", e_player, "can_move", false)
	self.world:emit("toggle_component", e_player, "can_interact", false)
	self.world:emit("anim_open_door", e_player)

	local door_id = e_door.id.value
	local next_room = Data.Doors.get_next(GameStates.current_id, door_id)
	self.world:emit("switch_state", next_room, 1.5, 0.5)
end

return Door
