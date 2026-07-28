local c_anim_data = Concord.component("animation_data_old", function(c, data)
	assert:type(data, "table")
	assert((data.resource_id and type(data.resource_id) == "string"), data.resource_id)
	assert:type(data.frames, "table")
	assert:type(data.rows_count, "number")
	assert:type(data.columns_count, "number")
	assert:type_or_nil(data.n_frames, "number")
	if data.start_frame then
		assert((data.start_frame >= 1 and data.start_frame <= data.n_frames), data)
	end
	if data.delay then
		assert:one_of(type(data.delay), { "table", "number" }, data.delay)
	end

	c.resource_id = data.resource_id
	c.spritesheet = Resources.data.images[c.resource_id]
	c.frames = data.frames
	c.delay = data.delay
	c.rows_count = data.rows_count
	c.columns_count = data.columns_count
	c.n_frames = data.n_frames
	c.start_frame = data.start_frame

	c.sheet_width = c.spritesheet:getWidth()
	c.sheet_height = c.spritesheet:getHeight()
	c.frame_width = math.floor(c.sheet_width / c.columns_count)
	c.frame_height = math.floor(c.sheet_height / c.rows_count)

	c.data = data
end)

function c_anim_data:serialize()
	return {
		data = self.data,
	}
end

function c_anim_data:deserialize(data)
	self:__populate(data.data)
end
