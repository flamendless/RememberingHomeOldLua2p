local Decals = {
	id = "Decals",
	debug_show = false,
	debug_list = {},
}

function Decals.init()
	Decals.tex_hand = Resources.data.images.tex_hand
	Decals.tex_hand:setFilter("nearest", "nearest")
	Decals.tex_hand:setWrap("clampzero", "clampzero")
end

function Decals.setup(e)
	assert(e.__isEntity)

	local c_decals_shaders = e.decals_shaders
	if c_decals_shaders then
		c_decals_shaders.shader = love.graphics.newShader(Shaders.paths[c_decals_shaders.value])
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

function Decals.update(dt, e)
	assert(e.__isEntity)

	local c_decals_shaders = e.decals_shaders
	if c_decals_shaders then
		-- INFO: let's unwrap instead of for-loop since we know the shaders data
		local c_decals = e.decals
		if c_decals.kind == Enums.decals.hand then
			local data = c_decals_shaders.data
			data.time = data.time + dt

			c_decals_shaders.shader:send("time", data.time)
			c_decals_shaders.shader:send("opacity", data.opacity)
			c_decals_shaders.shader:send("blood_amount", data.blood_amount)
			c_decals_shaders.shader:send("damage_amount", data.damage_amount)
			c_decals_shaders.shader:send("distort_amount", data.distort_amount)
			c_decals_shaders.shader:send("scale", data.scale)
			c_decals_shaders.shader:send("rotation", math.rad(data.rotation))
		end
	end
end

function Decals.render_hand(e)
	assert(e.__isEntity)
	assert(e.decals.kind == Enums.decals.hand, e.decals.kind)

	local rot = e.decals_shaders.data.rotation
	local sx, sy = unpack(e.decals_shaders.data.scale)
	local w, h = Decals.tex_hand:getDimensions()
	love.graphics.draw(
		Decals.tex_hand,
		e.pos.x,
		e.pos.y,
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
	local c_decals_shaders = e.decals_shaders
	if c_decals_shaders then
		temp_shader = love.graphics.getShader()
		love.graphics.setShader(c_decals_shaders.shader)
	end

	local c_color = e.color and e.color.value or Palette.colors.white
	love.graphics.setColor(c_color)

	local c_decals = e.decals
	if c_decals.kind == Enums.decals.hand then
		Decals.render_hand(e)
	end

	if temp_shader then
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
			if Slab.BeginTree(e.id.value) then
				Slab.Indent()

				local c_decals = e.decals
				Slab.Text("kind: " .. c_decals.kind)

				if c_decals.kind == Enums.decals.hand then
					local c_decals_shaders = e.decals_shaders
					local data = c_decals_shaders.data
					local _ = nil
					data.opacity, _ = UIWrapper.edit_range("opacity", data.opacity, 0, 1, false)
					data.blood_amount, _ = UIWrapper.edit_range("blood_amount", data.blood_amount, 0, 1, false)
					data.damage_amount, _ = UIWrapper.edit_range("damage_amount", data.damage_amount, 0, 1, false)
					data.distort_amount, _ = UIWrapper.edit_range("distort_amount", data.distort_amount, 0, 1, false)
					data.scale[1], _ = UIWrapper.edit_range("sx", data.scale[1], 0, 10, false)
					data.scale[2], _ = UIWrapper.edit_range("sy", data.scale[2], 0, 10, false)
					data.rotation, _ = UIWrapper.edit_range("r", data.rotation, 0, 360, true)
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
			local c_decals = e.decals
			if c_decals.kind == Enums.decals.hand then
				local sx, sy = unpack(e.decals_shaders.data.scale)
				local w, h = Decals.tex_hand:getDimensions()
				love.graphics.rectangle(
					"line",
					e.pos.x - w * sx/2,
					e.pos.y - h * sy/2,
					w * sx,
					h * sy
				)
			end
		end
	end
end

return Decals
