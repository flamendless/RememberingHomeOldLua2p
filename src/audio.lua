local Audio = {
	volume = 100,
}

function Audio.init()
	Audio.set_volume(Settings.current.volume)
	Audio.set_mute(Settings.current.muted)
end

function Audio.set_volume(volume)
	if type(volume) ~= "number" then
		error('Assertion failed: type(volume) == "number"')
	end
	Audio.volume = volume
	love.audio.setVolume(Audio.volume / 100)
end

function Audio.set_mute(mute)
	if type(mute) ~= "boolean" then
		error('Assertion failed: type(mute) == "boolean"')
	end
	if mute then
		love.audio.setVolume(0)
	else
		love.audio.setVolume(Audio.volume / 100)
	end
end

return Audio
