local AsmCandle = {}

local FLAME_OFFSET_Y = -12

function AsmCandle.candle(e, x, y, e_flame)
	assert(e.__isEntity, e)
	assert:type(x, "number")
	assert:type(y, "number")
	assert(e_flame.__isEntity, e_flame)

	local info = Items.get_info(Enums.item_id.lighter1)
	e:give("id", "candle")
		:give("sprite", info.id)
		:give("pos", x, y)
		:give("transform", 0, 1, 1, 0.5, 0.5)
		:give("z_index", 50)
		:give("collider", 16, 24, Enums.bump_filter.cross)
		:give("bump")
		:give("interactive")
		:give("candle", e_flame)
		:give("color", { 1, 1, 1, 1 })
end

function AsmCandle.flame_offset_y()
	return FLAME_OFFSET_Y
end

return AsmCandle
