local Anim = Concord.system({
	pool = { "anim", "pos" },
})

function Anim:init(world)
	self.world = world

	self.pool.onAdded = function(_, e)
		self:refresh_render(e)
	end

	if DEV then
		DevTools.register_slab_component("anim", function(e)
			self:debug_slab(e)
		end)
	end
end

function Anim:refresh_render(e)
	local obj = e.anim.obj
	local clip = obj:current_clip()
	local quad, _, _, r, sx, sy, ox, oy = obj:get_frame_info()

	e:give("sprite", clip.resource_id):give("quad", quad)

	if clip.is_flipped then
		local transform = e.transform
		if transform then
			ox = ox - transform.ox
			oy = oy - transform.oy
		end
		e:give("quad_transform", r, sx, sy, ox, oy)
	else
		e:remove("quad_transform")
	end

	obj.dirty = false
end

function Anim:update(dt)
	for _, e in ipairs(self.pool) do
		local obj = e.anim.obj
		local entity_dt = dt
		local dt_multiplier = e.dt_multiplier
		if dt_multiplier then
			entity_dt = dt * dt_multiplier.mul
		end

		obj:update(entity_dt)

		if obj.dirty then
			self:refresh_render(e)
		end

		if e.quad then
			e.quad.quad = obj:get_quad()
		end

		local current_frame = e.current_frame
		if current_frame then
			current_frame.value = obj.frame
			current_frame.max = obj.frame_max
		end
	end
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

	local function base_tag_for(tag)
		return (tag:gsub("_left$", ""))
	end

	local function sorted_tags(clips)
		local tags = {}
		for tag in pairs(clips) do
			tags[#tags + 1] = tag
		end
		table.sort(tags)
		return tags
	end

	function Anim:debug_play(e, tag)
		local obj = e.anim.obj
		obj:invalidate_tag(tag)
		obj:play(tag, base_tag_for(tag), true)
		self:refresh_render(e)
		if e.quad then
			e.quad.quad = obj:get_quad()
		end
	end

	function Anim:debug_slab(e)
		if not e.anim then return end
		local obj = e.anim.obj
		Slab.Text("tag: " .. (obj.current_tag or ""))
		Slab.Text("base: " .. (obj.base_tag or ""))
		Slab.Text(string.format("frame: %d / %d", obj.frame, obj.frame_max))
		if obj.anim8 then
			Slab.Text("status: " .. obj.anim8.status)
		end
	end

	function Anim:debug_update(dt)
		if not self.debug_show then
			DevTools.debug_anim.tag = nil
			return
		end
		self.debug_show = Slab.BeginWindow("anim", {
			Title = "Anim",
			IsOpen = self.debug_show,
		})

		if Slab.BeginComboBox("anim_cb_e", { Selected = selected }) then
			for _, e in ipairs(self.pool) do
				if e.id then
					local id = e.id.value
					if Slab.TextSelectable(id) then
						selected = id
						selected_e = e
						selected_anim = e.anim.obj.current_tag
						break
					end
				end
			end
			Slab.EndComboBox()
		end

		if selected_e and selected_e.anim then
			local obj = selected_e.anim.obj
			local clips = obj.clips
			local tags = sorted_tags(clips)

			Slab.Text("Tag: " .. obj.current_tag)
			Slab.SameLine()
			Slab.Text("Base: " .. (obj.base_tag or ""))

			Slab.Text("By tag")
			Slab.SameLine()
			if Slab.BeginComboBox("anim_cb_anim", { Selected = selected_anim }) then
				for _, tag in ipairs(tags) do
					if Slab.TextSelectable(tag) then
						selected_anim = tag
						self:debug_play(selected_e, tag)
						DevTools.debug_anim.tag = tag
						break
					end
				end
				Slab.EndComboBox()
			end

			Slab.Text("By signal")
			Slab.SameLine()
			if Slab.BeginComboBox("anim_cb_ev", { Selected = selected_anim }) then
				for _, tag in ipairs(tags) do
					local ev = "anim_" .. tag
					if Slab.TextSelectable(ev) then
						selected_anim = tag
						self.world:emit(ev, selected_e)
						DevTools.debug_anim.tag = selected_e.anim.obj.current_tag
						self:refresh_render(selected_e)
						break
					end
				end
				Slab.EndComboBox()
			end

			if selected_anim and clips[selected_anim] then
				local clip = clips[selected_anim]
				local max = clip.n_frames or obj.frame_max

				Slab.Text("Frame")
				Slab.SameLine()
				if Slab.InputNumberSlider("anim_frame", obj.frame, 1, max, opt_slider) then
					local v = Slab.GetInputNumber()
					obj:goto_frame(v)
					if selected_e.quad then
						selected_e.quad.quad = obj:get_quad()
					end
				end

				if Slab.Button("Pause start") then
					obj:pause_at_start()
				end
				Slab.SameLine()
				if Slab.Button("Pause end") then
					obj:pause_at_end()
				end
				Slab.SameLine()
				if Slab.Button("Resume") then
					obj:resume()
				end
				Slab.SameLine()
				if Slab.Button("Rebuild tag") then
					self:debug_play(selected_e, obj.current_tag)
				end

				local has_override = selected_e:has("override_animation")
				if Slab.CheckBox(has_override, "Override") then
					if has_override then
						selected_e:remove("override_animation")
					else
						selected_e:give("override_animation")
					end
				end
			end

			if obj.anim8 then
				Slab.Text("Status: " .. obj.anim8.status)
			end
		end

		Slab.EndWindow()
	end
end

return Anim
