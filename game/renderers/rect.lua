local Rect = {
	id = "Rect"
}

function Rect.render(e)
	local pos = e.pos
	local rect = e.rect
	local draw_mode = e.draw_mode.value
	local x, y, w, h = pos.x, pos.y, rect.w, rect.h
	local rx, ry = 0, 0

	local border = e.rect_border
	if border then
		rx = border.rx
		ry = border.ry
	end

	local t = e.transform
	if t then
		w = w * t.sx
		h = h * t.sy
		if t.ox == 0.5 then
			x = x - rect.half_w
		elseif t.ox == 1 then
			x = x - w
		end
		if t.oy == 0.5 then
			y = y - rect.half_h
		elseif t.oy == 1 then
			y = y - h
		end
	end

	local lw, temp_lw = e.line_width
	if lw then
		temp_lw = love.graphics.getLineWidth()
		love.graphics.setLineWidth(lw.value)
	end

	love.graphics.setLineStyle("rough")
	love.graphics.rectangle(draw_mode, x, y, w, h, rx, ry)

	if lw then
		love.graphics.setLineWidth(temp_lw)
	end
end

return Rect
