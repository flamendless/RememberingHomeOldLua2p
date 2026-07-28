local PositionalAudio = Concord.system({
	pool_listener = { "audio_listener", "pos", "body" },
	pool_emitter = { "sound_emitter", "pos" },
})

function PositionalAudio:init(world)
	self.world = world
	self.oneshots = {}
	self.e_player = nil
	Audio.init_spatial()

	self.pool_listener.onAdded = function(_, e)
		self.e_player = e
	end

	self.pool_listener.onRemoved = function(_, e)
		if self.e_player == e then
			self.e_player = nil
		end
	end

	self.pool_emitter.onAdded = function(_, e)
		local se = e:get("sound_emitter")
		if se.autoplay then
			self:start_emitter(e)
		end
	end

	self.pool_emitter.onRemoved = function(_, e)
		self:stop_emitter(e)
	end
end

function PositionalAudio:start_emitter(e)
	local se = e:get("sound_emitter")
	if se.active then
		return
	end

	local template = Audio.resolve_source(se.source)
	if not template then
		return
	end

	local pos = e:get("pos")
	se.active = Audio.play_positional(template, pos.x, pos.y, {
		volume = se.volume,
		loop = se.loop,
		relative = se.relative,
		ref_distance = se.ref_distance,
		max_distance = se.max_distance,
	})
	se.playing = se.active ~= nil
end

function PositionalAudio:stop_emitter(e)
	local se = e:get("sound_emitter")
	if se.active then
		Audio.stop_source(se.active)
		se.active = nil
		se.playing = false
	end
end

function PositionalAudio:cleanup_oneshots()
	for i = #self.oneshots, 1, -1 do
		local source = self.oneshots[i]
		if not source:isPlaying() then
			Audio.stop_source(source)
			table.remove(self.oneshots, i)
		end
	end
end

function PositionalAudio:update(dt)
	local listeners = self.pool_listener
	if #listeners > 0 then
		local e = listeners[1]
		local pos = e:get("pos")
		local body = e:get("body")
		Audio.set_listener(pos.x, pos.y, body.dir)
	end

	for _, e in ipairs(self.pool_emitter) do
		local se = e:get("sound_emitter")
		if se.active then
			local pos = e:get("pos")
			local ax, ay, az = Audio.to_audio_pos(pos.x, pos.y)
			se.active:setPosition(ax, ay, az)
			if se.oneshot and not se.active:isPlaying() then
				Audio.stop_source(se.active)
				se.active = nil
				se.playing = false
			end
		end
	end

	self:cleanup_oneshots()
end

function PositionalAudio:get_player()
	if self.e_player and self.e_player.__isEntity then
		return self.e_player
	end

	local e_player = self.world:getResource("e_player")
	if e_player then
		self.e_player = e_player
	end
	return e_player
end

function PositionalAudio:play_positional_sound(source, x, y, opts)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	opts = opts or {}

	local template = Audio.resolve_source(source)
	local active = Audio.play_positional(template, x, y, opts)
	if active and not opts.loop then
		table.insert(self.oneshots, active)
	end
end

function PositionalAudio:play_sound_on_entity(e, source, opts)
	assert(e.__isEntity, e)
	Log.debug("playing sound", e:get("id").value, source)
	opts = opts or {}

	if opts.persist then
		if e:has("sound_emitter") then
			self:stop_emitter(e)
		end
		e:give("sound_emitter", source, opts)
		if not opts.autoplay then
			self:start_emitter(e)
		end
	else
		local pos = e:get("pos")
		local template = Audio.resolve_source(source)
		local active = Audio.play_positional(template, pos.x, pos.y, opts)
		if active and not opts.loop then
			table.insert(self.oneshots, active)
		end
	end
end

function PositionalAudio:play_sound_on_player(source, opts)
	if not self.e_player then
		return
	end
	self:play_sound_on_entity(self.e_player, source, opts)
end

function PositionalAudio:stop_sound_on_entity(e)
	assert(e.__isEntity, e)
	if e:has("sound_emitter") then
		self:stop_emitter(e)
	end
end

return PositionalAudio
