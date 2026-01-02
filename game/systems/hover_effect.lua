local HoverEffect = Concord.system({
	pool_change_color = {"bounding_box", "hoverable", "color", "hover_change_color"},
	pool_change_scale = {"bounding_box", "hoverable", "transform", "hover_change_scale"},
})

function HoverEffect:init(world)
	self.world = world

	self.pool_change_scale.onRemoved = function(pool, e)
		local transform = e.transform
		transform.sx = transform.orig_scale.x
		transform.sy = transform.orig_scale.y
	end
end

function HoverEffect:hover_effects()
	self:hover_change_color()
	self:hover_change_scale()
end

function HoverEffect:hover_change_color()
	for _, e in ipairs(self.pool_change_color) do
		local color = e.color
		local hcc = e.hover_change_color
		local hoverable = e.hoverable

		if hoverable.is_hovered then
			color.value[1] = mathx.lerp(color.value[1], hcc.target[1], hcc.step)
			color.value[2] = mathx.lerp(color.value[2], hcc.target[2], hcc.step)
			color.value[3] = mathx.lerp(color.value[3], hcc.target[3], hcc.step)
			color.value[4] = mathx.lerp(color.value[4], hcc.target[4], hcc.step)
		else
			color.value[1] = mathx.lerp(color.value[1], color.original[1], hcc.step)
			color.value[2] = mathx.lerp(color.value[2], color.original[2], hcc.step)
			color.value[3] = mathx.lerp(color.value[3], color.original[3], hcc.step)
			color.value[4] = mathx.lerp(color.value[4], color.original[4], hcc.step)
		end
	end
end

function HoverEffect:hover_change_scale(mx, my)
	for _, e in ipairs(self.pool_change_scale) do
		local hoverable = e.hoverable
		local transform = e.transform
		local hcs = e.hover_change_scale

		if hoverable.is_hovered then
			transform.sx = mathx.lerp(transform.scale.x, hcs.target, hcs.step)
			transform.sy = mathx.lerp(transform.scale.y, hcs.target, hcs.step)
		else
			transform.sx = mathx.lerp(transform.scale.x, transform.orig_scale.x, hcs.step)
			transform.sy = mathx.lerp(transform.scale.y, transform.orig_scale.y, hcs.step)
		end
	end
end

return HoverEffect
