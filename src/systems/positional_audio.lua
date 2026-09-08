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
	if DEV or TEST.mode then
		self:track_debug_sound(se.source, se.active, se)
	end
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
	if DEV or TEST.mode then
		self:update_debug_entries(dt)
	end
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
	assert:type(x, "number")
	assert:type(y, "number")
	opts = opts or {}

	local template = Audio.resolve_source(source)
	local active = Audio.play_positional(template, x, y, opts)
	if active and not opts.loop then
		table.insert(self.oneshots, active)
	end
	if DEV or TEST.mode then
		self:track_debug_sound(source, active, opts)
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
		if DEV or TEST.mode then
			self:track_debug_sound(source, active, opts)
		end
	end
end

function PositionalAudio:play_sound_on_player(source, opts)
	local e_player = self:get_player()
	if not e_player then
		return
	end
	self:play_sound_on_entity(e_player, source, opts)
end

function PositionalAudio:resolve_event_source(source)
	if type(source) == "string" and Enums.sfx[source] then
		return Enums.sfx[source]
	end
	return source
end

function PositionalAudio:play_event_sound(opts)
	opts = opts or {}
	local source = self:resolve_event_source(opts.source)
	if not source then
		Log.warn("play_event_sound: no source", opts.source)
		return
	end

	if opts.on_player then
		self:play_sound_on_player(source, opts)
	elseif opts.x and opts.y then
		self:play_positional_sound(source, opts.x, opts.y, opts)
	else
		local e_player = self:get_player()
		if e_player then
			self:play_sound_on_entity(e_player, source, opts)
		end
	end
end

function PositionalAudio:stop_sound_on_entity(e)
	assert(e.__isEntity, e)
	if e:has("sound_emitter") then
		self:stop_emitter(e)
	end
end

if DEV or TEST.mode then
	local DEBUG_SOUND_PRUNE = 1
	local DEBUG_SOUND_LINE_H = 16
	local DEBUG_SOUND_MARGIN = 8
	local DEBUG_SOUND_ICON = 8

	local function resolve_debug_sound_name(source)
		if type(source) == "string" then
			return source
		end
		return "unknown"
	end

	local orig_init = PositionalAudio.init
	function PositionalAudio:init(world)
		orig_init(self, world)
		self.debug_entries = {}
	end

	function PositionalAudio:track_debug_sound(source, active, opts)
		opts = opts or {}
		if opts.relative then
			return
		end

		self.debug_entries[#self.debug_entries + 1] = {
			name = resolve_debug_sound_name(source),
			active = active,
			stopped = active == nil,
			stopped_age = 0,
		}
	end

	function PositionalAudio:update_debug_entries(dt)
		for i = #self.debug_entries, 1, -1 do
			local entry = self.debug_entries[i]
			local active = entry.active
			if active and active:isPlaying() then
				entry.stopped = false
				entry.stopped_age = 0
			else
				entry.stopped = true
				entry.stopped_age = entry.stopped_age + dt
				if entry.stopped_age >= DEBUG_SOUND_PRUNE then
					table.remove(self.debug_entries, i)
				end
			end
		end
	end

	function PositionalAudio:draw_debug_overlay()
		if #self.debug_entries == 0 then
			return
		end

		local font = love.graphics.getFont()
		local line_h = math.max(DEBUG_SOUND_LINE_H, font:getHeight())
		local _, wh = love.graphics.getDimensions()
		local y = wh - DEBUG_SOUND_MARGIN - line_h
		local icon_gap = 4
		local r, g, b, a = love.graphics.getColor()

		love.graphics.push()
		love.graphics.origin()
		love.graphics.setColor(1, 0, 0, 1)

		for i = #self.debug_entries, 1, -1 do
			local entry = self.debug_entries[i]
			local icon_x = DEBUG_SOUND_MARGIN
			local icon_y = y + (line_h - DEBUG_SOUND_ICON) * 0.5
			local text_x = icon_x + DEBUG_SOUND_ICON + icon_gap

			if entry.stopped then
				love.graphics.rectangle("fill", icon_x, icon_y, DEBUG_SOUND_ICON, DEBUG_SOUND_ICON)
			else
				local half = DEBUG_SOUND_ICON * 0.5
				love.graphics.polygon("fill",
					icon_x + DEBUG_SOUND_ICON, icon_y + half,
					icon_x, icon_y,
					icon_x, icon_y + DEBUG_SOUND_ICON
				)
			end

			love.graphics.print(entry.name, text_x, y)
			y = y - line_h
		end

		love.graphics.setColor(r, g, b, a)
		love.graphics.pop()
	end
end

if DEV then
	local debug_selected_sfx = Enums.sfx.car_door_hit
	local debug_sfx_names = {}
	for name in pairs(Enums.sfx) do
		debug_sfx_names[#debug_sfx_names + 1] = name
	end
	table.sort(debug_sfx_names)

	function PositionalAudio:play_test_sound()
		local e_player = self:get_player()
		if not e_player then
			return
		end
		self:play_sound_on_player(debug_selected_sfx)
	end

	function PositionalAudio:debug_update(dt)
		if not self.debug_show then
			return
		end

		self.debug_show = Slab.BeginWindow("positional_audio", {
			Title = "PositionalAudio",
			IsOpen = self.debug_show,
		})

		if Slab.BeginComboBox("cb_positional_audio_sfx", { Selected = debug_selected_sfx }) then
			for _, name in ipairs(debug_sfx_names) do
				if Slab.TextSelectable(name) then
					debug_selected_sfx = name
					break
				end
			end
			Slab.EndComboBox()
		end

		Slab.SameLine()
		if Slab.Button("Test sound") then
			self:play_test_sound()
		end

		if not self:get_player() then
			Slab.Text("No player (sound plays on player)")
		end

		Slab.EndWindow()
	end
end

return PositionalAudio
