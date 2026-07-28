local Candle = Concord.system({
	pool = { "candle", "pos" },
})

local FLAME_OFFSET_Y = Assemblages.Candle.flame_offset_y()

function Candle:init(world)
	self.world = world
end

function Candle:spawn_candle(x, y)
	assert:type(x, "number")
	assert:type(y, "number")

	local flame_y = y + FLAME_OFFSET_Y
	local e_flame = Concord.entity(self.world):assemble(Assemblages.Light.candle_flame, x, flame_y)
	Concord.entity(self.world):assemble(Assemblages.Candle.candle, x, y, e_flame)
end

function Candle:update(dt)
	for _, e in ipairs(self.pool) do
		local candle = e:get("candle")
		local e_flame = candle.e_flame
		local anchor = e_flame:get("flame_anchor")
		local pos = e:get("pos")
		anchor.base_x = pos.x
		anchor.base_y = pos.y + FLAME_OFFSET_Y
		anchor.dir = 1
	end
end

function Candle:on_flame_blown_out(e_flame)
	for _, e in ipairs(self.pool) do
		local candle = e:get("candle")
		if candle.e_flame == e_flame then
			candle.is_extinguished = true
		end
	end
end

function Candle:on_interact_candle(e_player, e_candle)
	assert(e_player.__isEntity and e_player:has("player"), e_player)
	assert(e_candle.__isEntity and e_candle:has("candle"), e_candle)

	local candle = e_candle:get("candle")
	if not candle.is_extinguished then
		return
	end

	local e_flame = candle.e_flame
	e_flame:get("flame_windable").extinguished = false
	candle.is_extinguished = false
end

return Candle
