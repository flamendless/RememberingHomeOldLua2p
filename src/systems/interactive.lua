local Interactive = Concord.system({
	pool = { "id", "interactive", "collider", "bump" },
})

function Interactive:init(world)
	self.world = world
end

function Interactive:on_collide_interactive(e, other)
	assert(e.__isEntity, e)
	assert(other.__isEntity, other)
	local body
	if e:has("body") then
		body = e:get("body")
	end
	local req_n
	if other:has("interactive_req_player_dir") then
		req_n = other:get("interactive_req_player_dir")
	end
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
