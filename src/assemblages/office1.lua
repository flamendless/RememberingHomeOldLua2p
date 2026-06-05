local Office1 = {
	lights = {},
	glows = {},
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

local pc_light = Data.Lights.office1.pc_light
Office1.glows.pc_glow = function(world)
	local grid_center_x = pc_light.x + pc_light.w * 0.5
	local grid_center_y = pc_light.y + pc_light.h * 0.5
	local cell_w = pc_light.w / pc_light.cols
	local cell_h = pc_light.h / pc_light.rows
	local glow_size = math.min(cell_w, cell_h) * 2

	local es = {}
	for _ = 1, pc_light.rows * pc_light.cols do
		table.insert(es, Concord.entity(world))
	end

	Assemblages.BillboardGlow.create_grid(
		es,
		grid_center_x,
		grid_center_y,
		pc_light.z + 1,
		pc_light.rows,
		pc_light.cols,
		cell_w,
		cell_h,
		1,
		Palette.get_diffuse("office1_pc"),
		glow_size
	)

	for i, e in ipairs(es) do
		e:give("id", "pc_glow" .. i)
			:give("glow_pulse", 8, 8)
			:give("glow_group", "pc_glow")
	end

	local _ = Concord.entity(world)
		:give("id", "pc_glow_blocker")
		:give("pos", grid_center_x + 2, grid_center_y + 2, pc_light.z)
		:give("rect", 16, 18)
		:give("glow_blocker")
end

return Office1
