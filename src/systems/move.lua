local Move = Concord.system({
	pool = { "pos", "move_by" },
	pool_move_x = { "pos", "move_to_x" },
	pool_original = { "pos", "move_to_original" },
})

local function internal_move_by(e, is_repeat)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if type(is_repeat) ~= "boolean" then
		error('Assertion failed: type(is_repeat) == "boolean"')
	end
	local pos = e.pos
	local move_by = e.move_by

	local f = Flux.to(pos, move_by.duration, {
		x = pos.x + move_by.x,
		y = pos.y + move_by.y,
	}):delay(move_by.delay)

	if is_repeat then
		f:oncomplete(function()
			internal_move_by(e, is_repeat)
		end)
	else
		f:oncomplete(function()
			e:remove("move_by")
		end)
	end
end

function Move:init()
	self.pool.onAdded = function(pool, e)
		internal_move_by(e, e.move_repeat ~= nil)
	end

	self.pool_move_x.onAdded = function(pool, e)
		local pos = e.pos
		local target = e.move_to_x
		Flux.to(pos, target.duration, { x = target.target_x }):delay(target.delay):oncomplete(function()
			e:remove("move_to_x")
		end)
	end

	self.pool_original.onAdded = function(pool, e)
		local pos = e.pos
		local move = e.move_to_original
		Flux.to(pos, move.duration, {
			x = pos.orig_x,
			y = pos.orig_y,
		})
			:delay(move.delay)
			:oncomplete(function()
				e:remove("move_to_original")
			end)
	end
end

return Move
