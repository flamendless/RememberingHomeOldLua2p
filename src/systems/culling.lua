local Culling = Concord.system({
	pool_sprite = {
		"cullable",
		"sprite",
		"pos",
		"!nf_renderer",
		"!notification",
	},
})

function Culling:init(world)
	self.world = world
end

function Culling:get_query_rect()
	local camera = self.world:getResource("camera")
	if camera then
		return camera:getVisible()
	else
		return 0, 0, love.graphics.getDimensions()
	end
end

function Culling:update(dt)
	local x, y, w, h = self:get_query_rect()
	x = x - 32
	y = y - 32
	w = w + 32 * 2
	h = h + 32 * 2
	local w2 = w/2
	local h2 = h/2

	for _, e in ipairs(self.pool_sprite) do
		local cullable = e.cullable
		local px, py, iw, ih = Helper.get_ltwh(e)
		local iw2, ih2 = iw/2, ih/2
		local a_pos = vec2(px, py)
		local a_hs = vec2(iw2, ih2)
		local b_pos = vec2(x + w2, y + h2)
		local b_hs = vec2(w2, h2)
		local within = intersect.aabb_aabb_overlap(a_pos, a_hs, b_pos, b_hs)
		cullable.value = not within
	end
end

function Culling:debug_update(dt)
	if not self.debug_show then
		return
	end
	self.debug_show = Slab.BeginWindow("culling", {
		Title = "Culling",
		IsOpen = self.debug_show,
	})
	for _, e in ipairs(self.pool_sprite) do
		local id = e.id.value
		local culled = e.cullable.value
		Slab.CheckBox(culled, id)
	end
	Slab.EndWindow()
end

return Culling
