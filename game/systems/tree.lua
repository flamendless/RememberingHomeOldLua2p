local Tree = Concord.system({
	pool_bg_tree = {"bg_tree", "pos", "!hspeed"},
})

function Tree:start_trees()
	for _, e in ipairs(self.pool_bg_tree) do
		e:remove("parallax_stop")
	end
end

function Tree:update(dt)
	for _, e in ipairs(self.pool_bg_tree) do
		if e.bg_tree.is_cover then
			local pos = e.pos
			local qt = e.quad_transform
			if pos.x + e.quad.info.w * qt.sx < 0 then
				e:destroy()
			end
		end
	end
end

return Tree
