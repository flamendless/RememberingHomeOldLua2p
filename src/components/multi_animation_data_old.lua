local c = Concord.component("multi_animation_data_old", function(c, first, data, modifier)
	assert(type(first) == "string", first)
	assert(type(data) == "table", data)
	assert(data[first], "no " .. first .. " found in data")

	for _, v in pairs(data) do
		assert(type(v.resource_id) == "string", v.resource_id)
		assert(
			type(v.delay) == "string" or type(v.delay) == "table" or type(v.delay) == "number",
			v.delay
		)
		assert(type(v.rows_count) == "number", v.rows_count)
		assert(type(v.columns_count) == "number", v.columns_count)
		assert(type(v.n_frames) == "number", v.n_frames)
	end

	if modifier then
		assert(type(modifier) == "table", modifier)
	end
	if modifier then
		for id, v in pairs(modifier) do
			assert(data[id], id)
			assert(type(v[1]) == "string", v[1])
			assert(type(v[2]) == "string", v[2])
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
