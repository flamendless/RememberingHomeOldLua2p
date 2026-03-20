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

-- local pc_light = Data.Lights.office1.pc_light
-- Office1.lights.pc_light = function(e)
-- 	e:assemble(
-- 		Assemblages.Light.spot,
-- 		pc_light.pos.x,
-- 		pc_light.pos.y,
-- 		pc_light.lz,
-- 		{ -32, 0, 0.49, 0.16 },
-- 		pc_light.ls,
-- 		Palette.get_diffuse("office1_pc")
-- 	)
-- 		:give("id", "pc_light")
-- 		:give("light_fading", pc_light.fade, -1)
-- end

return Office1
