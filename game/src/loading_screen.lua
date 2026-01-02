local LoadingScreen = {}

local font_preload = love.graphics.newFont("res/fonts/Jamboree.ttf", 48)
font_preload:setFilter("nearest", "nearest")
local oy = font_preload:getHeight() * 0.5

local canvas, shader

function LoadingScreen.init()
	--TODO set shader here
	canvas = love.graphics.newCanvas()
end

function LoadingScreen.update(dt) end

function LoadingScreen.draw()
	local w, h = love.graphics.getDimensions()
	--TODO improve this
	love.graphics.setCanvas(canvas)
		love.graphics.clear()
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, w, h)

		local str_loading = string.format("LOADING: %i%%", Preloader.percent)
		local ox = font_preload:getWidth(str_loading) * 0.5
		love.graphics.setFont(font_preload)

		love.graphics.setColor(1, 1, 1, 0.75)
		love.graphics.print(str_loading, w * 0.5, h * 0.5, 0, 1, 1, ox, oy)
	love.graphics.setCanvas()

	-- love.graphics.setShader(shader.shader)
	love.graphics.draw(canvas)
	-- love.graphics.setShader()
end

return LoadingScreen
