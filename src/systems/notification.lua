--TODO: (Brandon) this is unused, maybe remove completely?
local Notification = Concord.system({
	pool = { "notification" },
})

function Notification:init(world)
	self.world = world
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
