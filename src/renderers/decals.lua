local Decals = {
	id = "Decals",
	debug_show = false,
	debug_list = {},
}

local blacklist = {
	Enums.game_state.Menu,
}

function Decals.init(main_renderer, world)
	for _, v in ipairs(blacklist) do
		if v == GameStates.current_id then return end
	end

	assert(main_renderer.__isSystem)
	assert(world.__isWorld)
	Decals.world = world

	Decals.tex_hand = Resources.data.images.tex_hand
	Decals.tex_hand:setFilter("nearest", "nearest")
	Decals.tex_hand:setWrap("clampzero", "clampzero")
end

function Decals.setup(e)
	assert(e.__isEntity)

	local c_decals_shaders
	if e:has("decals_shaders") then
		c_decals_shaders = e:get("decals_shaders")
	end
	if c_decals_shaders then
		c_decals_shaders.shader = love.graphics.newShader(Shaders.paths[c_decals_shaders.value])
	end

	if e:has("decals_embed") then
		local c_decals_embed = e:get("decals_embed")
		local e_other = Decals.world:getEntityByKey(c_decals_embed.value)
		assert(e_other ~= nil)
	end

	if DEV then
		table.insert(Decals.debug_list, e)
	end
end

function Decals.remove(e)
	assert(e.__isEntity)
	if DEV then
		for i, e2 in ipairs(Decals.debug_list) do
			if e == e2 then
				table.remove(Decals.debug_list, i)
				break
			end
		end
	end
end

function Decals.send_uniforms(e)
	local c_decals_shaders
	if not e:has("decals_shaders") then
		return
	end
	c_decals_shaders = e:get("decals_shaders")

	local c_decals = e:get("decals")
	if c_decals.kind ~= Enums.decals.hand then
		return
	end

	local data = c_decals_shaders.data
	c_decals_shaders.shader:send("time", data.time)
	c_decals_shaders.shader:send("opacity", data.opacity)
	c_decals_shaders.shader:send("blood_amount", data.blood_amount)
	c_decals_shaders.shader:send("damage_amount", data.damage_amount)
	c_decals_shaders.shader:send("distort_amount", data.distort_amount)
	local uv_scale = data.uv_scale or data.scale[1]
	c_decals_shaders.shader:send("scale", { uv_scale, uv_scale })
	c_decals_shaders.shader:send("rotation", math.rad(data.rotation))
end

function Decals.update(dt, e)
	assert(e.__isEntity)

	if e:has("decals_shaders") then
		local c_decals_shaders = e:get("decals_shaders")
		local c_decals = e:get("decals")
		if c_decals.kind == Enums.decals.hand then
			c_decals_shaders.data.time = c_decals_shaders.data.time + dt
		end
		Decals.send_uniforms(e)
	end
end

function Decals.render_hand(e)
	assert(e.__isEntity)
	local c_decals = e:get("decals")
	assert(c_decals.kind == Enums.decals.hand, c_decals.kind)

	local c_decals_shaders = e:get("decals_shaders")
	local rot = c_decals_shaders.data.rotation
	local sx, sy = unpack(c_decals_shaders.data.scale)
	local w, h = Decals.tex_hand:getDimensions()
	local pos = e:get("pos")
	love.graphics.draw(
		Decals.tex_hand,
		pos.x,
		pos.y,
		rot,
		sx,
		sy,
		w / 2,
		h / 2
	)
end

function Decals.render(e)
	assert(e.__isEntity)

	local temp_shader
	local c_decals_shaders
	if e:has("decals_shaders") then
		c_decals_shaders = e:get("decals_shaders")
	end
	if c_decals_shaders then
		temp_shader = love.graphics.getShader()
		Decals.send_uniforms(e)
		love.graphics.setShader(c_decals_shaders.shader)
	end

	local c_color = Palette.colors.white
	if e:has("color") then
		c_color = e:get("color").value
	end
	love.graphics.setColor(c_color)

	local c_decals = e:get("decals")
	if c_decals.kind == Enums.decals.hand then
		Decals.render_hand(e)
	end

	if c_decals_shaders then
		love.graphics.setShader(temp_shader)
	end
end

function Decals.cleanup()
	if DEV then
		tablex.clear(Decals.debug_list)
	end
end

if DEV then
	local debug_outline = false

	function Decals.debug_update(dt)
		if not Decals.debug_show then return end
		Decals.debug_show = Slab.BeginWindow("renderer_decals", {
			Title = "Decals",
			IsOpen = Decals.debug_show,
		})

		if Slab.CheckBox(debug_outline, "Outline") then debug_outline = not debug_outline end

		for _, e in ipairs(Decals.debug_list) do
			if Slab.BeginTree(e:get("id").value) then
				Slab.Indent()

				local c_decals = e:get("decals")
				Slab.Text("kind: " .. c_decals.kind)

				if c_decals.kind == Enums.decals.hand then
					local c_decals_shaders = e:get("decals_shaders")
					local data = c_decals_shaders.data
					local _ = nil
					data.opacity, _ = UIWrapper.edit_range("opacity", data.opacity, 0, 1, false)
					data.blood_amount, _ = UIWrapper.edit_range("blood_amount", data.blood_amount, 0, 1, false)
					data.damage_amount, _ = UIWrapper.edit_range("damage_amount", data.damage_amount, 0, 1, false)
					data.distort_amount, _ = UIWrapper.edit_range("distort_amount", data.distort_amount, 0, 1, false)
					data.scale[1], _ = UIWrapper.edit_range("sx", data.scale[1], 0, 10, false)
					data.scale[2], _ = UIWrapper.edit_range("sy", data.scale[2], 0, 10, false)
					data.rotation, _ = UIWrapper.edit_range("rot", data.rotation, 0, 360, true)
				end

				if e:has("color") then
					local c_color = e:get("color")
					UIWrapper.color(c_color.value)
				end

				Slab.EndTree()
				Slab.Unindent()
			end
		end
		Slab.EndWindow()
	end

	function Decals.debug_draw()
		if not Decals.debug_show then return end
		if not debug_outline then return end
		love.graphics.setColor(1, 0, 0, 1)
		for _, e in ipairs(Decals.debug_list) do
			local c_decals = e:get("decals")
			if c_decals.kind == Enums.decals.hand then
				local c_decals_shaders = e:get("decals_shaders")
				local sx, sy = unpack(c_decals_shaders.data.scale)
				local w, h = Decals.tex_hand:getDimensions()
				local pos = e:get("pos")
				love.graphics.rectangle(
					"line",
					pos.x - w * sx/2,
					pos.y - h * sy/2,
					w * sx,
					h * sy
				)
			end
		end
	end
end

return Decals
