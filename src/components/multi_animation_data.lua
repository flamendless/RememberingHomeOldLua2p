local c = Concord.component("multi_animation_data", function(c, first, data, modifier)
	if type(first) ~= "string" then
		error('Assertion failed: type(first) == "string"')
	end
	if type(data) ~= "table" then
		error('Assertion failed: type(data) == "table"')
	end
	if not data[first] then
		error("no " .. first .. " found in data")
	end

	for _, v in pairs(data) do
		if type(v.resource_id) ~= "string" then
			error('Assertion failed: type(v.resource_id) == "string"')
		end
		if not (type(v.delay) == "number" or type(v.delay) == "table") then
			error('Assertion failed: type(v.delay) == "number" or type(v.delay) == "table"')
		end
		if type(v.rows_count) ~= "number" then
			error('Assertion failed: type(v.rows_count) == "number"')
		end
		if type(v.columns_count) ~= "number" then
			error('Assertion failed: type(v.columns_count) == "number"')
		end
		if type(v.n_frames) ~= "number" then
			error('Assertion failed: type(v.n_frames) == "number"')
		end
	end

	if modifier then
		if type(modifier) ~= "table" then
			error('Assertion failed: type(modifier) == "table"')
		end
	end
	if modifier then
		for id, v in pairs(modifier) do
			if not data[id] then
				error("Assertion failed: data[id]")
			end
			if type(v[1]) ~= "string" then
				error('Assertion failed: type(v[1]) == "string"')
			end
			if type(v[2]) ~= "string" then
				error('Assertion failed: type(v[2]) == "string"')
			end
		end
	end

	c.orig_data = data

	for _, v in pairs(data) do
		v.spritesheet = Resources.data.images[v.resource_id]
		v.sheet_width, v.sheet_height = v.spritesheet:getDimensions()
		v.frame_width = math.floor(v.sheet_width / v.columns_count)
		v.frame_height = math.floor(v.sheet_height / v.rows_count)
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
