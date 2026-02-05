local Atlas = Concord.system({
	pool = { "atlas", "sprite" },
})

local function create_quad(e)
	local sprite = e.sprite
	local atlas = e.atlas.value
	return love.graphics.newQuad(atlas.x, atlas.y, atlas.w, atlas.h, sprite.iw, sprite.ih)
end

function Atlas:init()
	self.pool.onAdded = function(pool, e)
		e:give("quad", create_quad(e))
	end
end

function Atlas:update_atlas(e, new_data)
	if not (self.pool:has(e)) then
		error("Assertion failed: self.pool:has(e)")
	end
	if type(new_data) ~= "table" then
		error('Assertion failed: type(new_data) == "table"')
	end
	local quad = e.quad
	quad.quad:setViewport(new_data.x, new_data.y, new_data.w, new_data.h)
	quad.info = tablex.copy(new_data)
end

return Atlas
