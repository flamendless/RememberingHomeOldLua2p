--TODO: (Brandon) this is unused, maybe remove completely?
local Notification = Concord.system({
	pool = { "notification" },
})

function Notification:init(world)
	self.world = world
end

function Notification:speech_bubble_update(_, e)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not e.notification then
		error("Assertion failed: e.notification")
	end
	if not (e.id.value == "speech_bubble") then
		error("got " .. e.id.value)
	end
	local anim8 = e.animation.anim8
	local data = e.animation_data
	if e.current_frame.value == data.n_frames then
		anim8:gotoFrame(4)
	end
end

function Notification:create_speech_bubble(e_player)
	if not (e_player.__isEntity and e_player.player) then
		error("Assertion failed: e_player.__isEntity and e_player.player")
	end
	local pos = e_player.pos
	local e = Concord.entity(self.world):assemble(Assemblages.ui.speech_bubble, e_player, pos.x, pos.y)
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
