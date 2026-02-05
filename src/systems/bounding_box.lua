local BoundingBox = Concord.system({
	pool = { "bounding_box", "pos" },
})

function BoundingBox:init(world)
	self.world = world
end

function BoundingBox:update(dt)
	for _, e in ipairs(self.pool) do
		local box = e.bounding_box
		local x, y = Helper.get_real_pos_box(e)
		box.x = x
		box.y = y
	end
end

function BoundingBox:on_camera_move(camera)
	if not (Gamera.isCamera(camera)) then
		error("Assertion failed: Gamera.isCamera(camera)")
	end
	for _, e in ipairs(self.pool) do
		local ui = e.ui_element
		local box = e.bounding_box
		local pos = e.pos
		local bx, by
		if ui then
			local transform = e.transform
			bx = pos.x
			by = pos.y
			if transform then
				local ox, oy = Helper.get_offset(e)
				bx = bx - ox * transform.orig_sx
				by = by - oy * transform.orig_sy
			end
		else
			bx, by = camera:toScreen(pos.x, pos.y)
		end
		box.screen_pos.x = bx
		box.screen_pos.y = by
	end
end

function BoundingBox:debug_update(dt)
	if not self.debug_show then
		return
	end
	-- self.debug_show = Slab.BeginWindow("bounding_box", {
	-- 	Title = "BoundingBox",
	-- 	IsOpen = self.debug_show,
	-- })
	-- Slab.EndWindow()
end

function BoundingBox:debug_draw()
	if not self.debug_show then
		return
	end
	love.graphics.push()
	love.graphics.origin()
	for _, e in ipairs(self.pool) do
		local bx, by = Helper.get_real_pos_box(e)
		local bw, bh = Helper.get_real_size(e)
		love.graphics.setColor(1, 0, 0, 1)
		if e.hoverabl and e.hoverable.is_hovered then
			love.graphics.setColor(1, 1, 0, 1)
		end
		love.graphics.rectangle("line", bx, by, bw, bh)
		love.graphics.circle("fill", bx + bw/2, by + bh/2, 2)
	end
	love.graphics.pop()
end

return BoundingBox
