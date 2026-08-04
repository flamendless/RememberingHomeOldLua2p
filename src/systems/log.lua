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
	local id = e:get("id")
	local str = "on_add_entity: " .. id.value
	table.insert(self.logs.all, str)
	table.insert(self.logs.entity, str)
	if DEV then Log.debug("Log", str) end
end

function LogsSystem:on_remove_entity(e)
	local id = e:get("id")
	local str = "on_remove_entity: " .. id.value
	table.insert(self.logs.all, str)
	table.insert(self.logs.entity, str)
	if DEV then Log.debug("Log", str) end
end

function LogsSystem:on_collide_interactive(e, other)
	local e_id = e:get("id")
	local other_id = other:get("id")
	local str = string.format("on_col: %s, %s", e_id.value, other_id.value)
	table.insert(self.logs.all, str)
	table.insert(self.logs.interactive, str)
	if DEV then Log.debug("Log", str) end
end

function LogsSystem:on_leave_interactive(e)
	local id = e:get("id")
	local str = "on_leave_col: " .. id.value
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

	local logs = self.logs[self.current]
	local n_logs = #logs
	local max_logs = 200
	local start = 1
	if n_logs > max_logs then
		Slab.Text(string.format("Showing last %d of %d entries", max_logs, n_logs))
		start = n_logs - max_logs + 1
	end
	for i = start, n_logs do
		Slab.Text(logs[i])
	end

	Slab.EndWindow()
end

return LogsSystem
