local FontSDF = {
	__typeName   = "fontsdf",
	__fontLookup = setmetatable({}, {__mode = "v"}),
}
FontSDF.mt = {__index = FontSDF}

function FontSDF.new(fileName, imageFileName, isMSDF)
	local fontSDF = setmetatable({
		font = love.graphics.newFont(fileName, imageFileName),

		weight = 0.2,

		isMSDF = isMSDF or false
	}, FontSDF.mt)

	FontSDF.__fontLookup[fontSDF.font] = fontSDF

	return fontSDF
end

-- FontSDF methods
function FontSDF:setWeight(weight)
	self.weight = weight
end

function FontSDF:getWeight()
	return self.weight
end

function FontSDF:setSmoothing()
end

function FontSDF:getSmoothing()
end

function FontSDF:setOutlineWeight(weight)
end

function FontSDF:getOutlineWeight()
end

function FontSDF:setOutlineColor(r, g, b, a)
end

function FontSDF:getOutlineColor()
end

function FontSDF:setShadowOffset(ox, oy)
end

function FontSDF:getShadowOffset(ox, oy)
end

function FontSDF:setShadowColor(r, g, b, a)
end

function FontSDF:getShadowColor(r, g, b, a)
end

function FontSDF:attach(shader)
	shader:send("weight", self.weight)
end

-- Font methods
function FontSDF:getAscent()
	return self.font:getAscent()
end

function FontSDF:getBaseline()
	return self.font:getBasline()
end

function FontSDF:getDPIScale()
	return self.font:getDPIScale()
end

function FontSDF:getFilter()
	return self.font:getFilter()
end

function FontSDF:getHeight()
	return self.font:getHeight()
end

function FontSDF:getLineHeight()
	return self.font:getLineHeight()
end

function FontSDF:getWidth(...)
	return self.font:getWidth(...)
end

function FontSDF:getWrap(...)
	return self.font:getWrap(...)
end

function FontSDF:hasGlyphs(...)
	return self.font:hasGlyphs(...)
end

function FontSDF:setFallbacks(...)
	return self.font:setFallbacks(...)
end

function FontSDF:setFilter(...)
	return self.font:setFilter(...)
end

function FontSDF:setLineHeight(...)
	return self.font:setLineHeight(...)
end

-- Object methods
function FontSDF:release()
	self.font:release()
end

function FontSDF:type()
	return FontSDF.__typeName
end

function FontSDF:typeOf(name)
	return name == FontSDF.__typeName or self.font.typeOf(name)
end

return setmetatable(FontSDF, {
	__call = function(_, ...) return FontSDF.new(...) end,
})
