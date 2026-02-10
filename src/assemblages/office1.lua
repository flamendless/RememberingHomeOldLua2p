local Office1 = {
	lights = {},
}

local pl = Data.Lights.office1.pl
for i, pos in ipairs(pl.pos) do
	Office1.lights["pl" .. i] = function(e)
		e:assemble(Assemblages.Light.point, pos.x, pos.y, pl.lz, pl.ls, Palette.get_diffuse("office1_side"))
			:give("id", "pl" .. i)
			:give("light_group", "side_pl")
			:give("light_switch_id", "top")
			:give("light_fading", pl.fade, -1)
	end
end

local pl_mid = Data.Lights.office1.pl_mid
for i, pos in ipairs(pl_mid.pos) do
	Office1.lights["pl_mid" .. i] = function(e)
		e:assemble(Assemblages.Light.point, pos.x, pos.y, pl_mid.lz, pl_mid.ls, Palette.get_diffuse("office1_mid_pl"))
			:give("id", "pl_mid" .. i)
			:give("light_group", "pl_mid")
			:give("light_switch_id", "bottom")
			:give("light_fading", pl_mid.fade, -1)
	end
end

return Office1
