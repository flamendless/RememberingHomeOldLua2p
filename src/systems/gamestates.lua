local GameStatesSystem = Concord.system()

function GameStatesSystem:init(world)
	self.world = world
	self.is_switching = false
end

function GameStatesSystem:switch_state(next_state, dur, delay)
	if not (type(next_state) == "string") then
		error('Assertion failed: type(next_state) == "string"')
	end
	if dur then
		if not (type(dur) == "number") then
			error('Assertion failed: type(dur) == "number"')
		end
	end
	if delay then
		if not (type(delay) == "number") then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	if self.is_switching then
		return
	end
	if GameStates.current_id == next_state then
		return
	end
	Log.info("switching state to", next_state)
	self.is_switching = true
	Fade.fade_out(function()
		if GameStates.current_id == "Splash" then
			Save.set_flag("splash_done", true, true)
		end
		GameStates.switch(next_state)
		Log.info("switched state to", next_state)
		self.is_switching = false
	end, dur, delay)
end

function GameStatesSystem:save_game()
	-- local data = self.world:serialize()
	-- Utils.serial.write($_SAVESTATE_FILENAME, data)
end

function GameStatesSystem:load_game()
	-- local data = Utils.serial.read($_SAVESTATE_FILENAME)
	-- self.world:deserialize(data, true)
end

local states = {
	"Menu",
	"Intro",
	"Outside",
	"StorageRoom",
	"UtilityRoom",
	"Kitchen",
	"LivingRoom",
	"TotallyDarkRoom",
}

function GameStatesSystem:debug_update(dt)
	if not self.debug_show then
		return
	end
	self.debug_show = Slab.BeginWindow("gs", {
		Title = "GameStatesSystem",
		IsOpen = self.debug_show,
	})
	if Slab.BeginComboBox("cb_gs", { Selected = self.world.current_id }) then
		for _, v in ipairs(states) do
			if Slab.TextSelectable(v) then
				self:switch_state(v, 1.5, 0.5)
				break
			end
		end
		Slab.EndComboBox()
	end
	Slab.EndWindow()
end

function GameStatesSystem:state_keypressed(key)
	if not love.keyboard.isDown("lshift") then
		return
	end
	if key == "0" then
		Fade.set_alpha(0)
	else
		local i = tonumber(key)
		if i and i >= 1 and i <= (#states - 2) then
			self:switch_state(states[i + 2], 0)
		end
	end
end

return GameStatesSystem
