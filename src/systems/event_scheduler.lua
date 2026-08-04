local EventScheduler = Concord.system()

local function pick_weighted(events)
	local total = 0
	for _, ev in ipairs(events) do
		total = total + (ev.weight or 1)
	end
	if total <= 0 then
		return nil
	end
	local roll = love.math.random() * total
	for _, ev in ipairs(events) do
		roll = roll - (ev.weight or 1)
		if roll <= 0 then
			return ev
		end
	end
	return events[#events]
end

function EventScheduler:init(world)
	self.world = world
	self.scene_id = nil
	self.config = nil
	self.ambient_timer = 0
	self.sequence = nil
end

function EventScheduler:clear_state()
	self.config = nil
	self.ambient_timer = 0
	self.sequence = nil
	self.world:setResource("event_emitters", nil)
end

function EventScheduler:sequence_done(key)
	if not Save.data.events then
		Save.data.events = {}
	end
	Save.data.events[key] = true
	Save.overwrite()
end

function EventScheduler:should_run_sequence(seq)
	if not seq.once then
		return true
	end
	local key = seq.save_key or (self.scene_id .. "_sequence")
	if Save.data.events and Save.data.events[key] then
		return false
	end
	return true
end

function EventScheduler:start_sequence(seq)
	self.sequence = {
		steps = seq.steps,
		index = 1,
		timer = seq.steps[1].delay or 0,
		save_key = seq.save_key or (self.scene_id .. "_sequence"),
		once = seq.once,
	}
end

function EventScheduler:setup_events(scene_id)
	assert:type(scene_id, "string")
	self:clear_state()
	self.scene_id = scene_id

	local config = Data.RoomEvents[scene_id]
	if not config then
		return
	end
	self.config = config

	local emitters = config.ceiling_emitters or config.emitters
	if emitters then
		local room_size = self.world:getResource("room_size")
		local room_w = room_size and room_size.width
		local emitter_meta = {}
		for _, t in ipairs(emitters) do
			local defaults = Data.RoomBounds.emitter_rect(scene_id, room_w, {
				h = t.h,
				w = t.w,
				x = t.x,
			})
			local x = t.x or defaults.x
			local y = t.y or defaults.y
			local w = t.w or defaults.w
			local h = t.h or defaults.h
			Concord.entity(self.world):assemble(Assemblages.Dust.emitter, t.key, x, y, w, h, t.dust)
			emitter_meta[#emitter_meta + 1] = {
				key = t.key,
				x = x,
				y = y,
				w = w,
				h = h,
				on_walk = t.on_walk,
			}
		end
		self.world:setResource("event_emitters", emitter_meta)
	end

	if config.sequence and config.sequence.steps and #config.sequence.steps > 0 then
		if self:should_run_sequence(config.sequence) then
			self:start_sequence(config.sequence)
		end
	end

	if config.ambient and config.ambient.enabled then
		local interval = config.ambient.interval or { min = 10, max = 20 }
		self.ambient_timer = love.math.random(interval.min, interval.max)
	end
end

function EventScheduler:should_run()
	local pause = self.world:getSystem(ECS.get_system_class("pause"))
	if pause and pause.is_paused then
		return false
	end

	local e_player = self.world:getResource("e_player")
	if e_player and e_player:has("hidden") then
		return false
	end

	return true
end

function EventScheduler:fire_event(def)
	local event_type = def.type
	local opts = def.opts or {}
	assert(Enums.event[event_type], event_type)

	if event_type == Enums.event.lightning then
		self.world:emit("lightning_flash", opts)
	elseif event_type == Enums.event.sound then
		self.world:emit("play_event_sound", opts)
	elseif event_type == Enums.event.dust_ceiling then
		assert:type(opts.key, "string")
		self.world:emit("trigger_dust_burst", Enums.dust_kind.emitter, opts.key)
	elseif event_type == Enums.event.dust_foot then
		assert:type(opts.key, "string")
		self.world:emit("trigger_dust_burst", Enums.dust_kind.foot, opts.key)
	elseif event_type == Enums.event.light_wind_pass then
		self.world:emit("wind_pass_lights", opts)
	end
end

function EventScheduler:update_ambient(dt)
	local ambient = self.config and self.config.ambient
	if not ambient or not ambient.enabled or not ambient.events then
		return
	end

	self.ambient_timer = self.ambient_timer - dt
	if self.ambient_timer > 0 then
		return
	end

	local picked = pick_weighted(ambient.events)
	if picked then
		self:fire_event(picked)
	end

	local interval = ambient.interval or { min = 10, max = 20 }
	self.ambient_timer = love.math.random(interval.min, interval.max)
end

function EventScheduler:update_sequence(dt)
	if not self.sequence then
		return
	end

	local seq = self.sequence
	seq.timer = seq.timer - dt
	if seq.timer > 0 then
		return
	end

	local step = seq.steps[seq.index]
	if step then
		self:fire_event(step)
	end

	seq.index = seq.index + 1
	local next_step = seq.steps[seq.index]
	if not next_step then
		if seq.once then
			self:sequence_done(seq.save_key)
		end
		self.sequence = nil
		return
	end

	seq.timer = next_step.delay or 0
end

function EventScheduler:update(dt)
	if not self.config then
		return
	end
	if not self:should_run() then
		return
	end

	self:update_sequence(dt)
	self:update_ambient(dt)
end

if DEV then
	local DEBUG_EVENT_OPTS = {
		[Enums.event.sound] = { source = "static", volume = 0.3, on_player = true },
		[Enums.event.dust_ceiling] = { key = "ceiling_main" },
		[Enums.event.dust_foot] = { key = "player" },
		[Enums.event.light_wind_pass] = {
			direction = "left",
			mode = "flicker",
			stagger = 0.08,
		},
	}

	function EventScheduler:debug_update(dt)
		if not self.debug_show then
			return
		end

		self.debug_show = Slab.BeginWindow("event_scheduler", {
			Title = "Event Scheduler",
			IsOpen = self.debug_show,
		})

		Slab.Text("Scene: " .. tostring(self.scene_id))
		Slab.Text("Ambient timer: " .. string.format("%.2f", self.ambient_timer))

		if self.sequence then
			Slab.Text("Sequence step: " .. self.sequence.index .. " / " .. #self.sequence.steps)
			Slab.Text("Step timer: " .. string.format("%.2f", self.sequence.timer))
		else
			Slab.Text("Sequence: idle")
		end

		Slab.Separator()
		Slab.Text("Fire event:")

		for _, name in ipairs({
			Enums.event.lightning,
			Enums.event.sound,
			Enums.event.dust_foot,
			Enums.event.dust_ceiling,
			Enums.event.light_wind_pass,
		}) do
			if Slab.Button(name) then
				local opts = DEBUG_EVENT_OPTS[name]
				if opts then
					opts = tablex.copy(opts)
				else
					opts = {}
				end
				self:fire_event({ type = name, opts = opts })
			end
			Slab.SameLine()
		end

		Slab.EndWindow()
	end
end

return EventScheduler
