local Kitchen = {
	lights = {},
}

local pl = Data.Lights.kitchen.pl
for i, pos in ipairs(pl.pos) do
	Kitchen.lights["pl" .. i] = function(e)
		e:assemble(Assemblages.Light.point, pos.x, pos.y, pl.lz, pl.ls, Palette.get_diffuse("kitchen_side"))
			:give("id", "pl" .. i)
			:give("light_group", "side_pl")
			:give("light_switch_id", "top")
			:give("light_fading", pl.fade, -1)
	end
end

local pl_mid = Data.Lights.kitchen.pl_mid
for i, pos in ipairs(pl_mid.pos) do
	Kitchen.lights["pl_mid" .. i] = function(e)
		e:assemble(Assemblages.Light.point, pos.x, 57, pl_mid.lz, pl_mid.ls, Palette.get_diffuse("kitchen_mid_pl"))
			:give("id", "pl_mid" .. i)
			:give("light_group", "mid_pl")
			:give("light_switch_id", "bottom")
			:give("light_fading", pl_mid.fade, -1)
	end
end

return Kitchen
