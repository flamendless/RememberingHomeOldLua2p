local UIWrapper = {}

function UIWrapper.edit_number(id, value, is_int)
	local v = value
	local initial = value
	if is_int then
		v = math.floor(v)
	end
	Slab.Text(id .. ":")
	Slab.SameLine()
	local bool = Slab.Input(id, {
		Text = tostring(v),
		ReturnOnText = false,
		NumbersOnly = true,
	})
	if bool then
		value = Slab.GetInputNumber()
		if is_int then
			value = math.floor(value)
		end
	end
	return value, bool, initial - value
end

function UIWrapper.edit_range(id, value, min, max, is_int, disabled)
	local initial = value
	Slab.Text(id .. ":")
	Slab.SameLine()
	local opts = {
		Precision = not is_int and 2 or 0,
	}
	if disabled then
		opts.Disabled = true
	end
	local bool = Slab.InputNumberSlider(id, value, min, max, opts)
	if bool then
		value = Slab.GetInputNumber()
		if is_int then
			value = math.floor(value)
		end
	end
	return value, bool, initial - value
end

function UIWrapper.color(color)
	assert:type(color, "table")
	assert(#color == 4 or #color == 3)
	color[1] = UIWrapper.edit_range("r", color[1], 0, 1)
	color[2] = UIWrapper.edit_range("g", color[2], 0, 1)
	color[3] = UIWrapper.edit_range("b", color[3], 0, 1)
	if #color == 4 then
		color[4] = UIWrapper.edit_range("a", color[4], 0, 1)
	end
end

function UIWrapper.edit_range_table(id, range, min, max, is_int)
	local vmin, cmin = UIWrapper.edit_range(id .. ".min", range.min, min, max, is_int)
	range.min = vmin
	local vmax, cmax = UIWrapper.edit_range(id .. ".max", range.max, min, max, is_int)
	range.max = vmax
	if range.max < range.min then
		range.max = range.min
	end
	return cmin or cmax
end

return UIWrapper
