local Lighter = Concord.system({
	pool_flame = { "id", "lighter_flame", "point_light", "pos", "diffuse" },
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

	self.e_flame = Concord.entity(self.world):assemble(
		Assemblages.Light.lighter_flame,
		FLAME_POWER
	)

	self.world:setResource("e_lighter", self.e_lighter)
end

function Lighter:lighter_update_pos(e_player)
	assert(e_player.__isEntity and e_player.player)
	local dir = e_player.body.dir
	self.e_lighter.anchor.padding_x = 16 * dir
	self.e_lighter.transform.sx = -dir
end

function Lighter:is_flame_lit()
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

function Lighter:update_flame_pos()
	if not self.e_player or not self.e_flame then
		return
	end

	local f_pos = self.e_flame.pos
	local pl = self.e_flame.point_light
	local lit = self:is_flame_lit()

	f_pos.x, f_pos.y = self:wick_world_pos(self.e_player)
	pl.value = self.e_flame.lighter_flame.power

	if lit then
		self.e_flame:remove("light_disabled")
	else
		self.e_flame:give("light_disabled")
	end

	self.world:emit("update_light_pos", self.e_flame)
end

function Lighter:update(dt)
	self:update_flame_pos()
end

return Lighter
