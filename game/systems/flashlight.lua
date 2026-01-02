local Flashlight = Concord.system({
	pool = {"id", "light_id", "point_light", "pos", "diffuse", "flashlight"},
	pool_flashlight = {"id", "flashlight_light"},
	pool_player = {"player_controller", "body", "collider"},
})

local Light = require("assemblages.light")

local min_light_power = 24
local consumption_rate = 0.1

function Flashlight:init(world)
	self.world = world
	self.player = nil

	self.pool.onAdded = function(pool, e)
		if not (self.flashlight == nil) then error("Flashlight was already added") end
		self.flashlight = e
		e:give("d_light_flicker", 0.5, 0.75, 0.25)
		:give("on_d_light_flicker_during", "flicker_sync",
			0, self.flashlight, self.pool_flashlight)
		:give("d_light_flicker_repeat", -1, 7)
		:give("d_light_flicker_sure_on_after")
	end

	self.pool_player.onAdded = function(pool, e)
		if not (self.player == nil) then error("Player was already added") end
		self.player = e
		self:create_flashlight()
	end
end

function Flashlight:create_flashlight()
	Concord.entity(self.world):assemble(Light.fl_spot,
			self.player, Animation.get_sync_data("flashlight"))

		:give("battery", 100)
		:give("battery_state", Enums.battery_state.full)

	self.start_l = Concord.entity(self.world):assemble(Light.fl_start)
	self.end_l = Concord.entity(self.world):assemble(Light.fl_end)
	table.insert(self.pool_flashlight, self.start_l)
	table.insert(self.pool_flashlight, self.end_l)
end

function Flashlight:update(dt)
	if self.flashlight == nil or self.player == nil then return end

	if not self.flashlight.light_disabled then
		self:update_flashlight()
		self:update_battery(dt)
	end

	if Inputs.released("flashlight") then
		local pl = self.start_l.point_light
		if self.flashlight.light_disabled then
			self.flashlight:remove("light_disabled")
			self.end_l:remove("light_disabled")
			pl.value = pl.orig_value
		else
			self.flashlight:give("light_disabled")
			self.end_l:give("light_disabled")
			pl.value = min_light_power
		end
	end

	self.world:emit("update_light_dir", self.flashlight)
	self.world:emit("update_light_pos", self.flashlight)
	self.world:emit("update_light_pos", self.start_l)
	self.world:emit("update_light_pos", self.end_l)
end

function Flashlight:update_flashlight()
	local body = self.player.body
	local p_pos = self.player.pos
	local col = self.player.collider
	local offset = self.player.fl_spawn_offset
	local f_pos = self.flashlight.pos
	local ldir = self.flashlight.light_dir
	local fd = ldir.value

	local bx = p_pos.x + col.w_h
	local by = p_pos.y + col.h_h
	ldir.value[2] = offset.dy
	fd[1] = ldir.orig_value[1] * body.dir
	f_pos.x = bx + offset.x * fd[1]
	f_pos.y = by + offset.y

	local strength = self.flashlight.point_light.value
	local s_pos = self.start_l.pos
	s_pos.x = f_pos.x
	s_pos.y = f_pos.y

	local e_pos = self.end_l.pos
	e_pos.x = f_pos.x + strength * fd[1] * fd[4]
	e_pos.y = f_pos.y
end

function Flashlight:update_battery(dt)
	if not self.flashlight then return end
	local battery = self.flashlight.battery
	local bs = self.flashlight.battery_state
	if not battery or bs.value == Enums.battery_state.empty then return end

	local f_pl = self.flashlight.point_light
	if f_pl.value <= 0 then
		bs:set(Enums.battery_state.empty)
		self.flashlight:give("light_disabled")
			:remove("battery")
			:remove("d_light_flicker")
		self.end_l:give("light_disabled")
		self.start_l:give("point_light", min_light_power)
		return
	end

	battery.pct = battery.pct - dt * consumption_rate
	f_pl.value = f_pl.orig_value * battery.pct/100

	local flicker = self.flashlight.d_light_flicker
	local f_repeat = self.flashlight.d_light_flicker_repeat
	if bs.value == Enums.battery_state.full and battery.pct <= 50 then
		bs:set(Enums.battery_state.low)
		flicker.during = 0.5
		flicker.on_chance = 0.65
		flicker.off_chance = 0.35
		f_repeat.delay = 2
	elseif bs.value == Enums.battery_state.low and battery.pct <= 25 then
		bs:set(Enums.battery_state.critical)
		flicker.during = 0.3
		flicker.on_chance = 0.5
		flicker.off_chance = 0.5
		f_repeat.delay = 1.25
	end
end

if DEV then
	local flags = {
		pos = false,
	}

	function Flashlight:debug_update(dt)
		if not self.debug_show then return end
		self.debug_show = Slab.BeginWindow("fl", {
			Title = "Flashlight",
			IsOpen = self.debug_show,
		})
		if Slab.CheckBox(flags.pos, "draw") then
			flags.pos = not flags.pos
		end

		local battery = self.flashlight and self.flashlight.battery
		if battery then
			Slab.Text("state: " .. self.flashlight.battery_state.value)
			Slab.Text("battery")
			Slab.SameLine()
			UIWrapper.edit_range("battery", battery.pct, 0, 100)
			consumption_rate = UIWrapper.edit_range("consumption rate", consumption_rate, 0, 10)
			local pl = self.flashlight.point_light
			UIWrapper.edit_range("power", pl.value, 0, pl.orig_value)
		end
		Slab.EndWindow()
	end

	function Flashlight:debug_draw()
		if not flags.pos then return end
		local p_pos = self.player.pos
		local col = self.player.collider
		local offset = self.player.fl_spawn_offset
		local ldir = self.flashlight.light_dir
		local fd = ldir.value
		local bx = p_pos.x + col.w_h
		local by = p_pos.y + col.h_h
		local fx = bx + offset.x * fd[1]
		local fy = by + offset.y
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.circle("fill", fx, fy, 2)
	end
end

return Flashlight
