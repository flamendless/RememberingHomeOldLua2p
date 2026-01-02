local Collision = Concord.system({
	pool = {"pos", "collider"},
	pool_circle = {"pos", "collider_circle"},
})

function Collision:check_circle_to_rect(cpos, rad)
	ASSERT(cpos:type() == "vec2")
	ASSERT(type(rad) == "number")
	for _, e in ipairs(self.pool) do
		local col = e.collider
		local offset = e.collider_offset
		local rpos = e.pos.pos:copy()

		if offset then
			rpos:vadd_inplace(offset.value)
		end

		local hs = col.size:copy():vector_mul_inplace(0.5)
		rpos:vsub_inplace(hs)

		local res = intersect.circle_aabb_overlap(cpos, rad, rpos, hs)
		col.is_hit = res

		if res then
			return true
		end
	end
	return false
end

function Collision:check_rect_to_circle(rpos, rsize)
	ASSERT(rpos:type() == "vec2")
	ASSERT(rsize:type() == "vec2")
	rpos:vsub_inplace(rsize)
	rsize:vector_mul_inplace(0.5)

	for _, e in ipairs(self.pool_circle) do
		local col_c = e.collider_circle
		local cpos = e.pos.pos:copy()
		local rad = col_c.size
		cpos:vadd_inplace(col_c.offset.value)

		local res = intersect.circle_aabb_overlap(cpos, rad, rpos, rsize)
		col_c.is_hit = res

		if res then
			return true
		end
	end
	return false
end

function Collision:check_collision(e)
	local pos = e.pos.pos
	local col = e.collider
	local col_c = e.collider_circle

	if col then
		local rpos = pos:copy()
		local rsize = col.size
		local offset = e.collider_offset
		if offset then
			rpos:vadd_inplace(offset.value)
		end
		col.is_hit = self:check_rect_to_circle(rpos, rsize)
	elseif col_c then
		local cpos = pos:copy()
		local rad = col_c.size
		cpos:vadd_inplace(col_c.offset)
		col_c.is_hit = self:check_circle_to_rect(cpos, rad)
	end
end

return Collision
