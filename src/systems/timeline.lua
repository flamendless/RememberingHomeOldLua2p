local Timeline = Concord.system()

function Timeline:init(world)
	self.world = world
	self.state = Enums.timeline.created
end

function Timeline:start_timeline(fn)
	if type(fn) ~= "function" then
		error('Assertion failed: type(fn) == "function"')
	end
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

		Slab.EndWindow()
	end
end

return Timeline
