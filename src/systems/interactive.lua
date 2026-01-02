local Concord = require("modules.concord.concord")

local Interactive = Concord.system({
	pool = { "id", "interactive", "collider", "bump" },
})

function Interactive:init(world)
	self.world = world
end

function Interactive:on_collide_interactive(e, other)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not other.__isEntity then
		error("Assertion failed: other.__isEntity")
	end
	local body = e.body
	local other_col = other.collider
	local req_n = other.interactive_req_player_dir
	if body and req_n and req_n.x ~= body.dir then
		return
	end
	e:give("within_interactive", other)
end

function Interactive:on_change_interactive(e, other)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not other.__isEntity then
		error("Assertion failed: other.__isEntity")
	end
	e:give("within_interactive", other)
end

function Interactive:on_leave_interactive(e)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	e:remove("within_interactive")
end

return Interactive
