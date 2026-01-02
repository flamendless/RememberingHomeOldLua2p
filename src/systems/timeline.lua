local Concord = require("modules.concord.concord")
local TLE = require("modules.tle.timeline")

local Timeline = Concord.system()

function Timeline:init(world)
	self.world = world
end

function Timeline:start_timeline(fn)
	if not (type(fn) == "function") then
		error('Assertion failed: type(fn) == "function"')
	end
	self.timeline = TLE.Do(fn)
end

function Timeline:resume_timeline()
	self.timeline:Unpause()
end

function Timeline:pause_timeline()
	self.timeline:Pause()
end

function Timeline:kill_timeline()
	self.timeline:Die()
end

return Timeline
