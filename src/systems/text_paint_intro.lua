local TextPaintIntro = Concord.system()

function TextPaintIntro:init(world)
	self.world = world
end

function TextPaintIntro:fade_text(e, dur, on_finish)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not (type(dur) == "number") then
		error('Assertion failed: type(dur) == "number"')
	end
	if not (type(on_finish) == "function") then
		error('Assertion failed: type(on_finish) == "function"')
	end
	self:generate_paint(e, dur)
	e:remove("hidden")

	local color = e.color
	Flux.to(color.value, dur, { [4] = 1 }):oncomplete(function()
		Flux.to(color.value, dur, { [4] = 0 }):oncomplete(on_finish)
	end)
end

function TextPaintIntro:generate_paint(e, dur_in, dur_out)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not (type(dur_in) == "number") then
		error('Assertion failed: type(dur_in) == "number"')
	end
	if dur_out then
		if not (type(dur_out) == "number") then
			error('Assertion failed: type(dur_out) == "number"')
		end
	end
	local transform = e.transform
	local text = e.static_text.value
	local font = e.font.value
	local str_w = font:getWidth(text)
	local str_h = font:getHeight(text)
	local offset = 96
	local text_pos = e.pos
	local x = text_pos.x + str_w/2
	local y = text_pos.y + str_h/2
	local chance = Lume.randomchoice({ true, false })
	local sx = chance == true and -1 or 1

	if transform then
		x = text_pos.x
		y = text_pos.y
	end

	local paint = Concord.entity(self.world)
		:give("id", "text_paint_intro")
		:give("animation_data", e.animation_data.data)
		:give("ui_element")
		:give("pos", x, y)
		:give("animation", true)
		:give("auto_scale", str_w + offset, str_h + offset, false)
		:give("transform", 0, sx, nil, 0.5, 0.5)
		:give("color", { 1, 1, 1, 0 })
		:give("layer", "text", 1)

	local color = paint.color

	Flux.to(color.value, dur_in, { [4] = 1 }):oncomplete(function()
		Flux.to(color.value, dur_out or dur_in, { [4] = 0 }):delay(1):oncomplete(function()
			paint:destroy()
		end)
	end)
end

return TextPaintIntro
