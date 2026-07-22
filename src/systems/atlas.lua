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
	assert((self.pool:has(e)), self)
	assert(type(new_data) == "table", new_data)
	local quad = e.quad
	quad.quad:setViewport(new_data.x, new_data.y, new_data.w, new_data.h)
	quad.info = tablex.copy(new_data)
end

return Atlas
