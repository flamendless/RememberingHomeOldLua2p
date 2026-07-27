local Flame = Concord.system({
	pool = { "flame", "point_light", "pos", "diffuse" },
})

local HEALTH_FLICKER_MIN = 3
local HEALTH_FLICKER_MAX = 7
local HEALTH_FLICKER_DURATION_MIN = 0.1
local HEALTH_FLICKER_DURATION_MAX = 0.25
local STRENGTH_MIN_RATIO = 0.5

function Flame:init(world)
	self.world = world
end

function Flame:is_lit(e)
	if e.flame_suppressed then
		return false
	end
	if e.flame_windable and e.flame_windable.extinguished then
		return false
	end
	if e.flame_health and e.flame_health.health <= 0 then
		return false
	end
	return true
end

function Flame:health_strength_ratio(flame_health)
	local ratio = flame_health.health / flame_health.max_health
	local t = math.sqrt(ratio)
	return ratio, STRENGTH_MIN_RATIO + (1 - STRENGTH_MIN_RATIO) * t
end

function Flame:trigger_health_flicker(e)
	local flicker = e.flame_flicker
	if not flicker then
		return
	end
	flicker.flicker_timer = HEALTH_FLICKER_DURATION_MIN
		+ love.math.random() * (HEALTH_FLICKER_DURATION_MAX - HEALTH_FLICKER_DURATION_MIN)
	flicker.next_threshold = love.math.random(HEALTH_FLICKER_MIN, HEALTH_FLICKER_MAX)
end

function Flame:consume_health_flicker(e, health_lost)
	if health_lost <= 0 or not e.flame_flicker then
		return
	end

	local flicker = e.flame_flicker
	flicker.since_flicker = flicker.since_flicker + health_lost
	while flicker.since_flicker >= flicker.next_threshold do
		flicker.since_flicker = flicker.since_flicker - flicker.next_threshold
		self:trigger_health_flicker(e)
	end
end

function Flame:update_flame_strength(e)
	local pl = e.point_light
	local diffuse = e.diffuse
	local color_ratio = 1
	local strength_ratio = 1

	if e.flame_health then
		color_ratio, strength_ratio = self:health_strength_ratio(e.flame_health)
	end

	pl.value = pl.orig_value * strength_ratio

	local windable = e.flame_windable
	local flicker = e.flame_flicker
	if (windable and windable.flicker_timer > 0) or (flicker and flicker.flicker_timer > 0) then
		pl.value = pl.value * (0.55 + love.math.random() * 0.45)
	end

	local orig = diffuse.orig_value
	local min_r = orig[1] * 0.3
	local min_g = orig[2] * 0.15
	local min_b = orig[3] * 0.05
	diffuse.value[1] = min_r + (orig[1] - min_r) * color_ratio
	diffuse.value[2] = min_g + (orig[2] - min_g) * color_ratio
	diffuse.value[3] = min_b + (orig[3] - min_b) * color_ratio

	self.world:emit("update_light_pos", e)
	self.world:emit("update_light_diffuse", e)
end

function Flame:update_flame_pos(e)
	local anchor = e.flame_anchor
	local windable = e.flame_windable
	local pos = e.pos

	if anchor then
		local offset = windable and windable.offset or 0
		local dir = anchor.dir
		pos.x = anchor.base_x + offset * dir
		pos.y = anchor.base_y
	end

	if self:is_lit(e) then
		e:remove("light_disabled")
	else
		e:give("light_disabled")
	end

	self.world:emit("update_light_pos", e)
end

function Flame:update(dt)
	for _, e in ipairs(self.pool) do
		local lit = self:is_lit(e)
		local health = e.flame_health
		local prev_health = health and health.health or 0

		if lit and health then
			health.health = math.max(0, health.health - dt * health.consumption_rate)
			if health.health <= 0 then
				if e.flame_windable then
					e.flame_windable.extinguished = true
				end
				self.world:emit("on_flame_health_empty", e)
			end
		end

		if health and e.flame_flicker then
			self:consume_health_flicker(e, prev_health - health.health)
			e.flame_flicker.flicker_timer = math.max(0, e.flame_flicker.flicker_timer - dt)
		end

		self:update_flame_strength(e)
		self:update_flame_pos(e)
	end
end

if DEV then
	local flags = {
		show_radius = false,
	}

	function Flame:debug_update(dt)
		if not self.debug_show then
			return
		end
		self.debug_show = Slab.BeginWindow("flame", {
			Title = "Flame",
			IsOpen = self.debug_show,
		})

		for _, e in ipairs(self.pool) do
			local health = e.flame_health
			if health then
				local id = e.id and e.id.value or "flame"
				health.health = UIWrapper.edit_range(
					id .. " health",
					health.health,
					0,
					health.max_health
				)
			end
		end

		if Slab.CheckBox(flags.show_radius, "show radius") then
			flags.show_radius = not flags.show_radius
		end

		Slab.EndWindow()
	end

	function Flame:debug_draw()
		if not flags.show_radius then
			return
		end

		for _, e in ipairs(self.pool) do
			local pos = e.pos
			local pl = e.point_light
			love.graphics.setColor(1, 0, 0, 1)
			love.graphics.circle("line", pos.x, pos.y, pl.value)
		end
	end
end

return Flame
