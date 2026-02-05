local Depth = Concord.system({
	pool = { "depth_zoom", "z_index" },
})

function Depth:init(world)
	self.world = world

	self.pool.onAdded = function(pool, e)
		if not e.transform and not e.quad_transform then
			error(e.id.value .. " must have a transform or quad_transform component")
		end
	end
end

function Depth:tween_depth_zoom(dur, factor, ease)
	if type(dur) ~= "number" then
		error('Assertion failed: type(dur) == "number"')
	end
	if type(factor) ~= "number" then
		error('Assertion failed: type(factor) == "number"')
	end
	if ease then
		if type(ease) ~= "string" then
			error('Assertion failed: type(ease) == "string"')
		end
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

function Depth:debug_wheelmoved(wx, wy)
	for _, e in ipairs(self.pool) do
		local zf = e.depth_zoom.value
		local t = e.transform or e.quad_transform
		t.sx = math.max(t.orig_sx, t.orig_sx + zf * wy)
		t.sy = math.max(t.orig_sy, t.orig_sy + zf * wy)
	end
end

return Depth
