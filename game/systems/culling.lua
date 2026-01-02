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
	x = x - CULL_PAD
	y = y - CULL_PAD
	w = w + CULL_PAD * 2
	h = h + CULL_PAD * 2
	local w2 = w * 0.5
	local h2 = h * 0.5

	for _, e in ipairs(self.pool_sprite) do
		local cullable = e.cullable
		local pos, size = Utils.math.get_ltwh(e)
		size:scalar_mul_inplace(0.5)
		local a_pos = pos
		local a_hs = size
		local b_pos = vec2(x + w2, y + h2)
		local b_hs = vec2(w2, h2)
		local within = intersect.aabb_aabb_overlap(a_pos, a_hs, b_pos, b_hs)
		cullable.value = not within
	end
end

if DEV then
	function Culling:debug_update(dt)
		if not self.debug_show then return end
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
end

return Culling
