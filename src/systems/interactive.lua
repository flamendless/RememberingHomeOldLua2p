local Interactive = Concord.system({
	pool = { "id", "interactive", "collider", "bump" },
})

function Interactive:init(world)
	self.world = world
end

function Interactive:on_collide_interactive(e, other)
	assert(e.__isEntity, e)
	assert(other.__isEntity, other)
	local body = e.body
	local req_n = other.interactive_req_player_dir
	if body and req_n and req_n.x ~= body.dir then
		return
	end
	e:give("within_interactive", other)
end

function Interactive:on_change_interactive(e, other)
	assert(e.__isEntity, e)
	assert(other.__isEntity, other)
	e:give("within_interactive", other)
end

function Interactive:on_leave_interactive(e)
	assert(e.__isEntity, e)
	e:remove("within_interactive")
end

return Interactive
