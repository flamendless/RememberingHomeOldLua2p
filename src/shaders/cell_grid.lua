local CellGrid = class({
	name = Enums.shaders.cell_grid,
})

local function seed_vec(seed)
	return { seed * 1.37, seed * 2.71 }
end

function CellGrid:new(values)
	assert:type_or_nil(values, "table")
	self.is_active = true
	self.shader = love.graphics.newShader(Shaders.paths.cell_grid)

	local defaults = Data.BgAssets.default_preset
	values = values or {}

	if values.cell_size_min and not values.cell_size then
		values.cell_size = values.cell_size_min
	end

	self.cell_size = values.cell_size or defaults.cell_size
	self.levels = values.levels or defaults.levels
	self.dither_amount = values.dither_amount or defaults.dither_amount
	self.hue_preserve = values.hue_preserve or defaults.hue_preserve
	self.contrast = values.contrast or defaults.contrast
	self.offset = values.offset or defaults.offset
	self.grain = values.grain or defaults.grain
	self.seed = values.seed or defaults.seed
	self.light_enabled = values.light_enabled ~= nil and values.light_enabled or defaults.light_enabled
	self.light_pos = values.light_pos and tablex.copy(values.light_pos) or tablex.copy(defaults.light_pos)
	self.light_radius = values.light_radius or defaults.light_radius
	self.light_falloff = values.light_falloff or defaults.light_falloff

	self:send_values()
end

function CellGrid:get_params()
	return {
		cell_size = self.cell_size,
		levels = self.levels,
		dither_amount = self.dither_amount,
		hue_preserve = self.hue_preserve,
		contrast = self.contrast,
		offset = self.offset,
		grain = self.grain,
		seed = self.seed,
		light_enabled = self.light_enabled,
		light_pos = tablex.copy(self.light_pos),
		light_radius = self.light_radius,
		light_falloff = self.light_falloff,
	}
end

function CellGrid:set_params(values)
	assert:type(values, "table")
	if values.cell_size_min and not values.cell_size then
		values.cell_size = values.cell_size_min
	end
	for k, v in pairs(values) do
		if self[k] ~= nil then
			if k == "light_pos" then
				self.light_pos = tablex.copy(v)
			else
				self[k] = v
			end
		end
	end
	self:send_values()
end

function CellGrid:send_values(tex_w, tex_h)
	if tex_w and tex_h then
		self.shader:send("u_tex_size", { tex_w, tex_h })
	end
	self.shader:send("u_cell_size", self.cell_size)
	self.shader:send("u_levels", self.levels)
	self.shader:send("u_dither_amount", self.dither_amount)
	self.shader:send("u_hue_preserve", self.hue_preserve)
	self.shader:send("u_contrast", self.contrast)
	self.shader:send("u_offset", self.offset)
	self.shader:send("u_grain", self.grain)
	self.shader:send("u_seed", seed_vec(self.seed))
	self.shader:send("u_light_enabled", self.light_enabled and 1 or 0)
	self.shader:send("u_light_pos", self.light_pos)
	self.shader:send("u_light_radius", self.light_radius)
	self.shader:send("u_light_falloff", self.light_falloff)
end

return CellGrid
