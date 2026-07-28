local Text = {
	id = "Text",
}

function Text.render(e)
	local str
	if e:has("text") then
		str = e:get("text").value
	elseif e:has("static_text") then
		str = e:get("static_text").value
	end
	if (not str) or #str == 0 then
		return
	end

	if e:has("font") then
		love.graphics.setFont(e:get("font").value)
	end

	local current_font = love.graphics.getFont()
	local r, sx, sy, ox, oy, kx, ky

	local textf
	if e:has("textf") then
		textf = e:get("textf")
	end
	local static_text
	if e:has("static_text") then
		static_text = e:get("static_text")
	end
	local transform
	if e:has("transform") then
		transform = e:get("transform")
	end
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

	local pos = e:get("pos")
	local x, y = pos.x, pos.y

	local rfp
	if e:has("reflowprint") then
		rfp = e:get("reflowprint")
	end
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
