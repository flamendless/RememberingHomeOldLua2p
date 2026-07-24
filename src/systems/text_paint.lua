local TextPaint = Concord.system({
	pool_text = { "text_with_paint" },
	pool_paint = { "paint" },
})

local def_delay_paint = 1
local def_delay_task = 1
local dur_flash = 0.15

local function flash_to_color(source, target_a, target_b, dur, count, current)
	local n = current or 0

	Flux.to(source, dur, {
		[1] = target_a[1],
		[2] = target_a[2],
		[3] = target_a[3],
	}):oncomplete(function()
		if n <= count then
			n = n + 1
			flash_to_color(source, target_b, target_a, dur, count, n)
		end
	end)
end

function TextPaint:init(world)
	self.world = world
end

function TextPaint:show_text_paint(e, dur, widest)
	assert((e.__isEntity and e.text_with_paint), e)
	assert(type(dur) == "number", dur)
	if widest then
		assert(type(widest) == "string", widest)
	end
	self:show_paint(e, dur, widest)
	e:remove("hidden")
	Flux.to(e.color.value, dur, { [4] = 1 })
end

function TextPaint:fade_text_paint(e, dur, on_complete)
	assert(e.__isEntity, e)
	assert(e.text_with_paint, e)
	assert(e.text_with_paint.e_paint.paint, e)
	assert(type(dur) == "number", dur)
	if on_complete then
		assert(type(on_complete) == "function", on_complete)
	end
	local delay = 0

	if e.task then
		local target = e.task.value
		local original = { unpack(e.color.value) }

		flash_to_color(e.color.value, target, original, dur_flash, 2)
		delay = def_delay_task
	end

	Flux.to(e.color.value, dur, { [4] = 0 }):delay(delay):oncomplete(function()
		if on_complete then
			on_complete()
		end

		e:give("hidden")
		-- e:destroy()
	end)
	self:fade_paint(e.text_with_paint.e_paint, dur, delay)
end

function TextPaint:show_paint(e, dur_in, widest)
	assert(e.__isEntity, e)
	assert(type(dur_in) == "number", dur_in)
	if widest then
		assert(type(widest) == "string", widest)
	end
	if e.static_text then
		assert(e.static_text ~= nil, e.static_text)
	end
	if e.text then
		assert(e.text ~= nil, e.text)
	end
	local str
	local text = e.text
	local static_text = e.static_text

	if static_text then
		str = static_text.value
	else
		str = text.value
	end

	local font = e.font.value
	local transform = e.transform
	local str_w = font:getWidth(widest or str)
	local str_h = font:getHeight(str)
	local offset = 96
	local x, y
	local text_pos = e.pos
	local chance = Lume.randomchoice({ true, false })
	local sx = chance == true and -1 or 1
	local sy = 0.75

	if transform then
		x = text_pos.x
		y = text_pos.y
	else
		x = text_pos.x + str_w/2
		y = text_pos.y + str_h/2
	end

	local paint = Concord.entity(self.world)
		:give("id", "text_paint")
		:give("pos", x, y)
		:give("animation", Animation.new_single(tablex.copy(e.animation.obj:current_clip()), true))
		:give("auto_scale", str_w + offset, str_h + offset, false)
		:give("transform", 0, sx, sy, 0.5, 0.5)
		:give("color", { 1, 1, 1, 0 })
		:give("paint")
		:give("ui_element")
		:ensure("key")

	e.text_with_paint.e_paint = paint
	Flux.to(paint.color.value, dur_in, { [4] = 1 })
end

function TextPaint:fade_paint(paint, dur, delay)
	assert(paint.__isEntity, paint)
	assert(type(dur) == "number", dur)
	assert(paint.paint, paint)
	if delay then
		assert(type(delay) == "number", delay)
	end
	Flux.to(paint.color.value, dur, { [4] = 0 }):delay(delay or def_delay_paint):oncomplete(function()
		paint:destroy()
	end)
end

function TextPaint:toggle_paint(bool)
	for _, e in ipairs(self.pool_text) do
		if bool then
			e:give("hidden")
		else
			e:remove("hidden")
		end
	end

	for _, e in ipairs(self.pool_paint) do
		if bool then
			e:give("hidden")
		else
			e:remove("hidden")
		end
	end
end

function TextPaint:interactive_interacted()
	self:toggle_paint(true)
end

function TextPaint:interact_cancelled()
	self:toggle_paint(false)
end

return TextPaint
