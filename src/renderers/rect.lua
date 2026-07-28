local Rect = {
	id = "Rect",
}

function Rect.render(e)
	local pos = e:get("pos")
	local rect = e:get("rect")
	local draw_mode = e:get("draw_mode").value
	local x, y, w, h = pos.x, pos.y, rect.w, rect.h
	local rx, ry = 0, 0

	local border
	if e:has("rect_border") then
		border = e:get("rect_border")
	end
	if border then
		rx = border.rx
		ry = border.ry
	end

	local t
	if e:has("transform") then
		t = e:get("transform")
	end
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

	local lw
	if e:has("line_width") then
		lw = e:get("line_width")
	end
	local temp_lw
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
