local Interactive = Concord.system({
	pool = { "id", "interactive", "collider", "bump" },
})

function Interactive:init(world)
	assert:world(world)
	self.world = world
end

function Interactive:on_collide_interactive(e, other)
	assert:entity(e)
	assert:entity(other)
	if not Helper.can_proceed_interact(e, other) then
		return
	end
	e:give("within_interactive", other)
end

function Interactive:on_change_interactive(e, other)
	assert:entity(e)
	assert:entity(other)
	if not Helper.can_proceed_interact(e, other) then
		if e:has("within_interactive") and e:get("within_interactive").entity == other then
			e:remove("within_interactive")
		end
		return
	end
	e:give("within_interactive", other)
end

function Interactive:on_leave_interactive(e)
	assert:entity(e)
	e:remove("within_interactive")
end

return Interactive
