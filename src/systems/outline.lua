local Outline = Concord.system({
	pool = { "id", "outline", "outline_val", "sprite", "pos" },
	pool_grouped = { "grouped" },
})

function Outline:init(world)
	self.world = world

	local col_outline = Palette.colors.outline
	self.pool.onAdded = function(pool, e)
		local outline = e:get("outline")
		local outliner = Outliner(true)
		outliner:outline(unpack(col_outline))
		outline.outliner = outliner
	end
end

function Outline:create_outline(e)
	assert((e.__isEntity and e:has("id") and e:has("pos")), e)
	local sprite = e:get("sprite")
	if not sprite then
		return
	end

	local grouped = e:get("grouped")
	local id
	if grouped then
		id = "outline_" .. grouped.value
	else
		id = "outline_" .. e:get("id").value
	end
	local cached_e = Cache.get_entity(id)
	if cached_e then
		cached_e:remove("hidden")
		return
	end

	local pos = e:get("pos")
	local x, y = pos.x - "4", pos.y - "4"
	local outline_e = Concord.entity(self.world)
		:give("id", id)
		:give("pos", x, y)
		:give("sprite", sprite.resource_id)
		:give("outline")
		:give("outline_val", e:get("outline_val").value)
		:give("z_index", e:get("z_index").value - 1, false)

	local quad = e:get("quad")
	if quad then
		local qx, qy, qw, qh = quad.quad:getViewport()
		local qsw, qsh = quad.quad:getTextureDimensions()
		local qt = e:get("quad_transform")
		if qt then
			outline_e:give("quad_transform", 0, qt.sx, qt.sy)
		end

		qx = qx - "4"
		qy = qy - "4"
		qw = qw + "4" * 2
		qh = qh + "4" * 2
		local nq = love.graphics.newQuad(qx, qy, qw, qh, qsw, qsh)
		outline_e:give("quad", nq)
	end
end

function Outline:on_change_interactive(e, other)
	self:remove_outlines()
	self:on_collide_interactive(e, other)
end

function Outline:on_collide_interactive(_, other)
	local other_grouped = other:get("grouped")
	if other_grouped then
		for _, e in ipairs(self.pool_grouped) do
			if e:get("grouped").value == other_grouped.value then
				self:create_outline(e)
			end
		end
	else
		self:create_outline(other)
	end
end

function Outline:on_leave_interactive(_, other)
	self:remove_outlines()
end

function Outline:remove_outlines()
	for _, e in ipairs(self.pool) do
		e:give("hidden")
		if not Cache.has_entity(e) then
			Cache.add_entity(e)
		end
	end
end

function Outline:cleanup()
	for _, e in ipairs(self.pool) do
		Cache.remove_entity(e)
		e:destroy()
	end
	Log.info("cleaned cache by system/outline")
end

return Outline
