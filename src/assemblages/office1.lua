local Office1 = {
	lights = {},
}

local pl = Data.Lights.office1.pl
for i, pos in ipairs(pl.pos) do
	Office1.lights["pl" .. i] = function(e)
		e:assemble(Assemblages.Light.point, pos.x, pos.y, pl.lz, pl.ls, Palette.get_diffuse("office1_sides"))
			:give("id", "pl" .. i)
			:give("light_group", "side_pl")
			:give("light_switch_id", "top")
			:give("light_fading", pl.fade, -1)
	end
end

return Office1
