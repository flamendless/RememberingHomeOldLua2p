local HandDecal = {}

HandDecal.HAND_TEX = 64
HandDecal.SKIP_HAND_SCALE = 0.85
HandDecal.SPLASH_HAND_SCALE = 1.05
HandDecal.SPLASH_HAND_UV_SCALE = 1.0
HandDecal.SPLASH_HAND_MARGIN = 20
HandDecal.SPLASH_HAND_EFFECTS = {
	blood_amount = 0.65,
	damage_amount = 0.5,
	distort_amount = 0.6,
}
HandDecal.KEY_LABEL_OFFSET = { x = 3, y = 5 }

local DEFAULTS = {
	scale = 0.4,
	rotation = 0,
	opacity = 0,
	blood_amount = 0,
	damage_amount = 0,
	distort_amount = 0,
	z_index = MAX_Z,
	color = Palette.diffuse.hand_decals,
}

function HandDecal.create(e, opts)
	opts = opts or {}
	assert:type(opts.x, "number")
	assert:type(opts.y, "number")

	local scale = opts.scale or DEFAULTS.scale
	local uv_scale = opts.uv_scale or scale
	local id = opts.id or "hand_decal"

	e:give("id", id)
		:give("key", opts.key or id)
		:give("z_index", opts.z_index or DEFAULTS.z_index)
		:give("pos", opts.x, opts.y, opts.z)
		:give("color", opts.color or DEFAULTS.color)
		:give("decals", Enums.decals.hand)
		:give("decals_shaders", Enums.shaders.hand, {
			time = 0,
			opacity = opts.opacity or DEFAULTS.opacity,
			blood_amount = opts.blood_amount or DEFAULTS.blood_amount,
			damage_amount = opts.damage_amount or DEFAULTS.damage_amount,
			distort_amount = opts.distort_amount or DEFAULTS.distort_amount,
			scale = { scale, scale },
			uv_scale = uv_scale,
			rotation = opts.rotation or DEFAULTS.rotation,
		})

	if opts.ui_element then
		e:give("ui_element")
	end
	if opts.skip then
		e:give("skip")
	end

	return e
end

function HandDecal.fade_in(e, target_opacity, duration, delay)
	assert(e.__isEntity and e:has("decals_shaders"))
	local decals_shaders = e:get("decals_shaders")
	return Flux.to(decals_shaders.data, duration, { opacity = target_opacity }):delay(delay or 0)
end

function HandDecal.fade_out(e, duration, on_complete)
	assert(e.__isEntity and e:has("decals_shaders"))
	local decals_shaders = e:get("decals_shaders")
	return Flux.to(decals_shaders.data, duration, { opacity = 0 }):oncomplete(function()
		e:destroy()
		if on_complete then
			on_complete()
		end
	end)
end

function HandDecal.pulse_opacity(e, duration, count, min_opacity, max_opacity)
	assert(e.__isEntity and e:has("decals_shaders"))
	min_opacity = min_opacity or 0
	max_opacity = max_opacity or 1
	count = count or 0

	local decals_shaders = e:get("decals_shaders")
	local data = decals_shaders.data
	local cycles = 0
	local fade_in, fade_out

	fade_out = function()
		Flux.to(data, duration, { opacity = min_opacity }):oncomplete(function()
			cycles = cycles + 1
			if count > 0 and cycles >= count * 2 then
				return
			end
			fade_in()
		end)
	end

	fade_in = function()
		Flux.to(data, duration, { opacity = max_opacity }):oncomplete(function()
			cycles = cycles + 1
			if count > 0 and cycles >= count * 2 then
				return
			end
			fade_out()
		end)
	end

	if data.opacity >= max_opacity then
		fade_out()
	else
		fade_in()
	end
end

function HandDecal.set_progress(e, progress, base_opacity, label)
	if not e or not e:has("decals_shaders") then
		return
	end
	progress = mathx.clamp(progress, 0, 1)
	base_opacity = base_opacity or 0.9
	local decals_shaders = e:get("decals_shaders")
	local data = decals_shaders.data
	data.opacity = base_opacity * (1 - progress)
	data.blood_amount = progress
	data.damage_amount = progress
	data.distort_amount = progress

	if label and label:has("color") then
		local label_color = label:get("color")
		label_color.value[4] = data.opacity
	end
end

function HandDecal.key_label_scale(hand_scale)
	return hand_scale / HandDecal.SKIP_HAND_SCALE
end

function HandDecal.create_key_label(world, text, opts)
	opts = opts or {}
	assert:type(text, "string")

	-- Screen-space labels always match the splash skip hint size.
	local hand_scale = opts.hand_scale or HandDecal.SKIP_HAND_SCALE
	local text_scale = HandDecal.key_label_scale(hand_scale)
	local id = opts.id or "hand_key_label"
	local e = Concord.entity(world)
		:give("id", id)
		:give("key", opts.key or id)
		:give("static_text", text)
		:give("font", "ui")
		:give("pos", opts.x or 0, opts.y or 0)
		:give("color", { 1, 1, 1, opts.opacity or 0 })
		:give("transform", 0, text_scale, text_scale, 0.5, 0.5)
		:give("z_index", opts.z_index or MAX_Z)

	if opts.ui_element then
		e:give("ui_element")
	end
	if opts.skip then
		e:give("skip")
	end

	return e
end

function HandDecal.sync_key_label(hand, label, camera, ox, oy)
	assert(hand.__isEntity and hand:has("decals_shaders"))
	assert(label.__isEntity and label:has("pos") and label:has("color"))

	ox = ox or HandDecal.KEY_LABEL_OFFSET.x
	oy = oy or HandDecal.KEY_LABEL_OFFSET.y
	local hand_decals_shaders = hand:get("decals_shaders")
	local label_color = label:get("color")
	label_color.value[4] = hand_decals_shaders.data.opacity

	local hand_pos = hand:get("pos")
	local label_pos = label:get("pos")
	if camera then
		local sx, sy = camera:toScreen(hand_pos.x, hand_pos.y)
		label_pos.x = sx + ox
		label_pos.y = sy + oy
	else
		label_pos.x = hand_pos.x + ox
		label_pos.y = hand_pos.y + oy
	end
end

function HandDecal.fade_key_label(e, duration, on_complete)
	assert(e.__isEntity and e:has("color"))
	local color = e:get("color")
	Flux.to(color.value, duration, { [4] = 0 }):oncomplete(function()
		e:destroy()
		if on_complete then
			on_complete()
		end
	end)
end

return HandDecal
