local Lighter = Concord.system({
	pool_flame = { "id", "lighter_flame", "point_light", "pos", "diffuse", "flame" },
})

local FLAME_POWER = 20
local FLAME_FRAME = 7
local WICK_X = 52
local WICK_Y = 15

local IGNITION_SEQUENCES = {
	full = {
		{ at = 0, sfx = Enums.sfx.lighter_click },
		{ at = 0.08, sfx = Enums.sfx.lighter_on, ignite = true },
	},
	medium = {
		{ at = 0, sfx = Enums.sfx.lighter_click },
		{ at = 0.08, sfx = Enums.sfx.lighter_on, ignite = true },
	},
	low = {
		{ at = 0, sfx = Enums.sfx.lighter_click },
		{ at = 0.25, sfx = Enums.sfx.lighter_click },
		{ at = 0.45, sfx = Enums.sfx.lighter_on, ignite = true },
	},
	critical = {
		{ at = 0, sfx = Enums.sfx.lighter_click },
		{ at = 0.12, sfx = Enums.sfx.lighter_click },
		{ at = 0.25, sfx = Enums.sfx.lighter_spark },
		{ at = 0.40, sfx = Enums.sfx.lighter_click },
		{ at = 0.55, sfx = Enums.sfx.lighter_on, ignite = true },
	},
}

function Lighter:init(world)
	self.world = world
	self.e_lighter = nil
	self.e_player = nil
	self.e_flame = nil
	self.ignition_complete = true
	self.ignition_timer = 0
	self.ignition_steps = nil
	self.ignition_step_idx = 1
end

function Lighter:spawn_lighter(e_player)
	assert(e_player.__isEntity and e_player:has("player"))
	self.e_player = e_player
	self.e_lighter = Concord.entity(self.world)
		:assemble(Assemblages.Lighter.lighter, e_player)

	self.e_flame = Concord.entity(self.world)
		:assemble(Assemblages.Light.lighter_flame, FLAME_POWER)
		:give("flame_frame_flicker", e_player, {
			[8] = 1.01,
			[9] = 0.97,
			[10] = 1.02,
			[11] = 0.99,
		})
		:give("flame_instability")

	self.world:setResource("e_lighter", self.e_lighter)
end

function Lighter:lighter_update_pos(e_player)
	assert(e_player.__isEntity and e_player:has("player"))
	local dir = e_player:get("body").dir
	self.e_lighter:get("anchor").padding_x = 16 * dir
	self.e_lighter:get("transform").sx = -dir
end

function Lighter:is_flame_frame_lit()
	local e = self.e_player
	if not e or not e:has("animation") then
		return false
	end

	local obj = e:get("animation").obj
	local tag = obj.base_tag
	local frame = math.floor(obj.anim8.position)

	if tag == Enums.anim_state.open_lighter then
		return frame >= FLAME_FRAME
	elseif tag == Enums.anim_state.close_lighter then
		return frame < FLAME_FRAME
	end

	return false
end

function Lighter:is_instability_out()
	if not self.e_flame or not self.e_flame:has("flame_instability") then
		return false
	end
	return self.e_flame:get("flame_instability").out_timer > 0
end

function Lighter:should_show_flame()
	return self:is_flame_frame_lit()
		and self.ignition_complete
		and not self:is_instability_out()
end

function Lighter:wick_world_pos(e_player)
	local pos = e_player:get("pos")
	local ox, oy = Helper.get_offset(e_player)
	local sx, sy = 1, 1
	local qt = e_player:get("quad_transform")
	if qt then
		sx = qt.sx
		sy = qt.sy
		ox = qt.ox
		oy = qt.oy
	else
		local transform = e_player:get("transform")
		if transform then
			sx = transform.sx
			sy = transform.sy
		end
	end

	return pos.x + (WICK_X - ox) * sx, pos.y + (WICK_Y - oy) * sy
end

function Lighter:request_close()
	local pc = self.world:getSystem(ECS.get_system_class("player_controller"))
	if not pc or not pc.on_lighter or pc:is_lighter_closing() then
		return
	end
	self.world:emit("on_close_lighter")
end

function Lighter:reset_ignition()
	self.ignition_complete = true
	self.ignition_timer = 0
	self.ignition_steps = nil
	self.ignition_step_idx = 1
end

function Lighter:play_ignition_sfx(sfx)
	Log.debug("TODO: lighter ignition sfx stub", sfx)
	self.world:emit("play_sound_on_player", sfx)
end

function Lighter:start_ignition(tier_id)
	self.ignition_complete = false
	self.ignition_timer = 0
	self.ignition_steps = IGNITION_SEQUENCES[tier_id] or IGNITION_SEQUENCES.full
	self.ignition_step_idx = 1
end

function Lighter:update_ignition(dt)
	if self.ignition_complete or not self.ignition_steps then
		return
	end

	self.ignition_timer = self.ignition_timer + dt
	while self.ignition_step_idx <= #self.ignition_steps do
		local step = self.ignition_steps[self.ignition_step_idx]
		if self.ignition_timer < step.at then
			break
		end
		self:play_ignition_sfx(step.sfx)
		if step.ignite then
			self.ignition_complete = true
		end
		self.ignition_step_idx = self.ignition_step_idx + 1
	end
end

function Lighter:resolve_fuel_tier()
	if not self.e_flame or not self.e_flame:has("flame_fuel_tiers") then
		return nil
	end
	local flame_health = self.e_flame:get("flame_health")
	if not flame_health or flame_health.max_health <= 0 then
		return nil
	end
	local fuel_tiers = self.e_flame:get("flame_fuel_tiers")
	local ratio = flame_health.health / flame_health.max_health
	local flame = self.world:getSystem(ECS.get_system_class("flame"))
	return flame:resolve_fuel_tier(fuel_tiers, ratio)
end

function Lighter:trigger_flicker_boost()
	if not self.e_flame or not self.e_flame:has("flame_flicker") then
		return
	end
	local flicker = self.e_flame:get("flame_flicker")
	flicker.flicker_timer = 0.1 + love.math.random() * 0.15
	flicker.next_threshold = love.math.random(2, 4)
end

function Lighter:update_instability(dt)
	if not self.e_flame or not self.e_flame:has("flame_instability") then
		return
	end

	if not self:is_flame_frame_lit() or not self.ignition_complete then
		return
	end

	local flame_health = self.e_flame:get("flame_health")
	if not flame_health or flame_health.health <= 0 then
		return
	end

	local tier = self:resolve_fuel_tier()
	if not tier then
		return
	end

	local instability = self.e_flame:get("flame_instability")
	instability.next_roll = instability.next_roll - dt
	if instability.next_roll > 0 then
		return
	end

	if tier.id == "full" then
		return
	elseif tier.id == "medium" then
		instability.next_roll = 0.5 + love.math.random() * 0.5
		self:trigger_flicker_boost()
	elseif tier.id == "low" then
		instability.next_roll = 0.4 + love.math.random() * 0.8
		self:trigger_flicker_boost()
		if love.math.random() < 0.4 then
			instability.shrink_timer = 0.15
		end
	elseif tier.id == "critical" then
		instability.next_roll = 0.2 + love.math.random() * 0.5
		self:trigger_flicker_boost()
		local roll = love.math.random()
		if roll < 0.3 then
			instability.out_timer = 0.08 + love.math.random() * 0.12
		elseif roll < 0.6 then
			instability.shrink_timer = 0.15
		else
			instability.spark_timer = 0.05 + love.math.random() * 0.08
		end
	end
end

function Lighter:anim_open_lighter(e_player)
	if e_player ~= self.e_player or not self.e_flame then
		return
	end

	if self.e_flame:has("flame_windable") then
		self.e_flame:get("flame_windable").extinguished = false
	end

	local flame_health = self.e_flame:get("flame_health")
	if not flame_health or flame_health.health <= 0 then
		self:reset_ignition()
		self.ignition_complete = false
		Log.debug("TODO: lighter opening sound with no fuel/gas left")
		self.world:emit("play_sound_on_player", Enums.sfx.lighter_empty)
		return
	end

	local tier = self:resolve_fuel_tier()
	local tier_id = tier and tier.id or "full"
	self:start_ignition(tier_id)
end

function Lighter:on_close_lighter()
	self:reset_ignition()
end

function Lighter:on_flame_blown_out(e)
	if self.e_flame and e == self.e_flame then
		self:request_close()
	end
end

function Lighter:on_flame_health_empty(e)
	if self.e_flame and e == self.e_flame then
		self:request_close()
	end
end

function Lighter:update(dt)
	if not self.e_player or not self.e_flame then
		return
	end

	local anchor = self.e_flame:get("flame_anchor")
	local bx, by = self:wick_world_pos(self.e_player)
	anchor.base_x = bx
	anchor.base_y = by
	anchor.dir = self.e_player:get("body").dir

	self:update_ignition(dt)
	self:update_instability(dt)

	if self:should_show_flame() then
		self.e_flame:remove("flame_suppressed")
	else
		self.e_flame:give("flame_suppressed")
	end
end

return Lighter
