local Tree = Concord.system({
	pool_bg_tree = { "bg_tree", "pos", "!hspeed" },
})

function Tree:start_trees()
	for _, e in ipairs(self.pool_bg_tree) do
		e:remove("parallax_stop")
	end
end

function Tree:update(dt)
	for _, e in ipairs(self.pool_bg_tree) do
		if e:get("bg_tree").is_cover then
			local pos = e:get("pos")
			local qt = e:get("quad_transform")
			local quad = e:get("quad")
			if pos.x + quad.info.w * qt.sx < 0 then
				e:destroy()
			end
		end
	end
end

return Tree
