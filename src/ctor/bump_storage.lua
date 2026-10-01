local meta = getmetatable(Bump.newWorld(128))
local BumpStorage = setmetatable({ super = meta.__index }, meta)

BumpStorage.__mt = {
	__index = BumpStorage,
}

local MAX_PROJECT_MOVE_ITERS = 64
local BUMP_CELL_SIZE = 128

local ctor = function(def)
	local self = setmetatable(Bump.newWorld(BUMP_CELL_SIZE), BumpStorage.__mt)
	table.insert(def, "collider")
	table.insert(def, "pos")
	table.insert(def, "bump")
	return self
end

function BumpStorage:add(e)
	assert:entity(e)
	local x, y, w, h = Helper.get_collider_rect(e)
	self.super.add(self, e, x, y, w, h)
end

function BumpStorage:update(e)
	assert:entity(e)
	local x, y, w, h = Helper.get_collider_rect(e)
	self.super.update(self, e, x, y, w, h)
end

function BumpStorage:has(e)
	assert:entity(e)
	return self:hasItem(e)
end

function BumpStorage:clear()
	for _, e in ipairs(self:getItems()) do
		self:remove(e)
	end
end

function BumpStorage:projectMove(item, x, y, w, h, goalX, goalY, filter)
	assert:type(x, "number")
	assert:type(y, "number")
	assert:type(w, "number")
	assert:type(h, "number")
	filter = filter or function(_, _)
		return "slide"
	end

	local projected_cols, projected_len = self:project(item, x, y, w, h, goalX, goalY, filter)

	local cols, len = self.fetchTable(), 0
	local visited = self.fetchTable()
	visited[item] = true

	local iters = 0
	while projected_len > 0 do
		iters = iters + 1
		if iters > MAX_PROJECT_MOVE_ITERS then
			Log.warn("BumpStorage: projectMove iteration cap", item, iters)
			break
		end

		local col = projected_cols[1]
		len = len + 1
		cols[len] = col

		for i = 2, projected_len do
			self.freeTable(projected_cols[i])
		end
		self.freeTable(projected_cols)

		visited[col.other] = true

		local response = self.responses[col.type]
		goalX, goalY, projected_cols, projected_len = response(
			self,
			col,
			x,
			y,
			w,
			h,
			goalX,
			goalY,
			filter,
			visited
		)
	end

	self.freeTable(visited)
	self.freeCollisions(projected_cols)

	return goalX, goalY, cols, len
end

return ctor
