local UI = {
	id = "UI",
	main_renderer = nil,
}

function UI.init(main_renderer, world)
	assert(main_renderer.__isSystem)
	assert(world.__isWorld)
	UI.world = world

	UI.main_renderer = main_renderer
end

function UI.render()
	UI.main_renderer:draw(true)
end

return UI
