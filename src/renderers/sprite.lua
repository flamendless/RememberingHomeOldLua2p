local Sprite = {
	id = "Sprite",
	e_bg = nil,

	debug_show = false,
	debug_batched = {},
}

local function draw(e, ...)
	local outline = e.outline and e.outline.outliner
	if outline then
		outline:draw(e.outline_val.value, ...)
	else
		love.graphics.draw(...)
	end
end

function Sprite.init()
	tablex.clear(Sprite.debug_batched)
end

function Sprite.setup_sprite(e)
	if not DEV then return end
	local sprite = e.sprite
	local s_id = sprite.resource_id
	if not Sprite.debug_batched[s_id] then
		Sprite.debug_batched[s_id] = { highest = 0, total = 0, current = 0 }
	end
end

function Sprite.set_bg(e)
	if not (e.__isEntity and e.sprite and e.bg) then
		error("Assertion failed: e.__isEntity and e.sprite and e.bg")
	end
	if not (Sprite.e_bg == nil) then
		error("only 1 bg entity is allowed")
	end
	Sprite.e_bg = e
end

function Sprite.render_bg()
	if not Sprite.e_bg then
		return
	end
	Sprite.render(Sprite.e_bg)
end

function Sprite.render(e)
	local rot, sx, sy, ox, oy, kx, ky
	local pos = e.pos
	local sprite = e.sprite

	local transform = e.transform
	if transform then
		rot = transform.rotation
		sx, sy = transform.sx, transform.sy
		ox, oy = Helper.get_offset(e)
		kx, ky = transform.kx, transform.ky
	end

	local quad = e.quad
	if quad then
		local quad_transform = e.quad_transform
		if quad_transform then
			rot = quad_transform.rotation
			sx, sy = quad_transform.sx, quad_transform.sy
			ox, oy = quad_transform.ox, quad_transform.oy
			kx, ky = quad_transform.kx, quad_transform.ky
		end
		draw(e, sprite.image, quad.quad, pos.x, pos.y, rot, sx, sy, ox, oy, kx, ky)
	else
		draw(e, sprite.image, pos.x, pos.y, rot, sx, sy, ox, oy, kx, ky)
	end
end

function Sprite.cleanup()
	Sprite.e_bg = nil

	tablex.clear(Sprite.debug_batched)
end

if DEV then
	function Sprite.debug_batching()
		for _, v in pairs(Sprite.debug_batched) do
			v.highest = 0
			v.total = 0
		end
	end

	function Sprite.debug_batching_update(e)
		local resource_id = e.sprite.resource_id
		local db = Sprite.debug_batched[resource_id]
		if not db then
			return
		end
		local prev_id = Sprite.debug_prev_id
		if prev_id then
			if prev_id == resource_id then
				db.current = db.current + 1
			else
				db.highest = math.max(db.highest, db.current)
				db.current = 0
			end
		end
		db.total = db.total + 1
		Sprite.debug_prev_id = resource_id
	end

	function Sprite.debug_update(dt)
		if not Sprite.debug_show then
			return
		end
		Sprite.debug_show = Slab.BeginWindow("renderer_sprite", {
			Title = "Sprite",
			IsOpen = Sprite.debug_show,
		})

		Slab.Text("Atlas Batching (highest : total)")
		Slab.Indent()
		for k, v in pairs(Sprite.debug_batched) do
			local str = string.format("%s = %d/%d", k, v.highest + 1, v.total + 1)
			Slab.Text(str)
		end
		Slab.Unindent()

		if Sprite.debug_list then
			if Slab.BeginTree("Entities") then
				for _, e in ipairs(Sprite.debug_list) do
					if Slab.BeginTree(e.id.value) then
						Slab.Indent()
						Slab.Indent()

						if e.color and Slab.BeginTree("color") then
							UIWrapper.color(e.color.value)
							Slab.EndTree()
						end
						if Slab.BeginTree("z index") then
							DevTools.draw_z_index(e)
							Slab.EndTree()
						end
						if Slab.BeginTree("sprite") then
							DevTools.draw_sprite(e)
							Slab.EndTree()
						end

						Slab.Unindent()
						Slab.Unindent()
						Slab.EndTree()
					end
				end
				Slab.EndTree()
			end
		end

		Slab.EndWindow()
	end
end

return Sprite
