local UIWrapper = {}

function UIWrapper.edit_number(id, value, is_int)
	local v = value
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
	return value, bool
end

function UIWrapper.edit_range(id, value, min, max, is_int)
	Slab.Text(id .. ":")
	Slab.SameLine()
	local bool = Slab.InputNumberSlider(id, value, min, max, {
		Precision = not is_int and 2 or 0,
	})
	if bool then
		value = Slab.GetInputNumber()
		if is_int then
			value = math.floor(value)
		end
	end
	return value, bool
end

if DEV then
	function UIWrapper.color(color)
		assert(type(color) == "table")
		assert(#color == 4 or #color == 3)
		color[1] = UIWrapper.edit_range("r", color[1], 0, 1)
		color[2] = UIWrapper.edit_range("g", color[2], 0, 1)
		color[3] = UIWrapper.edit_range("b", color[3], 0, 1)
		if #color == 4 then
			color[4] = UIWrapper.edit_range("a", color[4], 0, 1)
		end
	end
end

return UIWrapper
