local Candle = Concord.system({
	pool = { "candle", "pos" },
})

local FLAME_OFFSET_Y = Assemblages.Candle.flame_offset_y()

function Candle:init(world)
	self.world = world
end

function Candle:spawn_candle(x, y)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)

	local flame_y = y + FLAME_OFFSET_Y
	local e_flame = Concord.entity(self.world):assemble(Assemblages.Light.candle_flame, x, flame_y)
	Concord.entity(self.world):assemble(Assemblages.Candle.candle, x, y, e_flame)
end

function Candle:update(dt)
	for _, e in ipairs(self.pool) do
		local e_flame = e.candle.e_flame
		local anchor = e_flame.flame_anchor
		anchor.base_x = e.pos.x
		anchor.base_y = e.pos.y + FLAME_OFFSET_Y
		anchor.dir = 1
	end
end

function Candle:on_flame_blown_out(e_flame)
	for _, e in ipairs(self.pool) do
		if e.candle.e_flame == e_flame then
			e.candle.is_extinguished = true
		end
	end
end

function Candle:on_interact_candle(e_player, e_candle)
	assert(e_player.__isEntity and e_player.player, e_player)
	assert(e_candle.__isEntity and e_candle.candle, e_candle)

	if not e_candle.candle.is_extinguished then
		return
	end

	local e_flame = e_candle.candle.e_flame
	e_flame.flame_windable.extinguished = false
	e_candle.candle.is_extinguished = false
end

return Candle
