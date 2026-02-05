local WindowMode = {}

WindowMode.current = 1
WindowMode.modes = {
	{ width = 1024, height = 640 },
}
WindowMode.list = {}

function WindowMode.init()
	for _, t in ipairs(WindowMode.modes) do
		local str = t.width .. "x" .. t.height
		table.insert(WindowMode.list, str)
	end
end

function WindowMode.get_current()
	return WindowMode.modes[WindowMode.current]
end

return WindowMode
