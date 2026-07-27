Concord.component("audio_listener")

Concord.component("sound_emitter", function(c, source, opts)
	assert(source ~= nil, source)
	c.source = source
	opts = opts or {}
	c.volume = opts.volume or 1
	c.loop = opts.loop or false
	c.ref_distance = opts.ref_distance
	c.max_distance = opts.max_distance
	c.autoplay = opts.autoplay or false
	c.oneshot = opts.oneshot or false
	c.relative = opts.relative or false
	c.active = nil
	c.playing = false
end)
