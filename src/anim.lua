local Anim = {}
Anim.__index = Anim

local function prepare_clip(clip)
	assert(type(clip) == "table", clip)
	assert(type(clip.resource_id) == "string", clip.resource_id)
	assert(type(clip.frames) == "table", clip.frames)
	assert(type(clip.rows_count) == "number", clip.rows_count)
	assert(type(clip.columns_count) == "number", clip.columns_count)

	clip.spritesheet = Resources.data.images[clip.resource_id]
	assert(clip.spritesheet, clip.resource_id)
	clip.sheet_width, clip.sheet_height = clip.spritesheet:getDimensions()
	clip.frame_width = math.floor(clip.sheet_width / clip.columns_count)
	clip.frame_height = math.floor(clip.sheet_height / clip.rows_count)
	return clip
end

local function prepare_clips(data, mods)
	assert(type(data) == "table", data)
	for _, clip in pairs(data) do
		prepare_clip(clip)
	end
	if mods then
		for tag, v in pairs(mods) do
			assert(data[tag], tag)
			local target = v[1]
			data[target] = tablex.copy(data[tag])
			data[target].is_flipped = true
		end
	end
	return data
end

local function new(clips, first, is_multi)
	local self = setmetatable({}, Anim)
	self.clips = clips
	self.cache = {}
	self.callbacks = {}
	self.is_multi = is_multi
	self.current_tag = nil
	self.base_tag = nil
	self.is_playing = true
	self.is_flipped = false
	self.frame = 1
	self.frame_max = 0
	self.dirty = true
	self:_build(first, first)
	return self
end

function Anim.new_single(clip)
	prepare_clip(clip)
	return new({ default = clip }, "default", false)
end

function Anim.new_multi(data, mods, first)
	assert(type(first) == "string", first)
	prepare_clips(data, mods)
	assert(data[first], first)
	return new(data, first, true)
end

function Anim:set_data(data, mods, first)
	prepare_clips(data, mods)
	if first then
		assert(data[first], first)
	end
	self.clips = data
	self.cache = {}
	self.callbacks = {}
end

function Anim:_build(tag, base_tag)
	local clip = self.clips[tag]
	assert(clip, tag)

	local cached = self.cache[tag]
	local obj_grid, obj_animation
	if cached then
		obj_grid = cached.grid
		obj_animation = cached.animation
	else
		obj_grid = Anim8.newGrid(
			clip.frame_width, clip.frame_height, clip.sheet_width, clip.sheet_height
		)
		obj_animation = Anim8.newAnimation(obj_grid(unpack(clip.frames)), clip.delay, function(_, loops)
			self:_on_loop(loops)
		end)
		if clip.is_flipped then
			obj_animation:flipH()
		end
		self.cache[tag] = { grid = obj_grid, animation = obj_animation }
	end

	self.grid = obj_grid
	self.anim8 = obj_animation
	self.current_tag = tag
	self.base_tag = base_tag or tag
	self.is_flipped = clip.is_flipped == true
	self.frame_max = #obj_animation.frames
	self.frame = obj_animation.position

	if clip.start_frame then
		obj_animation:gotoFrame(clip.start_frame)
	end

	self.dirty = true
	return clip
end

function Anim:_on_loop(loops)
	self:emit("loop", loops)
	if self.callbacks.finish then
		self:emit("finish")
	end
end

function Anim:on(event, fn)
	assert(type(event) == "string", event)
	assert(type(fn) == "function", fn)
	local cbs = self.callbacks[event]
	if not cbs then
		cbs = {}
		self.callbacks[event] = cbs
	end
	cbs[#cbs + 1] = { fn = fn, once = false }
	return self
end

function Anim:once(event, fn)
	assert(type(event) == "string", event)
	assert(type(fn) == "function", fn)
	local cbs = self.callbacks[event]
	if not cbs then
		cbs = {}
		self.callbacks[event] = cbs
	end
	cbs[#cbs + 1] = { fn = fn, once = true }
	return self
end

function Anim:off(event)
	self.callbacks[event] = nil
	return self
end

function Anim:emit(event, ...)
	local cbs = self.callbacks[event]
	if not cbs then
		return
	end
	local keep
	for i = 1, #cbs do
		local cb = cbs[i]
		cb.fn(...)
		if not cb.once then
			keep = keep or {}
			keep[#keep + 1] = cb
		end
	end
	self.callbacks[event] = keep
end

function Anim:play(tag, base_tag, override)
	assert(type(tag) == "string", tag)
	if base_tag then
		assert(type(base_tag) == "string", base_tag)
	end
	if not override and tag == self.current_tag then
		return self
	end
	self.callbacks = {}
	self:_build(tag, base_tag)
	self.anim8:gotoFrame(1)
	self.anim8:resume()
	self.is_playing = true
	return self
end

function Anim:update(dt)
	local a = self.anim8
	a:update(dt)
	self.frame = a.position
	self.is_playing = a.status == "playing"
	self:emit("update", dt)
end

function Anim:pause_at_start()
	self.anim8:pauseAtStart()
	self.is_playing = false
	return self
end

function Anim:pause_at_end()
	self.anim8:pauseAtEnd()
	self.is_playing = false
	return self
end

function Anim:goto_frame(n)
	assert(type(n) == "number" and n > 0, n)
	self.anim8:gotoFrame(n)
	self.frame = self.anim8.position
	return self
end

function Anim:stop(event)
	assert(type(event) == "string", event)
	self.anim8[event](self.anim8)
	self.is_playing = false
	self:emit("finish")
	return self
end

function Anim:resume()
	self.anim8:resume()
	self.is_playing = true
	return self
end

function Anim:invalidate_tag(tag)
	if tag then
		self.cache[tag] = nil
	else
		self.cache = {}
	end
	return self
end

function Anim:current_clip()
	return self.clips[self.current_tag]
end

function Anim:get_quad()
	return (self.anim8:getFrameInfo())
end

function Anim:get_frame_info()
	return self.anim8:getFrameInfo()
end

return Anim
