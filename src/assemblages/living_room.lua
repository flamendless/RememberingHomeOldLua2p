local LivingRoom = {
	lights = {},
}

local pl = Data.Lights.living_room.pl
for i, pos in ipairs(pl.pos) do
	LivingRoom.lights["pl" .. i] = function(e)
		e:assemble(Assemblages.Light.point, pos.x, pos.y, pl.lz, pl.ls, Palette.get_diffuse("living_room_side"))
			:give("id", "pl" .. i)
			:give("light_group", "side_pl")
			:give("light_switch_id", "top")
			:give("light_fading", pl.fade, -1)
	end
end

local pl_mid = Data.Lights.living_room.pl_mid
for i, pos in ipairs(pl_mid.pos) do
	LivingRoom.lights["pl_mid" .. i] = function(e)
		e:assemble(Assemblages.Light.point, pos.x, pos.y, pl_mid.lz, pl_mid.ls, Palette.get_diffuse("living_room_mid_pl"))
			:give("id", "pl_mid" .. i)
			:give("light_group", "pl_mid")
			:give("light_switch_id", "bottom")
			:give("light_fading", pl_mid.fade, -1)
	end
end

return LivingRoom
