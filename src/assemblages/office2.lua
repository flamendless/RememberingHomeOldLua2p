local Office2 = {
	lights = {},
	glows = {},
}

local pl = Data.Lights.office2.pl
for i, pos in ipairs(pl.pos) do
	Office2.lights["pl" .. i] = function(e)
		e:assemble(Assemblages.Light.point, pos.x, pos.y, pl.lz, pl.ls, Palette.get_diffuse("office2_sides"))
			:give("id", "pl" .. i)
			:give("light_group", "side_pl")
			:give("light_switch_id", "top")
			:give("light_fading", pl.fade, -1)
	end
end

return Office2
