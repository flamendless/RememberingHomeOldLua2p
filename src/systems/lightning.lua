local Lightning = Concord.system()

function Lightning:init(world)
	self.world = world
end

function Lightning:lightning_flash(opts)
	opts = opts or {}
	local dl = self.world:getSystem(ECS.get_system_class("deferred_lighting"))
	if not dl or not dl.ambiance then
		return
	end

	local ambient = { unpack(dl.ambiance) }
	local flash = opts.flash or 1.0
	local peak = {
		math.min(1, ambient[1] + flash),
		math.min(1, ambient[2] + flash),
		math.min(1, ambient[3] + flash),
		ambient[4] or 1,
	}

	local restore = dl.orig_ambiance or ambient
	Flux.to(ambient, opts.flash_in or 0.08, {
		[1] = peak[1],
		[2] = peak[2],
		[3] = peak[3],
	}):onupdate(function()
		self.world:emit("set_ambiance", ambient)
	end):oncomplete(function()
		Flux.to(ambient, opts.flash_out or 0.4, {
			[1] = restore[1],
			[2] = restore[2],
			[3] = restore[3],
		}):onupdate(function()
			self.world:emit("set_ambiance", ambient)
		end)
	end)

	self.world:emit("play_sound_on_player", Enums.sfx.static, { volume = opts.volume or 0.2 })

	if opts.glitch then
		self.world:emit("ev_pp_invoke", Enums.shaders.glitch, "do_random_glitch")
		GameStates.after(opts.glitch_dur or 0.15, function()
			self.world:emit("ev_pp_invoke", Enums.shaders.glitch, "reset_glitch")
		end)
	end
end

return Lightning
