local Wind = Concord.system({
	pool = { "flame_windable", "pos" },
})

local WIND_OFFSET_SCALE = 0.6
local WIND_OFFSET_DECAY = 6
local WIND_FLICKER_BASE = 0.25
local DEFAULT_BLOW_RADIUS = 300

function Wind:init(world)
	self.world = world
	if DEV then
		self.debug_wind_strength = 5
		self.debug_blow_radius = DEFAULT_BLOW_RADIUS
	end
end

function Wind:is_blow_out_candidate(e)
	local windable = e.flame_windable
	if windable.extinguished then
		return false
	end
	if e.flame_suppressed then
		return false
	end
	if e.flame_health and e.flame_health.health <= 0 then
		return false
	end
	return true
end

function Wind:apply_gust(e, strength)
	local windable = e.flame_windable
	local anchor = e.flame_anchor
	local dir = anchor and anchor.dir or 1
	local sign = love.math.random() < 0.5 and -1 or 1
	windable.offset_target = sign * strength * WIND_OFFSET_SCALE * dir
	windable.flicker_timer = WIND_FLICKER_BASE + strength * 0.04

	if self:is_blow_out_candidate(e) and strength >= windable.blow_out_min_strength then
		local chance = (strength - windable.blow_out_min_strength) * windable.blow_out_chance_scale
		if love.math.random() < math.min(1, chance) then
			windable.extinguished = true
			self.world:emit("on_flame_blown_out", e)
		end
	end
end

function Wind:on_blow_wind(strength, x, y, radius)
	assert(type(strength) == "number", strength)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	radius = radius or DEFAULT_BLOW_RADIUS
	local r2 = radius * radius

	for _, e in ipairs(self.pool) do
		local pos = e.pos
		local dx = pos.x - x
		local dy = pos.y - y
		if dx * dx + dy * dy <= r2 then
			self:apply_gust(e, strength)
		end
	end
end

function Wind:update(dt)
	local blend = math.min(1, dt * 8)
	for _, e in ipairs(self.pool) do
		local windable = e.flame_windable
		windable.offset = windable.offset + (windable.offset_target - windable.offset) * blend
		windable.offset_target = windable.offset_target * math.max(0, 1 - dt * WIND_OFFSET_DECAY)
		windable.flicker_timer = math.max(0, windable.flicker_timer - dt)
	end
end

if DEV then
	function Wind:debug_update(dt)
		if not self.debug_show then
			return
		end
		self.debug_show = Slab.BeginWindow("wind", {
			Title = "Wind",
			IsOpen = self.debug_show,
		})

		self.debug_wind_strength = UIWrapper.edit_range(
			"wind strength",
			self.debug_wind_strength,
			0,
			20
		)
		self.debug_blow_radius = UIWrapper.edit_range(
			"blow radius",
			self.debug_blow_radius,
			0,
			600
		)

		if Slab.Button("Blow Wind") then
			local x, y = 0, 0
			local e_player = self.world:getResource("e_player")
			if e_player then
				x = e_player.pos.x
				y = e_player.pos.y
			end
			self:on_blow_wind(self.debug_wind_strength, x, y, self.debug_blow_radius)
		end

		Slab.EndWindow()
	end
end

return Wind
