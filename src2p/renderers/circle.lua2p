local Circle = {
	id = "Circle"
}

function Circle.render(e)
	local pos = e.pos
	local circle = e.circle
	local mode = e.draw_mode.value
	local arc_type = e.arc_type

	local line_width = e.line_width
	if line_width then
		love.graphics.setLineWidth(line_width.value)
	end

	if circle.is_arc then
		if arc_type then
			love.graphics.arc(mode, arc_type.value, pos.x, pos.y,
				circle.radius, circle.start_angle, circle.end_angle, circle.segments)
		else
			love.graphics.arc(mode, pos.x, pos.y,
				circle.radius, circle.start_angle, circle.end_angle, circle.segments)
		end
	else
		love.graphics.circle(mode, pos.x, pos.y, circle.radius, circle.segments)
	end
end

return Circle
