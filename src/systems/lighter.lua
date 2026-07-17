local Lighter = Concord.system()

function Lighter:init(world)
	self.world = world
	self.e_lighter = nil
end

function Lighter:spawn_lighter(e_player)
	assert(e_player.__isEntity and e_player.player)
	self.e_lighter = Concord.entity(self.world)
		:assemble(Assemblages.Lighter.lighter, e_player)

	self.world:setResource("e_lighter", self.e_lighter)
end

function Lighter:lighter_update_pos(e_player)
	assert(e_player.__isEntity and e_player.player)
	local dir = e_player.body.dir
	self.e_lighter.anchor.padding_x = 16 * dir
	self.e_lighter.transform.sx = -dir
end

function Lighter:update(dt)
end

return Lighter
