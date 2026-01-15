local c_anim_data = Concord.component("animation_data", function(c, data)
	if not (type(data) == "table") then
		error('Assertion failed: type(data) == "table"')
	end
	if not (data.resource_id and type(data.resource_id) == "string") then
		error('Assertion failed: data.resource_id and type(data.resource_id) == "string"')
	end
	if not (type(data.frames) == "table") then
		error('Assertion failed: type(data.frames) == "table"')
	end
	if not (type(data.rows_count) == "number") then
		error('Assertion failed: type(data.rows_count) == "number"')
	end
	if not (type(data.columns_count) == "number") then
		error('Assertion failed: type(data.columns_count) == "number"')
	end
	if data.n_frames then
		if not (type(data.n_frames) == "number") then
			error('Assertion failed: type(data.n_frames) == "number"')
		end
	end
	if data.start_frame then
		if not (data.start_frame >= 1 and data.start_frame <= data.n_frames) then
			error("Assertion failed: data.start_frame >= 1 and data.start_frame <= data.n_frames")
		end
	end
	if data.delay then
		if not (
			type(data.delay) == "table" or
			type(data.delay) == "number"
		) then
			error('Assertion failed: type(data.delay) == "table" or "number"')
		end
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
