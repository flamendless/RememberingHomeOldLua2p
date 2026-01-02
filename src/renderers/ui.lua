local RendererUI = {
	id = "UI",
	main_renderer = nil,
}

function UI.init(main_renderer)
	if not main_renderer.__isSystem then
		error("Assertion failed: main_renderer.__isSystem")
	end
	UI.main_renderer = main_renderer
end

function UI.render()
	UI.main_renderer:draw(true)
end

return UI
