local Lighter = Concord.system({
	pool_flame = { "id", "lighter_flame", "point_light", "pos", "diffuse", "flame" },
})

local FLAME_POWER = 12
local FLAME_FRAME = 7
local WICK_X = 52
local WICK_Y = 15

function Lighter:init(world)
	self.world = world
	self.e_lighter = nil
	self.e_player = nil
	self.e_flame = nil
end

function Lighter:spawn_lighter(e_player)
	assert(e_player.__isEntity and e_player.player)
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

	self.world:setResource("e_lighter", self.e_lighter)
end

function Lighter:lighter_update_pos(e_player)
	assert(e_player.__isEntity and e_player.player)
	local dir = e_player.body.dir
	self.e_lighter.anchor.padding_x = 16 * dir
	self.e_lighter.transform.sx = -dir
end

function Lighter:is_flame_frame_lit()
	local e = self.e_player
	if not e or not e.animation then
		return false
	end

	local obj = e.animation.obj
	local tag = obj.base_tag
	local frame = math.floor(obj.anim8.position)

	if tag == Enums.anim_state.open_lighter then
		return frame >= FLAME_FRAME
	elseif tag == Enums.anim_state.close_lighter then
		return frame < FLAME_FRAME
	end

	return false
end

function Lighter:wick_world_pos(e_player)
	local pos = e_player.pos
	local ox, oy = Helper.get_offset(e_player)
	local sx, sy = 1, 1
	local qt = e_player.quad_transform
	if qt then
		sx = qt.sx
		sy = qt.sy
		ox = qt.ox
		oy = qt.oy
	elseif e_player.transform then
		sx = e_player.transform.sx
		sy = e_player.transform.sy
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

function Lighter:on_anim_open_lighter(e_player)
	if not self.e_flame or not self.e_flame.flame_windable then
		return
	end
	self.e_flame.flame_windable.extinguished = false
	if self.e_flame.flame_health and self.e_flame.flame_health.health <= 0 then
		self.world:emit("play_sound_on_player", Enums.sfx.lighter_empty)
	end
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

	local anchor = self.e_flame.flame_anchor
	local bx, by = self:wick_world_pos(self.e_player)
	anchor.base_x = bx
	anchor.base_y = by
	anchor.dir = self.e_player.body.dir

	if self:is_flame_frame_lit() then
		self.e_flame:remove("flame_suppressed")
	else
		self.e_flame:give("flame_suppressed")
	end
end

return Lighter
