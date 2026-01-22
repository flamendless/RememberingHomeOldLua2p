local Text = {
	id = "Text",
}

function Text.render(e)
	local str = (e.text and e.text.value) or (e.static_text and e.static_text.value)
	if (not str) or #str == 0 then
		return
	end

	local font = e.font or e.font_sdf
	if font then
		love.graphics.setFont(font.value)
	end

	local current_font = love.graphics.getFont()
	local r, sx, sy, ox, oy, kx, ky

	local textf = e.textf
	local static_text = e.static_text
	local transform = e.transform
	if transform then
		r = transform.rotation
		sx, sy = transform.sx, transform.sy
		ox, oy = transform.ox, transform.oy
		kx, ky = transform.kx, transform.ky

		if transform.ox == 0.5 then
			if static_text then
				ox = static_text.obj:getWidth()/2
			elseif textf then
				ox = textf.limit/2
			else
				ox = current_font:getWidth(str)/2
			end
		end

		if transform.oy == 0.5 then
			if static_text then
				oy = static_text.obj:getHeight()/2
			elseif textf then
				local lines = current_font:getWidth(str) / textf.limit
				lines = math.ceil(lines)
				oy = current_font:getHeight()/2 * lines
			else
				oy = current_font:getHeight()/2
			end
		elseif transform.oy == 1 then
			if static_text then
				oy = static_text.obj:getHeight()
			else
				oy = current_font:getHeight()
			end
		end
	end

	local sdf = e.sdf
	if sdf then
		sx = sdf.sx
		sy = sdf.sy
	end

	local pos = e.pos
	local x, y = pos.x, pos.y

	local rfp = e.reflowprint
	if rfp then
		x = x - ox
		y = y - oy
		ReflowPrint(rfp.dt / rfp.current, str, x, y, rfp.width, rfp.alignment, sx, sy)
	elseif static_text then
		love.graphics.draw(static_text.obj, x, y, r, sx, sy, ox, oy, kx, ky)
	elseif textf then
		love.graphics.printf(str, x, y, textf.limit, textf.align, r, sx, sy, ox, oy)
	else
		love.graphics.print(str, x, y, r, sx, sy, ox, oy, kx, ky)
	end
end

return Text
