local Circle = {
	id = "Circle",
}

function Circle.render(e)
	local pos = e:get("pos")
	local circle = e:get("circle")
	local mode = e:get("draw_mode").value
	local arc_type
	if e:has("arc_type") then
		arc_type = e:get("arc_type")
	end

	local line_width
	if e:has("line_width") then
		line_width = e:get("line_width")
	end
	if line_width then
		love.graphics.setLineWidth(line_width.value)
	end

	if circle.is_arc then
		if arc_type then
			love.graphics.arc(
				mode,
				arc_type.value,
				pos.x,
				pos.y,
				circle.radius,
				circle.start_angle,
				circle.end_angle,
				circle.segments
			)
		else
			love.graphics.arc(mode, pos.x, pos.y, circle.radius, circle.start_angle, circle.end_angle, circle.segments)
		end
	else
		love.graphics.circle(mode, pos.x, pos.y, circle.radius, circle.segments)
	end
end

return Circle
