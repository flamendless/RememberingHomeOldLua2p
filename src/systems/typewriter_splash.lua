local Concord = require("modules.concord.concord")
local Timer = require("modules.hump.timer")

local TypewriterSplash = Concord.system({
	pool = { "text", "target_text", "typewriter", "pos", "typewriter_timer" },
})

function TypewriterSplash:init(world)
	self.world = world
end

function TypewriterSplash:start_typewriter()
	for _, e in ipairs(self.pool) do
		local text = e.text
		local typewriter = e.typewriter
		local timer = e.typewriter_timer
		local cb = e.typewriter_on_finish

		if not timer.timer then
			timer.timer = Timer()
			timer.timer:every(typewriter.every, function()
				local target = e.target_text.value

				if #text.value ~= #target then
					local ch = target:sub(#text.value + 1, #text.value + 1)

					text.value = text.value .. ch
				elseif cb then
					timer.timer:after(cb.delay, function()
						self.world:emit(cb.signal, unpack(cb.args))
						e:remove("typewriter_on_finish")
					end)
				end
			end)
		end
	end
end

function TypewriterSplash:update(dt)
	for _, e in ipairs(self.pool) do
		local timer = e.typewriter_timer
		if timer.timer then
			timer.timer:update(dt)
		end
	end
end

return TypewriterSplash
