local meta = getmetatable(Bump.newWorld(128))
local BumpStorage = setmetatable({super = meta.__index}, meta)

BumpStorage.__mt = {
	__index = BumpStorage,
}

local ctor = function(def)
	local self = setmetatable(Bump.newWorld(), BumpStorage.__mt)
	table.insert(def, "collider")
	table.insert(def, "pos")
	table.insert(def, "bump")
	return self
end

function BumpStorage:add(e)
	if not (e.__isEntity) then error("Assertion failed: e.__isEntity") end
	local pos = e.pos.pos
	local collider = e.collider
	local x, y = pos.x, pos.y
	local w, h = collider.size.x, collider.size.y
	local col_offset = e.collider_offset
	if col_offset then
		x = x + col_offset.value.x
		y = y + col_offset.value.y
	end
	self.super.add(self, e, x, y, w, h)
end

function BumpStorage:has(e)
	if not (e.__isEntity) then error("Assertion failed: e.__isEntity") end
	return self:hasItem(e)
end

function BumpStorage:clear()
	for _, e in ipairs(self:getItems()) do
		self:remove(e)
	end
end

return ctor
