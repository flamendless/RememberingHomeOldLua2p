local MovementDust = Concord.system()

function MovementDust:init(world)
	self.world = world
end

function MovementDust:should_run()
	local pause = self.world:getSystem(ECS.get_system_class("pause"))
	if pause and pause.is_paused then
		return false
	end

	local e_player = self.world:getResource("e_player")
	if not e_player or e_player:has("hidden") then
		return false
	end
	if not e_player:has("can_move") then
		return false
	end

	return true
end

function MovementDust:player_moving(e_player)
	assert(e_player.__isEntity and e_player:has("player") and e_player:has("body"), e_player)
	if e_player:has("hit_wall") or e_player:has("override_animation") then
		return false
	end

	return e_player:get("body").dx ~= 0
end

function MovementDust:player_foot_x(e_player)
	assert(e_player.__isEntity and e_player:has("player"), e_player)
	local bump = self.world:getSystem(ECS.get_system_class("bump_collision"))
	local rx, _, rw, _ = bump.pool:getRect(e_player)
	return rx + rw / 2
end

function MovementDust:ceiling_on_walk(e_player, emitters)
	assert(e_player.__isEntity and e_player:has("player"), e_player)
	assert:type(emitters, "table")
	local px = self:player_foot_x(e_player)

	for _, em in ipairs(emitters) do
		if em.on_walk and px >= em.x and px <= em.x + em.w then
			local chance = em.on_walk.chance or 0.25
			if love.math.random() < chance then
				self.world:emit("trigger_dust_burst", Enums.dust_kind.emitter, em.key)
			end
		end
	end
end

function MovementDust:update(dt)
	assert:type(dt, "number")
	if not self:should_run() then
		return
	end

	local e_player = self.world:getResource("e_player")
	if not e_player or not self:player_moving(e_player) then
		return
	end

	local emitters = self.world:getResource("event_emitters")
	if emitters then
		self:ceiling_on_walk(e_player, emitters)
	end
end

return MovementDust
