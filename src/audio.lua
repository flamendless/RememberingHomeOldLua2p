local Audio = {
	volume = 100,
}

function Audio.init()
	Audio.set_volume(Settings.current.volume)
	Audio.set_mute(Settings.current.muted)
end

function Audio.set_volume(volume)
	assert(type(volume) == "number", volume)
	Audio.volume = volume
	love.audio.setVolume(Audio.volume / 100)
end

function Audio.set_mute(mute)
	assert(type(mute) == "boolean", mute)
	if mute then
		love.audio.setVolume(0)
	else
		love.audio.setVolume(Audio.volume / 100)
	end
end

return Audio
