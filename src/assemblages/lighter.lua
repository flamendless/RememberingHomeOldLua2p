local AsmLighter = {}

function AsmLighter.lighter(e, e_player)
	assert(e.__isEntity)
	assert(e_player.__isEntity and e_player.player)

	--TODO: parametrize lighter variation 1 or 2
	local dir = e_player.body.dir
	local info = Items.get_info("lighter1")
	e:give("id", info.id)
		:give("sprite", info.id)
		:give("item", info.id, info.name, info.desc)
		:give("color", { 1, 1, 1, 1 })
		:give("pos", 0, 0)
		:give("transform", 0, -dir, 1, 0.5, 0.5)
		:give(
			"anchor",
			e_player,
			Enums.anchor.center,
			Enums.anchor.center,
			16 * dir,
			-16
		)
		:give("z_index", 99)
		:give("hidden")
end

return AsmLighter
