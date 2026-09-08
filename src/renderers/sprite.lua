local Sprite = {
	id = "Sprite",
	e_bg = nil,

	debug_show = false,
	debug_batched = {},
}

local function draw_with_blood_overlay(e, highlight, ...)
	local prev_shader = love.graphics.getShader()
	local highlighter = Sprite.overlay_highlighter
	highlighter.data.time = highlight.time
	highlighter.data.opacity = highlight.opacity
	highlighter.data.overlay_strength = highlight.overlay_strength
	highlighter:draw(...)
	love.graphics.setShader(prev_shader)
end

local function draw(e, ...)
	if e:has("interactive_highlight") then
		draw_with_blood_overlay(e, e:get("interactive_highlight"), ...)
	else
		love.graphics.draw(...)
	end
end

function Sprite.init(main_renderer, world)
	assert(main_renderer.__isSystem)
	assert(world.__isWorld)
	Sprite.world = world
	Sprite.overlay_highlighter = BloodHighlight.new()

	tablex.clear(Sprite.debug_batched)
end

function Sprite.setup(e)
	if not DEV then return end
	assert(e.__isEntity)
	local sprite = e:get("sprite")
	local s_id = sprite.resource_id
	if not Sprite.debug_batched[s_id] then
		Sprite.debug_batched[s_id] = { highest = 0, total = 0, current = 0 }
	end
end

function Sprite.remove(e)
	if not DEV then return end
	assert(e.__isEntity)
	local sprite = e:get("sprite")
	local s_id = sprite.resource_id
	Sprite.debug_batched[s_id] = nil
end

function Sprite.set_bg(e)
	assert((e.__isEntity and e:has("sprite") and e:has("bg")), e)
	assert:equal(Sprite.e_bg, nil, "only 1 bg entity is allowed")
	Sprite.e_bg = e
end

function Sprite.render_bg()
	if HANG_WATCH then
		hang_watch("sprite:render_bg")
	end
	if not Sprite.e_bg then
		if HANG_WATCH then
			hang_watch("sprite:render_bg skip")
		end
		return
	end
	if HANG_WATCH then
		hang_watch("sprite:render_bg draw")
	end
	Sprite.render(Sprite.e_bg)
	if HANG_WATCH then
		hang_watch("sprite:render_bg ok")
	end
end

function Sprite.render(e)
	assert(e.__isEntity)
	local rot, sx, sy, ox, oy, kx, ky
	local pos = e:get("pos")
	local sprite = e:get("sprite")

	local transform
	if e:has("transform") then
		transform = e:get("transform")
	end
	if transform then
		rot = transform.rotation
		sx, sy = transform.sx, transform.sy
		ox, oy = Helper.get_offset(e)
		kx, ky = transform.kx, transform.ky
	end

	local quad
	if e:has("quad") then
		quad = e:get("quad")
	end
	if quad then
		local quad_transform
		if e:has("quad_transform") then
			quad_transform = e:get("quad_transform")
		end
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
		local resource_id = e:get("sprite").resource_id
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
			Slab.Text("Use the Component List instead")
		end

		Slab.EndWindow()
	end
end

return Sprite
