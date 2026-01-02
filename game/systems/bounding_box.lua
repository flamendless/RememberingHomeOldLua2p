local BoundingBox = Concord.system({
	pool = {"bounding_box", "pos"},
})

function BoundingBox:init(world)
	self.world = world
end

function BoundingBox:update(dt)
	for _, e in ipairs(self.pool) do
		local box = e.bounding_box
		local real_pos = Utils.math.get_real_pos_box(e)
		box.pos = real_pos
	end
end

function BoundingBox:on_camera_move(camera)
	ASSERT(Gamera.isCamera(camera))
	for _, e in ipairs(self.pool) do
		local ui = e.ui_element
		local box = e.bounding_box
		local pos = e.pos.pos
		local bpos
		if ui then
			local transform = e.transform
			bpos = pos:copy()
			if transform then
				local offset = Utils.math.get_offset(e)
				local dt = offset:vector_mul_inplace(transform.orig_scale)
				bpos:ssub_inplace(dt)
			end
		else
			bpos = vec2(camera:toScreen(pos:unpack()))
		end
		box.screen_pos = bpos
	end
end

if _DEV then
	function BoundingBox:debug_update(dt)
		if not self.debug_show then return end
		-- self.debug_show = Slab.BeginWindow("bounding_box", {
		-- 	Title = "BoundingBox",
		-- 	IsOpen = self.debug_show,
		-- })
		-- Slab.EndWindow()
	end

	function BoundingBox:debug_draw()
		if not self.debug_show then return end
		love.graphics.push()
		love.graphics.origin()
		for _, e in ipairs(self.pool) do
			local bx, by = Utils.math.get_real_pos_box(e)
			local bw, bh = Utils.math.get_real_size(e)
			love.graphics.setColor(1, 0, 0, 1)
			if e.hoverabl and e.hoverable.is_hovered then
				love.graphics.setColor(1, 1, 0, 1)
			end
			love.graphics.rectangle("line", bx, by, bw, bh)
			love.graphics.circle("fill", bx + bw * 0.5, by + bh * 0.5, 2)
		end
		love.graphics.pop()
	end
end

return BoundingBox
