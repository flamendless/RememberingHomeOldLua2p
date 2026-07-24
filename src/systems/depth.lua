local Depth = Concord.system({
	pool = { "depth_zoom", "z_index" },
})

function Depth:init(world)
	self.world = world

	self.pool.onAdded = function(pool, e)
		assert(e.transform or e.quad_transform, e.id.value .. " must have a transform or quad_transform component")
	end
end

function Depth:tween_depth_zoom(dur, factor, ease)
	assert(type(dur) == "number", dur)
	assert(type(factor) == "number", factor)
	if ease then
		assert(type(ease) == "string", ease)
	end
	for _, e in ipairs(self.pool) do
		local zf = e.depth_zoom.value
		local t = e.transform or e.quad_transform
		Flux.to(t, dur, {
			sx = math.max(t.orig_sx, t.orig_sx + zf * factor),
			sy = math.max(t.orig_sy, t.orig_sy + zf * factor),
		}):ease(ease or "linear")
	end
end

if DEV then
	function Depth:debug_wheelmoved(wx, wy)
		for _, e in ipairs(self.pool) do
			local zf = e.depth_zoom.value
			local t = e.transform or e.quad_transform
			t.sx = math.max(t.orig_sx, t.orig_sx + zf * wy)
			t.sy = math.max(t.orig_sy, t.orig_sy + zf * wy)
		end
	end
end

return Depth
