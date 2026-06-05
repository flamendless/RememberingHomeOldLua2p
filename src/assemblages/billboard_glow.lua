local BillboardGlow = {}

function BillboardGlow.create(e, x, y, z, intensity, color, size)
	assert(e.__isEntity)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(type(z) == "number")
	assert(type(intensity) == "number")
	assert(type(color) == "table")
	assert(type(size) == "number")
	e:give("id", "billboard_glow")
		:give("pos", x, y, z)
		:give("billboard_glow", intensity, size)
		:give("z_index", z)
		:give("color", color)
	return e
end

function BillboardGlow.create_grid(
	es,
	center_x,
	center_y,
	z,
	rows,
	cols,
	cell_w,
	cell_h,
	intensity,
	color,
	size
)
	assert(type(es) == "table")
	assert(type(center_x) == "number")
	assert(type(center_y) == "number")
	assert(type(z) == "number")
	assert(type(rows) == "number")
	assert(type(cols) == "number")
	assert(type(cell_w) == "number")
	assert(type(cell_h) == "number")
	assert(type(intensity) == "number")
	assert(type(color) == "table")
	assert(type(size) == "number")

	local total_w = cell_w * (cols - 1)
	local total_h = cell_h * (rows - 1)
	local start_x = center_x - total_w * 0.5
	local start_y = center_y - total_h * 0.5

	for i = 0, rows - 1 do
		for j = 0, cols - 1 do
			local n = i * cols + j + 1
			local e = es[n]
			local px = start_x + j * cell_w
			local py = start_y + i * cell_h
			BillboardGlow.create(e, px, py, z, intensity, color, size)
		end
	end
end

return BillboardGlow
