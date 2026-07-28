local Audio = {
	volume = 100,
}

function Audio.init()
	Audio.set_volume(Settings.current.volume)
	Audio.set_mute(Settings.current.muted)
end

function Audio.set_volume(volume)
	assert:type(volume, "number")
	Audio.volume = volume
	love.audio.setVolume(Audio.volume / 100)
end

function Audio.set_mute(mute)
	assert:type(mute, "boolean")
	if mute then
		love.audio.setVolume(0)
	else
		love.audio.setVolume(Audio.volume / 100)
	end
end

function Audio.init_spatial()
	love.audio.setDistanceModel("inverseclamped")
end

function Audio.to_audio_pos(x, y)
	return x, 0, y
end

function Audio.set_listener(x, y, dir)
	local ax, ay, az = Audio.to_audio_pos(x, y)
	love.audio.setPosition(ax, ay, az)
	local fx = dir or 1
	love.audio.setOrientation(fx, 0, 0, 0, 1, 0)
end

function Audio.resolve_source(source_or_id)
	if type(source_or_id) == "userdata" and source_or_id:type() == "Source" then
		return source_or_id
	end
	if type(source_or_id) == "string" and Resources.data.sources then
		return Resources.data.sources[source_or_id]
	end
	return nil
end

function Audio.play_positional(template, x, y, opts)
	opts = opts or {}
	if not template then
		return nil
	end

	local source = template:clone()
	source:setRelative(opts.relative or false)
	source:setVolume(opts.volume or 1)
	if opts.loop then
		source:setLooping(true)
	end
	if opts.ref_distance and opts.max_distance then
		source:setAttenuationDistances(opts.ref_distance, opts.max_distance)
	end

	local ax, ay, az = Audio.to_audio_pos(x, y)
	source:setPosition(ax, ay, az)
	source:play()
	return source
end

function Audio.stop_source(source)
	if source then
		source:stop()
		source:release()
	end
end

return Audio
