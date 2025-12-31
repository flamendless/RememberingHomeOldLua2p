local PATH = (...):gsub('%.init$', '')
local DIR_PATH = PATH:gsub("%.", "/")

local FontSDF = require(PATH..".fontSDF")

local LoveSDF = {
	shaderSDF = love.graphics.newShader(
		"#define SDF;\n" ..love.filesystem.read(DIR_PATH.."/shader.glsl")
	),
	shaderMSDF = love.graphics.newShader(
		"#define MSDF;\n"..love.filesystem.read(DIR_PATH.."/shader.glsl")
	),

	lgOld = {
		setFont = love.graphics.setFont,
		print   = love.graphics.print,
		printf  = love.graphics.printf,
	},
}

function LoveSDF.newFontSDF(fileName, imageFileName)
	return FontSDF(fileName, imageFileName)
end

function LoveSDF.newFontMSDF(fileName, imageFileName)
	return FontSDF(fileName, imageFileName, true)
end

function LoveSDF.setFont(font)
	if (font:type() == "fontsdf") then
		-- Attach settings

		LoveSDF.lgOld.setFont(font.font)
	else
		LoveSDF.lgOld.setFont(font)
	end
end

function LoveSDF.print(...)
	local font = love.graphics.getFont()

	if (FontSDF.__fontLookup[font]) then
		font = FontSDF.__fontLookup[font]

		local previousShader = love.graphics.getShader()
		local shader = font.isMSDF and LoveSDF.shaderMSDF or LoveSDF.shaderSDF

		font:attach(shader)
		love.graphics.setShader(shader)

		LoveSDF.lgOld.print(...)

		love.graphics.setShader(previousShader)
	else
		LoveSDF.lgOld.print(...)
	end
end

function LoveSDF.printf(...)
	local font = love.graphics.getFont()

	if (font.isMSDF) then
		local previousShader = love.graphics.getShader()

		love.graphics.setShader(LoveSDF.shaderMSDF)
		LoveSDF.lgOld.printf(...)
		love.graphics.setShader(previousShader)
	else
		LoveSDF.lgOld.printf(...)
	end
end

function LoveSDF.mount()
	love.graphics.newFontSDF  = LoveSDF.newFontSDF
	love.graphics.newFontMSDF = LoveSDF.newFontMSDF

	love.graphics.setFont = LoveSDF.setFont
	love.graphics.print   = LoveSDF.print
	love.graphics.printf  = LoveSDF.printf

	return LoveSDF
end

function LoveSDF.unmount()
	love.graphics.newFontSDF  = nil
	love.graphics.newFontMSDF = nil

	love.graphics.setFont = LoveSDF.lgOld.setFont
	love.graphics.print   = LoveSDF.lgOld.print
	love.graphics.printf  = LoveSDF.lgOld.printf

	return LoveSDF
end

return LoveSDF