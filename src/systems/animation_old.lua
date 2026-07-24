local AnimationOld = Concord.system({
	pool = { "animation_old", "animation_data_old" },
	pool_multi = { "multi_animation_data_old", "animation_old" },
	pool_pause = { "animation_old", "animation_data_old", "animation_pause_at_old" },
	pool_change = { "animation_old", "animation_data_old", "change_animation_tag_old" },
})

local EMPTY_FN = function() end

function AnimationOld:setup_animation_data(e, new_tag)
	assert((e.__isEntity and e.animation_old), e)
	assert(type(new_tag) == "string", new_tag)
	if not e.multi_animation_data_old then return end
	local data = e.multi_animation_data_old.data[new_tag]
	if not data then return end
	if data.pause_at then
		local v
		if data.pause_at == Enums.pause_at.first then
			v = "anim_pause_at_start"
		elseif data.pause_at == Enums.pause_at.last then
			v = "anim_pause_at_end"
		end
		e:give("animation_on_loop", v, 0, e)
	end
end

function AnimationOld:setup_on_loop(e, animation)
	assert(animation.__isComponent, animation)
	local on_loop = e.animation_on_loop
	local on_finish = e.animation_on_finish

	if on_loop then
		return function()
			self.world:emit(on_loop.signal, unpack(on_loop.args))
			if on_finish then
				GameStates.after(on_finish.delay, function()
					self.world:emit(on_finish.signal, unpack(on_finish.args))
				end)
				e:remove("animation_on_finish")
			end
		end
	elseif animation.stop_on_last then
		return function()
			animation.anim8:pauseAtEnd()
		end
	end

	return EMPTY_FN
end

function AnimationOld:setup_animation(e, data, on_loop)
	assert(e.__isEntity, e)
	assert(type(data) == "table", data)
	assert(type(on_loop) == "function", on_loop)

	local animation = e.animation_old
	local current_tag = animation.current_tag
	local multi = e.multi_animation_data_old
	local obj_grid, obj_animation

	if not multi then
		obj_grid = Anim8.newGrid(data.frame_width, data.frame_height, data.sheet_width, data.sheet_height)
		obj_animation = Anim8.newAnimation(obj_grid(unpack(data.frames)), data.delay, on_loop)

	else
		local cache = self.cache_multi_animation[e.id.value]
		if cache[current_tag] then
			local cached = cache[current_tag]
			obj_grid = cached.grid
			obj_animation = cached.animation
			obj_animation.onLoop = on_loop
		else
			obj_grid = Anim8.newGrid(data.frame_width, data.frame_height, data.sheet_width, data.sheet_height)
			obj_animation = Anim8.newAnimation(obj_grid(unpack(data.frames)), data.delay, on_loop)
			cache[current_tag] = { grid = obj_grid, animation = obj_animation }
			if data.is_flipped then
				obj_animation:flipH()
			end
		end
	end

	animation.grid = obj_grid
	animation.anim8 = obj_animation

	local current_frame = e.current_frame
	if current_frame then
		current_frame.max = #obj_animation.frames
	end

	local quad, _, _, r, sx, sy, ox, oy = obj_animation:getFrameInfo()

	e:give("sprite", data.resource_id):give("quad", quad)

	if data.is_flipped then
		local transform = e.transform
		if transform then
			ox = ox - transform.ox
			oy = oy - transform.oy
		end
		e:give("quad_transform", r, sx, sy, ox, oy)
	else
		e:remove("quad_transform")
	end

	if data.start_frame then
		obj_animation:gotoFrame(data.start_frame)
	end

	Log.info("setup animation done", "id", e.id.value, current_tag)
end

function AnimationOld:init(world)
	self.world = world
	self.cache_multi_animation = {}

	self.pool.onAdded = function(pool, e)
		local data = e.animation_data_old
		local animation = e.animation_old
		local on_loop = self:setup_on_loop(e, animation)
		self:setup_animation(e, data, on_loop)
	end

	self.pool_multi.onAdded = function(pool, e)
		self.cache_multi_animation[e.id.value] = {}
		local multi = e.multi_animation_data_old
		local animation = e.animation_old
		self:setup_on_loop(e, animation)
		local data = multi.data[multi.first]
		animation.current_tag = multi.first
		e:give("animation_data_old", data)
		Log.trace("added multi_animation_data")
	end

	self.pool_pause.onAdded = function(pool, e)
		local data = e.animation_data_old
		local animation = e.animation_old
		if animation.anim8 == nil then
			local on_loop = self:setup_on_loop(e, animation)
			self:setup_animation(e, data, on_loop)
		end

		local pause_at = e.animation_pause_at_old
		if type(pause_at.at_frame) == "string" then
			if pause_at.at_frame == Enums.pause_at.first then
				animation.anim8:pauseAtStart()
			elseif pause_at.at_frame == Enums.pause_at.last then
				animation.anim8:pauseAtEnd()
			end
		elseif type(pause_at.at_frame) == "number" then
			assert(pause_at.at_frame <= data.n_frames, pause_at.at_frame)
			animation.anim8:gotoFrame(pause_at.at_frame)
			animation.anim8:pause()
		end
	end

	self.pool_pause.onRemoved = function(pool, e)
		local animation = e.animation_old
		animation.anim8:resume()
	end

	self.pool_change.onAdded = function(pool, e)
		local cat = e.change_animation_tag_old
		self:switch_animation_tag(e, cat.new_tag, nil, cat.override)
		local str = string.format("Switched animation tag to: %s, override: %s", cat.new_tag, tostring(cat.override))
		Log.trace(str)
	end
end

function AnimationOld:switch_animation_tag(e, new_tag, base_tag, override)
	assert(e.__isEntity, e)
	assert(type(new_tag) == "string", new_tag)
	if base_tag then
		assert(type(base_tag) == "string", base_tag)
	end
	if override then
		assert(type(override) == "boolean", override)
	end
	self:setup_animation_data(e, new_tag)
	local animation = e.animation_old
	local on_loop = self:setup_on_loop(e, animation)

	if override or (new_tag ~= animation.current_tag) then
		local multi = e.multi_animation_data_old
		if not multi then
			return
		end
		local data = multi.data[new_tag]
		assert(data, data)
		animation.current_tag = new_tag
		e:give("animation_data_old", data)
		self:setup_animation(e, data, on_loop)
		animation.anim8:gotoFrame(1)
		e.animation_old.anim8:resume()
		animation.base_tag = base_tag or new_tag
		e:remove("change_animation_tag_old")
	end

	self.world:emit("update_collider", e)
end

function AnimationOld:update(dt)
	for _, e in ipairs(self.pool) do
		local animation = e.animation_old
		local anim8 = animation and animation.anim8
		local entity_dt = dt
		local dt_multiplier = e.dt_multiplier
		if dt_multiplier then
			entity_dt = dt * dt_multiplier.mul
		end

		animation.is_playing = anim8.status == Enums.anim8_status.playing
		if animation.is_playing then
			local stop = e.animation_stop_old
			if stop then
				anim8[stop.event](animation.anim8)

				local on_finish = e.animation_on_finish
				if on_finish then
					GameStates.after(on_finish.delay, function()
						self.world:emit(on_finish.signal, unpack(on_finish.args))
					end)
					Log.info("animation on finish done")
				end
			end

			anim8:update(entity_dt)

			local current_frame = e.current_frame
			if current_frame then
				current_frame.value = anim8.position
			end

			local on_update = e.animation_on_update
			if on_update then
				self.world:emit(on_update.signal, entity_dt, e, unpack(on_update.args))
			end
		end

		e.quad.quad = anim8:getFrameInfo()
	end
end

function AnimationOld:anim_pause_at_start(e, signal)
	assert((e.__isEntity and e.animation_old), e)
	if signal then
		assert(type(signal) == "string", signal)
	end
	local anim = e.animation_old
	anim.anim8:pauseAtStart()
	if signal then
		self.world:emit(signal, e)
	end
end

function AnimationOld:anim_pause_at_end(e, signal)
	assert((e.__isEntity and e.animation_old), e)
	if signal then
		assert(type(signal) == "string", signal)
	end
	local anim = e.animation_old
	anim.anim8:pauseAtEnd()
	if signal then
		self.world:emit(signal, e)
	end
end

function AnimationOld:anim_loop_over_to(e, frame)
	assert(e.__isEntity, e)
	assert(type(frame) == "number" and frame > 0, frame)
	local anim = e.animation_old
	anim.anim8:gotoFrame(frame)
end

if DEV then
	local selected
	local selected_e
	local selected_anim
	local opt_slider = {
		ReturnOnText = false,
		NumbersOnly = true,
		Precision = 0,
	}

	function Animation:debug_update(dt)
		if not self.debug_show then
			DevTools.debug_anim.tag = nil
			return
		end
		self.debug_show = Slab.BeginWindow("animation_old", {
			Title = "MultiAnimation",
			IsOpen = self.debug_show,
		})

		if Slab.BeginComboBox("cb_e", { Selected = selected }) then
			for _, e in ipairs(self.pool) do
				local id = e.id.value
				if Slab.TextSelectable(id) then
					selected = id
					selected_e = e
					break
				end
			end
			Slab.EndComboBox()
		end

		if selected_e and selected_e.multi_animation_data_old then
			local multi_anim_data = selected_e.multi_animation_data_old.data

			Slab.Text("By tag")
			Slab.SameLine()
			if Slab.BeginComboBox("cb_anim", { Selected = selected_anim }) then
				for tag in pairs(multi_anim_data) do
					if Slab.TextSelectable(tag) then
						selected_anim = tag
						local cache = self.cache_multi_animation[selected_e.id.value]
						if cache then
							cache[tag] = nil
						end
						self:switch_animation_tag(selected_e, tag, nil, true)
						DevTools.debug_anim.tag = tag
						break
					end
				end
				Slab.EndComboBox()
			end

			Slab.Text("By signal")
			Slab.SameLine()
			if Slab.BeginComboBox("cb_ev", { Selected = selected_anim }) then
				for tag in pairs(multi_anim_data) do
					local ev = "anim_" .. tag
					if Slab.TextSelectable(ev) then
						selected_anim = tag
						local cache = self.cache_multi_animation[selected_e.id.value]
						if cache then
							cache[tag] = nil
						end
						self.world:emit(ev, selected_e)
						DevTools.debug_anim.tag = tag
						break
					end
				end
				Slab.EndComboBox()
			end

			local animation = selected_e.animation_old
			if selected_anim then
				Slab.Text("Frame")
				Slab.SameLine()
				local cur_frame = selected_e.current_frame
				local max = multi_anim_data[selected_anim].n_frames
				local anim_pause_at = selected_e.animation_pause_at_old
				local anim_stop = selected_e.animation_stop_old

				if Slab.InputNumberSlider("frame", cur_frame.value, 1, max, opt_slider) then
					local v = Slab.GetInputNumber()
					animation.anim8:gotoFrame(v)
					if not anim_pause_at and not anim_stop then
						cur_frame.value = v
					end
				end

				local anim_loop = selected_e.animation_old.stop_on_last
				local cat = selected_e.change_animation_tag_old

				Slab.CheckBox(anim_pause_at, "PauseAt")
				Slab.CheckBox(anim_stop, "Stop")
				Slab.CheckBox(anim_loop, "OnLoop")
				Slab.CheckBox(cat, "ChangeAnimTag")
			end

			Slab.Text("Status: " .. animation.anim8.status)
		end

		Slab.EndWindow()
	end
end

return AnimationOld
