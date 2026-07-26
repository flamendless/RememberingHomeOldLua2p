local Lighter = Concord.system({
	pool_flame = { "id", "lighter_flame", "point_light", "pos", "diffuse" },
})

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
		e_player,
		Animation.get_sync_data("lighter")
	)

	self.world:setResource("e_lighter", self.e_lighter)
end

function Lighter:lighter_update_pos(e_player)
	assert(e_player.__isEntity and e_player.player)
	local dir = e_player.body.dir
	self.e_lighter.anchor.padding_x = 16 * dir
	self.e_lighter.transform.sx = -dir
end

function Lighter:on_open_lighter()
	self:enable_flame()
end

function Lighter:anim_open_lighter(e)
	self:enable_flame()
end

function Lighter:on_close_lighter()
	self:disable_flame()
end

function Lighter:on_anim_close_lighter_done()
	self:disable_flame()
end

function Lighter:enable_flame()
	if not self.e_flame then
		return
	end
	self.e_flame:remove("light_disabled")
end

function Lighter:disable_flame()
	if not self.e_flame or not self.e_player then
		return
	end
	self.e_flame:give("light_disabled")
	local off = self.e_player.lighter_wick_offset
	off.x = off.orig_x
	off.y = off.orig_y
	off.power = off.orig_power
end

function Lighter:update_flame_pos()
	if not self.e_player or not self.e_flame then
		return
	end

	local body = self.e_player.body
	local p_pos = self.e_player.pos
	local col = self.e_player.collider
	local off = self.e_player.lighter_wick_offset
	local f_pos = self.e_flame.pos
	local pl = self.e_flame.point_light

	local bx = p_pos.x + col.w_h
	local by = p_pos.y + col.h_h
	f_pos.x = bx + off.x * body.dir
	f_pos.y = by + off.y
	pl.value = pl.orig_value * off.power

	self.world:emit("update_light_pos", self.e_flame)
end

function Lighter:update(dt)
	self:update_flame_pos()
end

return Lighter
