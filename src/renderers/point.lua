local Point = {
	id = "Point",
}

function Point.render(e)
	assert:entity(e)
	local pos = e:get("pos")
	love.graphics.setPointSize(e:get("point").value)
	love.graphics.points(pos.x, pos.y)
end

return Point
