utf8 = require"utf8"

reflowprint = require"reflowprint"

scalex,scaley = 1,1
alignment = "center"

function love.load()
	defaultFont = love.graphics.newFont()
	newFont = love.graphics.newFont(48)
	_dt = 0
	t = 1
	text="The quick brown fox jumped over the lazy dog."
end

function love.update(dt)
	dt = math.min(t,dt + 1)
end

function love.draw()
	_dt = _dt + love.timer.getDelta()
	love.window.setTitle("ScaleX: "..scalex.." ScaleY: "..scaley.." Alignment: "..alignment.." Text: "..text)

	local rpx,rpy,rpw,rph = 32,32,love.graphics.getWidth()/2-64,9000
	local bpx,bpy,bpw,bph = love.graphics.getWidth()/2+32,32,love.graphics.getWidth()/2-64,9000

	love.graphics.print("ReflowPrint",rpx,rpy-16)
	love.graphics.print("BadPrint",bpx,bpy-16)

	love.graphics.setFont(newFont)

	love.graphics.rectangle("line",rpx,rpy,rpw,rph)
	reflowprint(_dt/t,text,rpx,rpy,rpw,alignment,scalex,scaley)

	love.graphics.setFont(defaultFont)
end
