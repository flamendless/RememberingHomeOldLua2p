local Concord = require("modules.concord.concord")
local Flux = require("modules.flux.flux")
local Lume = require("modules.lume.lume")

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
	if not (e.__isEntity and e.text_with_paint) then
		error("Assertion failed: e.__isEntity and e.text_with_paint")
	end
	if not (type(dur) == "number") then
		error('Assertion failed: type(dur) == "number"')
	end
	if widest then
		if not (type(widest) == "string") then
			error('Assertion failed: type(widest) == "string"')
		end
	end
	self:show_paint(e, dur, widest)
	e:remove("hidden")
	Flux.to(e.color.value, dur, { [4] = 1 })
end

function TextPaint:fade_text_paint(e, dur, on_complete)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not e.text_with_paint then
		error("Assertion failed: e.text_with_paint")
	end
	if not e.text_with_paint.e_paint.paint then
		error("Assertion failed: e.text_with_paint.e_paint.paint")
	end
	if not (type(dur) == "number") then
		error('Assertion failed: type(dur) == "number"')
	end
	if on_complete then
		if not (type(on_complete) == "function") then
			error('Assertion failed: type(on_complete) == "function"')
		end
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
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not (type(dur_in) == "number") then
		error('Assertion failed: type(dur_in) == "number"')
	end
	if widest then
		if not (type(widest) == "string") then
			error('Assertion failed: type(widest) == "string"')
		end
	end
	if e.static_text then
		if not (e.static_text ~= nil) then
			error("Assertion failed: e.static_text ~= nil")
		end
	end
	if e.text then
		if not (e.text ~= nil) then
			error("Assertion failed: e.text ~= nil")
		end
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
		x = text_pos.x + str_w * 0.5
		y = text_pos.y + str_h * 0.5
	end

	local paint_id = e.text_with_paint.id
	local paint = Concord.entity(self.world)
		:give("id", "text_paint")
		:give("pos", x, y)
		:give("animation_data", e.animation_data.data)
		:give("animation", true)
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
	if not paint.__isEntity then
		error("Assertion failed: paint.__isEntity")
	end
	if not (type(dur) == "number") then
		error('Assertion failed: type(dur) == "number"')
	end
	if not paint.paint then
		error("Assertion failed: paint.paint")
	end
	if delay then
		if not (type(delay) == "number") then
			error('Assertion failed: type(delay) == "number"')
		end
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
