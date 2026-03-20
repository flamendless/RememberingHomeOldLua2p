local LogsSystem = Concord.system()

function LogsSystem:init(world)
	self.world = world
	self.logs = {
		all = {},
		entity = {},
		interactive = {},
	}
	self.tabs = { "all", "entity", "interactive" }
	self.current = self.tabs[1]
end

function LogsSystem:on_add_entity(e)
	local str = "on_add_entity: " .. e.id.value
	table.insert(self.logs.all, str)
	table.insert(self.logs.entity, str)
	if DEV then Log.debug("Log", str) end
end

function LogsSystem:on_remove_entity(e)
	local str = "on_remove_entity: " .. e.id.value
	table.insert(self.logs.all, str)
	table.insert(self.logs.entity, str)
	if DEV then Log.debug("Log", str) end
end

function LogsSystem:on_collide_interactive(e, other)
	local str = string.format("on_col: %s, %s", e.id.value, other.id.value)
	table.insert(self.logs.all, str)
	table.insert(self.logs.interactive, str)
	if DEV then Log.debug("Log", str) end
end

function LogsSystem:on_leave_interactive(e)
	local str = "on_leave_col: " .. e.id.value
	table.insert(self.logs.all, str)
	table.insert(self.logs.interactive, str)
	if DEV then Log.debug("Log", str) end
end

function LogsSystem:debug_update(dt)
	if not self.debug_show then
		return
	end
	self.debug_show = Slab.BeginWindow("log", {
		Title = self.debug_title,
		IsOpen = self.debug_show,
		AutoSizeWindowH = false,
	})
	for _, v in ipairs(self.tabs) do
		if Slab.Button(v) then
			self.current = v
		end
		Slab.SameLine()
	end

	if Slab.Button("clear") then
		tablex.clear(self.logs[self.current])
	end

	for _, str in ipairs(self.logs[self.current]) do
		Slab.Text(str)
	end

	Slab.EndWindow()
end

return LogsSystem
