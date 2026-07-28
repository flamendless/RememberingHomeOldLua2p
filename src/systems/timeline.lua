local Timeline = Concord.system()

local HISTORY_LIMIT = 100
local DEF = "<NONE>"

function Timeline:init(world)
	self.world = world
	self.state = Enums.timeline.created
	self.current_name = DEF
	self.history = {}
end

function Timeline:tle_log(msg)
	assert(type(msg) == "string", msg)
	Log.debug(string.format("TLE: %s", msg))
	self.current_name = msg
	table.insert(self.history, msg)
	if #self.history > HISTORY_LIMIT then
		table.remove(self.history, 1)
	end
end

function Timeline:start_timeline(fn)
	assert(type(fn) == "function", fn)
	tablex.clear(self.history)
	self.current_name = DEF
	self.state = Enums.timeline.playing
	self.timeline = TLE.Do(fn)
end

function Timeline:resume_timeline()
	self.state = Enums.timeline.playing
	self.timeline:Unpause()
end

function Timeline:pause_timeline()
	self.state = Enums.timeline.paused
	self.timeline:Pause()
end

function Timeline:kill_timeline()
	self.state = Enums.timeline.killed
	self.timeline:Die()
end

if DEV then
	local states = {
		resume = Timeline.resume_timeline,
		pause = Timeline.pause_timeline,
	}
	function Timeline:debug_update(dt)
		if not self.debug_show then
			return
		end

		self.debug_show = Slab.BeginWindow("timeline", {
			Title = "Timeline",
			IsOpen = self.debug_show,
		})

		Slab.Text("State: " .. self.state)
		if Slab.BeginComboBox("cb_state", { Selected = self.state }) then
			for k, v in pairs(states) do
				if Slab.TextSelectable(k) then
					v(self)
					break
				end
			end
			Slab.EndComboBox()
		end

		Slab.Text("Current: " .. self.current_name)
		if Slab.Button("clear") then
			tablex.clear(self.history)
			self.current_name = DEF
		end

		Slab.Text("History:")
		for _, str in ipairs(self.history) do
			Slab.Text(str)
		end

		Slab.EndWindow()
	end
end

return Timeline
