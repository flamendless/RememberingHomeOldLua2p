local Timer = {}

local instances = {}

function Timer.new(cron)
	ASSERT(type(cron) == "table")
	table.insert(instances, cron)
end

function Timer.update(dt)
	local to_remove = {}

	for i, cron in ipairs(instances) do
		local expired = cron:update(dt)
		if expired then
			to_remove[cron] = i
		end
	end

	for i = #instances, 1, -1 do
		local cron = instances[i]
		local n = to_remove[cron]
		table.remove(instances, n)
	end
end

function Timer.clear()
	tablex.clear(instances)
end

return Timer
