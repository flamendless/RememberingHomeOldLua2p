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
	if e:has("flame_suppressed") then
		return false
	end
	local flame_windable = e:get("flame_windable")
	if flame_windable and flame_windable.extinguished then
		return false
	end
	local flame_health = e:get("flame_health")
	if flame_health and flame_health.health <= 0 then
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
	local flicker = e:get("flame_flicker")
	if not flicker then
		return
	end
	flicker.flicker_timer = HEALTH_FLICKER_DURATION_MIN
		+ love.math.random() * (HEALTH_FLICKER_DURATION_MAX - HEALTH_FLICKER_DURATION_MIN)
	flicker.next_threshold = love.math.random(HEALTH_FLICKER_MIN, HEALTH_FLICKER_MAX)
end

function Flame:consume_health_flicker(e, health_lost)
	if health_lost <= 0 or not e:has("flame_flicker") then
		return
	end

	local flicker = e:get("flame_flicker")
	flicker.since_flicker = flicker.since_flicker + health_lost
	while flicker.since_flicker >= flicker.next_threshold do
		flicker.since_flicker = flicker.since_flicker - flicker.next_threshold
		self:trigger_health_flicker(e)
	end
end

function Flame:update_frame_flicker(e)
	local ff = e:get("flame_frame_flicker")
	if not ff then
		return
	end

	local e_source = self.world:getEntityByKey(ff.anim_key)
	if not e_source or not e_source:has("animation") then
		ff.light_mult = 1
		return
	end

	local obj = e_source:get("animation").obj
	local frame = math.floor(obj.anim8.position)
	ff.light_mult = ff.frame_mults[frame] or 1
end

function Flame:update_flame_strength(e)
	local pl = e:get("point_light")
	local diffuse = e:get("diffuse")
	local color_ratio = 1
	local strength_ratio = 1

	local flame_health = e:get("flame_health")
	if flame_health then
		color_ratio, strength_ratio = self:health_strength_ratio(flame_health)
	end

	pl.value = pl.orig_value * strength_ratio

	local frame_flicker = e:get("flame_frame_flicker")
	if frame_flicker then
		self:update_frame_flicker(e)
		if self:is_lit(e) then
			pl.value = pl.value * frame_flicker.light_mult
		end
	end

	local windable = e:get("flame_windable")
	local flicker = e:get("flame_flicker")
	local wind_flicker = false
	if windable and windable.flicker_timer > 0 then
		wind_flicker = true
	end
	local health_flicker = false
	if flicker and flicker.flicker_timer > 0 and not frame_flicker then
		health_flicker = true
	end
	if wind_flicker or health_flicker then
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
	local anchor = e:get("flame_anchor")
	local windable = e:get("flame_windable")
	local pos = e:get("pos")

	if anchor then
		local offset = 0
		if windable then
			offset = windable.offset
		end
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
		local health = e:get("flame_health")
		local prev_health = 0
		if health then
			prev_health = health.health
		end

		if lit and health then
			health.health = math.max(0, health.health - dt * health.consumption_rate)
			if health.health <= 0 then
				local flame_windable = e:get("flame_windable")
				if flame_windable then
					flame_windable.extinguished = true
				end
				self.world:emit("on_flame_health_empty", e)
			end
		end

		local flicker = e:get("flame_flicker")
		if health and flicker then
			self:consume_health_flicker(e, prev_health - health.health)
			flicker.flicker_timer = math.max(0, flicker.flicker_timer - dt)
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
			local health = e:get("flame_health")
			if health then
				local id_c = e:get("id")
				local id
				if id_c then
					id = id_c.value
				else
					id = "flame"
				end
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
			local pos = e:get("pos")
			local pl = e:get("point_light")
			love.graphics.setColor(1, 0, 0, 1)
			love.graphics.circle("line", pos.x, pos.y, pl.value)
		end
	end
end

return Flame
