local PATH = (...):gsub('%.init$', '')

require("").mount()

local fontSDF = love.graphics.newFontMSDF(PATH.."/exo.fnt", PATH.."/exo.png")
local fontTTF = love.graphics.newFont(PATH.."/comic.ttf", 32)

function love.draw()
    local text = "Hello World!"

    -- Works fine
    local width  = fontSDF:getWidth(text)
    local height = fontSDF:getHeight()

    love.graphics.setFont(fontSDF)
    love.graphics.print(text, 10, 10)

    love.graphics.setFont(fontTTF)
    love.graphics.print(text, 10, 60)
end