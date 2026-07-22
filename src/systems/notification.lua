--TODO: (Brandon) this is unused, maybe remove completely?
local Notification = Concord.system({
	pool = { "notification" },
})

function Notification:init(world)
	self.world = world
end

function Notification:speech_bubble_update(_, e)
	assert(e.__isEntity, e)
	assert(e.notification, e)
	assert(e.id.value == "speech_bubble", "got " .. e.id.value)
	local data = e.animation_data
	if e.current_frame.value == data.n_frames then
		local anim8 = e.animation.anim8
		anim8:gotoFrame(4)
	end
end

function Notification:create_speech_bubble(e_player)
	assert((e_player.__isEntity and e_player.player), e_player)
	local pos = e_player.pos
	local _ = Concord.entity(self.world):assemble(Assemblages.ui.speech_bubble, e_player, pos.x, pos.y)
end

function Notification:remove_speech_bubble()
	for _, e in ipairs(self.pool) do
		local n_id = e.notification.value
		if n_id == "speech_bubble" then
			e:destroy()
		end
	end
end

return Notification
