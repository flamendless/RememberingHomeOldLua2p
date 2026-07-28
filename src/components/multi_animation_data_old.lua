local c = Concord.component("multi_animation_data_old", function(c, first, data, modifier)
	assert:type(first, "string")
	assert:type(data, "table")
	assert(data[first], "no " .. first .. " found in data")

	for _, v in pairs(data) do
		assert:type(v.resource_id, "string")
		assert:one_of(type(v.delay), { "string", "table", "number" }, v.delay)
		assert:type(v.rows_count, "number")
		assert:type(v.columns_count, "number")
		assert:type(v.n_frames, "number")
	end

	assert:type_or_nil(modifier, "table")
	if modifier then
		for id, v in pairs(modifier) do
			assert(data[id], id)
			assert:type(v[1], "string")
			assert:type(v[2], "string")
		end
	end

	c.orig_data = data

	local TW, TH = 64, 64
	for _, v in pairs(data) do
		v.spritesheet = Resources.data.images[v.resource_id]
		v.sheet_width, v.sheet_height = v.spritesheet:getDimensions()
		v.frame_width = math.floor(v.sheet_width / v.columns_count)
		v.frame_height = math.floor(v.sheet_height / v.rows_count)
		assert(v.frame_width == TW, v.frame_width)
		assert(v.frame_height == TH, v.frame_height)
	end

	if modifier then
		for id, v in pairs(modifier) do
			local target = v[1]
			-- local action = v[2]
			data[target] = tablex.copy(data[id])
			data[target].is_flipped = true
		end
	end

	c.first = first
	c.data = data
	c.modifier = modifier
end)

function c:serialize()
	return {
		first = self.first,
		data = self.orig_data,
		modifier = self.modifier,
	}
end

function c:deserialize(data)
	self:__populate(data.first, data.data, data.modifier)
end
